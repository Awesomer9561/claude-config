# GitHub Handler

All GitHub-specific action logic for the ba-jira skill. Read this file when the profile routes to GitHub.

Before any action: the caller has already loaded the profile. Use the GitHub Config section from `profile.md` (owner, repo, labels). All operations use the `gh` CLI via Bash — no MCP tools.

---

## Action: READ

```bash
gh issue view <number> --json title,body,labels,state,assignees,comments,milestone
```

Present in this order: Title → State → Labels → Assignees → Overview → What needs to happen (body) → Acceptance Criteria (if present in body) → Comments (if relevant) → Gaps

Run a brief gap check after presenting — note: missing overview, missing acceptance criteria, vague or empty body, no labels set.

Offer: "Want me to assess this, improve it, or write QA scenarios for it?"

---

## Action: WRITE

Read `references/ticket-templates.md` for the GitHub Issue Template.
Read `references/ba-principles.md` before writing.

1. Identify issue type from context: bug, feature/enhancement, spike, task (ask if unclear)
2. Ask targeted clarifying questions if key information is missing
3. Draft the issue using the GitHub Issue Template from `references/ticket-templates.md`
4. Show the draft to the user for review
5. On confirmation, run:
   ```bash
   gh issue create --title "<title>" --body "<body>" [--label "<label>"] [--assignee "<user>"]
   ```
6. Report the created issue number and URL to the user

**Minimum info needed before writing:**
- Who is the user / stakeholder affected?
- What do they need to be able to do?
- What is the business reason / value?
- What does "done" look like to the business?

---

## Action: ASSESS

GitHub issues are less structured than Jira tickets, so a lighter assessment is used rather than the full 21-point scorecard.

Assess on these 5 dimensions:

| Dimension | What to check |
|-----------|--------------|
| **Clarity** | Is the title specific? Does the body explain the need clearly? |
| **Completeness** | Is there a problem statement? Is there at least one acceptance criterion or definition of done? |
| **Business Value** | Is the "why" present? Would a non-technical stakeholder understand why this matters? |
| **Testability** | Can the acceptance criteria be verified without reading the code? |
| **Scope** | Is the issue focused on one thing, or is it trying to do too much? |

Score each dimension: **Good / Needs Work / Missing**.

Overall verdict: **Ready / Needs Work / Not Ready**

List specific improvements for each dimension that scored below Good.

Ask: "Want me to rewrite this issue based on these findings?"

---

## Action: REWRITE

1. Fetch the current issue if not already loaded:
   ```bash
   gh issue view <number> --json title,body,labels,state,assignees
   ```
2. Run ASSESS internally (do not show unless asked)
3. Read `references/ticket-templates.md` GitHub Issue Template
4. Read `references/ba-principles.md`
5. Rewrite title and body preserving the original intent but applying BA standards
6. Show before and after clearly
7. On confirmation:
   ```bash
   gh issue edit <number> --title "<new title>" --body "<new body>"
   ```

---

## Action: UPDATE

Show the user the current field values before making any change.

| What to update | Command |
|---------------|---------|
| Title | `gh issue edit <number> --title "<title>"` |
| Body | `gh issue edit <number> --body "<body>"` |
| Add a label | `gh issue edit <number> --add-label "<label>"` |
| Remove a label | `gh issue edit <number> --remove-label "<label>"` |
| Add an assignee | `gh issue edit <number> --add-assignee "<user>"` |
| Remove an assignee | `gh issue edit <number> --remove-assignee "<user>"` |
| Close issue | `gh issue close <number>` |
| Reopen issue | `gh issue reopen <number>` |

Always show proposed changes. Ask for confirmation before running the command.

---

## Action: QA SCENARIOS

Read `references/qa-scenario-guide.md` before writing scenarios.

1. Fetch the issue body to read its acceptance criteria
2. Produce scenarios in business language covering:
   - Happy path
   - Negative / error cases
   - Edge cases
   - Business rules implied by acceptance criteria
3. Format using Given / When / Then in plain English
4. Show the scenarios to the user for review
5. On confirmation, post as a comment:
   ```bash
   gh issue comment <number> --body "<scenarios>"
   ```

---

## Action: SUMMARISE

Write a business-oriented summary of what was implemented and post it as a GitHub issue comment.

Read `references/ba-principles.md` before composing.

1. **Load the issue** — run `gh issue view <number> --json title,body,labels,state` to understand the original requirement. If no number provided, ask for one.
2. **Gather what was built** — if the user hasn't described it, ask: "What was delivered? Describe what changed from a user's perspective."
3. **Compose the summary** using the template below — no technical jargon.
4. **Show for review** — display the full comment. Ask: "Shall I post this to #[number]?"
5. **Post** — on confirmation:
   ```bash
   gh issue comment <number> --body "<summary>"
   ```

### Summary Comment Template

```
## ✅ Implementation Summary

**Issue:** #[NUMBER] — [Title]
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

#### Phase 1 — Load the Issue
1. Run `gh issue view <number> --json title,body,labels,state,assignees,comments,milestone`
2. Extract: business goal, acceptance criteria (from body), scope boundaries
3. If the issue has no acceptance criteria or is too vague, pause — offer to run ASSESS or REWRITE first.

#### Phase 2 — Understand the Codebase
Use the `repo` field from `.ba-tickets.json` to confirm which repo you're in. Explore the codebase to ground the plan in reality.

Use file and search tools to understand:
- Project structure, major modules, entry points
- Area of code most likely affected
- Existing patterns used in similar features
- Data models, state, types relevant to the issue
- User-facing entry points (routes, screens, components)
- Existing tests covering the affected area

If you cannot find the relevant area, say so and ask the user to point you to the right place.

#### Phase 3 — Generate the Implementation Plan
Read `references/planner-guide.md` for the full plan format.

Produce a structured plan covering:
1. **Issue Summary** — what the issue asks for in plain terms
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

## Allowed `gh` CLI Commands

Only use commands from this list. No `gh pr`, `gh repo`, `gh workflow`, or destructive commands.

| Action | Command |
|--------|---------|
| Read an issue | `gh issue view <number> --json title,body,labels,state,assignees,comments,milestone` |
| List / search issues | `gh issue list --search "<query>" --json number,title,state,labels` |
| Create an issue | `gh issue create --title "..." --body "..." [--label "..."] [--assignee "..."]` |
| Edit title or body | `gh issue edit <number> --title "..." --body "..."` |
| Add a label | `gh issue edit <number> --add-label "<label>"` |
| Remove a label | `gh issue edit <number> --remove-label "<label>"` |
| Add an assignee | `gh issue edit <number> --add-assignee "<user>"` |
| Remove an assignee | `gh issue edit <number> --remove-assignee "<user>"` |
| Close an issue | `gh issue close <number>` |
| Reopen an issue | `gh issue reopen <number>` |
| Add a comment | `gh issue comment <number> --body "..."` |
| Setup: detect repo | `gh repo view --json name,owner,url,defaultBranchRef` |
| Setup: list labels | `gh label list --json name` |

---

## Constraints

- Never include technical implementation details in any issue content produced in BA mode
- Never write acceptance criteria only engineers could verify
- Never create, edit, or comment on issues without showing the user first and getting confirmation
- Never run `gh` commands outside the allowed list above
- Never delete issues or labels
- Never invent or extrapolate content — if information is missing, ask for it
