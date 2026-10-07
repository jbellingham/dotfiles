---
name: board-log
description: >
  Persists a day's work to the matching cards on the personal Notion kanban board — one card per work item (Linear ticket or named piece of work), appended across days, so returning to a card cold tells you where you left off. Reads all projects' .remember/ session files for the target day, clusters them into workstreams, matches each to a board card, and writes a dated log entry plus an explicit "picking this up" line.

  Trigger for: /board-log, "log the day to my board", "persist today's work to Notion", "update my kanban board", "end of day board update", "log yesterday to the board".

  Do NOT trigger for: "what did I work on today" (that's daily-playback — read-only narrative, no writes), "snapshot this conversation" (conversation-snapshot), or "save my progress" (checkpoint).
---

# Board Log

Writes the day's work onto the personal Notion kanban board, one entry per work item.

The board is a **work-item** tracker, not a diary: cards are named `SWIFT-270`, `Eventing RFC`, `Review Cait's PR`. Work spanning multiple days lands on the **same card**, newest entry at the top. The point is that opening a card after two weeks away tells you what state it's in and what to do next.

## Board constants

| Thing | Value |
|---|---|
| Database | `https://app.notion.com/p/5ad1a239c5d18253bdfb01b39d8d592b` |
| Data source | `collection://5651a239-c5d1-83ca-919d-879fffd39716` |
| `data_source_id` | `5651a239-c5d1-83ca-919d-879fffd39716` |
| Kanban view | `view://2391a239-c5d1-82fb-9ff4-08584f1814c1` |

**Status property** — the kanban view groups by status *group*, so only three columns are visible:

| Group | Options in the group | Canonical option this skill writes |
|---|---|---|
| `to_do` | Not started | `Not started` |
| `in_progress` | In development, Testing, Reviewing | `In development` |
| `complete` | Done | `Done` |

Other properties: `Name` (title), `Team` (select: Design / Engineering), `Tags` (multi-select: RFCs / Architecture / PRs / Day-to-day), `Assign` (person), `Deadline` (date), `AI keywords` (multi-select, ignore).

## Notion tools

**Do not hardcode the MCP tool prefix.** Two connectors expose the same Notion tools under different names (`mcp__claude_ai_Notion__*` and `mcp__plugin_Notion_notion__*`), and which one resolves varies by session. Load them by search:

```
ToolSearch("notion fetch query data sources update page create pages")
```

Use whichever prefix comes back. The four tools needed are `*notion-fetch`, `*notion-query-data-sources`, `*notion-update-page`, `*notion-create-pages`. If none resolve, stop and tell the user the Notion connector isn't available in this session — do not fall back to writing a local file and calling it done.

Before the first write, read the markdown spec once: pass `notion://docs/enhanced-markdown-spec` as the `id` to `*notion-fetch`.

---

## Step 1: Resolve the target date

Default is **today**. The user may name another day ("for yesterday", "log Monday"). Resolve to an explicit calendar date and use it as `TARGET_DATE` throughout.

```bash
date +%F          # today (default)
date -v-1d +%F    # yesterday
date -v-3d +%F    # three days ago
```

**Never infer the day from which files exist or from file modification times.** Session files are flushed and renamed the *next* morning, so a file's mtime is typically one day after the work it describes. The `## HH:MM` headers inside files may be in another timezone. **The filename date is the only reliable signal.**

## Step 2: Gather the day's entries

Session history lives in per-project `.remember/` directories:

```bash
find ~/dev/work -maxdepth 2 -name ".remember" -type d
```

For each directory, read the file for `TARGET_DATE`. It is named `today-<TARGET_DATE>.md` while it is the open day and is renamed `today-<TARGET_DATE>.done.md` once it rolls over. Match both; prefer `.done.md` if somehow both exist:

```bash
ls <dir>/today-<TARGET_DATE>.md <dir>/today-<TARGET_DATE>.done.md 2>/dev/null
```

The filename date must match `TARGET_DATE` **exactly**. **Do not fall back to the newest available file** — grabbing the nearest file is what produces wrong-day writes, and here those writes are persistent.

`now.md` is the live rolling buffer. Include it only if **both** conditions hold:
1. `TARGET_DATE` is today, and
2. it is non-empty and its mtime date is today:
   ```bash
   [ -s <dir>/now.md ] && [ "$(stat -f '%Sm' -t '%F' <dir>/now.md)" = "<TARGET_DATE>" ]
   ```

For any past `TARGET_DATE`, ignore `now.md` entirely. If a project has both a dated file and a qualifying `now.md`, merge and deduplicate.

<CRITICAL>
Read ONLY the target-day files above. `.remember/` also holds cross-day rollups that will silently contaminate the board with other weeks' work. Do NOT draw on any of:

- `recent.md` (rolling 7-day), `archive.md` / `archive-*.md` (by-week), `core-memories.md`
- other days' `today-*.done.md` files
- `.remember` history, handoff text, or recalled memory already sitting in context from the SessionStart hook — that is background, not target-day data

If the day was quiet, write a short entry or report there is nothing to log. **Never pad a card with content from another day.** A wrong entry on a card is worse than a missing one, because you will trust it later.
</CRITICAL>

If no project has a file for `TARGET_DATE`, say so and stop.

## Step 3: Cluster into workstreams

Entries look like:

```
## 14:19 | preauth-swift-270
Created SWIFT-317 sidekiq limiter pool cap (Low, may not build—SWIFT-297 removes need); PR #7888 5 threads resolved; pending: SWIFT-317 analysis incomplete (faulty-station data excluded undocumented, correction started).
```

The header is `## <time or time-range> | <context>`, where context is usually the **git branch name**. Cluster on it:

- **Branch containing a ticket slug** (`preauth-swift-270` → `SWIFT-270`) → one workstream, ticket identified. Note the ticket is the *branch's* ticket; tickets merely *mentioned* in the body (SWIFT-317, SWIFT-297) are content, not separate workstreams, unless entries are clearly about doing that other ticket's work.
- **Branch with no ticket slug** (`master`, `spike/foo`) → cluster by topic across those entries.
- Entries from different projects (`chargefox`, `chargefox-mobile-app`) stay separate workstreams unless clearly the same piece of work; note the project in the entry when it isn't chargefox.

Preserve chronological order of entries within a workstream — the last one is usually where things stand.

## Step 4: Match each workstream to a card

One query for all card names:

```
*notion-query-data-sources with mode sql:
  SELECT url, "Name", "Status", "Team" FROM "collection://5651a239-c5d1-83ca-919d-879fffd39716"
```

**Programme redirects.** Some ticket work belongs on a programme card rather than a card per ticket, because the board is deliberately coarser than Linear. Check this table *before* matching by slug:

| Workstream signal | Card |
|---|---|
| Any `SWIFT-` ticket in the Linear project *New users are authed when their charge session starts on core* — 268, 270, 271, 272, 291, 296, 297, 302, 303, 304, 305, 313, 315, 316 — plus satellites 225, 269, 290, 293, 298, 306, 317, 70 | **Preauth on session start** |

A slug in this table redirects even though a card of that name may still exist. Show the redirect in the Step 5 plan (`SWIFT-270 → Preauth on session start`) so it stays visible and correctable.

When a new programme card is set up, add a row here rather than letting the skill fall back to per-ticket cards.

Otherwise resolve each workstream in this order:

1. **Ticket slug appears in `Name`** (e.g. `SWIFT-270`) → that card. Case-insensitive, and match the slug as a token so `SWIFT-27` never matches `SWIFT-270`.
2. **Close title match** on the topic → propose that card, flagged as a guess so the user can reject it in Step 5.
3. **No match** → propose a new card. Name it the ticket slug when there is one; otherwise a short noun phrase in the style already on the board (`Eventing RFC`, `Continue moving stuff into benefits engine`) — describing the piece of work, not the day.

Never create a card without it appearing as **NEW** in the Step 5 plan.

## Step 5: Compose the entry, then get one approval

For each workstream build:

```markdown
## <TARGET_DATE>
### [<SWIFT-nnn>](https://linear.app/chargefox/issue/<SWIFT-nnn>)
- <what happened, one bullet per meaningful thing>
- <ticket/PR numbers kept as written: #7888, SWIFT-317, r3848866734>
<callout icon="↩️">
	**Picking this up:** <the next action>
</callout>
---
```

**Ticket attribution.** An H3 heading linking to Linear groups the bullets under the ticket the work was against. It must be a **heading, not bold text** — bold renders as an ordinary paragraph and reads as part of the bullets, which defeats the point. Rules:

- **Link form is `https://linear.app/chargefox/issue/<SWIFT-nnn>`** — the bare identifier resolves; the title slug is not needed.
- **Only on programme cards** — a card that aggregates several tickets (anything in the redirect table). On a card that already *is* one ticket, the heading is noise; omit it.
- **The slug is the workstream's ticket, taken from the branch.** Do NOT attribute to a ticket merely named in a bullet: "Created SWIFT-317" is SWIFT-270's work that produced SWIFT-317, so it belongs under `SWIFT-270`.
- **Two headings on one date** when the day genuinely spanned two branches. Still one `<callout>` per date block, at the end — it covers the day, not each ticket.
- **No branch ticket** → omit the heading entirely rather than guessing one.
- **Heading levels:** `##` for the date and for a card's `Ticket index` section, `###` for ticket groups inside a date. Keep them distinct so the page outline stays readable.

**Notion markdown mechanics** (verified against `notion://docs/enhanced-markdown-spec`):

- **Blank lines are stripped.** A blank line before the resume line does *not* survive — it renders as part of the bullet block. That is why the resume line is a `<callout>`: it stays visually distinct without depending on whitespace. Use `<empty-block/>` if a genuine blank line is ever needed.
- The callout child must be indented with a **tab**, not spaces.
- Escape `~` when it means "approximately" (`\~158k`), and `* ~ ` [ ] < > { } | ^` generally, outside code spans. A bare `~~` would silently become strikethrough.

Rules for the bullets: present the substance, drop the timestamps, merge near-duplicate entries, keep concrete identifiers (PR numbers, ticket slugs, review-comment ids, file paths). Three to six bullets is typical. Prose bullets, not a transcript.

<CRITICAL>
**Never invent the "picking this up" line.** Build it only from explicit forward-looking markers in the source entries — `pending:`, `next:`, `TODO`, `WIP`, `blocked`, `unresolved`. If a workstream has none, write exactly:

a callout whose text is exactly `**Picking this up:** no next step recorded.`

A fabricated resume instruction is worse than none: it will be trusted weeks later when nothing remembers it was a guess.
</CRITICAL>

**Tag proposal — new cards only.** `Tags` is what makes the board filterable, so it only works if it stays sparse. Propose a tag only when one genuinely fits:

| Tag | Use for |
|---|---|
| `Architecture` | the work is a design, boundary or semantics *decision*, not delivery |
| `RFCs` | the output is a written RFC |
| `PRs` | reviewing someone else's PR |
| `Day-to-day` | routine ops or support |

A card can carry two (an RFC about architecture is `RFCs` + `Architecture`). **Most delivery cards get none** — a feature programme tagged `Architecture` dilutes the filter that makes the staff-level lane findable, which is the whole point. When nothing fits, propose no tag and say so.

Propose tags for **new cards only**. Never change `Tags` on an existing card unless the user asks — those are curated by hand.

**Status proposal — group-level only.** Infer the target *group*, never the option within it:

- work happened on the card at all → `in_progress`
- the ticket was closed, the PR merged, or the entries say the work is finished → `complete`
- `to_do` is never inferred; the skill does not move cards backwards

Then apply this rule: **if the card's current Status is already in the target group, propose no change and leave the property untouched.** A card the user hand-set to `Reviewing` must not be rewritten to `In development` — invisible in the kanban view, wrong in the table view. Only a genuine column change is ever written.

Present the plan as a table, then **stop and wait for explicit approval**:

```
Workstream          Card                        Status          Tags           Entry
────────────────────────────────────────────────────────────────────────────────────
preauth-swift-270   SWIFT-270 (existing)        no change       —              4 bullets
eventing rfc        Eventing consolidation (NEW) → In dev       RFCs, Arch     3 bullets
```

`—` in the Tags column means an existing card (never retagged) or a new card where no tag fits.

Show the full entry text for each below the table. Nothing is written until the user says yes. If they amend a card name, entry, or status, apply the amendment and re-show only what changed.

## Step 6: Write

**Existing card, no entry for `TARGET_DATE` yet** — prepend so the card opens on its latest state:

```
*notion-update-page
  page_id: <card id>
  command: insert_content
  position: {"type": "start"}
  content: <the dated block>
```

**Existing card that already has a `## <TARGET_DATE>` heading** (a re-run — this is common) — do not append a second block. Fetch the card, then replace the existing block:

```
*notion-update-page
  page_id: <card id>
  command: update_content
  content_updates: [{ old_str: <the existing dated block>, new_str: <the merged block> }]
```

Merge rather than clobber: keep bullets from the earlier run that are still true, add what is new. If the old block cannot be matched exactly, say so and ask before falling back to prepending.

**New card:**

```
*notion-create-pages
  parent: { type: "data_source_id", data_source_id: "5651a239-c5d1-83ca-919d-879fffd39716" }
  pages: [{
    properties: { "Name": "<card name>", "Team": "Engineering", "Status": "<approved group's canonical option>", "Tags": ["<approved tag>"] },
    content: "<the dated block>"
  }]
```

Set `Team: Engineering`. `Tags` takes a JSON array of strings (`["RFCs", "Architecture"]`); omit the key entirely when no tag was approved. Leave `Assign`, `Deadline` and `AI keywords` unset — the user curates those.

Do **not** pass `template_id`. Verified 2026-08-25: `create-pages` without it does not apply the data source's default `Task` template, so the card contains only the content written here.

**Status writes** are a separate `update_properties` call, only for cards where Step 5 proposed an actual group change:

```
*notion-update-page
  page_id: <card id>
  command: update_properties
  properties: { "Status": "In development" }
```

## Step 7: Report

One line per card with its URL and what happened to it:

```
SWIFT-270      entry added                 https://app.notion.com/p/3b91a239...
Board log      created, → In progress      https://app.notion.com/p/...
```

State plainly if a card was skipped and why. If any write failed, say which and leave the rest reported accurately — do not summarise a partial run as a success.

## Red flags

| Thought | Reality |
|---|---|
| "No file for that date, I'll use the newest one" | That writes the wrong day onto a card permanently. Stop and say there's no data. |
| "recent.md has more detail, I'll enrich from it" | It spans weeks. It will put other weeks' work on this card. |
| "There's no pending marker but the next step is obvious" | Write "no next step recorded". Inferred next steps get trusted later. |
| "The card is in Reviewing, work happened, so → In development" | Same column. Leave the property alone. |
| "I'll create the card and mention it in the summary" | Creation needs approval in the Step 5 plan first. |
| "Every card should get a tag" | Tags exist to filter. Tag everything and they filter nothing. Most delivery cards get none. |
| "This existing card is missing a tag, I'll add one" | Tags on existing cards are hand-curated. Leave them unless asked. |
| "It already has today's entry, I'll append another" | Merge into the existing block; duplicate dated headings make the card unreadable. |
| "Notion tools aren't resolving, I'll write a local file" | Report the connector is unavailable. A local file is not the deliverable. |
| "There's a SWIFT-270 card, so that's the match" | Check the programme redirect table first — a ticket card may exist but be retired. |
| "The user asked me to archive a card" | No MCP tool archives or trashes a Notion page. Say so; archiving is a UI action. |
| "The card looks empty, safe to retire" | Fetch it first. Hand-written notes and bookmark blocks do not show in a properties query, and bookmarks cannot be recreated from markdown. |
| "This bullet mentions SWIFT-317, so group it there" | Attribution follows the branch, not slugs named inside a bullet. |
