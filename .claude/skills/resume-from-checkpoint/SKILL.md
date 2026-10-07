---
name: resume-from-checkpoint
description: Show a summary of all saved session checkpoints and let the user pick which one to resume. Use this skill whenever the user says things like "what was I working on?", "resume", "pick up where I left off", "catch me up", "what sessions do I have open?", "what are my open tasks?", "what's in progress?", "where did I leave off?", "show me my checkpoints", or any similar phrase indicating they want to orient themselves at the start of a new session or pick up prior work.
---

# Resume from checkpoint — Recall and Select a Prior Session

Help the user quickly orient themselves across all their saved checkpoints and choose what to work on next.

## Step 1: Read all checkpoints

- List all `.md` files in `memory/checkpoints/`
- Read each file, noting its `updated:` date from the frontmatter (or file mtime as fallback)
- If no checkpoints exist, tell the user and suggest running `/checkpoint` at the end of a session

## Step 2: Offer to clean up stale checkpoints

A checkpoint is **stale** if its `updated:` date is more than 7 days ago.

If any stale checkpoints exist, show them first:

```
Stale checkpoints (older than 7 days):

  - jesse-billing-refactor       last updated: 2026-03-10  (10 days ago)
  - feat-fleet-management        last updated: 2026-03-08  (12 days ago)

Delete these? [y/n]
```

Wait for the user's response. If yes, delete those files. If no, keep them and include them in the selection menu below.

## Step 3: Present the selection menu

Show a compact, numbered list of remaining checkpoints — most recently updated first:

```
Active sessions:

  1. jesse/swift-19-repurpose-tokens      [updated: 2026-03-20]
     Repurposing SendAllTokensJob to send tokens to CPO networks
     Next: Add nil check in cpo_token_service.rb:42 before calling send_to_cpo

  2. jesse/billing-refactor               [updated: 2026-03-18]
     Extracting billing calculation into a dedicated service object
     Next: Write failing spec for BillingCalculator#compute_total
```

Each entry is 3 lines: branch + date / what it's about / immediate next step. Then ask:

**"Which would you like to resume? (enter a number)"**

If only one checkpoint remains after cleanup, skip the selection and go straight to Step 4.

## Step 4: Show full context for the chosen session

Once the user picks one:

1. Display the full checkpoint content
2. Reconcile with live git state:
   - Is the branch still present? (`git branch -a | grep <branch>`)
   - Any new commits since the checkpoint was saved? (`git log --oneline <branch> | head -5`)
   - Any open PRs? (`gh pr list --author @me --state open 2>/dev/null`)
3. If anything has changed since the checkpoint (new commits, merged PR, branch gone), call it out so the checkpoint doesn't mislead

Close with a clear, prominent restatement of the **Immediate Next Step**.

## Principles

- Stale cleanup comes first — don't bury the user in old sessions
- The selection menu is for scanning, not reading — keep each entry tight
- If git state has drifted from what the checkpoint describes, say so explicitly
- The goal is a 30-second re-orientation, not a full audit