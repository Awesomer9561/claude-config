# Ticket Templates

All templates are written in business language unless the type is developer-oriented (Sub-task). No placeholder text — every section must be filled meaningfully before the ticket is ready.

When applying a template, adapt the sections to match the available fields in `jira-config.md` for the relevant issue type. If a standard template section does not have a corresponding Jira field, include it in the Description body.

---

## User Story

> Use for: a new capability or behaviour that a user needs to be able to perform

**Title format:** `[Module] - [Feature] - [Short Description]`
Example: `Authentication - Password Reset - Allow users to recover access without contacting support`

---

As a [role],
I want [goal],
So that [benefit].

[Module]>[SubModule]>[Feature]:

**Acceptance Criteria:**

1. [Plain statement — independently verifiable by someone with no technical knowledge]
2. [Plain statement]
3. ...

---

## Bug Report

> Use for: something that is broken, behaving incorrectly, or not matching what was agreed

**Title format:** `[Module] - [Feature] - [Issue]`
Example: `Authentication - Password Reset - Reset email not delivered to Gmail addresses`

---

[Description paragraph — what the user experiences when they encounter this issue. Written so someone who wasn't there can understand the problem clearly.]

**Steps to Reproduce**

1. [Action]
2. [Action]
3. ...

**Actual Result**

> Only include this section when the actual behaviour can be confirmed with certainty. Skip it entirely if uncertain.

* [What the system does]

**Expected Result**

> Only include this section when the expected behaviour can be confirmed with certainty. Skip it entirely if uncertain.

* [What the system should do]

---

## Epic

> Use for: a large body of work that represents a significant business outcome, made up of multiple child stories

**Title format:** `[Module] - [Initiative] - [Goal]`
Example: `Authentication - Account Security - Enable customers to self-serve all password and security changes`

---

[Business objective — 2–3 sentences a non-technical stakeholder can read and immediately understand. What problem does this solve and what does the business gain?]

[Module]>[Initiative]:

**In Scope:**
- [What this epic covers]

**Out of Scope:**
- [What is deliberately excluded to keep the epic focused]

**Success Criteria:**
1. [Measurable outcome the business will use to judge success]
2. ...

---

## Task

> Use for: a specific piece of work that is not a user-facing story but needs to be tracked — internal process, configuration, documentation, investigation. Can be written in business or developer language depending on the nature of the work.

**Title format:** `[Module] - [Feature] - [Task Description]`
Example: `Authentication - Password Reset - Update user-facing error messages to match agreed wording`

---

[What needs to be done — clear and specific enough that the person picking it up knows exactly what is expected. Use business or technical language as appropriate.]

[Module]>[Feature]:

**Acceptance Criteria:**
1. [Specific verifiable outcome]
2. ...

---

## Sub-task

> Use for: a specific piece of work that is part of a parent story or task. Developer-oriented — technical language is appropriate here.

**Title format:** `[Module] - [Feature] - [Specific Task]`
Example: `Authentication - Password Reset - Write QA scenarios for the password reset happy path`

---

[Specific technical description of this sub-task's scope. Smaller and more focused than the parent.]

**Parent:** [TICKET-KEY]

**Acceptance Criteria:**
1. [Technical verifiable outcome]
2. ...

---

## Spike (Discovery / Research Ticket)

> Use for: a time-boxed investigation to answer a specific question before a story can be properly defined or estimated

**Title format:** `[Module] - [Feature] - Spike: [What to Investigate]`
Example: `Authentication - Password Reset - Spike: Understand options for delivering transactional emails to users`

---

[The specific question this spike is trying to resolve. Be precise — a vague question produces a vague outcome.]

[Module]>[Feature]:

**Why this matters:**
[What decision or story is blocked until we have this answer.]

**Output:**
[What the spike will produce — a recommendation, a written summary, a set of defined options with trade-offs.]

**Time Box:** [e.g. 3 days]

**Acceptance Criteria:**
1. Findings have been written up and shared with the team
2. A recommended approach has been identified (or it has been clearly documented why one cannot be recommended yet)
3. Follow-on stories have been proposed

---

## Choosing the Right Ticket Type (Jira)

| Situation | Use |
|---|---|
| A user needs a new capability | User Story |
| Something is broken | Bug |
| A large piece of work spanning multiple stories | Epic |
| Internal work with no direct user interaction | Task |
| A piece of work within a parent story | Sub-task |
| We need to investigate before we can define the work | Spike |
| A story is too large for one sprint | Split it into multiple User Stories |

---

## GitHub Issue Template

> Use for: any GitHub issue — feature requests, bugs, tasks, and investigations

**Title format:** `[Module] - [Feature] - [Short Description]`
Examples:
- `Authentication - Password Reset - Allow users to recover access without support`
- `Orders - Payment - Fix duplicate charge on retry`
- `Reporting - Export - Spike: Investigate CSV generation options`

---

[Overview — 2–3 sentences that anyone unfamiliar with the feature could understand. What triggered the need for this?]

[Module]>[Feature]:

**What needs to happen:**
- [ ] [Acceptance criterion]
- [ ] [Acceptance criterion]

**Out of scope:**
- [What is deliberately not being addressed to keep this focused]

**Notes / Dependencies:**
- Related: #[number]
- Blocked by: #[number]
- If none: "No dependencies identified"

---

## Choosing the Right GitHub Issue Type

| Situation | Title contains |
|-----------|----------------|
| New user capability | `[Module] - [Feature] - [Short Description]` |
| Something is broken | `[Module] - [Feature] - Fix: [Issue]` |
| Investigation needed | `[Module] - [Feature] - Spike: [What to investigate]` |
| Internal/process work | `[Module] - [Feature] - [Task Description]` |
