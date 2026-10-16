import re,urllib.request
from pathlib import Path
root=Path(__file__).resolve().parent.parent
url='https://takacsbence555-ctrl-github-io.vercel.app/'
with urllib.request.urlopen(url,timeout=20) as r:
 assert r.status==200,'Production unavailable'
 assert r.headers.get('Referrer-Policy')=='no-referrer','Private-link referrer policy missing'
 assert r.headers.get('X-Frame-Options')=='DENY','Framing protection missing'
 assert b'app.js' in r.read(),'Application shell missing'
print('PASS production HTTP 200, private-link and framing headers')
