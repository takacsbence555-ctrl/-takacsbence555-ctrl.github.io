'use strict';
// Server-only adapter. No scheduler, route or deployment is activated by importing it.
const crypto=require('node:crypto');
const transactional=new Set(['booking_confirmation','booking_reminder','booking_cancelled']);
class DeliveryError extends Error{constructor(code,retryable=false){super(code);this.code=code;this.retryable=retryable;}}
const escape=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
function renderNotification(job,{from,appOrigin}){
 if(!transactional.has(job.template))throw new DeliveryError('NON_TRANSACTIONAL_TEMPLATE');
 if(!/^\S+@\S+\.\S+$/.test(job.destination||'')||/[\r\n]/.test(from||'')||!from)throw new DeliveryError('INVALID_ADDRESS');
 const origin=new URL(appOrigin);if(origin.protocol!=='https:'||origin.origin!==appOrigin)throw new DeliveryError('INVALID_APP_ORIGIN');
 const p=job.payload||{},date=new Date(p.starts_at);if(!Number.isFinite(date.getTime()))throw new DeliveryError('INVALID_BOOKING_TIME');
 let time;try{time=new Intl.DateTimeFormat('en-GB',{timeZone:p.timezone,dateStyle:'full',timeStyle:'short'}).format(date);}catch{throw new DeliveryError('INVALID_TIMEZONE');}
 const title={booking_confirmation:'Booking confirmed',booking_reminder:'Appointment reminder',booking_cancelled:'Booking cancelled'}[job.template];
 const lines=[title,String(p.business_name||'Your business'),String(p.service_name||'Appointment')+' · '+time];
 let manage='';if(job.template!=='booking_cancelled'){if(!/^[0-9a-f-]{36}$/i.test(p.manage_token||''))throw new DeliveryError('INVALID_MANAGEMENT_TOKEN');manage=appOrigin+'/?manage='+encodeURIComponent(p.manage_token);lines.push('Manage your appointment: '+manage);}
 return {from,to:[job.destination],subject:title+' · '+String(p.business_name||'KAVELYQ').replace(/[\r\n]/g,' ').slice(0,120),text:lines.join('\n'),html:'<!doctype html><html lang="en"><head><title>'+escape(title)+'</title></head><body><h1>'+escape(title)+'</h1><p>'+escape(lines[1])+'</p><p>'+escape(lines[2])+'</p>'+(manage?'<p><a href="'+escape(manage)+'">Manage your appointment</a></p>':'')+'</body></html>'};
}
function createResendProvider({apiKey,fetchImpl=fetch,timeoutMs=10000}){
 if(!apiKey)throw new DeliveryError('PROVIDER_NOT_CONFIGURED');
 return {async send(message,key){let r;try{r=await fetchImpl('https://api.resend.com/emails',{method:'POST',headers:{Authorization:'Bearer '+apiKey,'Content-Type':'application/json','Idempotency-Key':key},body:JSON.stringify(message),signal:AbortSignal.timeout(timeoutMs)});}catch{throw new DeliveryError('PROVIDER_NETWORK_FAILURE',true);}
 if(!r.ok)throw new DeliveryError(r.status===429?'PROVIDER_RATE_LIMIT':r.status>=500?'PROVIDER_UNAVAILABLE':'PROVIDER_REJECTED',r.status===429||r.status>=500);
 let body;try{body=await r.json()}catch{throw new DeliveryError('INVALID_PROVIDER_RESPONSE',true)}if(typeof body.id!=='string'||!body.id)throw new DeliveryError('INVALID_PROVIDER_RESPONSE',true);return {id:body.id};}};
}
async function processNotifications({enabled=false,providerVerified=false,queue,provider,from,appOrigin,approvedRecipients=[]}){
 if(!enabled||!providerVerified)return {disabled:true,accepted:0,failed:0};
 if(!queue||!provider||!Array.isArray(approvedRecipients)||!approvedRecipients.length)throw new DeliveryError('APPROVED_RECIPIENTS_REQUIRED');
 const approved=new Set(approvedRecipients.map(x=>x.toLowerCase())),result={disabled:false,accepted:0,failed:0,skipped:0,unacknowledged:0};
 for(const job of await queue.claim(10)){
  if(!approved.has(String(job.destination).toLowerCase())||!transactional.has(job.template)){await queue.fail(job,'RECIPIENT_OR_TEMPLATE_NOT_APPROVED',false);result.skipped++;continue;}
  if(!await queue.isCurrent(job)){result.skipped++;continue;}
  let sent;try{const message=renderNotification(job,{from,appOrigin});sent=await provider.send(message,'kavelyq-notification-'+job.id);}catch(e){await queue.fail(job,e instanceof DeliveryError?e.code:'DELIVERY_FAILURE',e instanceof DeliveryError&&e.retryable);result.failed++;continue;}
  // Acknowledgement failure must not be treated as provider rejection: retry with the same key.
  try{await queue.accept(job,sent.id);result.accepted++;}catch{result.unacknowledged++;}
 }
 return result;
}
function verifyWebhook(raw,headers,secret,now=Math.floor(Date.now()/1000)){
 if(typeof raw!=='string'||Buffer.byteLength(raw)>65536||!secret?.startsWith('whsec_'))throw new DeliveryError('INVALID_WEBHOOK');
 const id=headers['svix-id'],ts=headers['svix-timestamp'],signatures=headers['svix-signature'];
 if(typeof id!=='string'||typeof ts!=='string'||!/^\d+$/.test(ts)||Math.abs(now-Number(ts))>300||typeof signatures!=='string')throw new DeliveryError('INVALID_WEBHOOK');
 const key=Buffer.from(secret.slice(6),'base64');if(key.length<16)throw new DeliveryError('INVALID_WEBHOOK');const expected=crypto.createHmac('sha256',key).update(id+'.'+ts+'.'+raw).digest();
 const valid=signatures.split(' ').some(s=>{const [version,value]=s.split(',');if(version!=='v1'||!value)return false;const got=Buffer.from(value,'base64');return got.length===expected.length&&crypto.timingSafeEqual(got,expected)});if(!valid)throw new DeliveryError('INVALID_WEBHOOK');
 let event;try{event=JSON.parse(raw)}catch{throw new DeliveryError('INVALID_WEBHOOK')}
 if(!['email.delivered','email.bounced','email.complained','email.suppressed','email.failed','email.delivery_delayed'].includes(event.type)||typeof event.data?.email_id!=='string')throw new DeliveryError('UNSUPPORTED_WEBHOOK');
 return {id,type:event.type,providerMessageId:event.data.email_id};
}
async function handleWebhook({raw,headers,secret,ledger,now}){const event=verifyWebhook(raw,headers,secret,now);if(!ledger||typeof ledger.recordOnce!=='function')throw new DeliveryError('DURABLE_EVENT_LEDGER_REQUIRED');return ledger.recordOnce(event);}
function createSupabaseQueue({origin,serviceRoleKey,fetchImpl=fetch,allowLoopback=false}){
 const u=new URL(origin);if(u.origin!==origin||!(u.protocol==='https:'&&u.hostname.endsWith('.supabase.co')||allowLoopback&&u.hostname==='127.0.0.1')||!serviceRoleKey)throw new DeliveryError('INVALID_QUEUE_CONFIGURATION');
 async function rpc(fn,data){const r=await fetchImpl(origin+'/rest/v1/rpc/'+fn,{method:'POST',headers:{apikey:serviceRoleKey,Authorization:'Bearer '+serviceRoleKey,'Content-Type':'application/json'},body:JSON.stringify(data),signal:AbortSignal.timeout(10000)});if(!r.ok)throw new DeliveryError('QUEUE_REQUEST_FAILED',true);return r.json();}
 return {claim:n=>rpc('claim_due_email_notifications',{p_limit:n}),isCurrent:j=>rpc('notification_claim_current',{p_id:j.id,p_attempt:j.attempt_count}),accept:async(j,id)=>{if(!await rpc('notification_finish_claim',{p_id:j.id,p_attempt:j.attempt_count,p_provider_id:id}))throw new DeliveryError('CLAIM_NO_LONGER_CURRENT');},fail:(j,code,retryable)=>rpc('notification_fail_claim',{p_id:j.id,p_attempt:j.attempt_count,p_code:code,p_retryable:Boolean(retryable)}),recordOnce:e=>rpc('notification_record_event',{p_event_id:e.id,p_provider_id:e.providerMessageId,p_type:e.type})};
}
module.exports={DeliveryError,renderNotification,createResendProvider,createSupabaseQueue,processNotifications,verifyWebhook,handleWebhook};
