---
name: teaching-mode
description: Toggle teaching mode on or off for the current project. Usage: /teaching-mode on|off|status
---

Check the argument: `on`, `off`, `status`, or absent.

**on**
```bash
touch .claude/teaching_mode
```
Reply: "Teaching mode **on**. Run `/teaching-mode off` to disable."

**off**
```bash
rm .claude/teaching_mode 2>/dev/null; true
```
Reply: "Teaching mode **off**."

**status**
```bash
[ -f .claude/teaching_mode ] && echo on || echo off
```
Reply: "Teaching mode is currently **[on|off]** in this project."

**no argument** — Reply: "Usage: `/teaching-mode on|off|status`"
