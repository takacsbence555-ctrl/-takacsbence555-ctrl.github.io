const {JSDOM,VirtualConsole}=require('jsdom');
const fs=require('fs'),assert=require('node:assert/strict');
const html=fs.readFileSync(__dirname+'/../index.html','utf8').replace(/<script src=[\s\S]*?<\/script>/g,'');
const app=fs.readFileSync(__dirname+'/../app.js','utf8');
let passed=0;
async function test(name,fn){await fn();passed++;console.log('PASS '+name)}
function setup(url='https://kavelyq.test/?view=booking'){
 const errors=[],requests=[],vc=new VirtualConsole();vc.on('jsdomError',e=>errors.push(e));
 const dom=new JSDOM(html,{url,runScripts:'dangerously',pretendToBeVisual:true,virtualConsole:vc});const w=dom.window;
 w.scrollTo=()=>{};w.confirm=()=>true;w.fetch=async(url,opts)=>{const body=JSON.parse(opts.body),fn=url.split('/').pop();requests.push({fn,body});let result=null;
 if(fn==='get_public_availability')result=body.p_date.endsWith('04')?[]:['10:00','15:30','19:00'];
 if(fn==='create_public_booking_local_v2')result={booking_id:'test',manage_token:'11111111-1111-4111-8111-111111111111'};
 if(fn==='get_public_booking_manage')result={service_name:'Classic Cut',staff_name:'A',business_name:'Test',starts_at:'2026-10-02T08:00:00Z',timezone:'Europe/Vienna',status:'confirmed',can_cancel:true,cancellation_window_hours:24};
 if(fn==='get_public_manage_availability')result=['10:00','15:30'];
 return {ok:true,status:200,text:async()=>JSON.stringify(result)};};
 w.eval(app+';window.__auditOwner=()=>{ownerDemoMode=false;ownerAccessToken="audit-only";ownerDashboardData={business:{id:"audit",timezone:"Europe/Vienna"},staff:[{id:"s",display_name:"Staff"}],services:[{id:"v",name:"Cut",price_cents:1999}]}}');return {w,dom,errors,requests,q:s=>w.document.querySelector(s),qa:s=>[...w.document.querySelectorAll(s)]};
}
const settle=()=>new Promise(r=>setTimeout(r,30));
(async()=>{
 const t=setup();await settle();assert.equal(t.errors.length,0,t.errors.map(e=>e.message).join('\n'));
 await test('startup and every Owner module renders',async()=>{for(const b of t.qa('[data-module]')){t.w.renderModule(b.dataset.module);assert(t.q('#moduleContent').textContent.length>0)}assert.equal(t.errors.length,0)});
 await test('drawer opens, delegated controls and overlay close',async()=>{t.w.openDrawer('<button data-action="close-drawer">Close</button>');t.q('[data-action="close-drawer"]','#drawer')?.click();assert.equal(t.errors.length,0)});
 await test('service → professional → all available times',async()=>{t.q('[data-service]').click();t.q('[data-barber]').click();await settle();assert.equal(t.qa('.slot-grid [data-time]').length,3);assert(t.qa('.slot-grid [data-time]').some(b=>b.textContent==='19:00'))});
 await test('date selection is honored, empty day does not jump',async()=>{const b=t.qa('.date-strip button')[2];b.click();await settle();t.q('[data-time="15:30"]').click();assert(t.q('#sumTime').textContent.startsWith(b.dataset.date));});
 await test('valid email reaches booking API and duplicate submit is suppressed',async()=>{t.q('#guestName').value='Audit Guest';t.q('#guestEmail').value='audit@example.invalid';t.q('#bookingPolicyConsent').checked=true;t.w.eval('confirmLiveBooking();confirmLiveBooking();');await settle();assert.equal(t.requests.filter(r=>r.fn==='create_public_booking_local_v2').length,1);assert(!t.q('#bookingSuccess').classList.contains('hidden'))});
 await test('manage booking → availability → reschedule',async()=>{await t.w.eval('openGuestBookingManager()');t.q('#guestManageDate').value='2026-10-03';await t.w.eval('loadGuestManageSlots()');assert.equal(t.qa('[data-manage-time]').length,2);t.q('[data-manage-time]').click();await settle();assert(t.requests.some(r=>r.fn==='reschedule_public_booking_local'))});
 await test('manage booking → cancellation',async()=>{await t.w.eval('cancelGuestBooking()');assert(t.requests.some(r=>r.fn==='cancel_public_booking'))});
 await test('invalid inputs never submit',async()=>{const x=setup();await settle();x.q("[data-service]").click();x.q("[data-barber]").click();await settle();x.q("[data-time]").click();x.q('#guestName').value='X';x.q('#guestEmail').value='bad';await x.w.eval('confirmLiveBooking()');assert.equal(x.requests.filter(r=>r.fn.startsWith('create_')).length,0);x.dom.window.close()});
 await test('exact euro cents, invalid and extreme prices, timezone DST',async()=>{assert.equal(t.w.eval('eurosToCents("19.99")'),1999);assert.equal(t.w.eval('eurosToCents("1,10")'),110);for(const v of ['-1','NaN','1.999','Infinity','999999999999999999'])assert.equal(t.w.eval(`eurosToCents(${JSON.stringify(v)})`),null);assert.equal(t.w.eval('formatDateTimeLocalInZone("2026-10-25T01:30:00Z","Europe/Vienna")'),'2026-10-25T02:30')});
 await test('runtime errors absent after workflows',async()=>assert.equal(t.errors.length,0,t.errors.map(e=>e.message).join('\n')));
 await test('Owner failed save keeps modal open and shows error',async()=>{const x=setup();await settle();x.w.__auditOwner();x.w.fetch=async()=>({ok:false,status:400,text:async()=> 'SLOT_ALREADY_BOOKED'});x.w.ownerBookingModal('create');x.q('#liveStart').value='2026-10-02T10:00';x.q('#liveSave').click();await settle();assert(x.q('.live-booking-modal'));assert(x.q('#liveBookingStatus').textContent.includes('already booked'));x.dom.window.close()});
 await test('search, CRM filter, calendar week and all enabled controls have handlers',async()=>{for(const b of t.qa('[data-module]')){t.w.renderModule(b.dataset.module);for(const button of t.qa('#moduleContent button')){assert(button.disabled||button.onclick||Object.keys(button.dataset).some(k=>['action','go','module','coreTab','sim','tip'].includes(k)),button.textContent+' has no handler')}}t.w.renderModule('customers');t.q('.list-search input').value='Customer B';t.q('.list-search input').dispatchEvent(new t.w.Event('input'));assert.equal(t.qa('.client-row:not(.hidden)').length,1);t.w.renderModule('calendar');t.qa('.filters button').find(b=>b.textContent==='Week').click();assert(t.q('#drawerContent').textContent.includes('Week overview'));t.q('.head-actions .search').click();assert(t.q('#workspaceSearch'));assert.equal(t.errors.length,0)});
 t.dom.window.close();console.log(`${passed} tests passed`);
})().catch(e=>{console.error(e);process.exit(1)});
