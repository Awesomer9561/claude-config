# Profile Format & Setup Flow

This file defines how per-repo ticket system profiles are created, stored, and used by the ba-jira skill.

---

## File Location

Profiles live globally, outside any repo:

```
~/.claude/ba-tickets/<repo-name>/profile.md
```

The `<repo-name>` is derived from the current repo at runtime — no file is written into the repo itself.

---

## Detecting the Repo Name

Run:
```bash
basename $(git rev-parse --show-toplevel)
```

This gives the repo directory name (e.g. `integration-api`, `instance-front-end`). If no git repo is found, ask the user for a name to use.

---

## `profile.md` Schema

One file per repo. Stores global, stable ticket system configuration. Never stores time-bound state (sprint names, sprint IDs, active assignees, current counts).

```markdown
---
repo: <repo-name>
source: jira          # jira | github | both
configured: YYYY-MM-DD
---

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

Triggered when no profile exists at `~/.claude/ba-tickets/<repo-name>/profile.md`.

### Step 1 — Detect repo name
Run `basename $(git rev-parse --show-toplevel)` to get the repo name.

### Step 2 — Check for existing profile
Check if `~/.claude/ba-tickets/<repo-name>/profile.md` already exists.

**If profile exists:** Load it and proceed — no setup needed.

**If profile does not exist:** Proceed to Steps 3–5.

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

If both available → ask: "This repo uses which ticket system(s)? Jira / GitHub / Both"
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

### Step 7 — Write profile
1. Create `~/.claude/ba-tickets/<repo-name>/` directory if it doesn't exist
2. Write `profile.md` using the schema above
3. Confirm to user: "Profile created for [repo-name] ([source]: [summary])."
