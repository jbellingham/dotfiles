---
name: route-feedback
description: Use when the user corrects or redirects Claude mid-session — before saving any feedback to memory. Routes broadly applicable feedback to rule files instead of memory; asks the user before creating new rule files.
---

# Route Feedback

Route corrections and mid-session redirects to the right destination: rule files for broadly applicable patterns, memory only for project-specific or one-off feedback.

## Decision Flow

```
Feedback received
      │
      ▼
Does it apply broadly to a file type or editing context?
      │
   Yes│                    No│
      ▼                      ▼
Does a .claude/rules/ file   Save to memory as usual
already cover that scope?
      │
   Yes│                    No│
      ▼                      ▼
Add to that rule file    Ask the user: "This seems like
(no memory entry)        a new rule for [scope]. Create
                         one before proceeding?"
                               │
                    User says yes│   User says no│
                               ▼               ▼
                         Create rule file  Save to memory
```

## Steps

### 1. Classify the feedback

Ask: would this apply to **anyone editing `[file type]` in this project**, or is it specific to this one task/output?

- "Always use PascalCase for .NET backend directories" → broadly applicable to `api/**/*.cs` context
- "Only add RubyDoc to public methods, not private ones" → broadly applicable to `app/**/*.rb` and `engines/**/app/**/*.rb`
- "Don't use `getByTestId` in frontend tests" → broadly applicable to `web/src/**/*.test.ts`
- "In this PR description, don't mention X" → one-off, save to memory

### 2. Check for a matching rule file

Look for `.claude/rules/` in the current project. Match the feedback's scope to the `paths:` frontmatter of existing rule files. Common patterns by stack:

| Feedback applies to | Look for rule file with paths |
|---|---|
| Rails backend source | `app/**/*.rb`, `engines/**/app/**/*.rb` |
| Rails engine source | `engines/**/app/**/*.rb` |
| Rails specs | `spec/**/*`, `engines/**/spec/**/*` |
| .NET backend source | `api/**/*.cs` |
| .NET domain layer | `api/src/Features/**/*.cs` |
| .NET backend tests | `api/tests/**/*.cs` |
| Frontend source | `web/src/**/*.{ts,vue,tsx}` |
| Frontend tests | `web/src/**/*.test.ts` |

Infer the stack from the current project's file structure if it isn't obvious from the feedback itself.

If no `.claude/rules/` directory exists, treat it the same as having no matching rule file — proceed to Step 4 to ask the user whether to create one (which will also create the directory).

### 3. Route to rule file

**If a matching rule file exists:** add the feedback as a concise rule under the most relevant section. Do not create a memory entry.

Format in the rule file:
```markdown
- **[Short rule name]**: [concrete instruction]. [Why — one sentence if non-obvious.]
```

### 4. Route to new rule file (ask first)

**If no matching rule file exists for the scope:** stop and ask:

> "This feedback applies broadly to `[inferred glob]` files. Should I create a new `.claude/rules/[name].md` for it before continuing?"

If the user confirms, create the rule file with correct `paths:` frontmatter, add the rule, then continue.

If the user declines, save to memory as a feedback entry.

### 5. Fall back to memory

Save to memory when the feedback is:
- Specific to the current task, PR, or output (not reusable)
- About Claude's response style, tone, or communication (not code)
- Already covered by an existing rule (no duplicate needed)
- The user explicitly wants it in memory

## What NOT to put in rules

- One-off corrections that won't recur
- Feedback that restates what the code/framework already enforces
- Personal preferences about Claude's tone or verbosity (those belong in global CLAUDE.md or memory)

## Examples

**Rails project** — User says: "Only add RubyDoc to public methods, not private ones."

1. Applies broadly to Rails backend source ✓
2. `rules/backend.md` exists with `paths: app/**/*.rb, engines/**/app/**/*.rb` ✓
3. Add to `rules/backend.md` under Code Conventions:
   ```markdown
   - **RubyDoc**: add `# @param`/`# @return` to all **public** methods only; omit on private and protected members.
   ```
4. No memory entry created.

---

**.NET project** — User says: "Don't add XML doc comments to private methods — only public ones."

1. Applies broadly to backend C# files (`api/**/*.cs`) ✓
2. `rules/backend.md` exists with `paths: api/**/*.cs` ✓
3. Add to `rules/backend.md` under Code Conventions:
   ```markdown
   - **XML doc comments**: `/// <summary>` on all **public** types and methods only; omit on private members.
   ```
4. No memory entry created.
