---
name: daily-playback
description: >
  Produces a structured daily narrative of all work sessions from a target day (today by default, or a past day the user names like "for yesterday") — not a conclusions summary, but a story of what happened: what was built, what was discovered, what pivoted, and what's unresolved. Reads from .remember/ session files to reconstruct the day across multiple conversations. Output includes YAML frontmatter metadata for persistence.

  Trigger for: /daily-playback, "play back today", "what did I work on today", "end of day recap", "daily digest", "journal today's sessions", "what happened today across our sessions", "recap the day", "day in review", or any time the user wants a record of the full day's work spanning multiple sessions.

  Do NOT trigger for: "summarize this conversation" or "what did we just do" — those want the current session only. Use conversation-playback for that instead.
---

# Daily Playback

The daily playback reconstructs the day's work as a narrative — not a bullet list of what got done, but a story of how the day unfolded: which sessions connected, what surprised you, what got unstuck, what's still open. The goal is something you'd actually want to re-read in three weeks.

The output includes YAML frontmatter so it can be pasted into a notes system or file and remain queryable.

---

## Step 1: Resolve the target date

This skill defaults to **today**, but the user may request another day ("for yesterday", "play back Monday"). Resolve the request to an explicit calendar date *first*, and use that as `TARGET_DATE` throughout. **Never infer the day from which files happen to exist, nor from file modification times** — both are misleading here:

- Session files are flushed and renamed the **next morning**, so a file's modification time is typically one day *after* the work it describes (e.g. `today-2026-06-17.md` was last modified on the 18th). Using mtime to pick the day shifts everything forward by one.
- The `## HH:MM` headers *inside* files may be UTC or another timezone, so they can't bucket entries into a local calendar day either (you'll see a single day's file span `04:23` to `23:12`). Use them only for ordering in Step 2.
- The **filename date string is the only reliable signal** for which day a session belongs to.

Compute `TARGET_DATE` explicitly (macOS `date`):

```bash
date +%F          # today (default)
date -v-1d +%F    # yesterday
date -v-3d +%F    # "3 days ago", etc.
```

For a named weekday, compute the matching `YYYY-MM-DD` the same way.

## Step 1b: Find the target day's session data

Session history is spread across per-project `.remember/` directories under `~/dev/work/`. Each project the user has worked in has its own. Find all of them:

```bash
find ~/dev/work -maxdepth 2 -name ".remember" -type d
```

For each directory found, locate the file for `TARGET_DATE`. A day's file is named `today-<TARGET_DATE>.md` while it is the current open day, and is **renamed to `today-<TARGET_DATE>.done.md`** once it rolls over (usually the next morning). **Match both forms:**

```bash
ls <dir>/today-<TARGET_DATE>.md <dir>/today-<TARGET_DATE>.done.md 2>/dev/null
```

Read whichever exists (if both somehow exist, prefer `.done.md` — it's the finalized version). The filename date must match `TARGET_DATE` **exactly** — **do NOT fall back to the newest available file** when the target date has no file. Grabbing the nearest file is exactly what produces wrong-day playbacks. If *no* project has a file for `TARGET_DATE`, tell the user there's no recorded work for that day and stop.

**`now.md` (the live rolling buffer) is only relevant when `TARGET_DATE` is today.** It holds the current day's not-yet-flushed entries. Include it only if **both**:
1. `TARGET_DATE` is today, AND
2. `now.md` is non-empty and its mtime date is today:
   ```bash
   [ -s <dir>/now.md ] && [ "$(stat -f '%Sm' -t '%F' <dir>/now.md)" = "<TARGET_DATE>" ]
   ```
For any **past** `TARGET_DATE`, ignore `now.md` entirely — its contents belong to the current day, not the target.

Derive the **project name** from the directory path: `~/dev/work/chargefox-mobile-app/.remember/` → project is `chargefox-mobile-app`. The top-level `~/dev/work/.remember/` directory → project is `work` (or omit if empty).

If a project has both a dated file and a qualifying `now.md` (today only), merge them and deduplicate — `now.md` may overlap with the dated file.

Collect all entries from all qualifying projects into one pool. If no entries are found anywhere, tell the user and stop.

**Read ONLY the target-day files above.** The narrative must be built *exclusively* from the `today-<TARGET_DATE>.md` / `today-<TARGET_DATE>.done.md` entries (plus a qualifying `now.md`) collected in this step. These files are NOT the only history present — `.remember/` also contains cross-day rollups that will silently contaminate a single-day playback with other weeks' work. **Do NOT draw on any of:**
- `recent.md` (rolling 7-day summary), `archive.md` (by-week rollups), or `core-memories.md` — these span many days/weeks. (Example failure: `archive.md` mentions a Sentry SDK upgrade and error-quota work from the week of 2026-05-19; pulling that in makes it look like Sentry triage happened on the target day when it didn't.)
- Other days' `today-*.done.md` files.
- Any `.remember` history, handoff text, or recalled-memory content already sitting in your context from the SessionStart hook — that is background, not target-day data.

If the target day genuinely had little activity, produce a short playback (or report that there's little to report) — **never pad it with remembered content from other days.**

---

## Step 2: Parse the entries

Each entry looks like:
```
## HH:MM | context
Terse notes about what happened
```

Or with a time range:
```
## HH:MM-HH:MM | context
Terse notes
```

Extract from each entry:
- **Start time** (and end time if present)
- **Context label** — the label after `|` in the header (may be "unknown" or a sub-area)
- **Project** — derived from which `.remember/` directory the entry came from
- **Content** — the raw notes, which are often very terse shorthand

After collecting all entries from all projects, **sort by start time** to get a unified chronological view of the day across projects.

If entries look like session continuation (same project, entries within ~30 min of each other), treat them as one session when narrativizing.

---

## Step 3: Build the narrative

Write prose organized by natural session groupings — not one section per entry. The Step 1b entries are your *only* raw material; your job is to reconstruct what was actually happening from them. If a topic (a project, a feature, a bug) isn't represented in the entries you collected for `TARGET_DATE`, it does not belong in the playback — no matter how prominent it is in your background context or memory of recent work.

**Expanding terse shorthand**: The entries use dense abbreviations. Interpret them using domain knowledge — "WF" likely means workflow, "plist" is a macOS property list, "SE notif" is system events notification, etc. Don't just quote the shorthand back — unpack it into plain English narrative.

**Session groupings**: Sessions that are clearly connected (same context, sequential timing, or building on each other) → one phase. Topic switches → new phase. Gaps of an hour or more can be acknowledged briefly ("After a break...").

**Timestamps are opaque**: The HH:MM values in the entry headers are reference points only — do NOT interpret them as a literal time of day. Don't characterize sessions as "midnight work", "early morning", "afternoon session", etc. based on the raw timestamp. The clock values in `.remember/` files may be in UTC or another timezone that doesn't match the user's local time. Use the timestamps only for ordering entries and computing time ranges — let phase titles describe the *work*, not the clock.

**Each phase should convey**:
- What the session was trying to accomplish (even if it wasn't explicit in the entry)
- What actually happened — including the wrong turns, surprises, and pivots
- What state things were left in

Write as "we" when appropriate (it was a collaboration). Use language that conveys sequence and causation:
- "This surfaced a constraint that..."
- "That wasn't working, so..."
- "Once that was resolved, the focus shifted to..."
- "The key was realizing that..."

**Length calibration**:
- 1–2 entries: 1 phase, 2–4 paragraphs — keep it tight
- 3–5 entries: 2–3 phases, 3–5 paragraphs each
- 6+ entries: more phases, compress similar sessions

A bad daily playback is a bullet list of what was done. Avoid this even when the entries are brief.

---

## Step 4: Surface carry-forwards

Only include this section if you find actual unresolved items. Look for:
- Work described as partial ("started", "still broken", "next step")
- Problems surfaced but not resolved within the day
- Decisions deferred ("will figure out later", "next session")
- Anything started but clearly not finished based on the context

For each carry-forward:
1. Name it concisely
2. Note which session it came from (time)
3. Explain why it matters given what happened the rest of the day — don't just re-state the entry

If nothing was left open, omit the section entirely (don't write "No carry-forwards").

---

## Step 5: Produce the output

Use this exact template:

```markdown
---
date: YYYY-MM-DD
generated_at: HH:MM
session_count: N
projects: [project-a, project-b, ...]
time_range: "HH:MM – HH:MM"
---

# Daily Playback — Weekday, Month DD, YYYY

## [Phase title]
[Prose narrative]

## [Phase title]
[Prose narrative]

...

---

## Carry-Forward

**[Item name]**: [What, where from, why it matters — 2–4 sentences]

...
```

**Metadata fields**:
- `date`: `TARGET_DATE` in YYYY-MM-DD (today by default, or the past day the user requested)
- `generated_at`: current time in HH:MM (24h)
- `session_count`: total number of distinct entries found across all projects
- `projects`: unique project names (from directory names), in order of first entry appearance
- `time_range`: earliest start time to latest end time across all projects and entries

**Phase titles**: Keep them descriptive and specific — "Getting the Alfred Workflow packaging right" not "Session 1". Titles should capture the character of the session, not just its subject.

Output the result directly in the conversation. Don't write a file unless the user explicitly asks.
