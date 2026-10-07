---
name: todo-to-backlog
description: Use when the user asks to process, promote, or move entries from TODO.md into Linear as structured issues
---

# todo-to-backlog

Read raw bullets from `docs/TODO.md`, create a Linear issue for each one, then clear the file.

## Linear Workspace

- **Team:** Chronicle
- **Labels available:** Bug, Feature, UX & Identity, Goals, Coverage, Capture, AI, Infrastructure, Technical
- **MCP tool:** `mcp__plugin_linear_linear__save_issue`

## Category Assignment

Pick the single most relevant category label for each issue.

| Topic signals | Label |
|--------------|-------|
| Broken behaviour, errors, crashes, regressions | _(no category — Bug label only)_ |
| Navigation, layout, visual design, labels, UX flow | `UX & Identity` |
| Goals, criteria linking | `Goals` |
| Coverage display, strength indicators | `Coverage` |
| Work log entry, quick capture, forms | `Capture` |
| AI drafting, critique, quality | `AI` |
| Deployment, CI/CD, hosting | `Infrastructure` |
| Code quality, testing, architecture, performance, auth | `Technical` |

## Issue Fields

For each bullet, derive:

| Field | How to set it |
|-------|--------------|
| **title** | Short imperative phrase — solution-framed, not complaint-framed ("Fix pointer cursor" not "Cursor doesn't change") |
| **description** | User story in Markdown: `As a [user/developer], I want [goal] so that [benefit].` followed by a `**Acceptance criteria:**` block with 2–5 concrete, testable bullets |
| **labels** | Bug issues: `["Bug"]`. Non-bug issues: `["<Category>"]`. A bug that clearly belongs to a category: `["Bug", "<Category>"]` |
| **state** | `"Todo"` for bugs and active stories; `"Backlog"` for speculative / low-priority items |
| **team** | `"Chronicle"` |

### Deciding Bug vs Feature

- **Bug** — the feature exists and is broken (wrong behaviour, missing visual affordance, unexpected error)
- **Feature / Todo** — the feature doesn't exist yet or needs to be built

### Deciding Todo vs Backlog

- **Todo** — concrete, actionable, clearly scoped
- **Backlog** — speculative, depends on other work, or intentionally deferred

## Process

1. Read `docs/TODO.md`.
2. If the file is empty, stop and tell the user there is nothing to process.
3. For each bullet, create one Linear issue using `mcp__plugin_linear_linear__save_issue` with the fields above.
4. Create issues in parallel where possible (independent bullets have no ordering dependency).
5. After all issues are created successfully, clear `docs/TODO.md` (overwrite with empty content — do not delete the file).
6. Report back: list each created issue with its Linear ID and title.

## Common Mistakes

- **Complaint-framed titles**: name the solution, not the symptom.
- **Vague acceptance criteria**: "works correctly" is not a criterion — name the observable outcome.
- **Wrong state**: bugs go to `"Todo"`, not `"Backlog"`.
- **Forgetting to clear TODO.md**: always clear after all issues are successfully created.
- **Wrong role**: `user` for user-facing behaviour; `developer` for invisible infrastructure work.
