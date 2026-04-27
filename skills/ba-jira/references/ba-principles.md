# BA Writing Principles

These principles govern everything written by the ba-jira skill. Read this file whenever producing any ticket content.

The goal: any ticket written by this skill should be fully understood by a non-technical business stakeholder, a QA tester with no engineering background, and a product owner — without needing a developer to explain what it means.

---

## The Core Rules

### 1. Write for the Reader, Not the Writer
The person writing a ticket already knows what they mean. The job of the ticket is to communicate that meaning to someone who wasn't in the meeting, didn't hear the conversation, and has no assumed context. Write for that person.

### 2. One Idea per Sentence
Long, compound sentences hide ambiguity. Break complex thoughts into short, clear sentences. If a sentence contains "and" more than once, it probably needs to be split.

### 3. Say What Happens, Not How It Happens
Business requirements describe the outcome the user experiences. They do not describe the method used to achieve it. "The user receives a confirmation email" is a requirement. "An SMTP service triggers a templated email via the notification microservice" is an implementation detail — it belongs in engineering notes, not in a Jira ticket.

### 4. State the Why, Not Just the What
Every ticket should answer: why are we doing this? What happens if we don't? A ticket without a stated business reason cannot be properly prioritised or challenged — and cannot be properly tested.

### 5. If It Cannot Be Tested, It Is Not a Requirement
Any acceptance criterion that cannot be verified by a QA tester without a developer's help is not a proper acceptance criterion. Rewrite it until it is observable and specific.

### 6. Never Assume Shared Understanding
Do not write "as per the usual process", "standard behaviour", "as discussed", or "as agreed". The ticket must stand alone. Anyone reading it cold — including future team members, auditors, or stakeholders — must be able to understand it fully.

### 7. Empty Fields Are Not Neutral
A blank "Dependencies" field does not mean "no dependencies" — it means "nobody checked". Always explicitly state "No dependencies identified" if that is the case. Intentional emptiness must be intentional, not accidental.

---

## Banned Jargon and Business-Language Replacements

When tempted to use any of the following, use the replacement instead. This is not just about simplifying language — it is about ensuring requirements are expressed at the right level.

### Technical Terms → Business Language

| Avoid | Use Instead |
|-------|------------|
| API / endpoint / REST call | "the system communicates with [service/partner name]" or omit entirely |
| Database / table / record | "the system stores / retrieves / updates [what data]" — or omit and focus on the user outcome |
| Deploy / release / push | "when this goes live", "once this is available to users" |
| Cache / invalidate | "the most up-to-date information is shown" |
| Token / JWT / session | "the user's login remains active" or "the user's access is verified" |
| Payload / request body | omit — describe what the user submits, not the format |
| Microservice / service / module | "the [feature name] part of the system" if needed at all |
| Frontend / backend | "what the user sees" / "behind the scenes" — or just describe the outcome |
| Query / SQL / JQL | omit — describe what the user needs to find or see |
| Regex / validation rule | "the system checks that [field] is in the correct format" |
| Null / empty / undefined | "blank", "not filled in", "missing" |
| Boolean / flag / toggle | "the setting is on/off" or "this is enabled/disabled" |
| Environment (dev/staging/prod) | "the live system" or "the test environment" if context requires it |
| Hard-coded / config | omit — describe the behaviour, not how it's controlled |
| Migration / schema change | omit — describe the business capability being enabled |
| Role / permission (technical) | "users who have access to [feature/area]" |
| Async / synchronous | "immediately" / "within [time]" / "in the background" |
| 200 / 404 / 500 / HTTP status | "successfully", "not found", "something went wrong" |
| Rate limiting | "users can only do this [X times] within [timeframe]" |
| Retry logic | "if it fails, the system tries again automatically" |
| Idempotent | "doing this more than once has the same result as doing it once" |
| CRUD | "create, view, update, delete" |
| MVP | "first version", "initial release" |
| Tech debt | "existing limitation", "known issue to be addressed" |
| Refactor | "improve how the [feature] works internally" — or omit if user-invisible |
| Unit / integration / E2E test | "testing" — QA scenarios describe the user behaviour being tested, not test types |
| CI/CD / pipeline | "the automated release process" — or omit if not business-relevant |
| SSO / SAML / OAuth | "[organisation's] single sign-on" / "the login system we use" |
| PII / GDPR compliance | "personal data handled in line with our data policy" |
| Kafka / queue / event | "the system is notified when [business event] occurs" |

### Vague Words → Specific Statements

| Avoid | Why | Use Instead |
|-------|-----|------------|
| "Improve" | Improvement by what measure? | "Reduce the time to [do X] from [current] to [target]" |
| "Enhance" | Not a requirement | Describe the specific capability being added |
| "Fix" (in a story title) | Stories should describe capabilities, not fixes | Use Bug type; describe the correct behaviour |
| "Update [screen/page]" | What update? | Describe what changes on that screen and why |
| "Handle [scenario]" | Handle how? | Describe the specific user outcome |
| "Support [thing]" | What does support mean here? | "Users can [do X]" or "The system accepts [Y]" |
| "As per discussion" | The ticket must stand alone | Write out what was discussed |
| "TBD / TBC" | Blocks QA, cannot be estimated | Either resolve or create a spike to resolve it |
| "Standard behaviour" | Whose standard? | Describe the specific behaviour |
| "Should work correctly" | Not testable | Describe what correct looks like |
| "User-friendly" | Subjective | Describe the specific usability criterion |
| "Fast / performant" | Subjective | "The page loads within 3 seconds" |
| "Seamless" | Marketing language | Describe the specific experience |

---

## Good Acceptance Criteria vs. Bad Acceptance Criteria

### Bad
> The system should process the order correctly

Why bad: "correctly" is undefined. No one can test this.

### Good
> Given a customer has items in their basket and a valid payment method saved, when they confirm their order, then an order confirmation number is displayed on screen and a confirmation email is sent to their registered address within 5 minutes

---

### Bad
> The API returns a 200 status when the user is authenticated

Why bad: this is a technical test, not a business requirement.

### Good
> A logged-in user can access their account dashboard without being asked to log in again during their session

---

### Bad
> Ensure data integrity is maintained

Why bad: completely untestable and meaningless to anyone outside engineering.

### Good
> The user's order history, saved addresses, and payment methods remain unchanged after the password reset process is completed

---

## Asking Clarifying Questions

Before writing a ticket, if any of these are unclear — ask. Do not fill in blanks with assumptions.

**The five questions every ticket must answer:**
1. Who is the user / who is affected?
2. What do they need to be able to do?
3. Why does this matter to the business?
4. What does "done" look like — what can the user do that they couldn't before?
5. What is out of scope — what are we deliberately not changing?

If the answer to any of these is genuinely "we don't know yet", the right ticket type is a Spike, not a Story.

---

## The BA Standard: A Finished Ticket

A finished ticket is one where:

- A new team member with no prior context could read it and know exactly what to build
- A QA tester could write test cases from the acceptance criteria alone
- A product owner could prioritise it without needing further explanation
- A business stakeholder could read it and recognise the value it delivers
- No engineer needs to be present in the room for anyone to understand it

If a ticket requires a verbal explanation to make sense, it is not finished.
