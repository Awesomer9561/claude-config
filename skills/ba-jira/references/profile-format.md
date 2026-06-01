# Profile Format & Setup Flow

This file defines how per-project ticket system profiles are created, stored, and used by the ba-jira skill.

---

## File Locations

### Per-repo registration (tracked in git)
```
<repo-root>/.ba-tickets.json
```

### Per-project profile (global, outside the skill)
```
~/.claude/ba-tickets/<project-slug>/profile.md
```

---

## `.ba-tickets.json` Schema

Created at the repo root during SETUP MODE. One file per repo, tracked in git.

```json
{
  "project": "probuy",
  "repo": "integration-api",
  "contextPath": "~/.claude/ba-tickets"
}
```

| Field | Purpose |
|-------|---------|
| `project` | Identifies the shared project profile. Multiple repos share one profile. |
| `repo` | Current repo name — used by Planner Mode to scope codebase exploration. |
| `contextPath` | Base directory for profiles. Default: `~/.claude/ba-tickets` |

---

## `profile.md` Schema

One file per project. Stores global, stable ticket system configuration. Never stores time-bound state (sprint names, sprint IDs, active assignees, current counts).

```markdown
---
project: <project-slug>
source: jira          # jira | github | both
configured: YYYY-MM-DD
---

## Registered Repos
- <repo-name> (registered YYYY-MM-DD)
- <repo-name> (registered YYYY-MM-DD)

## Jira Config
Site: <site>.atlassian.net
CloudID: <cloud-id>
ActiveProject: <project-key>
IssueTypes: Epic(<id>), Story(<id>), Task(<id>), Bug(<id>), Sub-task(<id>)
Statuses: <status> → <status> → <status>
CustomFieldIDs: Team(<field-id>), Sprint(<field-id>), StartDate(<field-id>)
LinkTypes: Blocks, Duplicate, Relates
PriorityOptions: Highest(1), High(2), Medium(3), Low(4), Lowest(5)

## GitHub Config
Owner: <org-or-user>
Repo: <repo-name>
DefaultBranch: <branch>
Labels: <label1>, <label2>, <label3>
```

**What belongs here (stable, global):**
- Site URLs, cloud IDs, project keys, issue type IDs
- Workflow status names and general transition flow
- Custom field IDs (e.g. `customfield_10020`) — not their current values
- Available link types, priority options, label names

**What never belongs here (time-bound):**
- Current sprint name or ID
- Active assignees or team members
- Current sprint start/end dates
- Issue counts or status counts

---

## SETUP MODE Flow

Triggered when no `.ba-tickets.json` is found walking up from CWD to `.git/`.

### Step 1 — Detect project name
Walk up from CWD to `.git/`. Use the parent directory name as the default project slug. Ask the user to confirm or change it.

### Step 2 — Check for existing profile
Check if `~/.claude/ba-tickets/<project>/profile.md` already exists.

**If profile exists (another repo already registered):**
- Skip all discovery steps
- Just append this repo to "Registered Repos" in the profile
- Write `.ba-tickets.json` at repo root
- Tell user: "Registered [repo] under project [project] — profile already configured ([source])."
- Done.

**If profile does not exist (first repo in this project):**
- Proceed to Steps 3–6.

### Step 3 — Check for legacy jira-config.md
Check if `skills/ba-jira/references/jira-config.md` exists and has `Status: CONFIGURED`.

If yes → use its data to pre-populate the Jira section without API calls. Skip Jira discovery (Step 4). Map the fields:
- Site/CloudID → directly from config
- ActiveProject → first project key listed
- IssueTypes → from the issue types table (keep name+ID only)
- Statuses → from the workflow section (status names only, no transition IDs)
- CustomFieldIDs → Team, Sprint, StartDate field IDs
- LinkTypes → Blocks, Duplicate, Relates, Contains
- PriorityOptions → Highest(1) through Lowest(5)

If no legacy config → run Jira discovery (Step 4) if Jira MCP is available.

### Step 4 — Detect available systems
Run these checks:
- **GitHub:** Run `gh repo view --json name,owner,url,defaultBranchRef` — if successful, GitHub is available
- **Jira:** Check if Atlassian MCP tools respond (try `getVisibleJiraProjects`) — if successful, Jira is available

If both available → ask: "This project uses which ticket system(s)? Jira / GitHub / Both"
If only one → confirm with user before proceeding.

### Step 5 — Run Jira discovery (only if Jira selected and no legacy config)
Call in sequence:
1. `getVisibleJiraProjects` — identify the active project
2. `getJiraIssueTypeMetaWithFields` for main issue types — record type IDs and custom field IDs (not values)
3. `getTransitionsForJiraIssue` on any existing ticket — record status names only
4. `getIssueLinkTypes` — record available link type names

### Step 6 — Run GitHub discovery (only if GitHub selected)
Run:
1. `gh repo view --json name,owner,url,defaultBranchRef` — get owner, repo, default branch
2. `gh label list --json name` — get available labels

### Step 7 — Write files
1. Create `~/.claude/ba-tickets/<project>/` directory
2. Write `profile.md` using the schema above
3. Write `.ba-tickets.json` at repo root
4. Confirm to user: "Profile created for project [project] ([source]: [summary]). All repos in this project can register by adding .ba-tickets.json pointing here."
