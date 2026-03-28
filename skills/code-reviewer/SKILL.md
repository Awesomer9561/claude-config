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

1. Run `git remote get-url origin` to get the remote URL
2. Compute the project ID: first 12 characters of SHA-256 hash of the remote URL
3. Check if a profile exists at `~/.claude/code-reviewer/projects/{project-id}/profile.md`
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
- Recent history: `git log --oneline -20` to learn commit style

**Generate a profile** at `~/.claude/code-reviewer/projects/{project-id}/profile.md` following the template at `~/.claude/skills/code-reviewer/references/profile-template.md`.

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

### Phase 3: Review

Apply the review checklist from `~/.claude/skills/code-reviewer/references/review-checklist.md` combined with the project-specific rules from the loaded profile.

For each finding, categorize as:
- **BLOCKING** -- Must fix before commit. Security vulnerabilities, data loss risks, breaking changes, logic errors.
- **WARNING** -- Should fix, but not a blocker. Performance issues, missing tests, code smells.
- **NOTE** -- Suggestion for improvement. Style, readability, documentation.

Refer to `~/.claude/code-reviewer/config.json` for severity classification rules.

### Phase 4: Gate Decision

**If BLOCKING issues found:**
1. Write review status to `~/.claude/code-reviewer/projects/{project-id}/review-status.json`:
   ```json
   {
     "status": "failed",
     "timestamp": <Date.now()>,
     "findings": { "blocking": <count>, "warnings": <count>, "notes": <count> },
     "files_reviewed": [<list of files>]
   }
   ```
2. Present findings in this format:
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
3. **STOP. Do NOT proceed to commit.**

**If no BLOCKING issues:**
1. Write review status:
   ```json
   {
     "status": "passed",
     "timestamp": <Date.now()>,
     "findings": { "blocking": 0, "warnings": <count>, "notes": <count> },
     "files_reviewed": [<list of files>]
   }
   ```
2. Present any warnings/notes as informational
3. Proceed to commit the changes using the standard commit flow

### Phase 5: Log

Append a one-line JSON entry to `~/.claude/code-reviewer/projects/{project-id}/history.jsonl`:
```json
{"timestamp": <epoch>, "status": "passed|failed", "files": <count>, "blocking": <n>, "warnings": <n>, "notes": <n>}
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

- Profiles live at `~/.claude/code-reviewer/projects/{project-id}/profile.md`
- Users can manually edit profiles to add custom rules
- To re-init a project profile, delete the file and run review again
- Profiles should be updated when major conventions change (user can ask "update project profile")
