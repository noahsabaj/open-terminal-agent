# Terminal Agent - Windows Installer
# irm https://raw.githubusercontent.com/noahsabaj/open-terminal-agent/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "  ╭─────╮" -ForegroundColor Cyan
Write-Host "  │ ◠ ◠ │   Terminal Agent Installer" -ForegroundColor Cyan
Write-Host "  │  ▽  │" -ForegroundColor Cyan
Write-Host "  ╰─────╯" -ForegroundColor Cyan
Write-Host ""

# Check for Python
$pythonPath = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonPath) {
    $pythonPath = Get-Command python3 -ErrorAction SilentlyContinue
}

if (-not $pythonPath) {
    Write-Host "✗ Python not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Install Python 3.10+ from: " -NoNewline
    Write-Host "https://python.org/downloads" -ForegroundColor Cyan
    Write-Host "  Make sure to check 'Add Python to PATH' during installation."
    Write-Host ""
    exit 1
}

# Check Python version
$pythonVersion = & $pythonPath.Source -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"
$versionParts = $pythonVersion -split '\.'
$major = [int]$versionParts[0]
$minor = [int]$versionParts[1]

if ($major -lt 3 -or ($major -eq 3 -and $minor -lt 10)) {
    Write-Host "✗ Python 3.10+ is required (found $pythonVersion)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Please upgrade Python to version 3.10 or later."
    exit 1
}

Write-Host "✓ Python $pythonVersion found" -ForegroundColor Green

# Check for pip
$pipWorks = $false
try {
    & $pythonPath.Source -m pip --version 2>$null | Out-Null
    $pipWorks = $true
} catch {}

if (-not $pipWorks) {
    Write-Host "✗ pip not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Try running: python -m ensurepip"
    exit 1
}

Write-Host "✓ pip found" -ForegroundColor Green

# Check for Ollama
$ollamaPath = Get-Command ollama -ErrorAction SilentlyContinue
if (-not $ollamaPath) {
    Write-Host "✗ Ollama not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Download Ollama from: " -NoNewline
    Write-Host "https://ollama.com/download" -ForegroundColor Cyan
    Write-Host "  Install it, then run this script again."
    Write-Host ""
    exit 1
}
Write-Host "✓ Ollama found" -ForegroundColor Green

# Prompt for Ollama signin
Write-Host ""
Write-Host "! Terminal Agent uses cloud models (e.g., minimax-m2.1:cloud)" -ForegroundColor Yellow
Write-Host "  If you haven't already, sign in to Ollama:"
Write-Host ""
Write-Host "  ollama signin" -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to continue (or Ctrl+C to sign in first)"
Write-Host ""

# Install terminal-agent via pip
Write-Host "↓ Installing open-terminal-agent..." -ForegroundColor Yellow
& $pythonPath.Source -m pip install --user open-terminal-agent

Write-Host "✓ Installed terminal-agent" -ForegroundColor Green

# Check if Scripts directory is in PATH
$scriptsDir = "$env:USERPROFILE\AppData\Local\Programs\Python\Python$major$minor\Scripts"
$altScriptsDir = "$env:USERPROFILE\.local\bin"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")

$needPathUpdate = $false
if ($userPath -notlike "*Scripts*" -and $userPath -notlike "*\.local\bin*") {
    # Try to find the actual Scripts directory
    $possiblePaths = @(
        "$env:USERPROFILE\AppData\Local\Programs\Python\Python$major$minor\Scripts",
        "$env:USERPROFILE\AppData\Roaming\Python\Python$major$minor\Scripts",
        "$env:LOCALAPPDATA\Programs\Python\Python$major$minor\Scripts"
    )

    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            [Environment]::SetEnvironmentVariable("Path", "$userPath;$path", "User")
            $env:Path = "$env:Path;$path"
            Write-Host "✓ Added to PATH: $path" -ForegroundColor Green
            $needPathUpdate = $true
            break
        }
    }
}

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Run " -NoNewline
Write-Host "terminal-agent" -ForegroundColor Cyan -NoNewline
Write-Host " to start."
Write-Host ""
Write-Host "Options:"
Write-Host "  terminal-agent" -ForegroundColor Cyan -NoNewline
Write-Host "                Start normally (prompts for permission)"
Write-Host "  terminal-agent --accept-edits" -ForegroundColor Cyan -NoNewline
Write-Host " Auto-approve file edits"
Write-Host "  terminal-agent --yolo" -ForegroundColor Cyan -NoNewline
Write-Host "         Full autonomous mode (no prompts)"
Write-Host ""

if ($needPathUpdate) {
    Write-Host "Note: You may need to restart your terminal for PATH changes to take effect." -ForegroundColor Yellow
    Write-Host ""
}
