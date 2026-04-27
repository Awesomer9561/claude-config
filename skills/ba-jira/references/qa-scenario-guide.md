# QA Scenario Guide — Plain-English Testing

QA scenarios written in this skill are for business stakeholders and QA testers — not engineers. They describe what the user experiences, not what happens in the system behind the scenes.

Every scenario must be understandable by someone who has never seen the code, database, or infrastructure. If a scenario requires technical knowledge to execute, it has been written incorrectly.

---

## Format: Given / When / Then

Every scenario follows this structure:

**Given** — the starting situation (who the user is, what state they're in)
**When** — the action the user takes
**Then** — what the user observes as the outcome

### Example (Good — Business Language)
```
Scenario: Successful password reset for a registered user

Given a user has a registered account with the email address "user@example.com"
When the user enters their email on the "Forgot Password" screen and submits it
Then the user sees a confirmation message: "We've sent a reset link to your email"
And the user receives an email containing a working reset link within 2 minutes
```

### Example (Bad — Technical Language — Do Not Write This)
```
Scenario: Password reset token generation

Given the user's email exists in the users table with status = 'active'
When a POST request is sent to /api/v2/auth/reset-password with the email payload
Then a 200 OK response is returned and a JWT token is inserted into the password_reset_tokens table with TTL 1800 seconds
```

The second example is useless to a QA tester or business stakeholder — it tests the system internals, not the user experience.

---

## Categories of Scenarios to Write

For every ticket, aim to cover all applicable categories. A complete QA scenario set usually has 5–12 scenarios depending on complexity.

### 1. Happy Path
The expected, successful journey. The user does everything correctly and gets the expected outcome.

Write at least one happy path scenario for every acceptance criterion.

```
Scenario: Customer completes checkout successfully

Given a logged-in customer has 2 items in their basket and a valid saved payment method
When the customer selects "Pay Now" and confirms their order
Then the order is placed and the customer sees an order confirmation screen with their order number
And the customer receives a confirmation email within 5 minutes
```

### 2. Negative / Error Cases
What happens when something goes wrong, is invalid, or is missing. The user must always receive clear, helpful feedback — they should never be left confused about what happened or what to do next.

```
Scenario: Customer enters an unregistered email on the password reset screen

Given a user enters an email address that has no associated account
When they submit the forgot password form
Then the user sees a message that does not reveal whether the email is registered or not
And no email is sent
And the user is given guidance on what to do next
```

Note: the scenario above captures a business rule (don't reveal whether an email is registered — common security practice) without any technical explanation of why.

### 3. Edge Cases / Boundary Conditions
Situations at the limits of what the feature handles. Think about: maximum lengths, minimum quantities, time limits, special characters, empty states, duplicate actions.

Describe boundaries in user terms, not system terms.

```
Scenario: Customer attempts to reset password a second time within 5 minutes

Given a customer has already requested a password reset link in the last 5 minutes
When they submit the forgot password form again with the same email
Then the customer sees a message explaining they must wait before requesting another link
And no new email is sent
```

```
Scenario: Customer clicks an expired reset link

Given a customer received a password reset email more than 30 minutes ago
When they click the reset link in that email
Then the customer sees a message explaining the link has expired
And they are offered the option to request a new link
```

### 4. Business Rule Scenarios
Scenarios that specifically test the business rules called out in the ticket. These are often missed because they're implied rather than explicit.

Identify business rules from the acceptance criteria and the "Business Rules" section of the ticket (if present), and write a dedicated scenario for each one.

```
Scenario: User with an unverified account cannot request a password reset

Given a user registered but never verified their email address
When they attempt to request a password reset
Then they are shown a message explaining their account is unverified
And they are offered the option to resend the verification email instead
```

### 5. Access / Permission Scenarios
Who should and should not have access to this feature or data?

```
Scenario: Logged-in user cannot use the password reset flow

Given a user is already logged in
When they navigate to the "Forgot Password" page
Then they are redirected to their account dashboard
And the reset form is not accessible
```

### 6. State / Data Persistence Scenarios
Does the system correctly remember what happened? Does data change when it should and stay the same when it shouldn't?

```
Scenario: Completing a password reset does not change other account details

Given a user successfully resets their password using the reset link
When they log in with their new password
Then their account name, email address, and saved preferences are unchanged
```

---

## Language Rules for QA Scenarios

**Always say:**
- "the user sees..."
- "the user receives..."
- "the user is shown..."
- "the user is redirected to..."
- "the user can / cannot..."
- "the screen displays..."
- "a message appears saying..."

**Never say:**
- "the API returns..."
- "the database records..."
- "the response payload contains..."
- "the token is generated..."
- "the service calls..."
- "the query returns..."
- "the server responds with 200..."
- "the cache is invalidated..."

**For error messages:** When the acceptance criteria specify an exact message, quote it. When they don't, describe what the message communicates to the user (e.g. "a message explaining that the link has expired and what the user should do next") rather than inventing wording that hasn't been agreed.

---

## QA Scenario Output Format

When presenting QA scenarios, use this format:

```
## QA Scenarios — [TICKET-KEY]: [Ticket Title]

### Happy Path

**Scenario 1: [Short descriptive name]**
Given [starting situation]
When [user action]
Then [observable outcome]
And [additional observable outcome if needed]

### Error Cases

**Scenario 2: [Short descriptive name]**
Given [starting situation]
When [user action]
Then [observable outcome]

### Edge Cases

**Scenario 3: [Short descriptive name]**
...

### Business Rules

**Scenario 4: [Short descriptive name]**
...
```

---

## How Many Scenarios Is Enough?

| Ticket Complexity | Minimum Scenarios |
|---|---|
| Simple / single behaviour | 3 (happy path, one error, one edge case) |
| Moderate / multi-condition | 5–8 |
| Complex / many rules and states | 8–15 |

If the acceptance criteria have 5 items, there should be at least 5 happy-path scenarios — one per criterion — plus negative and edge case scenarios on top.

If you find yourself writing more than 15 scenarios for a single story, consider whether the story is too large and should be split.

---

## After Writing Scenarios

Always ask the user:
1. "Do these scenarios cover what you had in mind, or are there situations I've missed?"
2. "Shall I add these to the ticket as a comment in Jira?"

If the user confirms, call `addCommentToJiraIssue` with the formatted scenario set.
