# Planner Mode Guide

This guide covers how to explore a codebase, construct a high-quality implementation plan, and execute changes safely and sequentially.

Planner mode is explicitly technical. File paths, function signatures, data types, component names, and architectural patterns are all expected and required. The audience for the plan is the user (a developer or technical stakeholder) who needs to understand, verify, and approve what will be built before a single line of code changes.

---

## Phase 2 in Detail: Codebase Exploration

Never skip this phase. A plan built without exploring the codebase is a plan built on guesses. Guesses cause regressions.

### What to Look For

**Project Structure**
Start broad. Understand the top-level layout before diving into specifics.
- What are the main directories? (e.g. `src/`, `app/`, `lib/`, `components/`, `services/`, `api/`, `tests/`)
- What framework and language is this? (infer from file extensions, package files, config files)
- Is this a monorepo? Are there multiple apps or packages?
- Where are the entry points? (e.g. `main.ts`, `App.tsx`, `index.js`, route files)

**The Affected Area**
Search specifically for the feature or behaviour described in the ticket.
- Search by the terms used in the ticket — screen names, feature names, business entities
- Look for existing files that implement the nearest similar thing — this is your pattern reference
- Identify the component/service/module hierarchy relevant to this change

**Existing Patterns**
The goal is to produce a plan that fits the codebase, not one that introduces new patterns unnecessarily.
- How are similar features structured? Follow those structures.
- How is state managed? (local state, context, Redux, Zustand, etc.)
- How are API calls made? (fetch, axios, react-query, custom hooks, etc.)
- How is error handling done?
- How are forms built and validated?
- How is navigation / routing handled?
- How are types/interfaces defined and shared?

**Data and Types**
- What types or interfaces represent the entities this ticket touches?
- Where are those types defined?
- What shape does the data come in from the backend (if readable)?

**Tests**
- Where do tests live? (`__tests__/`, `*.test.ts`, `*.spec.ts`, `cypress/`, etc.)
- What testing library is used? (Jest, Vitest, React Testing Library, Cypress, Playwright, etc.)
- Are there existing tests for the area being changed? Read them — they tell you the expected behaviour and will need updating.

### Exploration Tools to Use

- `Glob` — find files by pattern (e.g. `**/*.tsx`, `**/auth/**`, `**/*password*`)
- `Grep` — search for specific terms, function names, or identifiers across the codebase
- `Read` — read specific files once located
- `Bash` — run `ls`, directory listings, or quick searches if needed

Work from broad to narrow:
1. List the top-level structure
2. Find the most relevant directory or module
3. Read the key files in that area
4. Search for specific terms from the ticket across the wider codebase
5. Read any existing tests for the affected area

---

## Phase 3 in Detail: Plan Format

Use this exact structure when presenting a plan. Do not skip sections — an incomplete plan is not a plan.

---

```
## Implementation Plan — [TICKET-KEY]: [Ticket Title]

### Ticket Summary
[3–5 sentences describing what this ticket is asking for, which acceptance criteria are in scope, and what the user will be able to do once it's implemented. Plain language — this is to confirm mutual understanding before we go technical.]

### Approach
[The overall strategy. Which part of the stack is changing? What architectural pattern are you following (and why — especially if there were alternatives)? What is the simplest, safest path to meeting the acceptance criteria without over-engineering?]

### Assumptions
[Explicit list of anything that was not stated in the ticket but is being assumed. Each one should be clearly labelled so the user can challenge it.]

- Assumption 1: [state it]
- Assumption 2: [state it]
- If none: "No assumptions — the ticket and codebase exploration provided sufficient clarity."

### Files to Change

#### `path/to/file.ts`
**What's there now:** [Brief description of the current relevant content]
**What changes:** [Specific, detailed description of what will be added, modified, or removed and why]

#### `path/to/another/file.tsx`
**What's there now:** [...]
**What changes:** [...]

### New Files to Create

#### `path/to/new/file.ts`
**Purpose:** [Why this file needs to exist]
**Content:** [High-level description of what it will contain — types, functions, component structure, etc.]

### Change Sequence
The changes must be made in this order:

1. [Step 1 — file or action] — *Reason: [why this must come first]*
2. [Step 2] — *Reason: [dependency on step 1]*
3. [Step 3] — *Reason: [builds on step 2]*
...

### Edge Cases to Handle
[Specific conditions the implementation must account for, derived from the acceptance criteria and what was found in the codebase. Be concrete — not "handle errors" but "if the API call returns a 404, the user should see [specific message / behaviour]"]

- [Edge case 1]
- [Edge case 2]

### Tests to Add / Update

**Update existing:**
- `path/to/existing.test.ts` — [what needs changing and why]

**Add new:**
- Test: [what behaviour / scenario is being tested]
- Test: [...]

### Out of Scope
[What is deliberately not being changed in this implementation, and why.]

- [Thing 1 — not changing because: ...]
- [Thing 2 — not changing because: ...]

### Risks / Watch-outs
[Anything that could cause a problem, a regression, or needs extra care during implementation.]

- [Risk 1]
- [Risk 2]
```

---

## Phase 5 in Detail: Executing Changes

### The Rule: Read Before You Write
Always read the current state of a file before editing it. Never write to a file you haven't read in the current session — the file may have changed, or there may be context that affects the edit.

### The Rule: One File at a Time
Work through the Change Sequence one file at a time. Complete each change fully before moving to the next. Do not make partial changes across multiple files simultaneously.

### The Rule: Announce and Confirm
After each file change:
```
✓ Updated `src/components/auth/ForgotPassword.tsx`
  — Added email validation on submit, wired to the existing `useFormValidation` hook
  — Added error state display below the email input using the existing `FieldError` component
```

### The Rule: Stop on Surprises
If during execution you find:
- A file looks structurally different from what was observed during exploration
- A dependency doesn't exist that the plan assumed
- A type or interface conflict that the plan didn't account for
- An existing test that the planned change would break

**Stop. Tell the user. Get direction before continuing.**

Do not improvise silently. A surprised user is better than a broken codebase.

### Completion Summary Format

Once all changes are done:

```
## Implementation Complete — [TICKET-KEY]

### Changes Made

| File | Change |
|------|--------|
| `path/to/file.ts` | [one-line description] |
| `path/to/file.tsx` | [one-line description] |
| `path/to/new/file.ts` | Created — [purpose] |

### What to Verify
[Specific things the user should check manually, test, or QA before considering this done]

1. [Verification step 1 — in plain language]
2. [Verification step 2]

### Tests
[Confirm tests pass, or remind user to run the test suite.]

### Linked Ticket
If appropriate, offer: "Shall I transition [TICKET-KEY] to [next status] in Jira now?"
```

---

## Handling Common Situations

### Ticket is too vague to plan
> "This ticket doesn't have enough detail for me to produce a safe implementation plan. Specifically: [what's missing]. I'd recommend [assessing / rewriting] the ticket first. Want me to do that?"

### Codebase is not connected
> "I can't explore the codebase because no folder is connected. Could you connect your project folder and try again? Once I can see the code, I'll produce a grounded plan rather than working from assumptions."

### Multiple possible approaches
> "There are two reasonable approaches here:
> - **Option A** — [description, trade-off]
> - **Option B** — [description, trade-off]
> Which would you prefer? I'll build the plan around that."

### Scope seems larger than one ticket
> "After exploring the codebase, it looks like implementing this ticket as written would also require changes to [X and Y], which weren't mentioned in the ticket. Do you want me to include those in the plan, or should we create separate tickets for them and keep this one scoped tightly?"
