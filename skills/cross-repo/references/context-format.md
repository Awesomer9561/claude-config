# Context Format Reference

This document provides full examples of each context file type so Claude can produce consistent,
well-structured context documents.

## Table of Contents

1. [project.json](#projectjson)
2. [architecture.md](#architecturemd)
3. [Repo summary.md](#repo-summarymd)
4. [Repo api-surface.md](#repo-api-surfacemd)
5. [Repo dependencies.md](#repo-dependenciesmd)
6. [Repo recent-changes.md](#repo-recent-changesmd)
7. [Feature tracking file](#feature-tracking)
8. [Implementation plan](#implementation-plan)
9. [Decision record](#decision-record)

---

## project.json

```json
{
  "name": "taskflow",
  "description": "A project management SaaS — Kanban boards, time tracking, team collaboration",
  "repos": {
    "api": {
      "role": "backend-api",
      "techStack": "Python / FastAPI / PostgreSQL / Redis",
      "localPath": "/Users/dev/work/taskflow-api",
      "description": "REST + WebSocket API server"
    },
    "web": {
      "role": "frontend-web",
      "techStack": "TypeScript / React / Next.js / TanStack Query",
      "localPath": "/Users/dev/work/taskflow-web",
      "description": "Web client application"
    },
    "mobile": {
      "role": "mobile-app",
      "techStack": "TypeScript / React Native / Expo",
      "localPath": "/Users/dev/work/taskflow-mobile",
      "description": "iOS and Android mobile app"
    },
    "shared": {
      "role": "shared-library",
      "techStack": "TypeScript",
      "localPath": "/Users/dev/work/taskflow-shared",
      "description": "Shared types, validation schemas, and utilities"
    }
  },
  "createdAt": "2026-01-15T09:00:00Z",
  "updatedAt": "2026-03-21T14:30:00Z"
}
```

---

## architecture.md

```markdown
# TaskFlow Architecture

## Overview
TaskFlow is a project management platform with real-time collaboration. The system follows a
client-server architecture with a single API serving multiple clients (web and mobile).

## Communication Patterns
- **REST** for CRUD operations and queries
- **WebSocket** for real-time updates (board changes, comments, presence)
- **Redis pub/sub** bridges WebSocket events across API server instances

## Authentication
- JWT-based auth, tokens issued by the API
- Access tokens (15 min) + refresh tokens (7 days)
- OAuth2 support for Google and GitHub SSO

## Data Flow
1. Clients authenticate via `/auth/login` or `/auth/oauth`
2. CRUD operations go through REST endpoints
3. Mutations broadcast WebSocket events to relevant subscribers
4. Clients maintain optimistic UI and reconcile on WebSocket confirmation

## Key Shared Contracts
- All request/response types are defined in `taskflow-shared` and used by both API and clients
- Validation schemas (Zod) are shared — API validates incoming, clients validate forms
- WebSocket event types are defined in `shared/events.ts`

## Infrastructure
- API deployed on Railway
- Web client on Vercel
- PostgreSQL on Neon
- Redis on Upstash
```

---

## Repo summary.md

```markdown
# taskflow-api — Repo Summary

**Updated:** 2026-03-20

## Purpose
The main backend API for TaskFlow. Handles all business logic, data persistence, authentication,
and real-time event broadcasting. Serves both the web and mobile clients.

## Tech Stack
- **Language:** Python 3.12
- **Framework:** FastAPI with Pydantic v2
- **Database:** PostgreSQL via SQLAlchemy 2.0 (async)
- **Cache/PubSub:** Redis via redis-py
- **Auth:** PyJWT, passlib for password hashing
- **Testing:** pytest + httpx for async test client

## Architecture
```
src/
  api/
    routes/         # Route handlers grouped by domain (boards, tasks, users, auth)
    middleware/      # Auth, CORS, request logging, rate limiting
    dependencies/   # FastAPI dependency injection (db sessions, current user)
  core/
    models/         # SQLAlchemy ORM models
    schemas/        # Pydantic request/response schemas
    services/       # Business logic layer
    events/         # WebSocket event definitions and broadcaster
  db/
    migrations/     # Alembic migrations
    seeds/          # Development seed data
```

## Key Patterns
- **Service layer pattern:** Routes call services, services contain business logic, services call
  the ORM. Routes never touch the database directly.
- **Dependency injection:** Database sessions, auth context, and feature flags injected via FastAPI
  depends.
- **Event-driven updates:** All mutations emit events through the broadcaster. WebSocket clients
  subscribe to relevant channels (e.g., `board:{id}`).

## Entry Points
- `src/main.py` — FastAPI app creation and startup
- `src/api/routes/` — All HTTP endpoints
- `src/core/events/broadcaster.py` — WebSocket event hub
```

---

## Repo api-surface.md

```markdown
# taskflow-api — API Surface

**Updated:** 2026-03-20

## Authentication

### POST /auth/login
Request: `{ email: string, password: string }`
Response: `{ accessToken: string, refreshToken: string, user: User }`

### POST /auth/refresh
Request: `{ refreshToken: string }`
Response: `{ accessToken: string, refreshToken: string }`

### POST /auth/oauth/:provider
Request: `{ code: string, redirectUri: string }`
Response: `{ accessToken: string, refreshToken: string, user: User }`

## Boards

### GET /boards
Response: `Board[]` — all boards the current user has access to

### POST /boards
Request: `{ name: string, description?: string }`
Response: `Board`

### GET /boards/:id
Response: `Board` with `columns: Column[]` and `members: User[]`

### PUT /boards/:id
Request: `Partial<{ name, description, settings }>`
Response: `Board`

## Tasks

### GET /boards/:boardId/tasks
Query: `?status=active&assignee=userId&search=term`
Response: `{ tasks: Task[], total: number }`

### POST /boards/:boardId/tasks
Request: `{ title: string, columnId: string, description?: string, assigneeId?: string }`
Response: `Task`

### PATCH /tasks/:id
Request: `Partial<Task>` — supports partial updates
Response: `Task`

### POST /tasks/:id/move
Request: `{ columnId: string, position: number }`
Response: `Task` — also emits `task.moved` WebSocket event

## WebSocket Events

Connect: `ws://host/ws?token=<accessToken>`

### Inbound (client -> server)
- `subscribe` — `{ channel: "board:{id}" }` — join a board's update stream
- `unsubscribe` — `{ channel: "board:{id}" }` — leave a channel
- `presence.heartbeat` — `{ boardId: string }` — keep-alive for online indicators

### Outbound (server -> client)
- `task.created` — `{ task: Task, boardId: string }`
- `task.updated` — `{ task: Task, boardId: string, changes: string[] }`
- `task.moved` — `{ taskId: string, fromColumn: string, toColumn: string, position: number }`
- `board.updated` — `{ board: Board, changes: string[] }`
- `presence.update` — `{ boardId: string, users: { id, status }[] }`

## Shared Types

Key types consumed by clients (defined in taskflow-shared, mirrored in Pydantic schemas):
- `User: { id, email, name, avatarUrl, role }`
- `Board: { id, name, description, ownerId, settings, createdAt, updatedAt }`
- `Column: { id, boardId, name, position, color }`
- `Task: { id, boardId, columnId, title, description, assigneeId, position, labels, dueDate, createdAt, updatedAt }`
```

---

## Repo dependencies.md

```markdown
# taskflow-web — Dependencies

**Updated:** 2026-03-20

## What This Repo Consumes

### From: taskflow-api
- **REST endpoints:** All board and task CRUD endpoints (see api's api-surface.md)
- **WebSocket:** Connects to `/ws` for real-time updates on boards
- **Auth flow:** Calls `/auth/login`, `/auth/refresh`, `/auth/oauth/:provider`

### From: taskflow-shared
- **Types:** Imports `User`, `Board`, `Task`, `Column` types for type safety
- **Validation:** Uses Zod schemas for form validation (same schemas API uses for input validation)
- **Event types:** Uses `WebSocketEvent` union type for type-safe event handling

### External Services
- **Vercel:** Deployment and preview environments
- **Sentry:** Error tracking (DSN configured via env var)
```

---

## Repo recent-changes.md

```markdown
# taskflow-api — Recent Changes

## 2026-03-20 — Added task labels support

**What:** New `labels` field on tasks, plus CRUD endpoints for label definitions.
**Why:** Users want to categorize and filter tasks by custom labels.
**Contract:**
- Task now includes `labels: string[]` (array of label IDs)
- New endpoints: `GET/POST /boards/:id/labels`, `DELETE /labels/:id`
- Label shape: `{ id, boardId, name, color }`
**Impact on other repos:** Web and mobile need to render labels on task cards and add label
management UI to board settings.

---

## 2026-03-18 — Rate limiting on auth endpoints

**What:** Added rate limiting middleware to `/auth/*` routes — 5 attempts per minute per IP.
**Why:** Prevent brute-force login attacks.
**Contract:** Returns 429 with `{ error: "rate_limited", retryAfter: seconds }` when exceeded.
**Impact on other repos:** Clients should handle 429 responses gracefully and show the user a
message to wait before retrying.

---

## 2026-03-15 — WebSocket presence system

**What:** New presence tracking via WebSocket. Clients send heartbeats, server broadcasts who's
online per board.
**Why:** Show "online now" indicators on board view.
**Contract:**
- Client sends `presence.heartbeat` every 30 seconds with `{ boardId }`
- Server broadcasts `presence.update` with `{ boardId, users: [{ id, status }] }`
- Status is "online" (heartbeat within 60s) or "away" (no recent heartbeat)
**Impact on other repos:** Web and mobile should implement heartbeat sending and render presence
indicators on the board member list.
```

---

## Feature tracking

```markdown
# Feature: Task Labels

**Status:** In Progress
**Created:** 2026-03-19
**Updated:** 2026-03-20

## Overview
Allow users to create custom labels per board and assign them to tasks for categorization
and filtering.

## Implementation Status

| Repo | Status | Notes |
|------|--------|-------|
| shared | Done | Added `Label` type and Zod schema |
| api | Done | Endpoints, DB migration, service layer complete |
| web | In Progress | Label rendering on cards done, management UI pending |
| mobile | Not Started | Waiting for web to validate the UX patterns |

## Shared Contract
```typescript
type Label = {
  id: string;
  boardId: string;
  name: string;
  color: string; // hex color
};
```

## API Endpoints
- `GET /boards/:id/labels` — list board's labels
- `POST /boards/:id/labels` — create label `{ name, color }`
- `DELETE /labels/:id` — delete label (removes from all tasks)
- Tasks: `labels` field added (array of label IDs), filterable via `?labels=id1,id2`

## Open Questions
- Should we limit labels per board? API currently has no limit.
- Color picker UX — free-form hex or preset palette? Web team to decide.

## Changes From Original Plan
- Originally planned label groups/categories — deferred to v2 for simplicity.
```

---

## Implementation plan

```markdown
# Plan: Real-Time Notifications System

**Created:** 2026-03-21
**Status:** Planning

## Overview
Add in-app notifications so users see when they're assigned a task, mentioned in a comment,
or when a due date is approaching. Notifications should appear in real-time via WebSocket and
also be persisted for a notification inbox.

## Repos Involved
1. **shared** — Notification types and schemas
2. **api** — Notification storage, generation logic, WebSocket broadcasting
3. **web** — Notification bell, dropdown, inbox page
4. **mobile** — Push notification integration + in-app notification UI

## Implementation Sequence

### Phase 1: Foundation (shared + api)
1. **shared:** Define `Notification` type, event schemas, notification category enum
2. **api:** Create notifications table, migration, model
3. **api:** Notification service — create, mark-read, list with pagination
4. **api:** Hook into existing events (task.assigned, comment.mentioned) to generate notifications
5. **api:** New WebSocket event `notification.new` broadcasting to user channels

### Phase 2: Web Client
1. **web:** Notification bell component with unread count badge
2. **web:** Dropdown showing recent notifications
3. **web:** Full notification inbox page with filters and mark-all-read
4. **web:** WebSocket listener for `notification.new` — update bell count in real-time

### Phase 3: Mobile
1. **mobile:** Register for push notifications (FCM/APNs)
2. **api:** Push notification sender service (triggered alongside WebSocket broadcast)
3. **mobile:** In-app notification UI matching web patterns
4. **mobile:** Notification preferences screen

## Shared Contract
```typescript
type Notification = {
  id: string;
  userId: string;
  type: "task_assigned" | "comment_mention" | "due_date_reminder";
  title: string;
  body: string;
  resourceType: "task" | "comment" | "board";
  resourceId: string;
  read: boolean;
  createdAt: string;
};
```

## Risks and Open Questions
- **Notification volume:** High-activity boards could flood users. Need a batching/digest strategy.
- **Push notification permissions:** Mobile needs to handle the case where user denies push access.
- **Email notifications:** Out of scope for v1 but the notification service should be designed to
  support email as a future channel.
```

---

## Decision record

```markdown
# Decision: Use WebSocket channels per user for notifications

**Date:** 2026-03-21
**Status:** Accepted
**Participants:** Backend team, Frontend team

## Context
We're adding notifications and need to decide how to route them via WebSocket. Options were:
1. Per-user channels (each user subscribes to `user:{id}`)
2. Piggyback on existing board channels (notifications sent alongside board events)
3. Separate notification WebSocket connection

## Decision
Per-user channels. Each client subscribes to `user:{id}` on connect. Notification events are
broadcast to the user's channel regardless of which board they're viewing.

## Rationale
- Board channels don't work because notifications can come from boards you're not currently viewing
- A separate WS connection is wasteful and complicates reconnection logic
- Per-user channels are simple, efficient, and the server already supports channel subscriptions

## Consequences
- API needs a new channel subscription type (`user:{id}` in addition to `board:{id}`)
- Clients should subscribe to their user channel immediately on WebSocket connect
- The presence system is unaffected (it stays on board channels)
```
