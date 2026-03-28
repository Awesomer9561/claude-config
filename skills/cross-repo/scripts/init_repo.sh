#!/bin/bash
# Initialize a repo within a cross-repo project
# Usage: ./init_repo.sh <project-name> <repo-name> [context-path]
#
# Creates the repo's context subdirectory with template files.

set -e

PROJECT_NAME="${1:?Usage: init_repo.sh <project-name> <repo-name> [context-path]}"
REPO_NAME="${2:?Usage: init_repo.sh <project-name> <repo-name> [context-path]}"
CONTEXT_BASE="${3:-$HOME/.project-contexts}"
REPO_DIR="$CONTEXT_BASE/$PROJECT_NAME/repos/$REPO_NAME"

if [ -d "$REPO_DIR" ]; then
    echo "Repo '$REPO_NAME' already exists in project '$PROJECT_NAME'"
    exit 0
fi

echo "Creating repo context for '$REPO_NAME' in project '$PROJECT_NAME'..."

mkdir -p "$REPO_DIR"

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
TODAY="$(date +%Y-%m-%d)"

cat > "$REPO_DIR/summary.md" << MDEOF
# $REPO_NAME — Repo Summary

**Updated:** $TODAY

## Purpose
_What does this repo do?_

## Tech Stack
_Languages, frameworks, major libraries_

## Architecture
_How is the code organized?_

## Key Concepts
_Domain models, important abstractions_

## Entry Points
_Where do requests come in?_
MDEOF

cat > "$REPO_DIR/api-surface.md" << MDEOF
# $REPO_NAME — API Surface

**Updated:** $TODAY

_Document what this repo exposes to other repos: HTTP endpoints, WebSocket events,
exported modules, database schema, etc._
MDEOF

cat > "$REPO_DIR/dependencies.md" << MDEOF
# $REPO_NAME — Dependencies

**Updated:** $TODAY

## What This Repo Consumes

_Document what this repo needs from other repos in the project._
MDEOF

cat > "$REPO_DIR/recent-changes.md" << MDEOF
# $REPO_NAME — Recent Changes

## $TODAY — Initial setup

**What:** Repo added to cross-repo context tracking.
**Impact on other repos:** None yet.
MDEOF

echo "Done! Repo context for '$REPO_NAME' created at $REPO_DIR"
