#!/usr/bin/env node
// Code Review Gate - PreToolUse hook
// Intercepts `git commit` commands and blocks them unless a recent code review
// has passed. The actual review is performed by the code-reviewer skill (Claude);
// this hook only checks the status file written by that skill.
//
// Exit codes:
//   0 = allow the tool call
//   2 = block the tool call (message written to stderr)

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// ── Config defaults (overridden by ~/.claude/code-reviewer/config.json) ──
const CONFIG_PATH = path.join(
  process.env.HOME || process.env.USERPROFILE,
  '.claude', 'code-reviewer', 'config.json'
);
const PROJECTS_DIR = path.join(
  process.env.HOME || process.env.USERPROFILE,
  '.claude', 'code-reviewer', 'projects'
);

let config = {
  review_ttl_minutes: 10,
  bypass_patterns: ['WIP:', 'wip:', 'fixup!', 'squash!']
};

try {
  if (fs.existsSync(CONFIG_PATH)) {
    config = { ...config, ...JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf8')) };
  }
} catch (_) { /* use defaults */ }

// ── Helpers ──

function getProjectId(cwd) {
  try {
    const root = execSync('git rev-parse --show-toplevel', {
      cwd,
      encoding: 'utf8',
      stdio: ['pipe', 'pipe', 'pipe']
    }).trim();
    return path.basename(root);
  } catch (_) {
    return null;
  }
}

function extractCommitMessage(command) {
  // Try to extract -m "message" or -m 'message'
  const match = command.match(/-m\s+["']([^"']+)["']/);
  return match ? match[1] : '';
}

function shouldBypass(command) {
  const msg = extractCommitMessage(command);
  return config.bypass_patterns.some(p => msg.startsWith(p));
}

// ── Main ──

let input = '';
const stdinTimeout = setTimeout(() => process.exit(0), 3000);
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  clearTimeout(stdinTimeout);
  try {
    const data = JSON.parse(input);
    const toolName = data.tool_name;
    const toolInput = data.tool_input || {};

    // Only care about Bash calls
    if (toolName !== 'Bash') {
      process.exit(0);
    }

    const command = toolInput.command || '';

    // Only care about git commit commands
    if (!/^git\s+commit/.test(command) && !/&&\s*git\s+commit/.test(command)) {
      process.exit(0);
    }

    // Check bypass patterns (WIP:, fixup!, etc.)
    if (shouldBypass(command)) {
      process.exit(0);
    }

    // Derive project ID
    const cwd = data.cwd || process.cwd();
    const projectId = getProjectId(cwd);
    if (!projectId) {
      // Not a git repo — allow through
      process.exit(0);
    }

    // Check review status
    const statusPath = path.join(PROJECTS_DIR, projectId, 'review-status.json');
    if (!fs.existsSync(statusPath)) {
      process.stderr.write(
        '\n' +
        '╔══════════════════════════════════════════════════════════════╗\n' +
        '║  CODE REVIEW GATE: No review found for this project.       ║\n' +
        '║  Run "review changes" or "/code-reviewer" first.           ║\n' +
        '║  Bypass with WIP: prefix in commit message.                ║\n' +
        '╚══════════════════════════════════════════════════════════════╝\n'
      );
      process.exit(2);
    }

    const status = JSON.parse(fs.readFileSync(statusPath, 'utf8'));

    // Check if review passed
    if (status.status !== 'passed') {
      const count = status.findings ? status.findings.blocking : '?';
      process.stderr.write(
        '\n' +
        '╔══════════════════════════════════════════════════════════════╗\n' +
        `║  CODE REVIEW GATE: Review FAILED (${count} blocking issues).     ║\n` +
        '║  Fix the reported issues and run the review again.         ║\n' +
        '╚══════════════════════════════════════════════════════════════╝\n'
      );
      process.exit(2);
    }

    // Check TTL — review must be fresh
    const ttlMs = (config.review_ttl_minutes || 10) * 60 * 1000;
    const reviewAge = Date.now() - (status.timestamp || 0);
    if (reviewAge > ttlMs) {
      const mins = Math.round(reviewAge / 60000);
      process.stderr.write(
        '\n' +
        '╔══════════════════════════════════════════════════════════════╗\n' +
        `║  CODE REVIEW GATE: Review expired (${mins} min ago).             ║\n` +
        '║  Run "review changes" again before committing.             ║\n' +
        '╚══════════════════════════════════════════════════════════════╝\n'
      );
      process.exit(2);
    }

    // Review passed and fresh — allow the commit
    process.exit(0);

  } catch (e) {
    // On any error, fail open (don't block the developer)
    process.exit(0);
  }
});
