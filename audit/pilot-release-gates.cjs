'use strict';
// Read-only decision engine. Never executes release or provider operations.
const stages={backup:[],migrations:['backup'],auth:['migrations'],notifications:['backup','migrations'],validation:['auth'],deployment:['validation'],iphone:['deployment'],pilot:['iphone'],rollback:[]};
function evaluate(state={}){const verified=state.verified||{},approved=state.approved||{};return Object.entries(stages).map(([action,dependencies])=>({action,allowed:approved[action]===true&&dependencies.every(x=>verified[x]===true)&&(action!=='pilot'||['hosting','privacy','support','restrictedSignup','backupRecovery'].every(x=>verified[x]===true)),missing:[...(approved[action]===true?[]:['approval:'+action]),...dependencies.filter(x=>verified[x]!==true).map(x=>'verified:'+x),...(action==='pilot'?['hosting','privacy','support','restrictedSignup','backupRecovery'].filter(x=>verified[x]!==true).map(x=>'verified:'+x):[])]}));}
module.exports={evaluate};
if(require.main===module){const fs=require('node:fs');const state=process.argv[2]?JSON.parse(fs.readFileSync(process.argv[2],'utf8')):{};console.log(JSON.stringify(evaluate(state),null,2));}
