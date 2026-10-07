---
name: conversation-snapshot
description: >
  Snapshot the current conversation to Notion — extracts key points, decisions, and open questions, then creates a page under Code Analyses for later reference or resumption. Handles multiple snapshots in the same session by linking pages together and only capturing what's new. Use whenever you want to checkpoint progress mid-conversation, save a design discussion, or capture context before ending a session. Trigger phrases: "snapshot this", "save to Notion", "capture this conversation", "checkpoint this", "/snapshot".
---

## Purpose

Create a minimal, high-signal Notion page from the current conversation. No prose — just the facts, decisions, and loose ends a future reader needs. Multiple snapshots per session are linked together; each continuation only captures what's new.

## Steps

### 1. Get the session ID

```bash
echo $CLAUDE_CODE_SESSION_ID
```

### 2. Check for a prior snapshot

Search Notion for existing snapshots from this session:

- Use `mcp__plugin_Notion_notion__notion-search` with the session ID UUID as the query string
- If a result comes back whose content or title contains that UUID, it's a prior snapshot — note its URL and title
- If nothing matches, this is the first snapshot

### 3. Extract from the conversation

**Topic label** — 3–7 words, noun phrase. Describes what was worked on, not what was concluded.

**If this is the FIRST snapshot:**
- **Key points** — decisions, facts established, patterns agreed on, approaches ruled out. ≤15 words each, present tense. Drop anything that won't help a future reader.
- **Open questions** — unresolved threads, explicit unknowns. Phrased as questions. Omit if none.
- Aim for 3–8 bullets per section; fewer and sharper beats more and vague.

**If this is a SUBSEQUENT snapshot:**
- Write a single sentence (≤20 words) summarising what the PREVIOUS page covered — infer this from the conversation, not by fetching the prior page.
- **Key points** — ONLY what is new or changed since the last snapshot. Skip anything already captured.
- **Open questions** — ONLY new questions, or questions that have since been resolved (mark resolved ones with ~~strikethrough~~).
- If nothing new has happened, say so rather than padding.

### 4. Fetch the Notion markdown spec

Resource: `notion://docs/enhanced-markdown-spec` via `ReadMcpResourceTool` (server: `plugin:Notion:notion`)

### 5. Create the Notion page

Use `mcp__plugin_Notion_notion__notion-create-pages` with:

- **Parent:** `{ "type": "page_id", "page_id": "36d1a239c5d180499792f153ee4f1a9d" }`
- **Title:** `YYYY-MM-DD — [topic label]` — append ` (2)`, ` (3)` etc. for continuations
- **Content:** use the matching template below

#### First snapshot

```
**Session:** `<session-id>`
*Resume: `claude --resume <session-id>`*

## Key Points
- <point>

## Open Questions
- <question?>
```

#### Subsequent snapshot

```
**Session:** `<session-id>`
*Resume: `claude --resume <session-id>`*
**Previous:** [<prior page title>](<prior page URL>) — <one-sentence summary>

## New Key Points
- <point>

## Open Questions
- <new question?>
- ~~<resolved question>~~
```

Omit any section that has no content.

### 6. Reply to the user

One line only: page title and Notion URL.

Example: `Saved: "2026-06-01 — conversation-snapshot skill creation (2)" → https://notion.so/...`