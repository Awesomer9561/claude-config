# Profile Format & Setup Flow

This file defines how ticket system profiles — shared per project family, or per single repo — are created, stored, and used by the ba-jira skill.

---

## File Location

Profiles live globally, outside any repo. There are two kinds:

```
~/.claude/ba-tickets/_projects/<project>/profile.md   # shared by a project family — the normal case
~/.claude/ba-tickets/<repo-name>/profile.md           # single-repo override — rare, hand-made only
```

Repos in the same project almost always share a Jira site, project key, issue types, and
workflow, so the **project-family profile is the default**. A per-repo profile exists only
when one repo genuinely diverges from its siblings, and is never written automatically.

Nothing is written into the repo itself in either case.

---

## Detecting Repo and Project

```bash
ROOT=$(git rev-parse --show-toplevel)
basename "$ROOT"                          # repo name, e.g. ProBuy.IdentityService
cat "$ROOT/.crossrepo.json" 2>/dev/null   # project family, e.g. {"project": "probuy", ...}
```

- `.crossrepo.json` present → its `project` field is the family key. Use the shared path.
- `.crossrepo.json` absent → the repo stands alone. Use the per-repo path.
- No git repo at all → ask the user which name to use.

---

## `profile.md` Schema

One file per project family (or per repo, for a standalone repo). Stores global, stable ticket system configuration. Never stores time-bound state (sprint names, sprint IDs, active assignees, current counts).

Use `project:` in the frontmatter for a family profile and `repo:` for a single-repo profile —
otherwise the schema is identical. A family profile should also list its member repos and roles.

```markdown
---
project: <project>    # family profile — or `repo: <repo-name>` for a standalone repo
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

Triggered when neither profile path resolves — no `_projects/<project>/profile.md` for the
repo's family, and no `<repo-name>/profile.md` override. See **File Location** above.

### Step 1 — Detect repo name and project family
Run the commands under **Detecting Repo and Project** above. Record both the repo name and,
if `.crossrepo.json` is present, the `project` field.

### Step 2 — Check for an existing profile
Check, in order:
1. `~/.claude/ba-tickets/<repo-name>/profile.md` — hand-made override
2. `~/.claude/ba-tickets/_projects/<project>/profile.md` — family profile

**If either exists:** Load the first hit and proceed — no setup needed.

**If neither exists:** Proceed to Steps 3–5. **Write the result to the family path when a
`project` key was found**, and only to the per-repo path when the repo has no family.
A sibling repo joining an existing family must reuse that family's profile, never fork its own.

### Step 3 — Check for legacy jira-config.md

> **Scope guard — read first.** `references/jira-config.md` describes **one specific Jira site**
> (`probuy.atlassian.net`, project `PRB`). It predates project-family profiles and is *not*
> generic. Only use it to seed a profile when the current repo actually belongs to that site —
> i.e. `.crossrepo.json` says `"project": "probuy"`, or the user confirms the repo uses
> `probuy.atlassian.net`. For **any other project family** (e.g. `student-tracker`, `instance`),
> ignore this file entirely and run live discovery at Step 4. Seeding an unrelated family from it
> silently points a whole set of repos at the wrong Jira site.
>
> The `probuy` family profile already exists at `~/.claude/ba-tickets/_projects/probuy/profile.md`,
> so in practice this legacy path should no longer trigger for ProBuy repos either.

Check if `skills/ba-jira/references/jira-config.md` exists and has `Status: CONFIGURED`.

If yes **and the scope guard above passes** → use its data to pre-populate the Jira section without API calls. Skip Jira discovery (Step 4). Map the fields:
- Site/CloudID → directly from config
- ActiveProject → first project key listed
- IssueTypes → from the issue types table (keep name+ID only)
- Statuses → from the workflow section (status names only, no transition IDs)
- CustomFieldIDs → Team, Sprint, StartDate field IDs
- LinkTypes → Blocks, Duplicate, Relates, Contains
- PriorityOptions → Highest(1) through Lowest(5)

If no legacy config, **or the scope guard excluded it** → run Jira discovery (Step 4) if Jira MCP is available.

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
1. Pick the destination:
   - **Project family found** (`.crossrepo.json` has a `project` key) → `~/.claude/ba-tickets/_projects/<project>/`
   - **No family** → `~/.claude/ba-tickets/<repo-name>/`
2. Create the directory if it doesn't exist
3. Write `profile.md` using the schema above. For a family profile, use `project:` in the
   frontmatter instead of `repo:`, and list the member repos with their roles.
4. Confirm to user:
   - Family: "Profile created for the [project] family ([source]: [summary]) — shared by N repos."
   - Single repo: "Profile created for [repo-name] ([source]: [summary])."
