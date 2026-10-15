/* Public multi-industry illustrative booking preview; never calls backend. */
(function(){
'use strict';
const data={
 barber:{name:'NOIR BARBER',title:'Look sharp. Book your cut.',lead:'Pick a service, choose your barber and find a time that works for you.',staff:'Barber',services:[['Classic Cut',36,45],['Skin Fade',42,50],['Cut + Beard',52,60],['Beard Ritual',28,30]]},
 beauty:{name:'KAVELYQ BEAUTY · DEMO',title:'Your beauty appointment starts here.',lead:'Choose a makeup or beauty treatment and an available artist.',staff:'Artist',services:[['Everyday Makeup',55,60],['Evening Makeup',75,90],['Bridal Trial',110,120],['Facial Treatment',65,60]]},
 nails:{name:'KAVELYQ NAILS · DEMO',title:'Fresh nails. Easy booking.',lead:'Choose a nail or lash service and a technician.',staff:'Technician',services:[['Classic Manicure',35,45],['Gel Manicure',55,75],['Lash Extensions',85,120],['Lash Refill',50,60]]},
 wellness:{name:'KAVELYQ WELLNESS · DEMO',title:'Make time for yourself.',lead:'Choose a massage or wellness treatment and a therapist.',staff:'Therapist',services:[['Relaxing Massage',65,60],['Deep Tissue Massage',85,90],['Back Massage',40,30],['Wellness Consultation',25,30]]},
 other:{name:'KAVELYQ STUDIO · DEMO',title:'Book your next appointment.',lead:'Choose a service and a professional.',staff:'Professional',services:[['Consultation',25,30],['Standard Session',60,60],['Extended Session',95,90]]}
};
const descriptions={barber:'Haircuts, beard grooming and repeat appointments.',beauty:'Makeup sessions, bridal trials and beauty treatments.',nails:'Manicures, lash extensions and maintenance visits.',wellness:'Massages, body treatments and wellness appointments.',other:'Flexible appointments for independent professionals.'};
const select=document.getElementById('salesIndustry'),services=document.getElementById('previewServices'),staff=document.getElementById('previewProfessionals');
if(!select||!services||!staff)return;
const originals={services:services.innerHTML,staff:staff.innerHTML};
const escape=s=>String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
function apply(type){
 const d=data[type]||data.barber;
 document.getElementById('salesIndustryDescription').textContent=descriptions[type]||descriptions.barber;
 document.getElementById('previewStudioName').textContent=d.name;
 document.getElementById('previewBookingTitle').textContent=d.title;
 document.getElementById('previewBookingLead').textContent=d.lead;
 if(type==='barber'){services.innerHTML=originals.services;staff.innerHTML=originals.staff;}
 else{
 services.innerHTML=d.services.map(([name,price,duration])=>'<button class="service-card" data-service="'+escape(name)+'" data-price="'+price+'" data-duration="'+duration+'"><span><b>'+escape(name)+'</b><small>Demo service · '+duration+' min</small></span><strong>'+price+' €</strong></button>').join('');
 staff.innerHTML=['A','B','C'].map((n,i)=>'<button class="barber-card barber-pro" data-barber="Demo '+d.staff+' '+n+'"><span class="barber-portrait portrait-'+n.toLowerCase()+'"><span>'+n+'</span></span><span class="barber-copy"><b>Demo '+d.staff+' '+n+'</b><small>'+escape(d.staff)+' · illustrative profile</small><span class="barber-skills">Demo availability</span></span></button>').join('')+'<button class="barber-card barber-pro" data-barber="First available"><span class="barber-copy"><b>First available</b><small>Any available professional</small></span></button>';
 }
 if(window.state){window.state.bookStep=1;window.state.service='';window.state.barber='';window.state.time='';}
 document.querySelectorAll('.book-step').forEach((el,i)=>el.classList.toggle('hidden',i!==0));
}
select.addEventListener('change',()=>apply(select.value));
document.getElementById('salesIndustryPreview').addEventListener('click',()=>{
 apply(select.value);
 document.getElementById('salesEntry').classList.add('hidden');
 document.querySelector('[data-view="booking"]')?.click();
});
apply('barber');
})();