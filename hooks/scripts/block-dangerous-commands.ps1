<#
.SYNOPSIS
  PreToolUse guard: requires user confirmation before destructive shell commands.

.DESCRIPTION
  Reads the PreToolUse hook payload from stdin (JSON). When the tool being invoked
  is a terminal/shell command, the command text is matched against a denylist of
  high-risk, hard-to-reverse operations. On a match, the hook returns an "ask"
  permission decision so the user must explicitly confirm before it runs.

  This enforces the operational-safety rules in copilot-instructions.md
  deterministically, rather than relying on the agent to remember them.
#>

$ErrorActionPreference = 'Stop'

function Write-Decision {
    param(
        [ValidateSet('allow', 'ask', 'deny')]
        [string]$Decision,
        [string]$Reason
    )
    $payload = @{
        hookSpecificOutput = @{
            hookEventName            = 'PreToolUse'
            permissionDecision       = $Decision
            permissionDecisionReason = $Reason
        }
    }
    $payload | ConvertTo-Json -Depth 5 -Compress | Write-Output
}

# Read the full hook payload from stdin.
$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }

try {
    $hookInput = $raw | ConvertFrom-Json
}
catch {
    # If we can't parse the payload, don't block normal flow.
    exit 0
}

# Pull the candidate command text from common tool-input shapes.
$ti = $hookInput.tool_input
$command = $null
if ($null -ne $ti) {
    foreach ($prop in 'command', 'cmd', 'script', 'input') {
        if ($ti.PSObject.Properties.Name -contains $prop -and $ti.$prop) {
            $command = [string]$ti.$prop
            break
        }
    }
}

# Only the terminal/shell tools carry a command to inspect.
if ([string]::IsNullOrWhiteSpace($command)) { exit 0 }

# High-risk, hard-to-reverse patterns that warrant explicit confirmation.
$dangerous = @(
    'rm\s+-rf\s+/',                  # recursive force delete from root-ish paths
    'rm\s+-rf\s+~',
    'Remove-Item.*-Recurse.*-Force', # PowerShell recursive force delete
    'git\s+push\s+.*--force',        # force push
    'git\s+push\s+.*-f\b',
    'git\s+reset\s+--hard',          # discard local history/changes
    'git\s+clean\s+-[a-z]*f',        # delete untracked files
    'DROP\s+(TABLE|DATABASE|SCHEMA)',# destructive SQL
    'TRUNCATE\s+TABLE',
    '--no-verify',                   # bypass commit/push hooks
    'mkfs',                          # format filesystem
    'Format-Volume',
    ':\(\)\s*\{\s*:\|:&\s*\};:',     # fork bomb
    'chmod\s+-R\s+777'               # world-writable recursive
)

foreach ($pattern in $dangerous) {
    if ($command -match $pattern) {
        Write-Decision -Decision 'ask' -Reason "Potentially destructive command matched pattern '$pattern'. Confirm before running."
        exit 2
    }
}

# Nothing matched; allow normal processing.
exit 0
