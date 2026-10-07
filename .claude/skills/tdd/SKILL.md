---
name: tdd
description: Use when implementing any feature or bug fix — before writing any production code. Triggers on "write a test for X", "add this using TDD", "red-green-refactor", or when the user describes acceptance criteria or a failing test. Enforces the Red-Green-Refactor cycle strictly, one test at a time.
---

# TDD Workflow

One failing test → least code that passes it → refactor → repeat.

You already know the cycle. What follows is only the places where the correct move differs from the one that will feel natural, plus the project-specific bits you can't infer. Nothing else belongs in here.

## What each step actually requires

**Red.** One test. Run it. It must fail on the **assertion** — a NoMethodError, load error, or syntax error is not red, it's a test that hasn't run yet. Do not write the next test.

**Green.** The least code that passes *this* test. If you're writing something no current test asks for, stop and let the next red demand it.

**Refactor.** Green is the entry to this step, not the exit from the cycle. Every cycle: fix naming and duplication in what you just wrote. At a **logical-unit boundary** — the behaviour you were asked for is complete and its whole suite is green, not after each individual test — invoke `code-smell-detector` on the unit, then the `superpowers:requesting-code-review` skill. Act on their naming and duplication findings directly. Do **not** act on extraction suggestions — list them (what comes out, what it'd be called, what it buys) and workshop them. No new behaviour in this step.

## Where you'll defect

| The thought | The correction |
|---|---|
| "The implementation is obvious, I'll write the test after" | A test written after describes what the code does, not what it should do. The design signal is the whole point. |
| "I'll write the full spec file, then implement" | Batching skips the loop that shapes each next step. One test, green, then the next. |
| "The assertion is nearly right, I'll just adjust the expected value" | The most common way TDD fails silently. See the next section before you touch it. |
| "It's green, moving on" | Green means the refactor step is now safe, and it's the only moment it is. |
| "It passed first try — good" | Not good, unknown. Either the behaviour already existed or the test doesn't exercise it. Break the production code, watch it go red, restore it. |
| "This will obviously fail, no need to run it" | Then you don't know it fails for the *right reason*, which is the only thing red proves. |
| "Too simple to test" | Simple code breaks, and the test costs 30 seconds. |
| "I'll refactor first, then write the test" | Refactoring without a green suite is just editing. |
| "I need to see the shape of the code before I can test it" | That's the design step. The test is how you find the shape. |

## Fixing a test's assumption vs. weakening it

Both look like editing the test. The tell is **where the new expected value came from**:

- **From the ticket, the domain, the API contract, or a wrong factory setup** → legitimate. The test encoded a false assumption; correct it and keep the assertion just as strict.
- **From the failure output** → weakening. You've written down what the code happens to do and relabelled it the spec.

If you can't state the expected value without looking at the actual, the production code is what's wrong.

## Before declaring done

- Run the full suite, not just the file you touched.
- Changed a method name, signature, or constant? Grep `spec/` **and** `engines/**/spec/` for every reference.
- Baseline a "pre-existing" failure against the **merge-base**, not the branch tip — a branch-tip baseline hides regressions the branch itself introduced.
- Any test asserting an *absence* (cleanup ran, item excluded, no row written): confirm it fails when the behaviour is disabled. Otherwise its precondition may be established by something else entirely.

## Test level

Unit by default. Integration when the wiring is the risk (HTTP boundary, repository, validation edge). E2E only when a top-level journey has no coverage at all, or an incident showed unit + integration green while the assembled system was broken. **Not** because the feature is important.
