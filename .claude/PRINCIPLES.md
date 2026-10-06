# Development Principles

Language-agnostic principles applied to every project. A project's `CLAUDE.md` should express these as idiomatic conventions for that stack.

---

## Working Philosophy

- **Plan before implementing**: for any non-trivial task (3+ steps or architectural decisions), plan first; capture edge cases; aim for the thinnest slice of work. If blocked mid-task, stop and re-plan rather than pushing through.
- **Understand before implementing**: when debugging, trace the root cause before writing any code. Do not implement until explicitly asked.
- **Minimal changesets**: only change what is needed for the current task; no unrelated refactoring or cleanup.
- **Bug fixing**: when given a bug report with logs or failing tests, diagnose and fix autonomously — minimise check-ins.
- **User stories**: slice for end-to-end value, not technical concern; default to a single lean story.

---

## Code Quality

- **Null safety**: check for null/nil explicitly at boundaries; never let null propagate unexpectedly through the call stack.
- **Explicit over implicit**: no hidden callbacks, mixins, or side effects; inject collaborators; make control flow obvious.
- **Composition over inheritance**: single-responsibility objects that collaborate; extract collaborators rather than layering concerns onto one class/module.
- **No side-effect callbacks**: do not use lifecycle hooks (e.g. `after_save`, `after_create`) for side effects. Use explicit commands or event handlers instead.
- **Functional style**: prefer pure functions, minimal mutation, and immutability where practical. Avoid shared mutable state.
- **Null Object pattern over null returns**: when a method might return "nothing", consider returning a Null Object — an inert implementation of the expected type — rather than null. Callers can use the result unconditionally without guards, removing a whole category of null-check boilerplate. Use it when the absent case has a natural do-nothing or empty behaviour; use explicit null/Optional when absence is an error or a decision the caller must make.
- **Collections are never null**: a collection is either empty or populated — never null. Returning null from a collection method forces every caller to null-check before iterating, spreading defensive boilerplate across the codebase and creating a class of bugs that simply should not exist. Initialise collection fields at declaration or in the constructor; return empty collections from methods and repositories. This makes iteration always safe and null checks unnecessary at call sites.
- **Constructors produce valid objects**: a constructor must initialise every field required for the object to be in a consistent, usable state. An object that needs a sequence of setter calls before it is "ready" is not an object — it is a data bag waiting to be misconfigured. Prefer constructor injection or a named factory method over post-construction mutation.
- **Getters and setters require justification**: a public setter is a signal that external code is deciding what the object should contain — a likely violation of Tell Don't Ask. Before adding one, ask whether the caller should be *telling* the object to do something instead. Read-only properties (getters) are fine for exposing state that collaborators legitimately need to observe; write properties should be rare and deliberate.
- **Structured logging**: always log with structured key-value pairs — never string interpolation. Log at boundaries and significant state transitions.

---

## Error Handling

- **Result/Either pattern**: use a typed `Success`/`Failure` (or `Ok`/`Err`) return value for all public service/command methods.
- **Railway-Oriented Programming**: for 5+ chained failable operations, use monadic `do`-notation or equivalent to short-circuit on failure without nested conditionals.
- **Simple CRUD exception**: do not apply Result pattern to simple, non-failable reads or writes — use exceptions for genuinely unexpected conditions.

---

## Decision Checklist (before writing code)

1. Can this fail with null in production? → add explicit null checks
2. Does this class/module do more than one thing? → extract collaborators
3. Does this operation have 5+ failable steps? → use Result/Railway pattern
4. Is this query complex or reused? → extract to a Query Object or custom hook

---

## TDD

1. Write failing test first (Red)
2. Write minimal code to pass (Green)
3. Refactor if needed
4. Run full test suite before finishing
- **One test at a time**: write and validate a single test before writing the next. Do not write an entire test class in one pass — each test must be confirmed green before moving on.

---

## Test Design (classicist/Detroit school)

- **Prefer real objects**: use test doubles only at genuine system boundaries (external I/O, network, time). Isolated in-process infrastructure (e.g. in-memory DB, test job queues) is not a boundary — use it.
- **Know your framework seams**: many frameworks already intercept external calls in test mode (job queues, mailers, HTTP clients). Check before adding a stub on top of an existing seam — it is redundant and hides real failures.
- **Avoid tautological tests**: if the expected output is derived entirely from values declared in the stub setup, there is no independent oracle. The test can only fail if the stub is misconfigured, not if the production code regresses. Use real data so expected values come from the system, not the test author.
- **Legitimate stubs**: manufacturing specific infrastructure failures (DB errors, network timeouts) is impractical with real objects — stub the boundary to return a controlled failure for those contexts only, and document why.
- **Error path stubs differ from happy path stubs**: stubbing to simulate a failure condition is appropriate; stubbing to avoid real in-process infrastructure on the happy path usually is not.
- **Fix test assumptions first**: do not change production code to make tests pass unless the production code is actually buggy.
- **Exhaustive reference search**: when updating a changed constant/method, grep the entire codebase (including test directories) for ALL references before declaring done.

---

## Test Pyramid

- **Unit tests are the foundation**: the majority of tests should be fast, focused unit tests that exercise a single class or function in isolation. They give immediate feedback, run in milliseconds, and pin domain logic precisely. Prefer many small unit tests over fewer broad ones.
- **Integration tests for seams**: a smaller number of integration tests verify that components wire together correctly — HTTP handlers return the right status codes, repositories persist and retrieve correctly, validation rejects bad input at the boundary. These are slower; write them for seams, not for logic already covered by unit tests.
- **End-to-end tests for key user journeys only**: E2E tests are expensive to write, slow to run, and brittle under UI churn. Keep the suite small and stable by covering only the journeys a real user would consider critical — the paths where a silent failure would be a serious problem (e.g. sign-in, completing the primary happy path, a critical destructive action). Do not write E2E tests to cover logic; write them to prove the assembled system works for a human.
- **When to add a new E2E test**: add one when (a) a new top-level user journey is introduced that has no existing coverage, or (b) a production incident revealed that unit and integration tests passed while the assembled system was broken. Do not add one because a feature is important — importance is covered by unit tests. The trigger is *assembly risk*, not *business value*.
- **Slow tests belong at the top**: if a test requires a running server, a real browser, or an external process, it lives in the E2E suite — not smuggled into the unit or integration layer where it inflates cycle time.

---

## Linting and Static Analysis

- **Run linter after every change**: no exceptions.
- **Never disable a linter rule without asking**: violations indicate a code smell to fix, not a rule to suppress.

---

## Domain-Driven Design

- **Rich domain models**: put behaviour on domain objects — not on services or controllers. An `Order` should be able to `Place()`, `Cancel()`, and `ApplyDiscount()` itself; a service should orchestrate, not contain logic the domain object could own.
- **Anemic models are a smell**: if your domain classes are bags of properties with no methods, business rules have leaked into the application or service layer. Pull them back.
- **Aggregates enforce invariants**: choose an Aggregate Root that owns the consistency boundary. All mutations to related objects must go through the root; never reach inside and modify child entities directly.
- **Ubiquitous language**: name classes, methods, and variables using the domain's vocabulary — not technical synonyms. Code should read like the domain expert's prose.
- **Bounded Contexts isolate models**: the same word (`User`, `Product`) may mean different things in different sub-domains. Prefer explicit context boundaries over a single shared model that tries to satisfy everyone.
- **Domain events for side effects**: use domain events (or explicit commands) to cross bounded-context or aggregate boundaries — never reach across with direct calls.
- **Value Objects for concepts without identity**: model quantities, money, addresses, and similar concepts as immutable Value Objects rather than entities. Equality is by value, not by reference or ID. Avoid primitive obsession — a raw `string` for email or `int` for a user ID lets the compiler silently accept transposed arguments (e.g. `SendInvoice(userId, customerId)`) and scatters validation across the codebase. Extract into a named type and push validation and behaviour onto it. Rule of thumb: if a primitive has (a) a validation rule, (b) domain behaviour, or (c) appears as a meaningful concept in more than one place, it deserves its own type.

---

## Documentation

- **Document public API**: add doc comments (RubyDoc, JSDoc, docstrings, etc.) to all public methods/functions.
- **Omit inferable comments**: do not add comments that restate what the signature or body already make obvious.
