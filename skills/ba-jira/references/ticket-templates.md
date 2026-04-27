# Ticket Templates

All templates are written in business language. No technical jargon. Every section must be filled meaningfully — a template with placeholder text is not a finished ticket.

When applying a template, adapt the sections to match the available fields in `jira-config.md` for the relevant issue type. If a standard template section does not have a corresponding Jira field, include it in the Description body.

---

## User Story

> Use for: a new capability or behaviour that a user needs to be able to perform

**Title format:** `As a [user type], I can [do something] so that [benefit]`
Example: `As a customer, I can reset my password from the login screen so that I can regain access without contacting support`

---

**Background / Context**
What is the broader situation this story sits within? What triggered the need for this? Keep it to 2–4 sentences that anyone unfamiliar with the feature could understand.

**Problem Statement**
What is the user currently unable to do, or what friction are they experiencing? Be specific about what goes wrong or what is missing today.

**Business Value**
Why does this matter to the business? What outcome does it drive — customer satisfaction, revenue, efficiency, compliance, retention? Be explicit.

**Who is Affected**
Which user groups, teams, or departments are impacted by this change? (e.g. "All existing customers who have forgotten their password", "The customer support team who currently handle these requests manually")

**In Scope**
A clear list of what this story covers. Use plain sentences, not bullet fragments.
- Example: "The user can request a password reset by entering their registered email address"
- Example: "The user receives an email with a secure reset link within 2 minutes"
- Example: "The link expires after 30 minutes"

**Out of Scope**
What is deliberately not being addressed in this story to keep it focused?
- Example: "Changes to the email template design are not included"
- Example: "Password strength rules are not being changed"

**Acceptance Criteria**
Numbered list. Each criterion must be independently verifiable by someone with no technical knowledge. Written in plain English.

1. Given [situation], when [action], then [outcome]
2. Given [situation], when [action], then [outcome]
3. ...

**Business Rules**
Any rules that govern the behaviour described. These are decisions the business has made that QA needs to be aware of.
- Example: "A reset link can only be sent once every 5 minutes per email address"
- Example: "Unverified email addresses cannot request a reset"

**Dependencies**
Are there other tickets, teams, or external factors this story relies on before it can be completed?
- Example: "Requires the email notification service to be active — see [TICKET-KEY]"
- If none: "No dependencies identified"

**Definition of Done**
When can this story be closed? What must be true for it to be considered finished?
- Acceptance criteria have all passed in the test environment
- QA sign-off received
- [Any other business-specific conditions]

**Priority Justification**
Why is this priority level appropriate? What is the business consequence of delaying it?

---

## Bug Report

> Use for: something that is broken, behaving incorrectly, or not matching what was agreed

**Title format:** `[What is broken] — [brief description of the wrong behaviour]`
Example: `Password reset email — link not delivered to Gmail addresses`

---

**What is Happening**
Describe what the user experiences when they encounter this issue. Write it as if explaining to someone who wasn't there. Be specific about the exact incorrect behaviour.

**What Should Happen**
Describe the correct, expected behaviour. Reference the original acceptance criteria or agreed behaviour if known.

**Who is Affected**
Which users or user groups are experiencing this? Is it everyone, or a specific segment?
- Example: "Any user with a Gmail address who attempts to reset their password"

**Business Impact**
What is the real-world consequence of this bug? Is anyone being blocked from doing their job? Is revenue, compliance, or customer satisfaction at risk?
- Example: "Affected users cannot log in and are being directed to support, increasing ticket volume"

**How to Reproduce (Business Steps)**
The sequence of actions a user takes to encounter this bug — written as a user journey, not technical steps.

1. User goes to the login screen and clicks "Forgot password"
2. User enters their Gmail address and submits
3. User does not receive the reset email after 10 minutes
4. User checks spam — email is not there either

**How Often Does This Happen**
Is this consistent (happens every time), intermittent (sometimes), or hard to reproduce?

**Severity**
How serious is this? Use business impact to justify:
- **Critical** — completely blocks a core user journey or has a compliance/financial risk
- **High** — significantly degrades a key user journey; no workaround exists
- **Medium** — causes inconvenience but a workaround is available
- **Low** — minor cosmetic or edge case issue with minimal user impact

**Acceptance Criteria for the Fix**
How will we know the bug has been resolved?

1. Given a user with a Gmail address submits a password reset request, they receive the reset email within 2 minutes
2. The received email contains a working reset link

**Dependencies**
Any related tickets or known factors that may be connected to this bug.

---

## Epic

> Use for: a large body of work that represents a significant business outcome, made up of multiple child stories

**Title format:** A clear business objective
Example: `Enable customers to self-serve password and account security changes`

---

**Business Objective**
What is the business trying to achieve with this epic? What problem does it solve at a strategic level? Write 3–5 sentences that a non-technical stakeholder or senior leader could read and immediately understand.

**Success Vision**
When this epic is fully delivered, what does the world look like? What can users do that they couldn't before? What does the business gain?

**Who Benefits**
Which user groups, departments, or stakeholders benefit from the delivery of this epic?

**Scope Overview**
At a high level, what does this epic cover? (Child stories will define the detail)

**What is Out of Scope for this Epic**
What has been deliberately excluded so the epic stays focused?

**Business Value & Priority**
Why is this epic important now? What is the cost of not doing it? Link to any strategic goals, OKRs, or business drivers if known.

**Assumptions**
What assumptions are we making that would change the scope if proven wrong?

**Known Dependencies**
What does this epic depend on — other epics, teams, third-party services, or business decisions?

**Success Metrics**
How will the business measure whether this epic was successful once delivered?
- Example: "Self-serve password reset usage reaches 80% within 3 months of launch, reducing support tickets by 40%"

**Child Stories**
[To be broken down — use the DECOMPOSE action]

---

## Task

> Use for: a specific piece of work that is not a user-facing story but needs to be tracked — internal process, configuration, documentation, investigation

**Title format:** Clear action — what needs to be done
Example: `Update user-facing error messages for the password reset flow to match agreed wording`

---

**What Needs to Be Done**
A clear, specific description of the work. Written so that the person picking it up knows exactly what is expected.

**Why This Is Needed**
The business or process reason this task exists. What breaks or is missing if it isn't done?

**Who Owns It**
Which team or person is responsible?

**Acceptance Criteria**
How will we know this task is complete?

1. [Specific verifiable outcome]

**Dependencies**
Anything this task is waiting on, or anything that is waiting on this task.

---

## Sub-task

> Use for: a specific piece of work that is part of a parent story or task

**Title format:** Clear action — specific to the parent
Example: `Write QA scenarios for the password reset happy path`

---

**Parent Ticket**
[Link to parent]

**What Needs to Be Done**
Specific description of this sub-task's scope. It should be smaller and more focused than the parent.

**Acceptance Criteria**
1. [Specific verifiable outcome]

---

## Spike (Discovery / Research Ticket)

> Use for: a time-boxed investigation to answer a specific question before a story can be properly defined or estimated

**Title format:** `Spike: [question to answer]`
Example: `Spike: Understand what options exist for delivering password reset emails to users`

---

**The Question We Need to Answer**
What specific question is this spike trying to resolve? Be precise — a vague question produces a vague outcome.

**Why We Need to Know**
What decision or story is blocked until we have this answer?

**What We Will Produce**
What is the output of this spike? A recommendation? A written summary? A set of defined options?
- Example: "A summary of 2–3 options with the trade-offs written up in plain language so the team can choose an approach"

**Time Box**
How long should be spent on this investigation before stopping and reporting findings?
- Example: "No more than 3 days"

**Acceptance Criteria**
1. A written summary of findings has been shared with the team
2. A recommended approach has been identified (or it has been clearly documented why one cannot be recommended yet)
3. Next steps / follow-on stories have been proposed

---

## Choosing the Right Ticket Type

| Situation | Use |
|---|---|
| A user needs a new capability | User Story |
| Something is broken | Bug |
| A large piece of work spanning multiple stories | Epic |
| Internal work with no direct user interaction | Task |
| A piece of work within a parent story | Sub-task |
| We need to investigate before we can define the work | Spike |
| A story is too large for one sprint | Split it into multiple User Stories |
