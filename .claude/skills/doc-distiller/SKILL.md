---
name: doc-distiller
description: Distils dense design and spec documents into tight technical briefs — stripping context-setting, repetition, and obvious rationale while preserving decision specifics and implementation details. Use when the user shares a design doc, spec, or architecture document and asks to shorten, boil down, condense, extract the essence, TL;DR, or brief it — especially when the document is "too long" or intended for a technical audience that already knows the domain. Trigger on phrases like "boil this down", "too verbose", "distil this", "condense", "the essence of this", "brief version", or any request to shorten a design/spec doc.
---

# Doc Distiller

You're producing a technical brief for a reader who is already in the room: someone who knows the domain, the problem space, and the codebase. They don't need the backstory — they need to see what was decided and how it will be built.

## Core principle

**Preserve specificity, kill generality.** A concrete schema name, API route, config value, algorithm, or data structure must survive verbatim. A paragraph explaining why microservices are a good pattern must not.

## What to cut

- Background framing and "why this matters" preamble — unless the motivation is genuinely non-obvious to a domain expert
- Explanations of how standard technologies work
- Rationale for obvious choices ("we chose REST because it's widely understood")
- Repetition — if a decision appears in an overview and again in a details section, merge them
- Process meta-commentary ("this document covers...", "in the next section we will...")
- "Future work" and nice-to-haves that aren't load-bearing to the current proposal
- Hedging and caveats around standard engineering uncertainties
- Motivational framing that states business value in generic terms

## What to keep (compressed, never removed)

- The problem being solved — compress to one sentence; only expand if the framing is genuinely subtle
- Non-obvious design decisions and their actual rationale (the interesting *why*, not the obvious *why*)
- Concrete implementation details: schema names, routes, interfaces, data structures, algorithms, config, tooling choices, version numbers
- Hard constraints and dependencies
- Trade-offs that were explicitly decided (not just identified as trade-offs)
- Open questions that represent genuine forks in the design or unresolved blockers

## Output format

Don't force a rigid template. Write sections that fit the document's content. Common useful sections:

**In a nutshell** — the goal and chosen approach, in 2–3 sentences. Skip if the title already makes it clear.

**Design decisions** — specific choices as tight bullets. Each bullet names the decision and (if non-obvious) the rationale in a clause. Not: "We considered X, Y, and Z. After much deliberation we chose X because..." — just: "X — [brief why if needed]."

**Implementation** — what gets built. Preserve names, types, routes, field names, anything needed to act on this. Prose is fine; use a list only when there are truly parallel items.

**Open questions** — genuine blockers or unresolved design forks only. Omit this section if there are none.

Adapt section names to the document type. A DB schema migration doc looks different from an API design doc or an infrastructure change proposal.

## Length

Aim for roughly 20–30% of the original. Quality beats target — a 400-word original might compress to 120 words; a 3000-word doc might yield 500. Never pad to hit a length.

## Don't compress into jargon

Brevity must never cost clarity. Hitting the length target tempts you to abbreviate recurring terms or lean on insider shorthand — but an acronym or idiom that appears *only* in the brief, with no expansion the reader can anchor to, is worse than the longer phrase it replaced.

- **Never introduce an acronym the source didn't define.** If a term recurs enough to be worth shortening, expand it on first use — "charge point (CP)" — then abbreviate. In a short brief, spelling it out usually wins; the few words saved aren't worth a reader stumbling on an undefined token.
- **Don't drop the subject to save words.** "Config, not a build" reads as jargon; "standing up the station needs only configuration, no new code" reads as English. Compressed phrases that rely on the reader supplying the implied subject and contrast are a false economy.
- A term being obvious *in speech among engineers* doesn't make it clear *in writing* — the reader can't ask you what it meant.

## Tone

Write like a senior engineer briefing a peer, not a document summariser. Active voice, present tense, no throat-clearing. If the original is vague on something that matters, note it briefly rather than reproducing the vagueness faithfully.

## Input handling

The document will typically be pasted in or provided as a file path. Read the full document before writing anything. If the doc covers clearly distinct concerns (e.g. auth changes and a separate logging proposal in one doc), preserve that split in the brief rather than collapsing them into one blob.
