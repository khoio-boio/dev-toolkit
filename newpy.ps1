param(
    [Parameter(Mandatory = $true)]
    [string]$Name
)

$ErrorActionPreference = "Stop"

# ---- Configuration (safe defaults) ----
$Root = "C:\Users\profile 1\dev\python"

$projectPath = Join-Path $Root $Name
$srcPath     = Join-Path $projectPath "src"
$venvPath    = Join-Path $projectPath ".venv"
$vscodePath  = Join-Path $projectPath ".vscode"

if (Test-Path $projectPath) {
    throw "Project already exists: $projectPath"
}

# ---- Create project structure ----
New-Item -ItemType Directory -Path $projectPath | Out-Null
New-Item -ItemType Directory -Path $srcPath     | Out-Null
New-Item -ItemType Directory -Path $vscodePath  | Out-Null

# ---- Create requirements.txt ----
New-Item -ItemType File -Path (Join-Path $projectPath "requirements.txt") | Out-Null

# ---- Create starter Python file ----
$mainPy = @"
import sys

def main() -> None:
    print(sys.executable)

if __name__ == "__main__":
    main()
"@
Set-Content -Path (Join-Path $srcPath "main.py") -Value $mainPy -Encoding UTF8

# ---- Create virtual environment ----
python -m venv $venvPath

# ---- VS Code settings (pin interpreter + auto activate) ----
$settingsJson = @"
{
  "python.defaultInterpreterPath": "${venvPath}\\Scripts\\python.exe",
  "python.terminal.activateEnvironment": true
}
"@
Set-Content -Path (Join-Path $vscodePath "settings.json") -Value $settingsJson -Encoding UTF8

# ---- Initialize Git ----
git init $projectPath | Out-Null

# ---- Create .gitignore (Python-safe default) ----
$gitignore = @"
# ---- Virtual environment ----
.venv/

# ---- Python bytecode / cache ----
__pycache__/
*.pyc
*.pyo

# ---- Environment variables / secrets ----
.env

# ---- Editor / OS noise ----
.vscode/
.DS_Store
Thumbs.db

# ---- Logs ----
*.log
"@
Set-Content -Path (Join-Path $projectPath ".gitignore") -Value $gitignore -Encoding UTF8

# ---- Open project in VS Code ----
code $projectPath
