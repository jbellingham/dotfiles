---
name: Bootstrap CLAUDE.md
description: Set up or refresh .claude/CLAUDE.md and .claude/rules/ for the current project by translating ~/.claude/PRINCIPLES.md into path-scoped rules for the detected stack.
argument-hint: [--dry-run]
---

Generate a slim `.claude/CLAUDE.md` plus a set of path-scoped `.claude/rules/` files for the current project. Rules content comes from two sources of equal weight:

1. **`~/.claude/PRINCIPLES.md`** — personal principles translated into idiomatic stack conventions
2. **Known best practices for the detected tech stack** — independently sourced from your training knowledge for each library, framework, and tool detected

Both sources are merged into each rules file. Anything from best practices that does not directly conflict with `PRINCIPLES.md` is included. Where a best-practice conflicts with a principle, the principle wins and the conflict is flagged in the summary.

Accepts optional argument:
- `--dry-run` — print all generated content to the conversation without writing any files

---

## Process

Execute phases in order. Use parallel tool calls wherever steps are independent.

### Phase 1 — Read Principles

Read `~/.claude/PRINCIPLES.md`. Hold its full content in context for Phase 3.

### Phase 2 — Detect Tech Stack and Directory Structure (run in parallel)

**Tech stack** — inspect config files:

| File | Indicates |
|------|-----------|
| `*.csproj` / `*.sln` | C#/.NET; check for ASP.NET Core, EF Core, xUnit, Moq, FluentAssertions |
| `Gemfile` | Ruby; check for Rails, RSpec, RuboCop, Dry::Monads |
| `package.json` | Node/JS; check for React, Vue, TypeScript, Vitest, Jest, Biome, ESLint |
| `go.mod` | Go |
| `pyproject.toml` / `requirements.txt` | Python; check for pytest, mypy, ruff |
| `Cargo.toml` | Rust |
| `pom.xml` / `build.gradle` | JVM (Java/Kotlin) |
| `mix.exs` | Elixir/Phoenix |

Also detect: test framework, linter/formatter, ORM/DB layer, API layer (REST/GraphQL/gRPC), state management library, CSS framework, auth library, background job system, migration tool.

**Directory structure** — scan the project root to identify:

| What to find | How |
|---|---|
| Source root(s) | Look for `src/`, `app/`, `lib/`, `api/src/`, `web/src/`, or equivalent |
| Test root(s) | Look for `test/`, `tests/`, `spec/`, `api/tests/`, `web/src/**/*.test.*` |
| Frontend root | Look for `web/`, `frontend/`, `client/`, or a `package.json` with a UI framework |
| Backend root | Look for `api/`, `server/`, `backend/`, or a server-side language project |
| Domain/feature layer | Look for `Features/`, `Domain/`, `app/models/`, `lib/` to scope DDD rules |
| Test file pattern | Identify the file naming convention: `*.test.ts`, `*_spec.rb`, `*Tests.cs`, `*_test.go` |
| Config/infra files | Look for `Dockerfile`, `docker-compose.yml`, CI config (`.github/workflows/`, `.gitlab-ci.yml`), deployment manifests |

Record the actual directory paths found — these become the `paths` frontmatter values in the rules files.

### Phase 3 — Plan Rules Files

Before writing any content, decide which rules files are needed.

**Standard rules files** (create if the layer exists in the project):

| Rules file | Paths frontmatter | Content |
|---|---|---|
| `backend.md` | All backend source files (e.g. `api/**/*.cs`, `src/**/*.go`) | Architecture, code conventions, null safety, error handling, logging, doc comments |
| `ddd.md` | Domain/feature layer only (e.g. `api/src/Features/**/*.cs`, `app/models/**/*.rb`) | Rich models, aggregates, value objects, domain events — only if DDD is applicable |
| `testing-backend.md` | Backend test files (e.g. `api/tests/**/*.cs`, `spec/**/*_spec.rb`) | TDD cycle, test design rules, framework seams, anti-patterns, naming |
| `frontend.md` | Frontend source files (e.g. `web/src/**/*.{ts,vue,tsx}`, `src/**/*.{ts,tsx}`) | Import conventions, component patterns, state management, API call patterns, form validation, UX patterns, accessibility |
| `testing-frontend.md` | Frontend test files (e.g. `web/src/**/*.test.ts`, `src/**/*.test.{ts,tsx}`) | TDD cycle, testing-library usage, real stores, accessible queries |

**Propose new rules files** for any detected layer that does not fit the standard categories. Examples:

| Detection signal | Proposed rules file | Suggested paths |
|---|---|---|
| `Dockerfile` / `docker-compose.yml` | `infrastructure.md` | `Dockerfile`, `docker-compose*.yml`, `.github/workflows/**` |
| GraphQL schema files | `graphql.md` | `**/*.graphql`, `**/schema/**` |
| Prisma / Drizzle / TypeORM | `database.md` | `prisma/**`, `drizzle/**`, `**/migrations/**` |
| Terraform / Pulumi | `infrastructure.md` | `*.tf`, `pulumi/**` |
| Native mobile (React Native, Flutter) | `mobile.md` | `src/**/*.{tsx,dart}` (adjust to project) |
| Background jobs layer | `jobs.md` | `app/jobs/**`, `workers/**` |
| CLI commands layer | `cli.md` | `cmd/**`, `bin/**`, `lib/tasks/**` |

For each proposed new file: state the file name, the inferred `paths:` scope, and a one-line rationale. Ask the user to confirm before creating it. If the user declines, absorb the content into the closest existing file or CLAUDE.md as appropriate.

`.claude/CLAUDE.md` is always loaded and holds all general instructions. Rules files in `.claude/rules/` must have a `paths:` frontmatter — never create a rules file without paths, as that duplicates `CLAUDE.md`'s role.

### Phase 4 — Gather Best Practices Per Layer

For each detected layer (backend, frontend, testing, domain, and any new layers identified in Phase 3), independently recall known best practices for the specific libraries and frameworks detected. This is separate from PRINCIPLES.md — draw from your training knowledge.

For each layer, produce an annotated list of best practices. Mark each one:
- `[PRINCIPLES]` — sourced from or already covered by PRINCIPLES.md
- `[BEST PRACTICE]` — from training knowledge, not in PRINCIPLES.md
- `[CONFLICT]` — contradicts a principle (principle wins; flag in summary)

Focus on actionable, project-specific guidance. Skip generic programming advice that applies to any language.

**Best practice areas to consider by stack (non-exhaustive — apply judgement):**

#### ASP.NET Core / .NET
- Minimal API vs controller conventions; route attribute patterns
- `IOptions<T>` pattern for configuration; never read `IConfiguration` directly in handlers
- `CancellationToken` threading through async call chains
- `HttpClient` via `IHttpClientFactory` — never `new HttpClient()`
- Problem Details (`IProblemDetailsService`) for error responses
- Health checks (`/health`) and readiness probes
- EF Core: `AsNoTracking()` for read-only queries; explicit transactions for multi-step writes
- .NET Aspire: service discovery, resource registration patterns

#### Vue 3 / Vite
- `<script setup>` with `defineProps` / `defineEmits` / `defineExpose`
- `v-model` with component `modelValue` prop + `update:modelValue` emit pattern
- `watchEffect` vs `watch` — when each is appropriate
- `shallowRef` / `shallowReactive` for large objects that don't need deep reactivity
- Async components with `defineAsyncComponent` and `<Suspense>`
- `useTemplateRef` (Vue 3.5+) over `ref` for DOM refs
- Vite env variables (`import.meta.env.VITE_*`) — never `process.env`
- Route guards in Vue Router: `beforeEach` for auth, `beforeRouteEnter` for per-route data

#### TypeScript
- `satisfies` operator for type-safe literal objects without widening
- Discriminated unions over optional fields for variant types
- `const` assertions for literal inference
- Template literal types for string validation
- `unknown` over `any` for external data; narrow before use
- Avoid enums — use `const` objects with `as const` and infer the union type

#### xUnit / .NET Testing
- `[Fact]` for single-case tests, `[Theory]` + `[InlineData]` / `[MemberData]` for parameterised
- `IClassFixture<T>` for shared setup; `IAsyncLifetime` for async setup/teardown
- FluentAssertions: prefer `Should().Be()` chains over `Assert.*`; use `.BeEquivalentTo()` for deep object comparison
- Test project references: never reference the host project's DI container — test the handler directly

#### Vitest / Testing Library
- `userEvent` over `fireEvent` — simulates real browser interaction sequences
- `screen.getByRole` as primary query; `getByLabelText` for form inputs; `getByText` as fallback
- `waitFor` / `findBy*` for async assertions — never `setTimeout` in tests
- `vi.useFakeTimers()` / `vi.useRealTimers()` pair — always restore in `afterEach`
- Mock at the module boundary (`vi.mock('@/api/client')`), not inside composables

#### Rails
- `strong_parameters` in controllers; never `params.permit!`
- `before_action` for auth checks; avoid business logic in callbacks
- Scopes on models for reusable query fragments; never raw SQL in controllers
- `render json: { errors: ... }, status: :unprocessable_entity` for validation failures
- `Rails.cache` with explicit expiry; avoid N+1 with `includes`/`eager_load`

#### PostgreSQL / SQL
- Migrations: never drop a column in the same migration that removes code using it — two-phase: remove code first, drop column later
- Add indexes for all foreign keys and frequently-filtered columns
- Use `CHECK` constraints in the DB for enum-like columns, not just application validation
- Prefer `JSONB` over `JSON`; index JSONB with GIN when querying inside the column

#### Docker / CI
- Multi-stage builds: separate builder and runtime stages; never include dev dependencies in the final image
- Pin base image versions; avoid `:latest`
- CI: lint and type-check before running tests; fail fast
- Secrets: never `COPY .env` into an image; use build args or runtime env injection

### Phase 5 — Map Principles to Stack

For each principle in `PRINCIPLES.md`, determine:
1. The idiomatic stack-specific expression
2. Which rules file it belongs in

**Principle-to-stack mappings:**

#### Null Safety
| Stack | Expression |
|-------|-----------|
| C#/.NET | `<Nullable>enable</Nullable>` on; `FirstOrDefault()` + explicit null-check; never propagate null silently |
| Ruby/Rails | `find_by!` + rescue when absence is unexpected; `find_by` + explicit nil-check when absence is valid |
| TypeScript | strict null checks; `?? throw` or explicit guards; no `!` non-null assertions |
| Go | always check `err != nil`; never `_` an error return |
| Python | `Optional[T]` with explicit `None` checks; `dict.get(key)` with a default |
| Elixir | pattern match on `{:ok, v}` / `{:error, r}`; never let nil flow implicitly |

#### Result/Either Pattern
| Stack | Expression |
|-------|-----------|
| C#/.NET | `FluentResults` or a custom `Result<T>`; throw on unexpected failure for simple CRUD |
| Ruby | `Dry::Monads` with `do` notation; `Success(v)` / `Failure(r)` from service methods |
| TypeScript | `neverthrow` or `{ ok: true, value } / { ok: false, error }` discriminated union |
| Go | multiple return `(value, error)`; `fmt.Errorf("context: %w", err)` |
| Rust | `Result<T, E>` with `?` operator |
| Elixir | `{:ok, value}` / `{:error, reason}` tuples |

#### Testing — Real Objects
| Stack | Expression |
|-------|-----------|
| C#/.NET | in-memory SQLite via EF Core; Moq only for `UserManager<T>`, `SignInManager<T>`, and infrastructure failures |
| Ruby/Rails | `use_transactional_fixtures`; real AR records; `ActiveJob::TestAdapter` / `ActionMailer::TestAdapter` are already seams — no stub needed |
| TypeScript/Node | real in-memory implementations; `vi.spyOn(axios, ...)` only for HTTP boundaries |
| Python | `pytest-django` with `@pytest.mark.django_db`; mock only at network boundaries |
| Go | table-driven tests with real structs; `httptest.NewRecorder` for HTTP handlers |

#### Structured Logging
| Stack | Expression |
|-------|-----------|
| C#/.NET | Serilog message templates — `Log.Information("User {UserId}", id)` — never interpolation |
| Ruby/Rails | `Rails.logger.info("message", { key: value })` |
| TypeScript/Node | `logger.info({ key: value }, "message")` (pino/winston) |
| Go | `slog.Info("message", "key", value)` |
| Python | `logger.info("message", extra={"key": value})` |

#### Documentation
| Stack | Convention |
|-------|-----------|
| C#/.NET | `/// <summary>` XML doc comments on all public types and methods |
| Ruby | RubyDoc (`# @param`, `# @return`) on all public methods |
| TypeScript | JSDoc (`/** ... */`) on all exported functions and types |
| Python | Docstrings on all public functions/classes (Google or NumPy style) |
| Go | GoDoc (`// FuncName does...`) on all exported symbols |
| Elixir | `@doc` and `@spec` on all public functions |

#### DDD
| Concept | C#/.NET | Ruby/Rails | TypeScript/Node | Go |
|---------|---------|-----------|-----------------|-----|
| Rich models | methods on entity/aggregate classes, not in handlers | behaviour on AR/plain Ruby models, not service objects | methods on domain classes, not in controller/service | methods on domain structs, not service functions |
| Aggregates | EF Core aggregates via navigation with controlled access | `has_many` with controlled access; expose mutation methods on root | root class owns mutations to children | root struct exposes methods; child structs unexported or returned by value |
| Value Objects | C# `record` or `record struct` with value equality | frozen plain Ruby structs with `==` by content | `readonly` class with structural equality; no ID field | small struct with no ID; compared by value |
| Domain Events | MediatR `INotification` published after aggregate mutation | plain Ruby objects dispatched via publisher after mutation | plain TS objects emitted via EventEmitter/mediator after mutation | plain Go structs returned from domain methods, dispatched by caller |

### Phase 6 — Compose the Output Files

Merge PRINCIPLES.md mappings (Phase 5) and best practices (Phase 4) into each rules file. For items with overlap, write one combined rule — do not duplicate.

#### 6a — `.claude/CLAUDE.md` (always loaded — general instructions)

```markdown
# <Project Name> — Claude Instructions

## Overview
<One sentence: what the project is and its primary stack.>

## Quick Commands
\`\`\`bash
<lint command>
<test command>
<build command>
<any other key commands>
\`\`\`

## Critical Rules
1. Run `<lint>` and `<test>` after every change — no exceptions.
2. Never suppress a linter warning or compiler error without asking first.
3. TDD is mandatory — use the `tdd` skill before writing any production code, including in subagents.
4. <doc comment rule for this stack>

## Project Structure
\`\`\`
<source root>    # application code
<test root>      # tests
\`\`\`

## Working Philosophy
- **Plan before implementing**: for non-trivial tasks (3+ steps or architectural decisions), plan first; aim for the thinnest slice. If blocked, stop and re-plan.
- **Understand before implementing**: when debugging, trace the root cause before writing any code.
- **Minimal changesets**: only change what is needed; no unrelated refactoring.

## Path-Scoped Rules
<Table listing each rules file, its paths, and what it covers — so readers know where to look.>
```

#### 6b — `backend.md` (scoped to backend source files)

Include from both sources:
- Architecture overview (vertical slices / MVC / module structure — whatever applies)
- Code conventions: null safety, functional style, null object pattern, collections never null, constructors, getters/setters, result pattern, structured logging
- Framework-specific best practices (e.g. EF Core `AsNoTracking`, `IHttpClientFactory`, `IOptions<T>`, `CancellationToken` propagation for .NET)
- Decision checklist
- Doc comment convention
- Post-implementation checklist (DI registration, migrations, seed data — adapt to stack)

#### 6c — `ddd.md` (scoped to domain/feature layer — omit if not applicable)

Include: rich models, aggregates, value objects (with typed IDs example), domain events, decision checklist. Use concrete before/after code examples.

#### 6d — `testing-backend.md` (scoped to backend test files)

Include from both sources:
- TDD cycle (Red → Green → Refactor, one test at a time)
- Core rules (behaviour not implementation, real objects, assert outcomes)
- Framework seams specific to this stack
- Framework-specific test patterns (e.g. `[Theory]`/`[InlineData]`, `IClassFixture`, FluentAssertions for .NET; `pytest.mark.parametrize` for Python)
- Tautological test anti-pattern with a concrete example
- Legitimate stubs guidance
- Naming convention
- At least one ✅ correct and one ❌ incorrect example

#### 6e — `frontend.md` (scoped to frontend source files — omit if no frontend)

Include from both sources:
- Import path conventions
- Component patterns, file naming, file order, props/emits conventions
- State management patterns
- API call patterns and error handling
- Form validation, submit UX (disable while in flight, inline errors, success feedback)
- Loading, empty, and error state requirements
- Async data patterns
- Navigation conventions
- Accessibility requirements (WCAG 2.1 AA baseline)
- Framework-specific best practices (e.g. `v-model` with `modelValue`, `useTemplateRef`, Vite env vars for Vue; `satisfies` operator, discriminated unions for TypeScript)
- Type safety rules

#### 6f — `testing-frontend.md` (scoped to frontend test files — omit if no frontend)

Include from both sources:
- TDD cycle
- Framework seams (what's real vs what needs stubbing)
- Accessible query rules (role → label → text hierarchy; never testId)
- Framework-specific patterns (e.g. `userEvent` over `fireEvent`, `findBy*` for async, `vi.useFakeTimers()` for Vitest)
- Naming convention
- Examples

#### 6g — Additional rules files (from Phase 3 proposals confirmed by user)

For each confirmed new file, include all relevant best practices from Phase 4 for that layer.

### Phase 7 — Check Existing Files and Write

**If `--dry-run`**: print all generated content to the conversation. Do not write any files.

**Otherwise**, for each file:

1. Check if `.claude/rules/` exists; create it if not.
2. For each rules file and for `.claude/CLAUDE.md`:
   - **Does not exist** → write it directly.
   - **Exists** → perform a gap analysis:
     a. Read the existing file.
     b. Identify: (i) principles in `PRINCIPLES.md` missing or outdated in the existing file, (ii) best practices for the detected stack not yet in the file, (iii) anything that contradicts current principles.
     c. Present proposed changes as a diff or bulleted list — **do not write yet**.
     d. Ask the user to confirm.
     e. On confirmation, apply targeted edits (prefer edits over full rewrites).

### Phase 8 — Summary

Report:
- Stack and directory structure detected
- Path scopes inferred for each rules file
- New rules files proposed (and whether confirmed or declined)
- Files written or proposed (or `--dry-run` note)
- Any principles with no idiomatic mapping, flagged `⚠️ [NEEDS MAPPING]`
- Any best practices that conflicted with PRINCIPLES.md, flagged `⚠️ [CONFLICT — principle wins]`
