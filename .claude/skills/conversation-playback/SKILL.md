---
name: conversation-playback
description: >
  Replays the intellectual journey of a conversation as a rich narrative — not just conclusions, but how you got there: what was tried, what failed, why direction changed, and what ideas got dropped along the way. Also re-raises forgotten threads and checks design/spec docs for drift from actual decisions.

  Trigger when the user wants to understand the arc of the conversation, not just its current state. Use for: /playback, "play back our conversation", "how did we get here / what led to this decision", "what did we try before landing here", "recap the conversation / where we've been", "surface any forgotten or dropped ideas", "I think we raised X earlier but never resolved it", "reconstruct the journey for my team", "before I update the spec", or any time the conversation has taken many turns and needs grounding.

  Also trigger when the user asks whether a design doc or spec has drifted from what was actually decided in the conversation.

  Do NOT trigger for: "summarize the conversation", "what did we decide?", "key takeaways", "TL;DR", "save to Notion", or "write a spec doc from scratch". Those want conclusions only; this skill reconstructs the reasoning behind them.
---

# Conversation Playback

The purpose of a playback is to reconstruct the *intellectual journey* of a conversation — not just where it landed, but how it got there. This is more useful than a summary because it preserves the reasoning behind decisions, not just the decisions themselves. It also catches things that got dropped.

## What makes a good playback

A good playback reads like it was written by someone who was in the room. It captures:

- **The arc**: how the conversation evolved over time, where it changed direction and why
- **Dead ends and wrong turns**: ideas that seemed promising but didn't work — these explain why the final direction looks the way it does
- **The pivots**: moments where the conversation materially shifted, and what caused the shift
- **Retroactive invalidations**: the most important pivots to capture — a single question or piece of information that made everything designed before it obsolete. When this happens, call it out explicitly: prior work wasn't wasted, but it no longer describes the system being built. A design doc written before this moment is essentially a document about a different project.
- **Discoveries**: things that weren't known at the start and got figured out along the way
- **Forgotten threads**: ideas raised seriously but dropped without resolution

A bad playback is just a bullet list of conclusions. Avoid this.

---

## How to run a playback

### Step 1: Read the full conversation

Before writing anything, read the conversation from the very beginning — chronologically. As you read, keep track of:

- Every substantive idea, proposal, or hypothesis, no matter how briefly raised
- Which ideas were: **adopted** (still active), **rejected/superseded** (explicitly ruled out), or **dropped** (raised but never resolved)
- The pivots — moments where the direction changed materially and why. Pay special attention to **retroactive invalidations**: a single question or answer that makes everything designed before it obsolete. These are easy to gloss over as just another pivot, but they're distinct — they mean prior design work was done in good faith but is now irrelevant, and any design doc written before that moment describes a different system.
- The emotional register — where was there conviction? where was there doubt or back-and-forth?
- The user's actual intent vs. what they said literally (these diverge in long conversations)

Don't start writing until you've read everything.

### Step 2: Write the narrative

Write the playback as prose organized into natural phases — not bullet points, not headers for every exchange, not a transcript. Each phase should have a short title that captures its character.

Good phase titles capture what was happening, not just what was decided:
- "Starting from first principles"
- "The wrong turn with [approach X]"
- "The pivot"
- "Where things clicked into place"
- "Settling the details"

Within each phase, write in flowing prose. Use language that conveys movement and causality:
- "This led to..."
- "At this point the conversation shifted when..."
- "This worked until we realized..."
- "The key insight was..."

Don't just enumerate what happened — explain *why* the conversation moved the way it did.

**Calibrate length to the conversation:**
- Short (under ~30 exchanges): 1–2 phases, 2–4 paragraphs each — keep it tight
- Medium (30–100 exchanges): 2–4 phases, 3–6 paragraphs each
- Long (100+ exchanges): more phases, but compress the early stages once the direction becomes clear

**What to include:**
- Ideas that turned out to be wrong, and why — "we tried X, it failed because Y, which led us to Z" is more useful than just "Z"
- Moments of genuine disagreement or doubt, even if they resolved
- Realizations that changed the framing, not just the answer

**What to leave out:**
- Purely procedural exchanges ("can you read this file?", tool calls, error messages)
- Ideas that were clearly throwaway from the start
- Repetition — if the same idea came up three times, trace its evolution once, don't describe it three times

### Step 3: Surface forgotten threads

After the narrative, add a **Forgotten Threads** section. These are ideas that were raised with some seriousness but dropped without resolution — and that might still be worth considering given where things landed.

For each forgotten thread:
1. State what the idea was
2. Note when it came up and what prompted it
3. Explain why it might still matter, given the current state of things — make a case for it, don't just list it neutrally

Apply judgment. Not every discarded idea deserves re-raising. Ask: given what we now know and where we've landed, would a thoughtful person want this back on the table? If the idea was clearly superseded or ruled out for solid reasons, leave it out. If there's genuine uncertainty about whether it was adequately considered, include it.

If there are no meaningful forgotten threads, say so in one sentence. Don't manufacture them.

### Step 4: Check design and spec docs

Look for design or spec docs that are in play:
- Files mentioned or edited during this conversation
- Common patterns: `DESIGN.md`, `SPEC.md`, `ARCHITECTURE.md`, `RFC.md`, `docs/`, `spec/`, `design/`

For each doc found, read it and compare it against what the conversation actually decided. Check for:

- **Inconsistencies** (flag clearly — these are the most important): the doc says X, but the conversation decided Y
- **Gaps**: something decided in the conversation that isn't in the doc yet
- **Stale content**: things the doc says that were superseded mid-conversation (not necessarily wrong, but worth flagging)
- **Consistent**: briefly note what was checked and is fine — don't enumerate every sentence, just give enough to confirm you checked

Format this as a compact structured list, not prose. Make it scannable.

If no design or spec docs exist, skip this section and say so in one line.

---

## Output format

```
# Conversation Playback

## [Phase title]
[Prose narrative of this phase]

## [Phase title]
[Prose narrative of this phase]

...

---

## Forgotten Threads

**[Short name for the idea]**: [What it was, when it came up, why it might still matter — 2–4 sentences]

...

(or: "No significant forgotten threads." if none.)

---

## Design Doc Check

### [filename]

- ✗ **Inconsistency**: [what the doc says] vs [what was decided]
- △ **Gap**: [decision not yet reflected in doc]
- ~ **Stale**: [content that was superseded, and by what]
- ✓ **Consistent**: [brief note — just enough to show it was checked]

(or: "No design or spec docs found." if none.)
```

---

## Style notes

Write as "we" when appropriate — this was a collaboration. Be specific over vague: "we ruled out Redis for session storage because TTL management conflicted with our refresh token design" is more useful than "we evaluated storage options."

Don't summarize by listing conclusions. The point is to reconstruct the *reasoning*, not just the outcomes. A reader who only had the conclusions wouldn't need a playback — they need to understand why.
