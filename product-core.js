/* Pure, testable product logic. No network requests or customer communications. */
(function(root){
'use strict';
const plans=Object.freeze({essential:{priceGBP:19,ai:false},intelligence:{priceGBP:39,ai:true},billingEnabled:false});
function dateInZone(value,zone){return new Intl.DateTimeFormat('en-CA',{timeZone:zone,year:'numeric',month:'2-digit',day:'2-digit'}).format(new Date(value));}
function addDays(date,n){const d=new Date(date+'T12:00:00Z');d.setUTCDate(d.getUTCDate()+n);return d.toISOString().slice(0,10);}
function range(date,view){if(!/^\d{4}-\d{2}-\d{2}$/.test(date)||Number.isNaN(Date.parse(date)))throw new Error('Invalid date');if(view==='month')return {start:date.slice(0,7)+'-01',end:addDays(date.slice(0,7)+'-01',new Date(+date.slice(0,4),+date.slice(5,7),0).getDate())};if(view==='week'){const day=new Date(date+'T12:00:00Z').getUTCDay();const start=addDays(date,-((day+6)%7));return {start,end:addDays(start,7)}}return {start:date,end:addDays(date,1)};}
function calendarRows(bookings,date,view,staff,zone){const r=range(date,view);return bookings.filter(b=>{const d=dateInZone(b.starts_at,zone);return d>=r.start&&d<r.end&&(!staff||b.staff===staff||b.staff_id===staff)}).sort((a,b)=>new Date(a.starts_at)-new Date(b.starts_at));}
function insights(bookings,customers,now=new Date()){
 const future=bookings.filter(b=>b.status==='confirmed'&&new Date(b.starts_at)>=now),completed=bookings.filter(b=>b.status==='completed');
 const amount=b=>Number.isSafeInteger(b.price_cents)&&b.price_cents>=0?b.price_cents:null;
 const priced=future.filter(b=>amount(b)!==null);
 return {upcoming:future.length,bookedCents:priced.reduce((s,b)=>s+b.price_cents,0),missingPrices:future.length-priced.length,completed:completed.length,cancelled:bookings.filter(b=>b.status==='cancelled').length,noShows:bookings.filter(b=>b.status==='no_show').length,overdue:customers.filter(c=>{if(!(c.last_visit||c.last_visit_at))return false;return (now-new Date(c.last_visit||c.last_visit_at))/86400000>(c.rebook_interval_days||28)*1.25}).length};
}
function parseCSV(text){
 if(typeof text!=='string'||text.length>2e6)throw new Error('File must be under 2 MB');
 const rows=[];let row=[],field='',quoted=false;
 for(let i=0;i<text.length;i++){const c=text[i];if(c==='"'){if(quoted&&text[i+1]==='"'){field+='"';i++;}else if(quoted||field==='')quoted=!quoted;else throw new Error('Unexpected quote');}else if(c===','&&!quoted){row.push(field);field='';}else if((c==='\n'||c==='\r')&&!quoted){if(c==='\r'&&text[i+1]==='\n')i++;row.push(field);if(row.some(x=>x.trim()))rows.push(row);row=[];field='';}else field+=c;if(rows.length>5000)throw new Error('Maximum 5,000 rows');}
 if(quoted)throw new Error('Unclosed quoted field');row.push(field);if(row.some(x=>x.trim()))rows.push(row);
 if(rows.length<2)throw new Error('Add a header and at least one data row');
 const headers=rows.shift().map(x=>x.replace(/^\uFEFF/,'').trim().toLowerCase());if(new Set(headers).size!==headers.length)throw new Error('Duplicate headers');
 if(!headers.includes('name'))throw new Error('Required column: name');
 const seen=new Set(),records=[],errors=[];
 rows.forEach((r,i)=>{const record=Object.fromEntries(headers.map((h,j)=>[h,(r[j]||'').trim()]));const issues=[];if(r.length!==headers.length)issues.push('Column count mismatch');if(record.name.length<2||record.name.length>120)issues.push('Name must have 2–120 characters');if(record.email&&!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(record.email))issues.push('Invalid email');if(record.phone&&!/^\+?[0-9 ()-]{6,40}$/.test(record.phone))issues.push('Invalid phone');const key=record.email?.toLowerCase()||record.phone?.replace(/\D/g,'')||record.name.toLowerCase();if(seen.has(key))issues.push('Duplicate in file');seen.add(key);if(issues.length)errors.push({row:i+2,issues});else records.push(record);});return {headers,records,errors,total:rows.length};
}
function brandingConfig(raw){const c={accent:raw.accent||'#c8e986',font:raw.font||'system',logo_url:raw.logo_url||'',hero_url:raw.hero_url||'',description:raw.description||''};if(!/^#[0-9a-f]{6}$/i.test(c.accent)||!['system','georgia','arial'].includes(c.font)||c.description.length>1000)throw new Error('Invalid branding');for(const key of ['logo_url','hero_url']){if(c[key]){const u=new URL(c[key]);if(u.protocol!=='https:'||c[key].length>2048)throw new Error('Images require HTTPS URLs')}}const rgb=c.accent.slice(1).match(/../g).map(x=>{const v=parseInt(x,16)/255;return v<=0.04045?v/12.92:((v+0.055)/1.055)**2.4});const l=rgb[0]*0.2126+rgb[1]*0.7152+rgb[2]*0.0722;c.foreground=l>0.179?'#000000':'#ffffff';return c;}
const api={plans,dateInZone,addDays,range,calendarRows,insights,parseCSV,brandingConfig};if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.KavelyqProduct=api;
})(typeof window==='undefined'?globalThis:window);
