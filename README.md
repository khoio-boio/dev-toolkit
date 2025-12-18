# Dev Toolkit (Windows PowerShell)

A small collection of PowerShell scripts I use to bootstrap clean, repeatable development projects on Windows.

This repo is intentionally practical:
- Scripts are designed for day-to-day use, not just demos
- Defaults favor reproducibility (project-local envs, consistent structure, safe `.gitignore`)
- Commands are written to be understandable and modifiable

---

## What this solves

When starting a new project, it is easy to lose time to:
- inconsistent folder structures
- missing virtual environments / mis-selected interpreters
- forgetting `.gitignore` basics
- redoing boilerplate across projects

These scripts make “new project setup” predictable and fast.

---

## Scripts

### `newpy.ps1` — Python project bootstrap

Creates a Python project with:
- standard structure (`src/`, `requirements.txt`)
- project-local venv (`.venv/`)
- VS Code workspace settings to pin the interpreter and auto-activate the venv
- Git initialization + safe `.gitignore`
- opens the folder in VS Code

**Example:**
```powershell
newpy myproject 
```

**Result:**
```
myproject/
  .venv/
  .vscode/
    settings.json
  src/
    main.py
  requirements.txt
  .gitignore
```

### `newjava.ps1` - Java project bootstrap

Creates a Java project with
- standard structure (``)
