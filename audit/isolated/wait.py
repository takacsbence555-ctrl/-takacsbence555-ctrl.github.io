import sys,time,urllib.request
deadline=time.monotonic()+120
while True:
    try:
        with urllib.request.urlopen(sys.argv[1],timeout=3) as response:
            if response.status==200: break
    except Exception:
        if time.monotonic()>deadline: raise SystemExit('Local service did not become healthy')
        time.sleep(1)
print('Local service healthy')
