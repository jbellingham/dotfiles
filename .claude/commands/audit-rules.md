---
name: Audit Rules
description: Analyse codebase adherence to .claude/rules/ files. Reports direct violations and spirit violations, ranked by fix value. Top 10 come with agent-ready fix suggestions; the rest are summarised.
argument-hint: [ path ] [ --rules <rule-file>[,<rule-file>...] ]
---

Audit the codebase against its `.claude/rules/` files. Report direct violations, spirit violations, and concrete fix
suggestions ready to hand off to a code agent.

Accepts optional arguments:

- `[path]` — scope the audit to a subdirectory (default: full project)
- `--rules <file>[,<file>...]` — audit against one or more rules files only, comma-separated (e.g. `--rules ddd.md` or `--rules ddd.md,backend.md`)

---

## Process

### Phase 1 — Load Rules

Read every file in `.claude/rules/`. For each file extract:

- The `paths:` glob patterns from the YAML frontmatter
- All rules, grouping them into **hard rules** (explicit dos/don'ts) and **intent** (principles and rationale that imply
  additional standards beyond the literal text)

If `--rules <file>[,<file>...]` was passed, load only those files. Split on commas, trim whitespace from each name.

If `.claude/rules/` does not exist or is empty, report this and stop.

### Phase 2 — Enumerate Files

For each rules file, use the Glob tool (or `rg --files` via Bash) to resolve every `paths:` glob pattern from its frontmatter into a concrete list of file paths. Do this for real — do not reason about what files probably exist.

Combine the results into an explicit, numbered list:

```
ddd.md (247 files)
  1. app/models/charge_session.rb
  2. app/models/user.rb
  ...
247. engines/emsp/app/services/emsp/token_sync_service.rb

backend.md (312 files)
  1. app/controllers/api/v1/sessions_controller.rb
  ...
```

Apply the optional `[path]` scope argument as an additional filter if provided.

Exclude generated files and vendored dependencies (see "What NOT to Report" below for the full list).

**Do not proceed to Phase 3 until you have a concrete, numbered file list for every rules file.**

### Phase 3 — Batch Plan and Parallel Analysis

Before spawning any subagents, output a batch plan to the conversation in this format:

```
Batch plan:
  ddd.md    — 247 files → 4 batches (1–80, 81–160, 161–240, 241–247)
  backend.md — 312 files → 4 batches (1–80, 81–160, 161–240, 241–312)
  Total subagents: 8
```

The batch count for each rules file is `ceil(total_files / 80)`. The total subagents is the sum across all rules files. There is no discretion here — every file from the Phase 2 list must appear in exactly one batch.

Then spawn all subagents in parallel. For each (rules file, batch) pair, the subagent receives:

- The full content of its rules file
- Its assigned batch of source files (at most 80)
- The instructions below

**Subagent instructions:**

> Read every source file in your list. For each file, check it against every rule in your rules document. Produce a flat
> list of findings. Each finding must include:
>
> - `file`: relative path from project root
> - `line`: line number (or range)
> - `rule`: the specific rule or principle being violated (quote it)
> - `type`: `VIOLATION` (direct, unambiguous breach) or `SPIRIT` (against the intent but not the letter — explain why)
> - `evidence`: the actual code that is problematic (quote it, max 5 lines)
> - `impact`: one of `correctness`, `security`, `maintainability`, `consistency`, `style`
> - `fix`: a self-contained, concrete description of what to change — specific enough that a code agent can implement it
    without reading the rules or this report. Include the replacement code or pattern where relevant.
>
> Read every file in your list completely. Do not skip files because they look clean at a glance.
>
> For `SPIRIT` findings: only flag something if you can articulate a clear connection to a stated principle, not just a
> general code quality concern. If you cannot connect it to a rule, omit it.

### Phase 4 — Collect and Score

Gather all findings from all subagents (across all batches and all rules files). Deduplicate: same file + line + rule = one finding. When the same violation is found by two batches for the same rules file, keep one instance.

Score each finding for **fix value** using this formula:

```
value = impact_score × (1 / effort_score) × type_multiplier × ruleset_multiplier × stack_multiplier
```

**Impact scores:**
| Impact | Score |
|--------|-------|
| `security` | 5 |
| `correctness` | 4 |
| `maintainability` | 3 |
| `consistency` | 2 |
| `style` | 1 |

**Type multiplier:** `VIOLATION` findings score ×1.5; `SPIRIT` findings score ×1.0.

**Effort scores** (estimate from the fix description):
| Effort | Score |
|--------|-------|
| Rename / single-line change | 1 |
| Extract method / component | 2 |
| Refactor a function or class | 3 |
| Architectural change | 5 |

**Ruleset multiplier:** DDD and backend rules address the core domain and are higher priority than other rule sets:
| Rules file | Multiplier |
|------------|-----------|
| `ddd.md` | ×1.5 |
| `backend.md` | ×1.5 |
| `graphql.md`, `testing.md`, `frontend.md`, `testing-frontend.md` | ×1.0 |

**Stack multiplier:** apply a reduced weight to findings in the legacy React stack — it is in maintenance mode and not a
priority for active investment:
| File location | Multiplier |
|---------------|-----------|
| `app/javascript/src/**` (React components, pages, modules) | ×0.2 |
| All other files | ×1.0 |

Sort all findings by score descending.

### Phase 5 — Write Report

Compose the full report as a markdown string, then write it to:

```
.claude/audits/audit-<YYYY-MM-DD>.md
```

Create the `.claude/audits/` directory if it does not exist. If a file for today already exists, append a counter
suffix: `audit-<rules file>-<YYYY-MM-DD>-2.md`.

After writing, tell the user the file path. Do not reproduce the full report body in the conversation — print only a
brief summary (header stats + the titles of the top 10 findings as a numbered list).

#### Report structure

The written file must contain the following sections in order:

---

**Header:**

```
## Rules Audit — <date>
Scoped to: <path or "full project">
Rules analysed: <list of rules files>
Files scanned: <N>
Findings: <X violations, Y spirit violations>
```

**Top 10 — Highest Value Fixes**

For each of the top 10 findings by score:

```
### [N] <Short title> · <VIOLATION|SPIRIT> · <impact> · <rules file>

**Score:** `<final score>` = impact(<impact_score>) × 1/effort(<effort_score>) × type(<type_multiplier>) × ruleset(<ruleset_multiplier>) × stack(<stack_multiplier>)

**Rule:** "<quoted rule>"

**Location:** `<file>:<line>`

**Evidence:**
\`\`\`<language>
<offending code>
\`\`\`

**Why this matters:** <one sentence connecting the violation to the consequence — be concrete, not generic>

**Fix (agent-ready):**
<Complete, self-contained description. Include:
- Exactly what to change and where
- The replacement code or pattern
- Any related files that also need updating (e.g. if renaming a method, note call sites)
- Whether tests need updating>
```

If multiple findings share the same root cause (e.g. the same anti-pattern repeated in 8 files), group them under one
entry and list all affected files in the fix description. Count this as one of the 10.

**Remaining Findings — Summary**

If there are more than 10 findings:

```
## Remaining Findings (<N> total)

### By rule
| Rule (abbreviated) | Violations | Spirit | Files affected |
|--------------------|-----------|--------|----------------|
| ...                | N          | N      | N              |

### By file
| File | Findings |
|-----|---------|
| ... | N       |

Run `/audit-rules --rules <file>` to deep-dive a specific rule set.
```

**Footer:**

```
## How to apply fixes
These findings are ordered by fix value. You can ask me to fix them using subagents — either all of them, or a subset
(e.g. "fix findings 1, 3, and 5" or "fix everything in the graphql rules"). Each finding's "Fix (agent-ready)" block
contains enough context for a subagent to implement it independently.
Re-run `/audit-rules` after applying fixes to verify findings are resolved.

## Files analysed
<rules-file-name>
- path/to/file.rb
- path/to/another_file.rb
...

<next-rules-file-name>
- path/to/file.rb
...
```

List every file that was actually read by a subagent, grouped by the rules file that covered it. If a file falls under
multiple rules files (e.g. `app/models/` is in scope for both `ddd.md` and `backend.md`), list it under each.

---

## Scoring Guidance — What Counts as High Value

When breaking ties or applying judgement, prefer findings where:

1. **The violation is load-bearing** — e.g. a missing null check on a code path that runs in production, not just in a
   helper no one calls
2. **The fix is low-effort** — a one-line change that closes a correctness gap outranks a style fix requiring a large
   refactor
3. **The violation is widespread** — fixing the pattern in one place and documenting it stops it spreading further
4. **The spirit violation reveals a missing rule** — flag this in the summary so the user can consider adding it to the
   rules file

## What NOT to Report

- Issues in files explicitly excluded from the rules' `paths:` scope
- Generated code — skip any file matching:
  - `db/schema.rb` (regenerated from migrations)
  - `db/structure.sql` (alternative schema format)
  - `app/javascript/**/__generated__/**` (GraphQL codegen output)
  - `app/javascript/**/*.generated.ts` (codegen type files)
  - `public/assets/**`, `public/packs/**` (Sprockets / Webpacker output)
  - `tmp/**` (Rails temp files)
  - `dist/`, `node_modules/` (JS build output and dependencies)
  - `*.snap` (Jest snapshot files — flag snapshot test usage instead, not the snapshots themselves)
  - `.rubocop_todo.yml` (auto-generated lint suppression)
- Findings that require knowledge the rules don't provide (e.g. "this might be a performance issue" — only report what
  the rules say)
- Stylistic preferences not mentioned in any rule
