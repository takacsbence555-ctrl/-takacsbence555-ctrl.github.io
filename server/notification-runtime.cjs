'use strict';
// Server-only HTTP boundary. Both capabilities require explicit environment opt-in.
const crypto=require('node:crypto');
const {DeliveryError,createSupabaseQueue,createResendProvider,processNotifications,verifyWebhook}=require('./notifications.cjs');
const project='https://lpnewhfsbpwyjgdpoxqj.supabase.co';
const reply=(status,body,extra={})=>Response.json(body,{status,headers:{'Cache-Control':'private, no-store','X-Content-Type-Options':'nosniff',...extra}});
function authorised(request,secret){const expected=Buffer.from('Bearer '+(secret||'')),actual=Buffer.from(request.headers.get('authorization')||'');return typeof secret==='string'&&secret.length>=32&&actual.length===expected.length&&crypto.timingSafeEqual(actual,expected);}
async function boundedBody(request,timeoutMs){
 if(Number(request.headers.get('content-length')||0)>65536)throw new DeliveryError('INVALID_WEBHOOK');
 const reader=request.body?.getReader();if(!reader)throw new DeliveryError('INVALID_WEBHOOK');let timer;const chunks=[];let size=0;
 try{return await Promise.race([(async()=>{for(;;){const {done,value}=await reader.read();if(done)break;size+=value.byteLength;if(size>65536)throw new DeliveryError('INVALID_WEBHOOK');chunks.push(value);}return new TextDecoder('utf-8',{fatal:true}).decode(Buffer.concat(chunks));})(),new Promise((_,reject)=>{timer=setTimeout(()=>reject(new DeliveryError('INVALID_WEBHOOK')),timeoutMs);})]);}
 finally{clearTimeout(timer);void reader.cancel().catch(()=>{});}
}
function createNotificationHandlers({env=process.env,queueFactory,providerFactory,logger=e=>console.info(JSON.stringify(e)),bodyTimeoutMs=5000}={}){
 const log=(event,code)=>logger({event,code});
 const queue=()=>{if(queueFactory)return queueFactory();if(env.SUPABASE_URL&&env.SUPABASE_URL!==project)throw new DeliveryError('INVALID_QUEUE_CONFIGURATION');return createSupabaseQueue({origin:project,serviceRoleKey:env.SUPABASE_SERVICE_ROLE_KEY});};
 return {
 async worker(request){
  if(request.method!=='POST')return reply(405,{error:'METHOD_NOT_ALLOWED'},{Allow:'POST'});
  if(request.headers.has('origin')||!authorised(request,env.NOTIFICATION_WORKER_SECRET))return reply(401,{error:'UNAUTHORISED'});
  if(env.NOTIFICATIONS_ENABLED!=='true'||env.NOTIFICATIONS_PROVIDER_VERIFIED!=='true')return reply(503,{error:'DELIVERY_DISABLED'});
  try{
   const approved=JSON.parse(env.NOTIFICATION_APPROVED_RECIPIENTS||'[]');if(!Array.isArray(approved)||!approved.length||approved.length>100||approved.some(x=>typeof x!=='string'||x.length>254||!/^\S+@\S+\.\S+$/.test(x)))throw new DeliveryError('INVALID_RUNTIME_CONFIGURATION');
   const origin=new URL(env.APP_ORIGIN);if(origin.protocol!=='https:'||origin.origin!==env.APP_ORIGIN||!env.RESEND_FROM||/[\r\n]/.test(env.RESEND_FROM))throw new DeliveryError('INVALID_RUNTIME_CONFIGURATION');
   const result=await processNotifications({enabled:true,providerVerified:true,queue:queue(),provider:providerFactory?providerFactory():createResendProvider({apiKey:env.RESEND_API_KEY}),from:env.RESEND_FROM,appOrigin:env.APP_ORIGIN,approvedRecipients:approved,claimLimit:1});
   logger({event:'notification_worker_result',accepted:result.accepted,failed:result.failed,skipped:result.skipped,unacknowledged:result.unacknowledged});
   return reply(result.unacknowledged?503:200,result);
  }catch{log('notification_worker_error','PROCESSING_UNAVAILABLE');return reply(503,{error:'PROCESSING_UNAVAILABLE'});}
 },
 async webhook(request){
  if(request.method!=='POST')return reply(405,{error:'METHOD_NOT_ALLOWED'},{Allow:'POST'});
  if(env.NOTIFICATIONS_WEBHOOK_ENABLED!=='true'||!env.RESEND_WEBHOOK_SECRET)return reply(503,{error:'WEBHOOK_DISABLED'});
  let event;try{const raw=await boundedBody(request,bodyTimeoutMs);event=verifyWebhook(raw,Object.fromEntries(request.headers),env.RESEND_WEBHOOK_SECRET);}catch(e){if(e instanceof DeliveryError&&e.code==='UNSUPPORTED_WEBHOOK')return reply(200,{status:'ignored'});log('notification_webhook_rejected','INVALID_WEBHOOK');return reply(400,{error:'INVALID_WEBHOOK'});}
  try{const result=await queue().recordOnce(event);if(!['recorded','duplicate'].includes(result))throw Error('Not recorded');log('notification_webhook_result',result.toUpperCase());return reply(200,{status:result});}
  catch{log('notification_webhook_error','EVENT_NOT_PERSISTED');return reply(503,{error:'EVENT_NOT_PERSISTED'});}
 }
 };
}
module.exports={createNotificationHandlers};
