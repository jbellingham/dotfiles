---
name: checkpoint
description: Save a structured snapshot of the current session's work context to memory so it can be recalled in a future session. Supports multiple parallel sessions — each checkpoint is saved separately, keyed by branch or a custom name. Use this skill whenever the user says things like "save my progress", "checkpoint", "I'm wrapping up", "save context", "save where I am", "end of session", "I'll pick this up later", "save what we've done", or anything indicating they want to preserve their current working state for later recall. Also invoke proactively when helping a user wrap up a branch or feature.
---

# Checkpoint — Save Current Session Context

Save a structured snapshot of this session to `memory/checkpoints/` so it can be recalled alongside other parallel sessions in a future `/resume`.

Each checkpoint is a single file per session. One file per session, not one per save.

## Step 1: Determine the checkpoint filename

The file path is `memory/checkpoints/<name>.md`. Choose `<name>`:

1. If the user specified a name, slugify it (lowercase, spaces/slashes → `-`)
2. Otherwise, use the current git branch: `git branch --show-current`, slugified
   - e.g. `jesse/swift-19-repurpose-tokens` → `jesse-swift-19-repurpose-tokens`

Create `memory/checkpoints/` if it doesn't exist.

**If a file already exists for this name and the user did not specify a custom name:** read the existing checkpoint, then ask:

> A checkpoint already exists for `<branch>`:
> _"<existing title>"_ (last updated: YYYY-MM-DD)
>
> Is this the same session, or a different one running in parallel on the same branch?
> - **Same** — I'll overwrite it with the current state
> - **Different** — give me a short name or description for this session

Wait for the response:
- **Same / overwrite**: proceed to Step 2 with the existing filename
- **Different**: ask for a short description if they haven't given one, slugify it and append to the branch slug — e.g. `jesse-swift-19-repurpose-tokens-billing-fix`. Then proceed to Step 2 with the new filename.

## Step 2: Gather context in parallel

- `git status` — uncommitted/staged changes
- `git log --oneline -10` — recent commits on this branch
- `git branch --show-current` — current branch
- `gh pr list --author @me --state open 2>/dev/null` — open PRs (skip if unavailable)
- Read existing checkpoint file if it exists — understand prior state, but you will overwrite it
- Draw on the **current conversation** — the most valuable source. What were we just working on? What decisions were made? What's unfinished or blocked?

## Step 3: Write the checkpoint

Write the following to the checkpoint file, **replacing any previous content**:

```markdown
---
updated: YYYY-MM-DD
branch: <current branch>
---

# <Short descriptive title of what this session is about>

## What I Was Working On
<!-- 2-4 sentences: the specific task/feature/bug — concrete, not vague -->

## Where I Got To
<!-- What's done, what's partially done, what hasn't been started yet -->

## Immediate Next Step
<!-- The single most concrete next action — specific enough to act on without re-reading all the context -->
<!-- Good: "Add nil check in `cpo_token_service.rb:42` before calling `send_to_cpo`" -->
<!-- Bad: "Continue the work" -->

## Open Questions / Blockers
<!-- Anything unresolved needing a decision or investigation — omit if none -->

## Relevant Context
<!-- Key decisions, gotchas, important file paths, anything future-you will thank you for knowing -->
<!-- Omit anything re-derivable from reading the code or git log -->

## Git State
- Branch: <branch name>
- Uncommitted changes: <list files or "none">
- Open PRs: <list titles or "none">
```

## Step 4: Confirm to the user

Tell the user where the checkpoint was saved and briefly confirm the 3 most important things captured (branch, what's in progress, immediate next step). 3–4 lines max.

## Principles

- Write for someone with **zero memory of this session** — that person is future-you
- "Immediate Next Step" is the most important field — make it specific and actionable
- Ruthlessly omit anything re-derivable from reading the code or git log
- If the branch already has a checkpoint and no custom name was given, **always prompt** before overwriting — the user may have a parallel session running on the same branch
- Omit sections with nothing useful to say rather than writing filler