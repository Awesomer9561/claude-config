---
name: code-reviewer
description: Global code review gate that runs before every commit. Learns per-project conventions, reviews changes for quality/security/performance, and blocks commits until issues are resolved. Use when user says "commit changes", "review changes", "review code", "/commit", "/review", or any request to commit or review.
---

# Code Reviewer

A stack-agnostic code review skill that enforces quality gates before commits. Works across all repositories (frontend, backend, fullstack) and learns project-specific conventions.

## When to Activate

- User says "commit changes", "commit", "review changes", "review code"
- User invokes `/commit` or `/review`
- Before any `git commit` operation
- User asks to "check my changes" or "look at what I changed"

## Workflow

### Phase 1: Project Detection

1. Run `git rev-parse --show-toplevel` to get the repo root path
2. Derive the project name from the repo's folder name (basename of the repo root)
3. Check if a profile exists at `~/.claude/code-reviewer/projects/{repo-folder-name}/profile.md`
4. If no profile exists, run the **Init Flow** (Phase 1b) before proceeding
5. If profile exists, read it and load it as context for the review

### Phase 1b: Init Flow (First Time per Repo)

When no profile exists for this project, tell the user: "No project profile found. Scanning codebase to learn conventions..."

**Scan the following (read-only):**
- Tech stack files: `*.csproj`, `package.json`, `go.mod`, `requirements.txt`, `Cargo.toml`, `pom.xml`, `build.gradle`
- Directory structure: `ls` the first 3 levels of the source tree
- Lint/format configs: `.eslintrc*`, `.prettierrc*`, `tsconfig.json`, `.editorconfig`, `pyproject.toml`, `.rubocop.yml`, `stylecop.json`, `Directory.Build.props`
- Project instructions: `CLAUDE.md`, `README.md`, `.cursor/rules`, `.github/CONTRIBUTING.md`
- Sample source files: read 3-5 representative files from the main source directory
- Test files: identify test framework, naming patterns, test location
- Build command: check `package.json` scripts (`build`), `Makefile`, `*.csproj`/`*.sln`, `go.mod`, `Cargo.toml`, `pom.xml`, `build.gradle` to determine the project's build command
- Recent history: `git log --oneline -20` to learn commit style

**Generate a profile** at `~/.claude/code-reviewer/projects/{repo-folder-name}/profile.md` following the template at `~/.claude/skills/code-reviewer/references/profile-template.md`.

**Present the profile** to the user and ask: "Here's what I learned about this project. Anything to adjust?"

After confirmation (or adjustment), proceed to Phase 2.

### Phase 2: Gather Changes

Run these commands to understand what changed:
```
git status
git diff --cached        # staged changes
git diff                 # unstaged changes
```

For each changed file:
- Read the **full file** (not just the diff) to understand context
- For large files (>500 lines), read the changed sections with surrounding context

If no changes are found, inform the user and stop.

### Phase 2b: Build

Before reviewing, build the project to catch compilation and type errors early.

1. Read the project profile's **Build Command** field
2. Run the build command at the repo root
3. **If the build fails:**
   - Treat build errors as BLOCKING findings
   - Run `date +%s000` via Bash to get the current epoch milliseconds
   - Write a failed `review-status.json` with `"status": "failed"` and the build error details
   - Present the build errors to the user: "Build failed. Fix build errors before review can proceed."
   - **STOP. Do NOT proceed to review or commit.**
4. **If the build succeeds:** proceed to Phase 3

### Phase 3: Review

Apply the review checklist from `~/.claude/skills/code-reviewer/references/review-checklist.md` combined with the project-specific rules from the loaded profile.

For each finding, categorize as:
- **BLOCKING** -- Must fix before commit. Security vulnerabilities, data loss risks, breaking changes, logic errors.
- **WARNING** -- Should fix, but not a blocker. Performance issues, missing tests, code smells.
- **NOTE** -- Suggestion for improvement. Style, readability, documentation.

Refer to `~/.claude/code-reviewer/config.json` for severity classification rules.

### Phase 4: Gate Decision

**CRITICAL — Getting the timestamp right:**
Before writing `review-status.json` or `history.jsonl`, you MUST run:
```bash
date +%s000
```
Capture the output and use that exact value as the `timestamp` field. Do NOT calculate, estimate, or hardcode the epoch — always get it from this shell command. The hook compares this against `Date.now()` to check TTL, so a wrong value will reject the commit as expired.

**If BLOCKING issues found:**
1. Run `date +%s000` via Bash to get the current epoch milliseconds
2. Write review status to `~/.claude/code-reviewer/projects/{repo-folder-name}/review-status.json`:
   ```json
   {
     "status": "failed",
     "timestamp": <output from date +%s000>,
     "findings": { "blocking": <count>, "warnings": <count>, "notes": <count> },
     "files_reviewed": [<list of files>]
   }
   ```
3. Present findings in this format:
   ```
   ## Review Results: FAILED

   ### BLOCKING (must fix)
   - **[file:line]** [category] Description of issue
     Suggested fix: ...

   ### WARNINGS (should fix)
   - **[file:line]** [category] Description

   ### NOTES
   - **[file:line]** Description

   Fix the blocking issues and run review again.
   ```
4. **STOP. Do NOT proceed to commit.**

**If no BLOCKING issues:**
1. Run `date +%s000` via Bash to get the current epoch milliseconds
2. Write review status:
   ```json
   {
     "status": "passed",
     "timestamp": <output from date +%s000>,
     "findings": { "blocking": 0, "warnings": <count>, "notes": <count> },
     "files_reviewed": [<list of files>]
   }
   ```
3. Present any warnings/notes as informational
4. Proceed to commit the changes using the standard commit flow

### Phase 5: Log

Run `date +%s000` if not already captured in this phase. Append a one-line JSON entry to `~/.claude/code-reviewer/projects/{repo-folder-name}/history.jsonl`:
```json
{"timestamp": <output from date +%s000>, "status": "passed|failed", "files": <count>, "blocking": <n>, "warnings": <n>, "notes": <n>}
```

## Important Rules

- **Never skip the review** when the user asks to commit. The PreToolUse hook at `~/.claude/hooks/code-review-gate.js` will block the commit anyway if review hasn't passed.
- **Read full files**, not just diffs. Context matters for catching issues.
- **Be specific** in findings -- include file paths, line numbers, and concrete fix suggestions.
- **Respect the project profile** -- don't flag things that are established conventions in the project.
- **Don't be pedantic** -- focus on real issues, not style preferences (unless the project profile says otherwise).
- **Bypass**: Commits with messages starting with `WIP:`, `wip:`, `fixup!`, or `squash!` are allowed through the hook without review.
- The review TTL is configurable in `~/.claude/code-reviewer/config.json` (default: 10 minutes).

## Profile Management

- Profiles live at `~/.claude/code-reviewer/projects/{repo-folder-name}/profile.md`
- Users can manually edit profiles to add custom rules
- To re-init a project profile, delete the file and run review again
- Profiles should be updated when major conventions change (user can ask "update project profile")
