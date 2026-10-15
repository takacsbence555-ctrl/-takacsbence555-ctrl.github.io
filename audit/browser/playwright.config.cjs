const {defineConfig,devices}=require('@playwright/test');
module.exports=defineConfig({testDir:'.',testMatch:'journeys.spec.cjs',workers:1,retries:0,timeout:90000,globalTimeout:900000,
reporter:[['list'],['json',{outputFile:'results.json'}],['html',{open:'never'}]],
use:{baseURL:process.env.BASE_URL||'http://127.0.0.1:4173',trace:'off',video:'off',screenshot:'only-on-failure'},
projects:[{name:'desktop',use:{...devices['Desktop Chrome']}},{name:'mobile',use:{...devices['iPhone 13'],browserName:'webkit'}}],
webServer:process.env.BASE_URL?undefined:{command:'python3 serve.py',url:'http://127.0.0.1:4173',reuseExistingServer:false}});
