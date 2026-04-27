# BA Quality Scorecard — Assessment Framework

Use this framework whenever assessing a ticket (ASSESS action) or running an internal quality check before rewriting (REWRITE action).

Score each dimension 0–3. Total score out of 21. Derive a verdict from the overall score and any hard-fail conditions.

---

## Scoring Scale

| Score | Meaning |
|-------|---------|
| 3 | Excellent — fully meets the standard, no gaps |
| 2 | Acceptable — mostly there, minor improvements needed |
| 1 | Weak — present but significantly incomplete or unclear |
| 0 | Missing — not present at all, or so vague as to be useless |

---

## Dimensions

### 1. Clarity (0–3)
Is the ticket unambiguous? Could two different people read it and arrive at the same understanding of what needs to be built or fixed?

**Score 3:** Every sentence has one interpretation. The title alone communicates the work. No vague words ("improve", "enhance", "fix stuff", "update screen").
**Score 2:** Mostly clear. One or two phrases could be interpreted in more than one way but the overall intent is evident.
**Score 1:** The intent can be guessed but key details are vague, missing, or contradictory.
**Score 0:** The ticket title and description do not clearly convey what needs to happen.

**Red flags to call out:** "TBD", "TBC", "as per discussion", "as agreed", "standard behaviour", vague titles like "Fix login bug" or "Update profile page"

---

### 2. Completeness (0–3)
Are all required sections present and meaningfully filled? Are required fields (per `jira-config.md`) populated?

**Score 3:** All expected sections are present with substantive content. All required fields are set (priority, issue type, labels, etc.). No placeholder text remaining.
**Score 2:** Most sections are present. One or two minor omissions that don't block understanding.
**Score 1:** Key sections are missing (e.g. no acceptance criteria, no background, no scope).
**Score 0:** The ticket is essentially a title with little or no body content.

**Check specifically:** Background/context, problem statement, acceptance criteria, scope (in and out), dependencies, definition of done, all required config fields

---

### 3. Business Value (0–3)
Is it clear WHY this work matters? Is the business reason explicit?

**Score 3:** The "why" is clearly stated, specific, and compelling. The value to users or the business is unmistakable. Anyone reading it would understand the priority without needing further explanation.
**Score 2:** Business value is mentioned but somewhat generic ("improve user experience", "increase efficiency") without specifics.
**Score 1:** Business value is implied but not stated. You have to infer it.
**Score 0:** No business value is stated. The ticket describes what to do but gives no reason why.

---

### 4. Testability (0–3)
Can QA verify this ticket without needing a developer to explain what "done" means?

**Score 3:** Acceptance criteria are specific, measurable, and written in plain English. Each criterion can be independently verified by a QA tester or business stakeholder. QA scenarios are present (or would be easy to derive directly from the AC).
**Score 2:** Acceptance criteria exist but one or two are vague or ambiguous ("the page should load correctly", "the system should respond appropriately").
**Score 1:** Acceptance criteria are present but mostly untestable — too vague, too technical, or missing key conditions.
**Score 0:** No acceptance criteria. QA has nothing to test against.

**Hard fail:** If there are zero acceptance criteria, the ticket cannot be Sprint Ready regardless of other scores.

---

### 5. Scope (0–3)
Is the scope appropriate? Is it clearly bounded?

**Score 3:** In-scope and out-of-scope are explicitly stated. The scope is appropriate for the issue type — stories are deliverable in a single sprint, epics are properly sized as multi-story initiatives.
**Score 2:** Scope is mostly clear but one area is ambiguous — it's unclear whether something is included or not.
**Score 1:** Scope is vague. It's hard to tell where this ticket ends and the next one begins. Risk of scope creep.
**Score 0:** No scope definition. The ticket could mean almost anything.

**Flag if:** A story appears too large for a single sprint (suggest splitting). An epic has been written at story level.

---

### 6. Dependencies (0–3)
Have dependencies been identified and handled?

**Score 3:** Dependencies are explicitly listed with relevant ticket keys. "No dependencies" is explicitly stated if that's the case — the BA has actively considered it rather than left it blank.
**Score 2:** Dependencies are mentioned but not fully described or linked.
**Score 1:** Dependencies are likely but haven't been identified — there are obvious connections to other work that aren't referenced.
**Score 0:** Dependencies section is blank with no indication that it was considered.

---

### 7. Sprint Readiness (0–3)
Is this ticket ready to be picked up by a team in the next sprint without needing further clarification?

**Score 3:** A team member could pick this up cold and know exactly what to deliver and when to close it. No open questions. No blockers.
**Score 2:** Nearly ready. One small clarification might be needed but it's not a blocker.
**Score 1:** Would require a significant conversation before the team could start. Key decisions are unresolved.
**Score 0:** Cannot be started — blocking dependency, fundamental ambiguity, or key information entirely missing.

---

## Scoring Summary Template

Use this format when presenting an assessment:

```
## BA Quality Assessment — [TICKET-KEY]: [Ticket Title]

| Dimension       | Score | Verdict |
|----------------|-------|---------|
| Clarity         | x / 3 | [comment] |
| Completeness    | x / 3 | [comment] |
| Business Value  | x / 3 | [comment] |
| Testability     | x / 3 | [comment] |
| Scope           | x / 3 | [comment] |
| Dependencies    | x / 3 | [comment] |
| Sprint Readiness| x / 3 | [comment] |
| **Total**       | **x / 21** | |

## Overall Verdict
[Sprint Ready / Needs Work / Not Ready]

## What Needs to Change
1. [Specific actionable improvement for each dimension that scored below 3]
2. ...

## Hard Fails (if any)
[Any condition that makes the ticket immediately Not Ready regardless of total score]
```

---

## Verdict Thresholds

| Score Range | Verdict | Meaning |
|------------|---------|---------|
| 18–21 | **Sprint Ready** | Ticket meets BA standards. Minor polish optional. |
| 12–17 | **Needs Work** | Ticket has meaningful gaps. Address before sprint. |
| 0–11 | **Not Ready** | Ticket requires significant rework before it can be estimated or actioned. |

### Hard Fails (auto "Not Ready" regardless of score)
Any of the following triggers an automatic **Not Ready** verdict:
- Zero acceptance criteria
- Title is a placeholder or completely vague ("Fix bug", "Update page", "TBD")
- Business value is entirely absent
- A blocking dependency is unresolved and unacknowledged
- Required Jira fields (per config) are empty

---

## Improvement Guidance

When flagging improvements, be specific and constructive. Don't just say "add acceptance criteria" — say:

> "Acceptance criteria are missing. Based on the problem described, the criteria should cover: (1) what a successful outcome looks like for the user, (2) any error or failure states, (3) the specific conditions under which the feature is available. Here's a draft based on what's in the ticket: [draft]"

Always offer to rewrite after an assessment. A good assessment is most valuable when it leads to an improved ticket.
