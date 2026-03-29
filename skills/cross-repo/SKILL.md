---
name: cross-repo
description: >
  Cross-repo context sharing and multi-agent planning for multi-repo projects. Maintains a shared
  knowledge base across repositories (e.g., frontend + backend + mobile) so Claude understands the
  full picture in any single repo. Planning mode spawns parallel agents per repo that analyze real
  code and negotiate iteratively until consensus. Trigger on: "cross-repo", "sync context", "project
  context", "plan across repos", "multi-repo", "what does the backend/frontend expect", .crossrepo.json
  detection, feature planning spanning codebases, sharing implementation details between repos, or
  "update context"/"sync" in a configured repo.
---

# Cross-Repo Context Sharing

You are managing a shared knowledge base that lives outside any single repository, enabling Claude
to understand and coordinate work across multiple codebases that belong to the same project.

The fundamental problem: when a developer works in their backend repo, they lose context about what
the frontend expects. When they switch to the frontend, they forget the implementation decisions made
in the backend. This skill solves that by maintaining a persistent, structured context store that
travels between sessions and repos — and when it's time to plan, by spawning specialist agents that
analyze real code and negotiate with each other until they agree.

## How It Works

A **project** is a group of related repositories (e.g., "acme-app" might have repos: `api`,
`web-client`, `mobile-app`, `shared-lib`). Each project has a shared context directory at
`~/.project-contexts/<project-name>/` that any repo in the project can read from and write to.

Each repo gets a small `.crossrepo.json` config file that tells Claude which project it belongs to
and what role it plays.

## Modes of Operation

This skill operates in several modes depending on what the user needs:

---

### 1. Setup Mode (first-time config)

**When:** No `.crossrepo.json` exists in the current working directory (or its parents), OR the user
explicitly asks to set up cross-repo context.

**What to do:**

1. Look for `.crossrepo.json` by walking up from the current directory to find the repo root (look
   for `.git/` as the anchor). If found, skip to Operational Mode.

2. If not found, ask the user:
   - "Which project does this repo belong to?" — List existing projects from `~/.project-contexts/`
     plus an option to create a new one.
   - "What should I call this repo in the project?" — Suggest a name based on the directory name.
   - "What role does this repo play?" — e.g., backend-api, frontend-web, mobile-app, shared-library,
     infrastructure, microservice, etc.
   - "What's the tech stack?" — e.g., Node/Express, React/Next.js, Python/FastAPI, etc.

3. Create `.crossrepo.json` at the repo root:
   ```json
   {
     "project": "acme-app",
     "repo": "api",
     "role": "backend-api",
     "techStack": "Node.js / Express / PostgreSQL",
     "contextPath": "~/.project-contexts"
   }
   ```

4. Initialize the project context directory if it doesn't exist. Use the init scripts:
   - `scripts/init_project.sh <project-name>` — creates the project directory structure
   - `scripts/init_repo.sh <project-name> <repo-name>` — creates the repo's context folder

5. Generate an initial repo summary by scanning the codebase — look at package.json (or equivalent),
   directory structure, route definitions, model definitions, etc. Save to the repo's context folder.

6. Update `project.json` to include this repo in the repos map.

7. **Create or update the repo's CLAUDE.md** to bootstrap cross-repo on session start. This is
   critical — without it, future sessions won't know to load cross-repo context automatically.

   Append (or create) the following block to `CLAUDE.md` at the repo root:

   ```markdown
   ## Cross-Repo Context

   This repo is part of the "{project-name}" project. On session start, load shared context
   and resume from the previous session.

   At the beginning of every conversation:
   1. Read `.crossrepo.json` in this repo root
   2. Load the shared project context from `{contextPath}/{project-name}/`
   3. Read other repos' summaries, API surfaces, and recent changes
   4. Read any active features and plans
   5. Read the 3 most recent session logs from `{contextPath}/{project-name}/sessions/{repo-name}/`
      and briefly recap what was discussed, what's pending, and any open questions
   6. Ask if the user wants to continue where they left off or start fresh

   Before ending a conversation or when the user says "save", "done", "sync", or "bye":
   1. Write a session log to `{contextPath}/{project-name}/sessions/{repo-name}/{date}-{slug}.md`
      capturing: what was discussed, decisions made, what was implemented, what's pending, open
      questions, and any context that affects other repos
   2. Run context sync if any code changes affect other repos

   This ensures continuity across sessions — nothing is lost between conversations.
   ```

   If a `CLAUDE.md` already exists, append the cross-repo block at the end rather than
   overwriting — the file may contain other important project instructions.

8. Print a confirmation with what was set up and suggest next steps (like setting up the other repos).

---

### 2. Context Loading (on session start, triggered by CLAUDE.md)

**When:** The repo's `CLAUDE.md` contains the cross-repo bootstrap instructions (created during
setup). Claude reads `CLAUDE.md` on session start, sees the instruction to load cross-repo context,
and follows through.

**What to do:**

1. Read `.crossrepo.json` to identify the project and repo.
2. Read the project-level files:
   - `project.json` — overall architecture, repo list
   - `architecture.md` — high-level system design
3. Read OTHER repos' summaries (not this repo's own — you already have the code):
   - `repos/<other-repo>/summary.md` — what it does, key patterns
   - `repos/<other-repo>/api-surface.md` — what it exposes
   - `repos/<other-repo>/recent-changes.md` — what changed recently
4. Read active features and recent decisions:
   - `features/*.md` — any in-progress feature work
   - `decisions/*.md` — recent architecture/implementation decisions

This gives you the full picture of what the other repos expect and provide, so you can work in the
current repo with awareness of the broader system.

---

### 3. Context Sync (after significant work)

**When:** The user asks to "sync context", "update context", "save context", or after completing
significant implementation work (a new API endpoint, a new feature, a schema change, etc.). You
should also proactively suggest syncing when you notice the work would affect other repos.

**What to do:**

1. Analyze what changed in the current session — new endpoints, changed data shapes, new events,
   modified contracts, etc.
2. Update this repo's context files:
   - `repos/<this-repo>/summary.md` — if the overall purpose or structure changed
   - `repos/<this-repo>/api-surface.md` — if APIs, events, or exports changed
   - `repos/<this-repo>/recent-changes.md` — always append what was done, with date
3. If a feature is being tracked, update `features/<feature>.md` with implementation progress.
4. If a significant decision was made, create/update `decisions/<decision>.md`.
5. Summarize what was synced and flag anything that other repos might need to act on:
   - "The `/users` endpoint now returns a `displayName` field — the frontend may want to use this."
   - "The auth middleware now expects a `X-Request-ID` header — all clients should send this."

---

### 4. Planning Mode — Multi-Agent Consensus

**When:** The user says "plan", "plan implementation", "plan feature", "cross-repo plan", or asks
something like "how should we implement X across the project?"

This is the most powerful mode. Instead of a single agent reading stale context files, this spawns
a specialist agent per repo. Each agent analyzes its repo's actual codebase, and they iterate
through rounds of cross-communication until they reach consensus on a unified plan.

Think of it as a war room: one specialist per codebase, all sitting at the same table, passing
notes back and forth until they agree on exactly how to build the feature together.

**Read `references/planning-agents.md` for the full agent prompt templates and protocol.**

Here is the high-level orchestration flow:

#### Step 0: Preparation

1. Read `project.json` to discover all repos and their `localPath` values.
2. Verify access to each repo's filesystem. If a repo path is not accessible, ask the user to
   mount it or skip that repo for this planning session.
3. Ask the user what they want to build. Get enough clarity to write a crisp feature brief — a
   2-3 sentence description of the feature, who it's for, and why it matters. Ask clarifying
   questions if the request is vague.
4. Create the scratchpad directory:
   `~/.project-contexts/<project>/scratch/<feature-slug>/`
   This is the shared communication channel where agents read and write to each other.

#### Step 1: Reconnaissance (parallel — all agents at once)

Spawn one subagent per repo, **all in the same turn** so they run in parallel. Each agent:

- Gets the feature brief and the list of all repos in the project
- Has access to its own repo's codebase (via the `localPath`)
- Deeply analyzes the repo: directory structure, existing patterns, relevant code, models, routes,
  services, tests, configs
- Writes a **recon report** to the scratchpad:
  `scratch/<feature>/round-1/<repo-name>-recon.md`

The recon report should cover:
- Current state: what exists today that's relevant to this feature
- Capabilities: what this repo can already do that the feature can build on
- Patterns: how similar things are done in this codebase (so the plan respects existing conventions)
- Constraints: tech limitations, architectural boundaries, things that would be hard to change
- Initial thoughts: early ideas on how this repo's part of the feature could work

#### Step 2: Cross-Talk — Proposals (parallel)

Once all recon reports are written, spawn agents again (one per repo, all parallel). Each agent:

- Reads ALL other repos' recon reports from the scratchpad
- Now understands the full landscape — what every repo can do, how they're structured, what
  patterns they follow
- Writes a **proposal** to the scratchpad:
  `scratch/<feature>/round-2/<repo-name>-proposal.md`

The proposal should cover:
- **What I'll build:** This repo's part of the feature, in detail
- **What I need from each other repo:** Specific contracts, endpoints, events, types, or behaviors
  that this repo requires from others. Be precise — name the endpoint path, the event shape, the
  type definition.
- **What I'll provide to each other repo:** What this repo will expose for others to consume.
  Same level of specificity.
- **Suggested shared contracts:** Any types, interfaces, or schemas that should be agreed upon.
- **Concerns:** Anything in the other repos' recon that worries this agent — potential conflicts,
  mismatched assumptions, performance concerns, etc.

#### Step 3: Negotiation Loop (iterates until consensus)

This is where the magic happens. Agents read each other's proposals, find mismatches, and resolve
them. This loop continues until there are no unresolved conflicts.

**Each round of negotiation:**

Spawn agents again (one per repo, parallel). Each agent:

- Reads ALL proposals and any previous negotiation rounds from the scratchpad
- Identifies **conflicts**: places where what repo A offers doesn't match what repo B needs, or
  where two repos propose incompatible approaches
- Identifies **gaps**: things nobody addressed, edge cases, missing error handling contracts
- Identifies **agreements**: things that are already aligned
- Writes a **negotiation response**:
  `scratch/<feature>/round-N/<repo-name>-negotiation.md`

The negotiation response should cover:
- **Agreements:** "I accept repo-X's proposal for [specific thing]"
- **Counter-proposals:** "Repo-X proposed [X] but I need [Y] instead because [reason]. How about
  [compromise]?"
- **Resolved conflicts:** "The conflict about [topic] is resolved — we'll go with [approach]"
- **Remaining concerns:** Anything still unresolved
- **Status: CONSENSUS or NEEDS_DISCUSSION** — this is critical. Each agent must explicitly declare
  whether they're satisfied with the current state or need another round.

**Consensus check after each round:**

After all agents write their negotiation responses, read them all and check:
- If ALL agents report `CONSENSUS` → proceed to synthesis
- If ANY agent reports `NEEDS_DISCUSSION` → run another negotiation round
- Safety valve: if 5 rounds pass without consensus, escalate to the user. Present the unresolved
  conflicts and ask them to make the call. Don't let agents loop forever.

#### Step 4: Synthesis (single coordinator)

Once all agents reach consensus, produce the final unified plan. This can be done by you (the
orchestrator) since you can read the full scratchpad.

Read all recon reports, proposals, and negotiation rounds. Synthesize into:

**The plan document** — saved to `plans/<feature-name>.md`:

```markdown
# Plan: [Feature Name]

**Created:** [date]
**Status:** Approved by all repo agents
**Consensus reached:** Round [N]

## Overview
[What this feature does and why — from the original brief]

## Repos Involved
[Which repos and what each one's role is]

## Shared Contracts
[The agreed-upon types, interfaces, API schemas, event shapes. This is the most important section —
it's what the agents negotiated to agree on. Include exact type definitions, endpoint signatures,
event payloads.]

## Implementation Sequence
[What order to build things. Include rationale — why this order, what are the dependencies.]

## Per-Repo Implementation Plan

### [repo-name]
**What to build:** [detailed description]
**Key files to create/modify:** [specific paths from the recon]
**Depends on:** [what needs to exist in other repos first]
**Provides to others:** [what this repo will expose once done]
**Implementation notes:** [repo-specific patterns to follow, gotchas from the recon]

[repeat for each repo]

## Risks and Mitigations
[From the negotiation — things that were contentious or tricky]

## Open Questions
[Anything the agents couldn't resolve that needs human input]

## Agent Discussion Log
[Brief summary of key points from the negotiation — what was debated, what compromises were made,
and why. This helps the user understand the reasoning, not just the conclusion.]
```

**The feature tracking file** — saved to `features/<feature-name>.md`:

Initialize with all repos set to "Not Started" and the agreed contracts from the plan.

#### Step 5: Present to User

Show the user:
1. A summary of the plan — the key decisions and contracts
2. How many rounds it took to reach consensus
3. Any notable debates from the negotiation (what the agents disagreed about and how they resolved it)
4. Link to the full plan file
5. Ask if they want to review the raw scratchpad discussion for more detail

The scratchpad persists at `scratch/<feature>/` so the user can always go back and read the full
agent discussion. This transparency matters — the user should be able to understand not just WHAT
was decided but WHY.

---

### 5. Feature Tracking

**When:** The user mentions a specific feature by name that exists in `features/`, or starts
implementing something that was planned.

**What to do:**

1. Load the feature file and any associated plan.
2. Show the user where things stand — what's done, what's pending, what's blocked.
3. As work progresses, update the feature file with:
   - Which repos have completed their part
   - Any changes to the original plan (contracts evolved, new edge cases found)
   - Blockers or questions for other repos
4. When implementation in the current repo deviates from the plan, note why and update the plan so
   the next repo session knows.

---

### 6. Lookup Mode

**When:** The user asks a question about another repo — "what endpoints does the backend have?",
"what auth method does the API use?", "what does the mobile app expect?"

**What to do:**

1. Read the relevant repo's context files.
2. Answer the question from the stored context.
3. Note the timestamp on the context — if it's stale, warn the user it might be outdated and suggest
   syncing from that repo.

---

### 7. Session Memory (persistent conversation context)

Claude sessions are ephemeral — when a session ends, everything discussed is lost. This mode
solves that by capturing structured session logs that persist in the project context directory,
so the next session can pick up exactly where you left off.

#### 7a. Session Resume (on session start)

**When:** Every session start, as part of Context Loading (mode 2).

**What to do:**

After loading cross-repo context, check for recent session logs:
1. Read `sessions/<this-repo>/` directory — list files sorted by date (newest first)
2. Load the **3 most recent** session logs for this repo
3. Also check `sessions/_cross-repo/` for any cross-repo planning sessions
4. Present a brief recap to the user:
   - "Last session (March 20): You were working on the fee module payment flow. You implemented
     the Razorpay webhook handler but left the receipt generation pending. Open question: should
     receipts be generated synchronously or via a background job?"
5. Ask if they want to continue where they left off or start fresh

This is what gives the user the "resume a conversation" experience. The session logs ARE the
long-term memory.

#### 7b. Session Capture (end of session / periodic)

**When:**
- The user says "save session", "end session", "save progress", or "save context"
- Before the user exits (if they say "bye", "done for now", "that's it", etc.)
- Proactively suggest capturing after 15+ minutes of substantive work
- During context sync (mode 3) — always capture a session log alongside the code context update

**What to do:**

Write a session log to: `sessions/<this-repo>/<YYYY-MM-DD>-<slug>.md`

The slug should be a 2-4 word description of what the session was about (e.g., `auth-middleware-refactor`, `fee-payment-bugfix`, `dashboard-charts`).

Use this structure:

```markdown
# Session: [descriptive title]

**Date:** YYYY-MM-DD HH:MM
**Repo:** [repo-name]
**Duration:** [approximate — based on conversation length]

## Summary
[2-3 sentence overview of what this session was about]

## What Was Discussed
[Key topics, questions raised, trade-offs considered. Include enough context that a future
session can understand the reasoning, not just the conclusions.]

- Topic 1: [description of discussion, options considered]
- Topic 2: [description]

## Decisions Made
[Specific decisions with rationale — these are the most important things to preserve]

- **Decision:** [what was decided]
  **Rationale:** [why — this is critical for future sessions to understand intent]
  **Alternatives considered:** [what else was on the table]

## What Was Implemented
[Code changes, files created/modified, features built. Be specific about file paths.]

- Created `src/services/paymentService.ts` — Razorpay webhook handler
- Modified `src/routes/fees.ts` — added POST /fees/webhook endpoint
- Updated Zod schema for payment validation

## What's Still Pending
[Unfinished work, next steps, things deliberately deferred. This is what the next session
should pick up.]

- [ ] Receipt PDF generation after successful payment
- [ ] Email notification to parent on payment confirmation
- [ ] Error handling for Razorpay timeout scenarios

## Open Questions
[Unanswered questions that need human decision or further investigation]

- Should receipt generation be sync (simpler) or async via background job (more resilient)?
- Do we need to support partial payments for fee installments?

## Context for Other Repos
[Anything from this session that affects other repos — flagged so it shows up when the
other repo loads context]

- Backend now has a `/fees/webhook` endpoint — frontend needs to redirect to a success page
  after Razorpay checkout completes
- Payment status enum expanded: added `PROCESSING` state between `PENDING` and `COMPLETED`

## Learned Preferences
[Any user preferences or corrections observed during this session — patterns the user likes,
things they corrected, conventions they established]

- User prefers extracting service logic into separate files rather than inline in route handlers
- Date formatting should always use `formatDate()` from lib/format.ts, never raw date-fns
```

#### 7c. Cross-Repo Session Logs

When a session involves cross-repo planning or work that spans multiple repos, save the log to
`sessions/_cross-repo/<YYYY-MM-DD>-<slug>.md` instead of a repo-specific directory. This ensures
it shows up when loading context from ANY repo in the project.

#### 7d. Session Log Pruning

Session logs accumulate over time. To keep them useful:
- Load only the 3 most recent per repo on session start (+ any cross-repo logs from the past week)
- Older logs remain on disk and can be searched on demand ("what did we discuss about auth last
  month?")
- If the sessions directory exceeds 50 files for a repo, suggest archiving old ones:
  move files older than 30 days to `sessions/<repo>/archive/`

#### 7e. Relationship to Context Sync

Session Memory and Context Sync (mode 3) complement each other:
- **Context Sync** captures WHAT changed — API surfaces, code changes, contracts
- **Session Memory** captures WHY and WHAT'S NEXT — reasoning, decisions, pending work, open questions

Always run both when the user syncs. Context Sync updates the shared project knowledge.
Session Memory preserves the conversational context so nothing is lost between sessions.

---

## Context Directory Structure

```
~/.project-contexts/
  <project-name>/
    project.json            # Project metadata
    architecture.md         # High-level system design
    repos/
      <repo-name>/
        summary.md          # What this repo does, tech stack, key patterns
        api-surface.md      # APIs, events, exports — what other repos consume
        dependencies.md     # What this repo consumes from other repos
        recent-changes.md   # Chronological log of significant changes
    features/
      <feature-name>.md     # Feature tracking across repos
    plans/
      <plan-name>.md        # Cross-repo implementation plans
    decisions/
      <decision-name>.md    # Architecture and implementation decisions
    sessions/               # Persistent session memory (long-term conversation context)
      <repo-name>/          # Per-repo session logs
        2026-03-21-auth-refactor.md
        2026-03-20-fee-payment.md
        archive/            # Auto-archived older sessions
      _cross-repo/          # Sessions spanning multiple repos
        2026-03-21-notification-planning.md
    scratch/
      <feature-slug>/       # Multi-agent planning scratchpad (persisted)
        round-1/            # Recon reports
        round-2/            # Proposals
        round-N/            # Negotiation rounds
```

For detailed examples of every context file format, read `references/context-format.md`.

### project.json format

```json
{
  "name": "acme-app",
  "description": "Acme's main product — a SaaS platform for widget management",
  "repos": {
    "api": {
      "role": "backend-api",
      "techStack": "Node.js / Express / PostgreSQL",
      "localPath": "/Users/dev/projects/acme-api",
      "description": "REST API server"
    },
    "web": {
      "role": "frontend-web",
      "techStack": "React / Next.js / TypeScript",
      "localPath": "/Users/dev/projects/acme-web",
      "description": "Web client SPA"
    }
  },
  "updatedAt": "2026-03-21T10:00:00Z"
}
```

## When to Proactively Suggest Syncing

After any of these, gently suggest the user sync context:
- Adding or modifying an API endpoint
- Changing a database schema or data model
- Modifying authentication or authorization logic
- Changing shared types, interfaces, or contracts
- Implementing a feature that was planned cross-repo
- Making a decision that affects how repos interact

The suggestion should be brief: "This changes the API surface — want me to sync the cross-repo
context so the frontend session picks this up?"

## Important Principles

**Don't over-index on your own context.** When working in repo A, the context files from repo B are
your source of truth for what B does. Don't hallucinate or assume — if the context doesn't say, tell
the user you don't know and suggest they sync from repo B.

**Keep context files focused and current.** These files are read by future Claude sessions, so they
need to be clear and accurate. Don't dump entire codebases into them — summarize the important parts.
A good repo summary is 50-150 lines. A good API surface doc lists endpoints with their shapes, not
entire OpenAPI specs.

**Plans are living documents.** When implementation reveals that the plan needs to change (and it
always does), update the plan. The next repo session will read the updated plan.

**Timestamps matter.** Always include dates in recent-changes.md entries and update `updatedAt` in
project.json. If context is more than a week old, mention this to the user so they can decide if
it's still trustworthy.

**Respect the user's setup.** The `contextPath` in `.crossrepo.json` can be overridden if the user
wants context stored somewhere other than `~/.project-contexts/`. Always read this field rather than
hardcoding the path.

**The scratchpad is the source of truth for planning decisions.** It shows how agents reasoned,
what they disagreed about, and why they settled on particular contracts. Preserve it — it's
invaluable when the user later asks "why did we decide to do it this way?"
