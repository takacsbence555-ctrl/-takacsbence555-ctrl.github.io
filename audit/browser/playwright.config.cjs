const {defineConfig,devices}=require('@playwright/test');
if(process.env.BASE_URL)throw Error('Guest mutation suite is isolated only; use production smoke for hosted checks');
module.exports=defineConfig({testDir:'.',testMatch:'journeys.spec.cjs',workers:1,retries:0,timeout:90000,globalTimeout:900000,
reporter:[['list'],['json',{outputFile:'results.json'}],['html',{open:'never'}]],
use:{baseURL:'http://127.0.0.1:4173',trace:'off',video:'off',screenshot:'only-on-failure'},
projects:[{name:'desktop',use:{...devices['Desktop Chrome']}},{name:'mobile',use:{...devices['iPhone 13'],browserName:'webkit'}}],
webServer:{command:'python3 serve.py',url:'http://127.0.0.1:4173',reuseExistingServer:false}});
