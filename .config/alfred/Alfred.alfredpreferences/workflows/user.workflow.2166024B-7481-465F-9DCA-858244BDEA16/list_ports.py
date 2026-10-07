#!/usr/bin/env python3
import subprocess
import json

result = subprocess.run(
    ['lsof', '-nP', '-iTCP', '-sTCP:LISTEN'],
    capture_output=True,
    text=True
)

items = []
seen = set()

for line in result.stdout.strip().split('\n')[1:]:
    parts = line.split()
    if len(parts) < 9:
        continue

    cmd, pid, addr = parts[0], parts[1], parts[8]
    addr = addr.split()[0]  # strip trailing "(LISTEN)" if present

    if ':' not in addr:
        continue

    port = addr.rsplit(':', 1)[1]

    if not port.isdigit() or port in seen:
        continue
    seen.add(port)

    items.append({
        'uid': 'port-' + port,
        'title': 'Port ' + port,
        'subtitle': cmd + ' — PID ' + pid,
        'arg': pid,
        'autocomplete': port,
        'match': port + ' ' + cmd,
        'variables': {'port': port, 'process_name': cmd},
    })

items.sort(key=lambda x: int(x['title'].split()[1]))

if not items:
    items = [{'title': 'No listening TCP ports', 'subtitle': '', 'valid': False}]

print(json.dumps({'items': items}))
