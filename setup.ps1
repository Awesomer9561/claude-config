# Claude Config Setup Script (Windows)
# Creates symlinks from this repo into ~/.claude/
# Run as: powershell -ExecutionPolicy Bypass -File setup.ps1
# NOTE: Requires elevated (Admin) prompt for symlinks, or Developer Mode enabled.

$ErrorActionPreference = "Stop"

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"

Write-Host "Setting up Claude config from: $RepoDir"
Write-Host "Target: $ClaudeDir"
Write-Host ""

# Ensure target dirs exist
foreach ($sub in @("skills", "hooks", "code-reviewer")) {
    $dir = Join-Path $ClaudeDir $sub
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# Symlink skills
$skillsSource = Join-Path $RepoDir "skills"
foreach ($skill in Get-ChildItem -Path $skillsSource -Directory) {
    $target = Join-Path $ClaudeDir "skills\$($skill.Name)"

    # Remove existing symlink
    if (Test-Path $target) {
        $item = Get-Item $target -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            Remove-Item $target -Force
        } else {
            Write-Warning "$target exists (not a symlink). Back it up or remove it first."
            continue
        }
    }

    New-Item -ItemType SymbolicLink -Path $target -Target $skill.FullName | Out-Null
    Write-Host "  Linked skill: $($skill.Name)"
}

# Symlink hooks
$hooksSource = Join-Path $RepoDir "hooks"
if (Test-Path $hooksSource) {
    foreach ($hook in Get-ChildItem -Path $hooksSource -File) {
        $target = Join-Path $ClaudeDir "hooks\$($hook.Name)"

        if (Test-Path $target) {
            $item = Get-Item $target -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                Remove-Item $target -Force
            }
        }

        New-Item -ItemType SymbolicLink -Path $target -Target $hook.FullName -Force | Out-Null
        Write-Host "  Linked hook: $($hook.Name)"
    }
}

# Symlink reviewer config
$reviewerConfigSrc = Join-Path $RepoDir "code-reviewer\config.json"
$reviewerConfigDst = Join-Path $ClaudeDir "code-reviewer\config.json"

if (Test-Path $reviewerConfigDst) {
    $item = Get-Item $reviewerConfigDst -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        Remove-Item $reviewerConfigDst -Force
    }
}

New-Item -ItemType SymbolicLink -Path $reviewerConfigDst -Target $reviewerConfigSrc -Force | Out-Null
Write-Host "  Linked: code-reviewer\config.json"

Write-Host ""
Write-Host "Done! Now merge the PreToolUse hook from settings.reference.json"
Write-Host "into your ~/.claude/settings.json manually (paths may differ per machine)."
