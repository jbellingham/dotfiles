# Codebase Documenter

Produce a structured, interlinked documentation suite for the current codebase. Output is written as multiple Markdown files to `<projectRoot>/.claude/documents/`, with one file per feature or architectural concept, linked together via a top-level index. The final step updates the project's `CLAUDE.md` to reference the index.

## Invocation

Triggered when the user asks to: "document the codebase", "map the architecture", "create a system overview", "document data flows", "analyse the system", or similar exploratory documentation requests.

Accepts optional scope arguments:
- `--features` – document feature files only (skip pure-architecture docs)
- `--flows` – include detailed data flow traces in each feature doc
- `--models` – include detailed data model docs
- `--arch` – document architecture concepts only (skip per-feature docs)
- No argument = full documentation suite (all document types)

## Document Structure

The output is a set of interlinked Markdown files:

```
<projectRoot>/.claude/documents/
├── INDEX.md                        ← top-level summary + routing document
├── architecture/
│   ├── overview.md                 ← layers, entry points, tech stack
│   ├── data-models.md              ← ERD + per-model detail
│   ├── background-processing.md    ← jobs, queues, scheduling
│   ├── external-integrations.md    ← third-party services and clients
│   └── <concept>.md               ← one file per significant arch concept
└── features/
    ├── <feature-name>.md           ← one file per top-level feature area
    └── ...
```

Each document links to related documents. Feature docs link to the architecture docs they depend on. Architecture docs link back to the features that use them.

## Process

Execute phases in order. Use parallel tool calls wherever steps are independent.

### Phase 1 — Orientation (always run)

1. Read `README.md`, `CLAUDE.md`, `.claude/CLAUDE.md`, and any top-level docs to understand the application's stated purpose and actors.
2. Inspect the root directory structure to identify the tech stack, package manager, and major top-level directories.
3. Identify the application type (Rails monolith, microservice, React Native app, Node API, etc.) from config files (`Gemfile`, `package.json`, `go.mod`, etc.).
4. Check whether `.claude/documents/` already exists. If it does, read `INDEX.md` (if present) to understand what was previously documented before overwriting.
5. Determine the `projectRoot` (the directory containing `.claude/`).

### Phase 2 — Architecture Discovery

Run these discovery steps in parallel where possible:

1. **Entry points**: Find all inbound surfaces — HTTP routes, GraphQL schema roots, WebSocket handlers, background job base classes, CLI commands, event consumers.
2. **Layers**: Identify architectural layers (controllers/resolvers → services/mediators → models/repos → external clients). Note which directories own each layer.
3. **Engines / bounded contexts**: List any Rails engines, npm workspaces, or modular packages and what each owns.
4. **External integrations**: Grep for third-party API clients, SDKs, and queue/pubsub connections.
5. **Background jobs**: Find job classes, queue names, and what triggers each job.
6. **Data models**: Read schema files and model definitions. Extract entity names, key fields, associations, and domain aggregate groupings.

### Phase 3 — Feature Discovery

1. Enumerate top-level feature areas from routes, controllers, GraphQL mutations/queries, and the README.
2. For each feature area, trace: entry point → primary service/handler → models touched → external calls → jobs enqueued.
3. Identify which architectural concepts each feature depends on (e.g., "Billing" depends on "External Integrations: Stripe" and "Background Processing: BillingJob").

### Phase 4 — Plan the Document Set

Before writing any files:

1. List all documents to be created: architecture docs and feature docs.
2. For each document, note which other documents it will link to (cross-references).
3. This plan forms the skeleton — build it mentally before writing Phase 5.

The minimum document set is:
- `INDEX.md` (always)
- `architecture/overview.md` (always)
- One `features/<name>.md` per discovered feature area
- Additional architecture docs only where the concept is substantial enough to warrant its own file (e.g., a complex job pipeline, a rich set of external integrations, a deep data model)

### Phase 5 — Write Documents

Write all files to `<projectRoot>/.claude/documents/`. Create directories as needed.

**Write order:** architecture docs first, then feature docs, then INDEX.md last (so all links are resolvable when writing the index).

For each document:
- Use the relevant template from `references/output-template.md`
- Every claim must be grounded in code found during discovery — no assumptions
- Include file paths for all referenced components (e.g., `app/services/billing_service.rb:42`)
- Use Mermaid `flowchart LR` or `erDiagram` for diagrams
- Flag anything that couldn't be fully traced as `> ⚠️ [NEEDS INVESTIGATION] <reason>`
- Link to related documents using relative Markdown links: `[Billing feature](../features/billing.md)`

### Phase 6 — Write INDEX.md

Write `<projectRoot>/.claude/documents/INDEX.md` using the index template from `references/output-template.md`.

The index must:
- Provide a 3–5 sentence plain-English description of what the system does
- Include the high-level architecture diagram (Mermaid)
- List all architecture documents with one-line descriptions and links
- List all feature documents with one-line descriptions and links
- Note the date generated and the git branch/SHA it was analysed from

### Phase 7 — Update CLAUDE.md

Read the project's `.claude/CLAUDE.md`. Append (or update if the section already exists) a `## System Documentation` section containing:

```markdown
## System Documentation

Architecture and feature documentation is maintained in `.claude/documents/`.
Start with [INDEX.md](.claude/documents/INDEX.md) to understand the system at a high level
and navigate to specific feature or architecture documents.

Reference these documents when:
- Building or modifying a feature — read the relevant feature doc first
- Tracing a data flow — check the feature doc's "Data Flow" section
- Understanding how components relate — start from the architecture overview
- Onboarding to the codebase — read INDEX.md then the architecture overview

Last generated: <YYYY-MM-DD> from branch `<branch>`.
```

If the project has no `.claude/CLAUDE.md`, create one with only this section.

### Phase 8 — Summary

Print to the conversation:
- The number of documents written and their paths
- Any `[NEEDS INVESTIGATION]` items that require follow-up
- A reminder that docs can be regenerated by re-invoking this skill

## Exploration Patterns

Refer to `references/exploration-patterns.md` for language/framework-specific grep patterns and glob expressions to locate entry points, models, and integrations during Phases 2–3.

## Quality Criteria

- Documents are self-contained enough to be useful in isolation, but linked so relationships are navigable.
- Every inter-document link uses a relative path and resolves correctly within `.claude/documents/`.
- No document exceeds ~400 lines — if a concept is larger, split it into sub-documents and link them.
- Feature docs always link to the architecture docs they depend on; architecture docs always back-link to features that use them.
- CLAUDE.md update is atomic: the section is either fully present or fully absent — never partial.
