#!/bin/bash
# Claude Config Setup Script
# Symlinks skills, hooks, and config from this repo into ~/.claude/

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Setting up Claude config from: $REPO_DIR"
echo "Target: $CLAUDE_DIR"
echo ""

# Ensure target dirs exist
mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/hooks" "$CLAUDE_DIR/code-reviewer"

# Symlink skills
for skill in "$REPO_DIR"/skills/*/; do
  name=$(basename "$skill")
  target="$CLAUDE_DIR/skills/$name"
  if [ -L "$target" ]; then rm "$target"; fi
  if [ -d "$target" ]; then
    echo "WARN: $target exists (not a symlink). Back it up or remove it first."
    continue
  fi
  ln -s "$skill" "$target"
  echo "  Linked skill: $name"
done

# Symlink hooks
for hook in "$REPO_DIR"/hooks/*; do
  name=$(basename "$hook")
  target="$CLAUDE_DIR/hooks/$name"
  if [ -L "$target" ]; then rm "$target"; fi
  ln -sf "$hook" "$target"
  echo "  Linked hook: $name"
done

# Symlink reviewer config
ln -sf "$REPO_DIR/code-reviewer/config.json" "$CLAUDE_DIR/code-reviewer/config.json"
echo "  Linked: code-reviewer/config.json"

echo ""
echo "Done! Now merge the PreToolUse hook from settings.reference.json"
echo "into your ~/.claude/settings.json manually (paths may differ per machine)."
