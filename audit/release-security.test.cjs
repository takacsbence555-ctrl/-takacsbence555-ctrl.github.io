// Static source/deployment guards, not a penetration-test certification.
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..');
function findings(text){const result=[];for(const [name,re]of [['server key',/\bsb_secret_[A-Za-z0-9_-]{20,}/g],['email API key',/\bre_[A-Za-z0-9]{24,}/g],['AWS access key',/\bAKIA[0-9A-Z]{16}\b/g],['private key',/-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----\s+[A-Za-z0-9+/=\s]+-----END/g]])if(re.test(text))result.push(name);for(const token of text.match(/\beyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/g)||[]){try{if(JSON.parse(Buffer.from(token.split('.')[1],'base64url')).role==='service_role')result.push('embedded service-role JWT');}catch{}}return result;}
assert(findings('sb_'+'secret_'+'a'.repeat(30)).includes('server key'));
assert(findings('re'+'_'+'a'.repeat(30)).includes('email API key'));
assert.deepEqual(findings('sb_publishable_'+'a'.repeat(30)),[]);
function walk(dir){return fs.readdirSync(dir,{withFileTypes:true}).flatMap(x=>['.git','node_modules','__pycache__','test-results','playwright-report'].includes(x.name)?[]:x.isDirectory()?walk(path.join(dir,x.name)):/\.(c?js|json|sql|py|html|css|ya?ml|md)$/.test(x.name)?[path.join(dir,x.name)]:[]);}
let scanned=0;for(const file of walk(root)){const hits=findings(fs.readFileSync(file,'utf8'));assert.equal(hits.length,0,'Potential credential in '+path.relative(root,file)+': '+hits.join(', '));scanned++;}
const vercel=JSON.parse(fs.readFileSync(path.join(root,'vercel.json')));assert.equal(vercel.git.deploymentEnabled['release/final-20261015'],false);assert(!vercel.crons?.length,'Unapproved production scheduler');
assert(!fs.existsSync(path.join(root,'api')),'Review any new production API route before release');
const headers=Object.fromEntries(vercel.headers.flatMap(x=>x.headers).map(x=>[x.key.toLowerCase(),x.value]));assert.equal(headers['referrer-policy'],'no-referrer');assert(headers['content-security-policy'].includes("script-src 'self';"));assert(headers['content-security-policy'].includes("frame-ancestors 'none'"));
for(const folder of ['audit','audit/browser']){const pkg=JSON.parse(fs.readFileSync(path.join(root,folder,'package.json')));assert(fs.existsSync(path.join(root,folder,'package-lock.json')));for(const v of Object.values(pkg.devDependencies||{}))assert(/^\d+\.\d+\.\d+$/.test(v),'Unpinned dependency');}
console.log('PASS credential-pattern guards, '+scanned+' source files, disabled release deployment/scheduler, CSP, private-link headers and pinned dependency manifests');
