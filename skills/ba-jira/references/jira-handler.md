# Jira Handler

All Jira-specific action logic for the ba-jira skill. Read this file when the profile routes to Jira.

Before any action: the caller has already loaded the profile. Use the Jira Config section from `profile.md` — do not re-read `jira-config.md` or call setup APIs unless the profile says `source` is not configured for Jira.

---

## Config Refresh

If the user says "refresh Jira config", "resync Jira", or "update Jira settings":
1. Re-run Steps 4–5 of the SETUP MODE flow in `references/profile-format.md`
2. Overwrite the `## Jira Config` section in `profile.md` with fresh data
3. Confirm: "Jira config refreshed."

---

## Action: READ

1. Call `getJiraIssue` with the provided issue key
2. Present in this order: Title → Type → Status → Priority → Business Context → Problem Statement → Acceptance Criteria → QA Scenarios (if present) → Dependencies → Missing / Gaps
3. Present in clean BA language — no raw Jira field dumps
4. Handle attachments per the **Attachment Handling** rules below
5. Automatically run a brief gap check — note any missing fields, vague acceptance criteria, or empty required fields
6. Offer: "Want me to assess this in full, improve it, or write QA scenarios for it?"

---

## Action: WRITE

Read `references/ticket-templates.md` for the appropriate template.
Read `references/ba-principles.md` before writing.

1. Identify the issue type from context (ask if unclear)
2. Ask targeted clarifying questions if key information is missing — do not invent content. Ask one focused question at a time.
3. Apply the correct template from `references/ticket-templates.md`
4. Write the full ticket in BA language
5. Show the drafted ticket to the user for review
6. On confirmation, call `createJiraIssue` with appropriate field mappings from the profile
7. Report the created issue key back to the user

**Minimum info needed before writing:**
- Who is the user / stakeholder affected?
- What do they need to be able to do?
- What is the business reason / value?
- What does "done" look like to the business?

---

## Action: ASSESS

Read `references/assessment-framework.md` for the full scoring rubric.

1. Fetch the ticket if not already loaded (`getJiraIssue`)
2. Run through every dimension of the BA Quality Scorecard
3. Present a score per dimension with specific evidence from the ticket
4. Give an overall verdict: **Sprint Ready / Needs Work / Not Ready**
5. List specific, actionable improvements for every dimension that scored below full marks
6. Ask: "Want me to rewrite this ticket based on these findings?"

---

## Action: REWRITE

1. Fetch the current ticket content if not already loaded
2. Run ASSESS internally (do not show the scorecard unless asked)
3. Read `references/ticket-templates.md` for the appropriate template
4. Read `references/ba-principles.md`
5. Rewrite the full ticket preserving the original intent but applying BA standards throughout
6. Show the before and after side by side (or clearly separated)
7. Ask for confirmation before calling `editJiraIssue` to update Jira

---

## Action: DECOMPOSE

For epic breakdown:
1. Fetch the epic if a key is provided (`getJiraIssue`)
2. Read the epic's objective and scope
3. Produce a set of child user stories, each:
   - Independently deliverable
   - Carrying clear business value on its own
   - Written in user story format: *As a [person], I want [goal], so that [benefit]*
   - With draft acceptance criteria
   - Sized appropriately (flag any that feel too large)
4. Present all proposed stories for review
5. On confirmation, call `createJiraIssue` for each story and link them to the parent epic

---

## Action: SPRINT READINESS

Run through the Sprint Readiness Checklist:

- [ ] Title is clear and specific
- [ ] Issue type is correctly set
- [ ] Business context / background is present
- [ ] Problem statement is clear
- [ ] Acceptance criteria are present, specific, and testable
- [ ] QA scenarios exist (at least happy path + one negative case)
- [ ] Priority is set and justified
- [ ] All required fields (per profile) are filled
- [ ] Dependencies are identified (or explicitly stated as none)
- [ ] Scope is appropriate for a single sprint
- [ ] No blocking issues unresolved
- [ ] No unanswered questions / placeholders ("TBD", "TBC", "TODO") remaining

Verdict: **Ready / Nearly Ready (list gaps) / Not Ready (list blockers)**

---

## Action: QA SCENARIOS

Read `references/qa-scenario-guide.md` before writing scenarios.

1. Read the ticket's acceptance criteria
2. Produce scenarios in business language covering:
   - Happy path
   - Negative / error cases
   - Edge cases
   - Any business rules implied by the acceptance criteria
3. Format using Given / When / Then in plain English
4. Attach scenarios to the ticket as a comment via `addCommentToJiraIssue` on confirmation

---

## Action: UPDATE

1. Fetch current ticket (`getJiraIssue`)
2. Show current values of fields being changed
3. Apply BA principles to any text fields being updated
4. Show proposed changes clearly
5. On confirmation, call `editJiraIssue`
6. Confirm update with the user

---

## Action: SUMMARISE

Write a business-oriented summary of what was implemented and post it as a Jira comment.

Read `references/ba-principles.md` before composing.

1. **Load the ticket** — call `getJiraIssue` to understand the original requirement. If no key provided, ask for one.
2. **Gather what was built** — if the user hasn't described it, ask: "What was delivered? Describe what changed from a user's perspective."
3. **Compose the summary** using the template below — no technical jargon.
4. **Show for review** — display the full comment. Ask: "Shall I post this to [ticket-key]?"
5. **Post** — on confirmation, call `addCommentToJiraIssue`.

### Summary Comment Template

```
## ✅ Implementation Summary

**Ticket:** [KEY] — [Title]
**Summary date:** [Today's date]

---

### What was delivered

[2–4 sentences in plain English describing what the user can now do, what was fixed, or what changed. Written from the end user or business perspective. No code references, no API names, no database terms.]

### What to verify

[Bullet list of 2–5 things a QA tester or stakeholder should check. Written as actions: "Navigate to X and confirm Y", "Try doing Z and check that…". No technical steps.]

### Scope of change

[One sentence on what was deliberately left out of scope, if relevant. Omit entirely if everything was delivered.]
```

**Language Rules:**
- ✅ "users can now…", "the screen now shows…", "clicking [button] now…"
- ❌ Never say: API, endpoint, database, query, migration, deployment, service, component, function, branch, PR, merge, commit, schema, payload, backend, frontend

---

## Action: PLAN *(Planner Mode)*

Read `references/planner-guide.md` before starting.

#### Phase 1 — Load the Ticket
1. Call `getJiraIssue` with the provided ticket key
2. Extract: business goal, acceptance criteria, scope boundaries, linked tickets
3. If the ticket has no acceptance criteria or is too vague, pause — offer to run ASSESS or REWRITE first.

#### Phase 2 — Understand the Codebase
Explore the codebase to ground the plan in reality. Use the `repo` field from `.ba-tickets.json` to confirm which repo you're in.

Use file and search tools to understand:
- Project structure, major modules, entry points
- Area of code most likely affected
- Existing patterns used in similar features
- Data models, state, types relevant to the ticket
- User-facing entry points (routes, screens, components)
- Existing tests covering the affected area

If you cannot find the relevant area, say so and ask the user to point you to the right place.

#### Phase 3 — Generate the Implementation Plan
Read `references/planner-guide.md` for the full plan format.

Produce a structured plan covering:
1. **Ticket Summary** — what the ticket asks for in plain terms
2. **Approach** — implementation strategy and why
3. **Assumptions** — explicitly flagged
4. **Files to Change** — path, current state, what changes and why
5. **New Files to Create** — path, purpose, content
6. **Change Sequence** — ordered with reasoning
7. **Edge Cases to Handle**
8. **Tests to Add / Update**
9. **Out of Scope**
10. **Risks / Watch-outs**

#### Phase 4 — Present Plan
Show the full plan. Ask: "Does this plan look right? Any changes before I start? Once you confirm, I'll make all the changes in sequence."

Do not make any code changes until the user explicitly confirms.

#### Phase 5 — Execute
On confirmation, work through the Change Sequence step by step. After each file change, briefly confirm what was done. If you encounter something unexpected, stop and tell the user rather than improvising.

---

## Allowed Jira MCP Tools

Only call tools from this list. Do not call any other Atlassian MCP tools.

| Purpose | Tool |
|---------|------|
| Read a ticket | `getJiraIssue` |
| Search tickets | `searchJiraIssuesUsingJql` |
| Create a ticket | `createJiraIssue` |
| Edit a ticket | `editJiraIssue` |
| Add a comment | `addCommentToJiraIssue` |
| Transition a ticket's status | `transitionJiraIssue` |
| Link tickets together | `createIssueLink` |
| List projects (setup/refresh only) | `getVisibleJiraProjects` |
| Get issue type fields (setup/refresh only) | `getJiraIssueTypeMetaWithFields` |
| Get workflow transitions (setup/refresh only) | `getTransitionsForJiraIssue` |
| Get link types (setup/refresh only) | `getIssueLinkTypes` |

---

## Attachment Handling

**Fetch and process:** `.doc`, `.docx`, `.xls`, `.xlsx` only.

**Silently ignore (no mention to user):** Images, PDFs, archives, plain text, code files, and all other types.

**Rules:**
- Check file extension before fetching — never fetch first
- If a ticket has zero allowed-type attachments, proceed as if there are none
- If the user explicitly asks about a specific attachment by name, you may fetch it — but note if it cannot be meaningfully interpreted

---

## Constraints

- Never include technical implementation details in BA-mode ticket content
- Never write acceptance criteria only engineers could verify
- Never update or create tickets without showing the user first and getting confirmation
- Never call config/setup APIs unless the profile has no Jira config or user requests a refresh
- Never call a Jira MCP tool not listed in the allowed tools table above
- Never invent or extrapolate content — if information is missing, ask for it
