---
name: alfred-workflow
description: Build Alfred 5 workflows from scratch: Script Filters, keyword triggers, shell/Python actions, and notifications. Packages the result as a ready-to-install .alfredworkflow file. Use whenever the user wants to create, extend, or modify an Alfred workflow, automate something in Alfred, build a Script Filter, write a keyword trigger, or package an Alfred automation — even if they don't say "Alfred workflow" explicitly and just describe what they want Alfred to do.
---

# Alfred Workflow Builder

## File structure

An Alfred workflow is a zip archive renamed `.alfredworkflow`, with all files at the **root level** (no subdirectory):

```
info.plist          # workflow definition (required)
list_items.py       # script files referenced in plist
action.sh
icon.png            # optional
```

## Generating info.plist

Always use Python's `plistlib` — never write XML by hand (XML escaping is error-prone and hard to debug):

```python
import plistlib, uuid

SF  = str(uuid.uuid4()).upper()
ACT = str(uuid.uuid4()).upper()
NOT = str(uuid.uuid4()).upper()

workflow = {
    'bundleid': 'com.yourname.alfred.workflow-name',
    'category': 'Productivity',
    'connections': {
        SF:  [{'destinationuid': ACT, 'modifiers': 0, 'modifiersubtext': '', 'vitoclose': True}],
        ACT: [{'destinationuid': NOT, 'modifiers': 0, 'modifiersubtext': '', 'vitoclose': False}],
    },
    'createdby': 'Your Name',
    'description': 'What this workflow does',
    'disabled': False,
    'name': 'Workflow Name',
    'objects': [...],  # see Object Types below
    'readme': 'Usage instructions for the workflow.',
    'uidata': {
        SF:  {'xpos': 50.0,  'ypos': 50.0},
        ACT: {'xpos': 350.0, 'ypos': 50.0},
        NOT: {'xpos': 650.0, 'ypos': 50.0},
    },
    'version': '1.0',
    'webaddress': '',
}

with open('info.plist', 'wb') as f:
    plistlib.dump(workflow, f, fmt=plistlib.FMT_XML)
```

`vitoclose: False` on the Script Filter → Action connection makes Alfred close its window when the user selects an item — almost always what you want. (`vitoclose: True` means "veto the close" = keep Alfred open, which is the opposite of what most workflows need.)

## Object types

### Script Filter (keyword + dynamic list)

```python
{
    'config': {
        'alfredfiltersresults': True,          # Alfred fuzzy-filters returned items
        'alfredfiltersresultsmatchmode': 2,    # 2 = substring (use for port/name search)
        'argumenttreatemptyqueryasnil': False, # False = run script even with empty query (shows all results on first open)
        'argumenttrimmode': 0,
        'argumenttype': 1,
        'escaping': 102,
        'keyword': 'mykey',
        'queuedelaycustom': 3,
        'queuedelayimmediatelyinitially': True,
        'queuedelaymode': 0,
        'queuemode': 1,
        'runningsubtext': 'Loading…',
        'script': '/usr/bin/python3 ./list_items.py',  # inline one-liner, or use scriptfile
        'scriptargtype': 1,
        'scriptfile': '',
        'subtext': 'Hint shown in Alfred',
        'title': 'Trigger title',
        'type': 11,       # 11 = zsh  |  7 = JXA/JavaScript
        'withspace': True,
    },
    'type': 'alfred.workflow.input.scriptfilter',
    'uid': SF,
    'version': 3,   # must be 3 for Alfred 5
}
```

### Action Script

**Always use the inline `script` field — `scriptfile` is silently ignored for action objects in Alfred 5.** Use `scriptargtype: 0` with `{query}` substitution to receive the selected item's `arg`:

```python
{
    'config': {
        'concurrently': False,
        'escaping': 102,
        'script': 'kill -9 {query} 2>/dev/null && echo "Done" || echo "Failed"',
        'scriptargtype': 0,   # Alfred substitutes {query} with the selected item's arg
        'scriptfile': '',     # leave empty — scriptfile doesn't work for actions
        'type': 11,
    },
    'type': 'alfred.workflow.action.script',   # NOT action.runscript
    'uid': ACT,
    'version': 2,
}
```

Item variables set in the Script Filter (`variables: {'port': ..., 'process_name': ...}`) are available as `$port`, `$process_name` etc. in the action script environment.
```

### Post Notification

The notification's `text: '{query}'` receives whatever the action script printed to **stdout**. Make sure the action script `echo`s a message — that's what appears in the notification body.

```python
{
    'config': {
        'lastpathcomponent': False,
        'onlyshowifquerypopulated': False,
        'removeextension': False,
        'text': '{query}',   # body = stdout from the action script
        'title': 'Done',
    },
    'type': 'alfred.workflow.output.notification',
    'uid': NOT,
    'version': 1,
}
```

## Script Filter JSON output

The Script Filter script must print a single JSON object to stdout:

```python
import json

print(json.dumps({
    'items': [
        {
            'uid': 'unique-stable-id',     # Alfred uses this for ranking memory
            'title': 'Port 3000',
            'subtitle': 'node — PID 1234',
            'arg': '1234',                 # passed to the next action as $1
            'autocomplete': '3000',
            'match': '3000 node',          # Alfred searches this; combine fields here
            'variables': {                 # Alfred exports these as env vars in next script
                'port': '3000',
                'process_name': 'node',
            },
        }
    ]
}))
```

The `match` field is key: with `alfredfiltersresults: True`, Alfred searches `title`, `subtitle`, and `match`. Put anything the user might search in `match` (e.g., both a port number and a process name).

For non-actionable items (empty state, errors): `{'title': 'Nothing found', 'subtitle': '', 'valid': False}`.

## Writing script files

**Python (Script Filter)** — use `/usr/bin/python3` for reliability:

```python
#!/usr/bin/env python3
import subprocess, json

# Alfred sets CWD to the workflow directory, so ./other_file.py works
result = subprocess.run(['lsof', '-nP', '-iTCP', '-sTCP:LISTEN'],
                        capture_output=True, text=True)

items = []
seen = set()
for line in result.stdout.strip().split('\n')[1:]:
    parts = line.split()
    if len(parts) < 9:
        continue
    cmd, pid, addr = parts[0], parts[1], parts[8]
    addr = addr.split()[0]          # strip trailing "(LISTEN)" if present
    port = addr.rsplit(':', 1)[1]   # rsplit handles IPv6 like [::1]:3000
    if not port.isdigit() or port in seen:
        continue
    seen.add(port)
    items.append({'uid': f'port-{port}', 'title': f'Port {port}',
                  'subtitle': f'{cmd} — PID {pid}', 'arg': pid,
                  'autocomplete': port, 'match': f'{port} {cmd}',
                  'variables': {'port': port, 'process_name': cmd}})

items.sort(key=lambda x: int(x['title'].split()[1]))
print(json.dumps({'items': items or [{'title': 'No results', 'valid': False}]}))
```

**Shell (Action Script)** — item variables are exported as env vars:

```zsh
#!/bin/zsh
pid="$1"           # the item's 'arg' field
# $port and $process_name come from the item's 'variables' dict
if kill -9 "$pid" 2>/dev/null; then
    echo "Killed $process_name on port $port"
else
    echo "PID $pid not found — already stopped?"
fi
```

## Packaging

```bash
cd /path/to/workflow-dir
zip -r "../My Workflow.alfredworkflow" .
# Files go at zip root — no subdirectory
```

Double-click to install in Alfred.

## Connections and modifiers

To add Cmd+Enter as a modifier (e.g., open vs. copy):
```python
'connections': {
    SF: [
        {'destinationuid': ACT_OPEN, 'modifiers': 0,      'modifiersubtext': '',               'vitoclose': True},
        {'destinationuid': ACT_COPY, 'modifiers': 1048576, 'modifiersubtext': '⌘ Copy to clipboard', 'vitoclose': True},
    ]
}
```
Modifier bitmasks: 0 = Enter, 1048576 = ⌘, 524288 = ⌥, 131072 = ⌃, 2097152 = ⇧.

## Common gotchas

- `lsof` output includes `(LISTEN)` after the address — always `addr.split()[0]` before parsing
- IPv6 shows the same port twice (IPv4 + IPv6) — deduplicate by port with a `seen` set
- Use `rsplit(':', 1)[1]` to extract port from addresses like `[::1]:3000`
- The correct action type is `alfred.workflow.action.script`, not `action.runscript`
- **Action scripts must use inline `script` field** — `scriptfile` is silently ignored for actions
- **Use `scriptargtype: 0` with `{query}`** in action scripts to receive the selected item's `arg`; `scriptargtype: 1` / `$1` does not work for inline action scripts
- **`vitoclose: False`** closes Alfred on selection; `vitoclose: True` keeps it open ("veto the close") — use `False` for the Script Filter → Action connection in nearly all cases
- **Notifications require DND/Focus to be off** — Alfred notifications are silently swallowed by macOS Focus mode; users will see them accumulate in Notification Center but never pop up
- Notification body is `text`, not `subtitle`
- Script Filter version must be `3`; Action Script version must be `2`
