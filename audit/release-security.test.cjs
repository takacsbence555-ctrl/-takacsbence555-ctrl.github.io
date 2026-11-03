// Static source/deployment guards, not a penetration-test certification.
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..');
function findings(text){const result=[];for(const [name,re]of [['server key',/\bsb_secret_[A-Za-z0-9_-]{20,}/g],['email API key',/\bre_[A-Za-z0-9]{24,}/g],['AWS access key',/\bAKIA[0-9A-Z]{16}\b/g],['age identity',/\bAGE-SECRET-KEY-1[0-9A-Z]{20,}\b/g],['private key',/-----BEGIN (?:RSA |EC |OPENSSH |ENCRYPTED )?PRIVATE KEY-----\s+[A-Za-z0-9+/=\s]+-----END/g]])if(re.test(text))result.push(name);for(const token of text.match(/\beyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/g)||[]){try{if(JSON.parse(Buffer.from(token.split('.')[1],'base64url')).role==='service_role')result.push('embedded service-role JWT');}catch{}}return result;}
assert(findings('sb_'+'secret_'+'a'.repeat(30)).includes('server key'));
assert(findings('re'+'_'+'a'.repeat(30)).includes('email API key'));
assert.deepEqual(findings('sb_publishable_'+'a'.repeat(30)),[]);
assert(findings('AGE-'+'SECRET-KEY-1'+'A'.repeat(58)).includes('age identity'));
assert.deepEqual(findings('age1'+'a'.repeat(58)),[]);
assert(findings('-----BEGIN '+'ENCRYPTED PRIVATE KEY-----\nAAAA\n-----END'+' ENCRYPTED PRIVATE KEY-----').includes('private key'));
function walk(dir){return fs.readdirSync(dir,{withFileTypes:true}).flatMap(x=>{if(x.isFile())assert(!/\.(dump|cms|age|pem|key)$/i.test(x.name),'Backup/identity artifact must not be in the source tree: '+path.relative(root,path.join(dir,x.name)));return ['.git','node_modules','__pycache__','test-results','playwright-report'].includes(x.name)?[]:x.isDirectory()?walk(path.join(dir,x.name)):/(?:\.(?:c?js|mjs|json|sql|py|html|css|ya?ml|md|txt|pem|key)|(?:^|\/)\.env(?:\..*)?)$/.test(x.name)?[path.join(dir,x.name)]:[];});}
const guest=fs.readFileSync(path.join(root,'audit/browser/journeys.spec.cjs'),'utf8');
assert(guest.includes("require('./isolated-backend.cjs')"));
assert(!guest.includes("request.post(api+"),'Guest mutations must never target hosted backend');
const smoke=fs.readFileSync(path.join(root,'audit/http.test.py'),'utf8');
assert(!smoke.includes("'/rest/v1/rpc/create_public_booking"),'Production smoke must not invoke booking mutations');
const workflow=fs.readFileSync(path.join(root,'.github/workflows/isolated.yml'),'utf8');
assert(workflow.indexOf('< audit/owner-atomic-hours.pending.sql')<workflow.indexOf('< audit/notification-adapter.pending.sql'),'CI must use documented migration order');
assert(workflow.includes('python3 audit/isolated/migrations.py'),'Missing transactional migration rehearsal');
let scanned=0;for(const file of walk(root)){const hits=findings(fs.readFileSync(file,'utf8'));assert.equal(hits.length,0,'Potential credential in '+path.relative(root,file)+': '+hits.join(', '));scanned++;}
const vercel=JSON.parse(fs.readFileSync(path.join(root,'vercel.json')));assert.equal(vercel.git.deploymentEnabled['release/final-20261015'],false);assert(!vercel.crons?.length,'Unapproved production scheduler');
assert.deepEqual(fs.readdirSync(path.join(root,'api')).sort(),['notification-worker.mjs','resend-webhook.mjs'],'Unreviewed API route');
for(const name of ['notification-worker','resend-webhook']){const route=fs.readFileSync(path.join(root,'api',name+'.mjs'),'utf8');assert(route.includes('notification-runtime.cjs'));assert(route.includes('export async function POST'));assert(!route.includes('process.env.'));}
const headers=Object.fromEntries(vercel.headers.flatMap(x=>x.headers).map(x=>[x.key.toLowerCase(),x.value]));assert.equal(headers['referrer-policy'],'no-referrer');assert(headers['content-security-policy'].includes("script-src 'self';"));assert(headers['content-security-policy'].includes("frame-ancestors 'none'"));
for(const folder of ['audit','audit/browser']){const pkg=JSON.parse(fs.readFileSync(path.join(root,folder,'package.json')));assert(fs.existsSync(path.join(root,folder,'package-lock.json')));for(const v of Object.values(pkg.devDependencies||{}))assert(/^\d+\.\d+\.\d+$/.test(v),'Unpinned dependency');}
console.log('PASS credential-pattern guards, '+scanned+' source files, disabled release deployment/scheduler, CSP, private-link headers and pinned dependency manifests');
