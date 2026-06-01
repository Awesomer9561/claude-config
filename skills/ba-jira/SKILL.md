---
name: ba-jira
description: Senior BA skill for Jira and GitHub work item interactions — including a Planner mode that turns tickets into executable code implementation plans. ALWAYS use this skill whenever the user mentions any Jira ticket, GitHub issue, work item, user story, bug, epic, task, subtask, or any issue key (e.g. ABC-123, PROJ-456, #123, owner/repo#123, github.com issue URLs). Triggers on BA phrases like "show me this ticket", "read ticket", "read issue", "write a story", "create a bug", "create a Jira issue", "create a github issue", "assess this ticket", "review this work item", "is this sprint ready", "break down this epic", "improve this ticket", "write acceptance criteria", "write AC", "create QA scenarios", "score this ticket", "rewrite this ticket". Triggers on Planner phrases like "plan this ticket", "implement this ticket", "build this", "plan the implementation for", "what do I need to change for", "create an implementation plan for", "plan [ticket-key]", "implement [ticket-key]", "plan #[number]". Triggers on Summary phrases like "summarise what was done", "write an implementation summary", "add a summary comment", "document what was built", "post a summary to [ticket-key]", "post a summary to #[number]". Claude must NEVER directly access Jira or GitHub issues without going through this skill.
---

# BA Ticket Skill — Router

This skill handles both Jira tickets and GitHub issues. It works in two modes:

**BA Mode** — Senior Business Analyst. Read, write, assess, and improve work items in business language. No technical jargon.

**Planner Mode** — Senior engineer and technical planner. Read a ticket, explore the codebase, produce a step-by-step implementation plan, then execute on confirmation.

---

## Step 1 — Load Profile

Walk up from CWD to `.git/` looking for `.ba-tickets.json`.

**If found:**
- Read `.ba-tickets.json` to get `project`, `repo`, and `contextPath`
- Load `<contextPath>/<project>/profile.md`
- Use the profile for all subsequent steps

**If not found:**
- Enter SETUP MODE: read `references/profile-format.md` and follow the full setup flow
- Do not proceed until the profile is created and loaded

---

## Step 2 — Detect Source

Read the `source` field from `profile.md`:

| Profile source | Routing |
|----------------|---------|
| `jira` | Always route to Jira handler |
| `github` | Always route to GitHub handler |
| `both` | Inspect user input to determine system (see below) |

**When source is `both`, detect from input:**
- Jira key pattern (e.g. `PRB-123`, `ABC-456`) → **Jira**
- GitHub issue number (`#123`), scoped reference (`owner/repo#123`), or GitHub URL → **GitHub**
- BA phrase without a key (e.g. "create a github issue", "open a jira story") → use the explicit system name in the phrase
- Ambiguous (e.g. "plan #123" with no context) → ask: "Is this a Jira ticket or a GitHub issue?"

---

## Step 3 — Detect Intent

Map the user's request to one of these actions:

| User Intent | Action |
|---|---|
| "show me / get / read [key or #number]" | READ |
| "write / create a [type]" | WRITE |
| "assess / review / score this" | ASSESS |
| "improve / rewrite this" | REWRITE |
| "break down this epic" | DECOMPOSE *(Jira only)* |
| "is this sprint ready?" | SPRINT READINESS *(Jira only)* |
| "write QA scenarios / test cases" | QA SCENARIOS |
| "update / edit this" | UPDATE |
| "plan / implement / build [key or #number]" | PLAN |
| "summarise / document what was done for [key or #number]" | SUMMARISE |

If intent is ambiguous, ask before proceeding.

---

## Step 4 — Delegate to Handler

Read the relevant handler file and follow its instructions exactly:

- **Jira** → `references/jira-handler.md`
- **GitHub** → `references/github-handler.md`

Also load supporting references when the handler instructs:

| Reference | Load When |
|---|---|
| `references/ticket-templates.md` | WRITE, REWRITE, DECOMPOSE |
| `references/assessment-framework.md` | ASSESS, REWRITE |
| `references/qa-scenario-guide.md` | QA SCENARIOS |
| `references/ba-principles.md` | WRITE, REWRITE, SUMMARISE, any ticket content |
| `references/planner-guide.md` | PLAN |
| `references/profile-format.md` | SETUP MODE or profile refresh |

---

## What You Never Do

- Never access Jira MCP tools or GitHub CLI directly — always go through the handler files
- Never perform any action not defined in the handler files
- Never skip Step 1 (profile load) — the profile determines which system to use
- Never invent or extrapolate content — if information is missing, ask for it
- Never make code changes (Planner Mode) without explicit user confirmation of the plan
