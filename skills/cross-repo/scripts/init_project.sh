#!/bin/bash
# Initialize a cross-repo project context directory
# Usage: ./init_project.sh <project-name> [context-path]
#
# This creates the directory structure for a new project's shared context.

set -e

PROJECT_NAME="${1:?Usage: init_project.sh <project-name> [context-path]}"
CONTEXT_BASE="${2:-$HOME/.project-contexts}"
PROJECT_DIR="$CONTEXT_BASE/$PROJECT_NAME"

if [ -d "$PROJECT_DIR" ]; then
    echo "Project '$PROJECT_NAME' already exists at $PROJECT_DIR"
    exit 0
fi

echo "Creating project context directory at $PROJECT_DIR..."

mkdir -p "$PROJECT_DIR"/{repos,features,plans,decisions,sessions/_cross-repo,scratch}

# Create project.json
cat > "$PROJECT_DIR/project.json" << JSONEOF
{
  "name": "$PROJECT_NAME",
  "description": "",
  "repos": {},
  "createdAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "updatedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
JSONEOF

# Create empty architecture.md
cat > "$PROJECT_DIR/architecture.md" << 'MDEOF'
# Architecture

<!-- This file describes the high-level system architecture of the project.
     Update this as the system evolves. -->

## Overview

_To be filled in as repos are added and the architecture takes shape._

## Communication Patterns

_How do the repos communicate? REST? GraphQL? WebSocket? Message queues?_

## Authentication

_How is auth handled across the system?_

## Data Flow

_How does data flow through the system?_
MDEOF

echo "Done! Project '$PROJECT_NAME' initialized at $PROJECT_DIR"
echo ""
echo "Next steps:"
echo "  1. cd into each repo and add a .crossrepo.json config"
echo "  2. Run context sync to populate repo summaries"
