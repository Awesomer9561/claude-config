# Jira Configuration

## Status
CONFIGURED

> This file is populated automatically on first use of the ba-jira skill.
> To trigger setup, simply ask Claude to read, write, or work on any Jira ticket.
> To force a refresh, say: "refresh my Jira config" or "resync Jira settings".

---

## Last Synced
2026-04-22

## Cloud
- **Site:** probuy.atlassian.net
- **Cloud ID:** c1796e8c-1545-4018-85ad-24c855e49efe

## Projects

| Key | Name | Description |
|-----|------|-------------|
| PRB | Probuy | Primary active project (classic software project). Sole project configured for BA skill use. |

> Note: A second project (`PK` — "PRB Kanban - OLD") exists on the site but is explicitly marked OLD (migrated 30 Nov 2025) and is excluded from this configuration. If work is needed there, request a config refresh.

---

## Issue Types

### PRB

| Type Name | Type ID | Subtask? | Hierarchy | Description |
|-----------|---------|----------|-----------|-------------|
| Epic | 10000 | No | 1 | A big user story that needs to be broken down. Top-level work item. |
| Story | 10008 | No | 0 | Tracks functionality or features expressed as user goals. |
| Task | 10009 | No | 0 | A small, distinct piece of work. |
| Bug | 10011 | No | 0 | A problem or error. |
| Enhancement | 10223 | No | 0 | A new enhancement suggestion for the product. |
| Objective | 10148 | No | 0 | Objective-type work item. |
| Theme | 10149 | No | 0 | Theme-type work item. |
| Sub-task | 10010 | Yes | -1 | A small piece of work that's part of a larger task. Requires a Parent. |

> Working preference: **Epic → Story / Bug / Task / Enhancement → Sub-task** is the natural hierarchy. Objective and Theme are available but rarely used; confirm with user before reaching for them.

---

## Fields by Issue Type

All standard issue types in PRB share a common core set of fields. Differences are called out per type.

### Common fields (Story, Task, Enhancement, Objective, Theme — 17 fields)

| Field Name | Field ID | Required | Type | Options / Notes |
|------------|----------|----------|------|-----------------|
| Summary | summary | **Yes** | text | Ticket title |
| Issue Type | issuetype | **Yes** | issuetype | Set at creation |
| Project | project | **Yes** | project | PRB |
| Description | description | No | rich text (ADF) | Main body content |
| Priority | priority | No (defaults to Medium) | select | See Priority Options below |
| Assignee | assignee | No | user | — |
| Labels | labels | No | string[] | Free-form tags |
| Parent | parent | No | issuelink | Used to link to Epic |
| Components | components | No | component[] | Project-level components (none currently defined) |
| Fix versions | fixVersions | No | version[] | — |
| Linked Issues | issuelinks | No | issuelinks[] | — |
| Attachment | attachment | No | attachment[] | — |
| Due date | duedate | No | date | — |
| Team | customfield_10001 | No | team | Atlassian Teams picker |
| Start date | customfield_10015 | No | date | — |
| Sprint | customfield_10020 | No | sprint[] | Active/future sprint picker |
| Bug Type | customfield_10178 | No | select | UI / Functional / API / Textual — available across types, primarily useful on Bug |

### Bug — Additional fields (19 total)

Adds these to the common set:

| Field Name | Field ID | Required | Type | Options / Notes |
|------------|----------|----------|------|-----------------|
| Environment | environment | No | text | Where the bug was observed |
| Affects versions | versions | No | version[] | — |

### Epic — Field differences (16 total)

Same as the common set **except**:
- **No `parent` field** — Epics are the top of the hierarchy

### Sub-task — Field differences (17 total)

Same as the common set **except**:
- **`parent` is REQUIRED** — a Sub-task must have a parent issue when created

---

## Custom Fields (All Projects)

| Field Name | Field ID | Type | Available Options |
|------------|----------|------|-------------------|
| Team | customfield_10001 | team | Atlassian Teams (auto-complete) |
| Start date | customfield_10015 | date | — |
| Sprint | customfield_10020 | sprint | Active / future sprints |
| Bug Type | customfield_10178 | select | UI (10121), Functional (10122), API (10123), Textual (10124) |

---

## Priority Options

| Name | ID | Notes |
|------|-----|-------|
| Highest | 1 | Emergency / critical production issue |
| High | 2 | Important, should be next sprint |
| Medium | 3 | **Default** — normal backlog priority |
| Low | 4 | Nice to have |
| Lowest | 5 | Backlog / icebox |

---

## Workflow

### PRB

Workflow (observed statuses):
- **To Do** (id 10010, category: To Do)
- **Reopened** (id 4, category: To Do)
- **In Progress** (standard Jira, category: In Progress)
- **In Testing** (id 10235, category: In Progress)
- **STAGING** (id 10162, category: In Progress)
- **Fixed** (id 10236, category: In Progress — used as resolved state)
- **Done** (standard terminal state, category: Done)

### Transition Map (observed from PRB-371 "In Testing" state)

| From Status | Transition ID | Transition Name | To Status |
|-------------|---------------|-----------------|-----------|
| In Testing | 11 | To Do | To Do |
| In Testing | 101 | STAGING | STAGING |
| In Testing | 6 | resolved | Fixed |
| In Testing | 7 | Under reopened | Reopened |

> Transition IDs and names vary by source status. When a ticket needs transitioning, the skill should fetch transitions for that specific ticket via `getTransitionsForJiraIssue` to get the valid next steps. The list above is a sample, not exhaustive.

---

## Issue Link Types

| Name | Inward | Outward | Notes |
|------|--------|---------|-------|
| Blocks | is blocked by | blocks | Most common dependency link |
| Cloners | is cloned by | clones | Duplicate-for-iteration |
| Duplicate | is duplicated by | duplicates | For de-duping tickets |
| Relates | relates to | relates to | Soft, non-dependency relation |
| contains | is contained by | contains | Grouping link |
| Polaris datapoint work item link | added to idea | is idea for | Jira Polaris — product discovery |
| Polaris merge work item link | merged into | merged from | Jira Polaris |
| Polaris work item link | is implemented by | implements | Jira Polaris |

> For day-to-day BA work, use **Blocks**, **Duplicate**, and **Relates**. The Polaris link types are only relevant if the team is using Jira Polaris for discovery.

---

## Components (if used)

### PRB
None currently defined on the project.

---

## Notes / Observations

- **Project style:** PRB is a **classic** (not next-gen) software project, which is why Parent can be used on Story/Task/Bug to link to Epics (rather than the `customfield_10014` "Epic Link" pattern).
- **Custom field note:** `customfield_10178` "Bug Type" is available on Story, Task, Enhancement, Sub-task, and Bug — it's project-wide rather than Bug-specific. Primary use is on Bug issue type.
- **Sub-task constraint:** `parent` is required. Never attempt to create a Sub-task without providing a parent issue key.
- **Epic constraint:** Epics have no `parent` field available. Do not attempt to set one.
- **Priority defaults** to "Medium" on all types that support it, including when omitted on create.
- **Ticket-quality observation:** Existing tickets (e.g. PRB-371) mix business language with technical detail (file paths, code references, log-level specifics). The BA skill should write cleanly in business language only; when rewriting, strip technical implementation detail out of descriptions and acceptance criteria.
- **Workflow naming quirks:** Transition names use inconsistent casing ("STAGING" all-caps, "resolved" lowercase, "Under reopened"). Status "Fixed" is used as the resolved state rather than "Done". Keep this in mind when transitioning — map user intent ("mark this done", "move to staging") to the actual transition names observed per ticket.
- **Second project `PK` is excluded.** If work is needed on the OLD Kanban project, run a config refresh first.
