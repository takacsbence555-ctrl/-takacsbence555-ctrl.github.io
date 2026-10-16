from functools import partial
from http.server import ThreadingHTTPServer,SimpleHTTPRequestHandler
from pathlib import Path
import json
root=Path(__file__).resolve().parents[2]
headers=json.loads((root/'vercel.json').read_text()).get('headers',[])
class Handler(SimpleHTTPRequestHandler):
 def end_headers(self):
  for rule in headers:
   if rule['source']=='/(.*)':
    for header in rule['headers']: self.send_header(header['key'],header['value'])
  super().end_headers()
ThreadingHTTPServer(('127.0.0.1',4173),partial(Handler,directory=str(root))).serve_forever()
