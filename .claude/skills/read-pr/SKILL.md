---
name: read-pr
description: Presents a diff in the order the change actually reads — the state it introduces, then where execution enters, then the path it takes through the stack — instead of GitHub's alphabetical file list. Each test travels with its subject; generated files sink. Works on a pull request or on a branch with no PR yet. Use when the user wants to read, understand, or orient themselves in a PR or their own working tree ("help me read PR 8015", "what order should I read this in", "walk me through my changes", "/read-pr"). This skill does NOT review, critique, rate, or summarise the change — for that, use pr-review.
---

# Read a change in the order it happens

GitHub sorts the Files tab by path, which describes the filesystem rather than
the change: callers before callees, tests dumped far from their subjects,
incidental edits between the two halves of the core logic. The reader has to
inventory everything before any of it means anything.

This skill supplies the ordering GitHub withholds, and only that.

## The hard constraint

**You are not reviewing this change. You never see its code.**

Work exclusively from the JSON digest the script returns. Do not run `git diff`
or `gh pr diff`, do not open changed files, do not fetch the PR body or its
Linear ticket. Seeing only structural facts is what keeps orientation from
sliding into assessment.

You **may** infer the journey — which file execution enters through, what it
reaches next — because that is the ordering the reader asked for, and the
digest's `role` and `mentioned_by` fields are the evidence for it.

You may **not** emit:

- an assessment of quality, risk, correctness, style or test coverage
- a suggestion, concern, question, or anything phrased as "note that…"
- a description of *what the change does* or *why* — the order carries that
- a guess at a file's contents beyond what the digest states

If the digest is ambiguous, keep the script's order. Do not speculate to
resolve it.

## Steps

### 1. Build the digest

```bash
ruby ~/.claude/skills/read-pr/pr_digest.rb            # the branch's PR, or its own changes if it has none
ruby ~/.claude/skills/read-pr/pr_digest.rb 8015       # by number, current repo
ruby ~/.claude/skills/read-pr/pr_digest.rb https://github.com/owner/repo/pull/8015
ruby ~/.claude/skills/read-pr/pr_digest.rb --local    # force the working tree even when a PR exists
```

With no argument it uses the current branch's pull request, and falls back to
the working tree when the branch has none — everything since the branch left
the mainline, committed or not, plus untracked files.

If it exits non-zero, relay the error and stop.

### 2. Read the digest

`source` is either `{kind: "pull_request", …}` or `{kind: "working_tree", base: …}`.
`files` is already in reading order. Each carries `path`, `additions`,
`deletions`, `status`, `defines`, `refs`, `mentioned_by`, `noise`, `url`, and
`role`:

| `role` | Means |
|---|---|
| `foundation` | Declares names other changed files use; uses none itself — the state the change introduces |
| `entry` | A job, controller, mutation, channel, mailer or task that reaches into the change — where a journey starts |
| `flow` | Sits between the two: reached from somewhere, reaches somewhere |
| `isolated` | Nothing in this change references it, and it references nothing |
| `test` | A spec, placed beside its subject |
| `generated` | Lockfile, schema dump, snapshot, pure rename, whitespace-only |

### 3. Group and adjust

Keep the order unless a fact in the digest contradicts it. Split the list into
2–4 groups with a short heading naming the part of the change — *what it is*,
never *how good it is*. Follow the roles:

- `foundation` files open the read: "The new state", "New shapes".
- `entry` files start the journey: "Where it starts", "Entry point".
- `flow` files follow it: "What it calls", "Through the stack".
- `isolated` and leftover specs trail: "Elsewhere", "Neighbouring specs".

Four words per heading at most. With one group, or with every file `isolated`
(a change whose files reference nothing of each other's), drop the headings and
print a flat list. Every `generated` file goes last under `Skim last`.

### 4. Present

Full paths, counts, and structural facts only. Link each path to its `url`.
When `source.kind` is `working_tree`, `url` is null — say once that there is no
Files tab to anchor to, and print bare paths.

```
PR #8015 — chargefox/chargefox — reading order

The new state
  1. [app/models/payment_authorisation.rb](url)              +21 -1   defines :unreconciled, :expire
  2. [spec/models/payment_authorisation_spec.rb](url)        +64 -1

Where it starts
  3. [app/jobs/charge_customer_job.rb](url)                  +38 -3   mentions CapturePreauthHoldAction

Through the stack
  4. [app/mediators/capture_preauth_hold_action.rb](url)     +218 -0
  5. [spec/mediators/capture_preauth_hold_action_spec.rb](url)  +277 -0

Skim last
  6. [Gemfile.lock](url)                                     +8 -8    generated
```

Then stop. No trailing commentary.

## Facts, and their limits

`refs`/`mentioned_by` are **textual matches**, not name resolution: file A
mentions file B when A's changed lines carry a name B declares. Say "mentions",
never "calls" or "depends on". Generic short names are excluded from linking, so
these under-report rather than invent — and two files declaring the same name
can produce one spurious edge.

`defines` and `refs` are extracted for Ruby and TypeScript/JavaScript only.
Other languages are ordered by path layer and carry no symbol facts — never
invent them.

The digest sees only changed lines. An unchanged caller elsewhere in the
codebase is invisible, so a missing `mentioned_by` is not evidence of anything.

Files marked skip-worktree are invisible to `git`, so they are absent from a
working-tree digest exactly as they are from `git status`.

## Maintenance

`pr_digest.rb` is covered by `test_pr_digest.rb` — run `ruby test_pr_digest.rb`
from the skill directory after any change. Add a failing test before adjusting
a heuristic.
