const {defineConfig,devices}=require('@playwright/test');
module.exports=defineConfig({testDir:'.',testMatch:'owner.spec.cjs',workers:1,retries:0,timeout:180000,globalTimeout:1200000,
reporter:[['list'],['json',{outputFile:'owner-results.json'}]],
use:{baseURL:'http://127.0.0.1:4173',actionTimeout:15000,navigationTimeout:15000,trace:'off',video:'off',screenshot:'off'},
projects:[{name:'desktop',use:{...devices['Desktop Chrome'],timezoneId:'America/Los_Angeles'}},{name:'mobile',use:{...devices['iPhone 13'],browserName:'webkit',timezoneId:'Asia/Tokyo'}}],
webServer:{command:'python3 serve.py',url:'http://127.0.0.1:4173',reuseExistingServer:false}});
