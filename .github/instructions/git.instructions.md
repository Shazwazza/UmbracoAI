---
description: Rules for working git
applyTo: '**/*'
---
# Git

* Anytime a task is completed and files are changed, a Git commit should be made to track changes.

## CRITICAL: Branch discipline for Umbraco work

**You MUST use a develop branch for any changes under `src/MyProject`.**

* **Before your first commit** that touches files in `src/MyProject`, check which branch you are on:
  ```
  git branch --show-current
  ```
* If the current branch is `main` or `master`, you MUST create and checkout a **new, unique** develop branch before making any changes:
  1. First list existing develop branches to avoid collisions:
     ```
     git branch --list 'develop/*'
     ```
  2. Choose a branch name that does **not** already exist. Use today's date plus a short suffix, e.g. `develop/demo-build-YYYY-MM-DD` or `develop/demo-build-YYYY-MM-DD-v2`.
  3. Then create and switch to it:
     ```
     git checkout -b develop/<unique-descriptive-name>
     ```
  > ⚠️ Never attempt to create a branch whose name is already in the list — `git checkout -b` will fail. Always verify uniqueness first.
* If the current branch is already a `develop/*` branch, stay on it — do NOT create a new one.
* DO NOT commit Umbraco-related changes directly to `main` or `master`. This is a hard rule, not a suggestion.
* Non-Umbraco changes (e.g., updates to `.github/instructions/`, `.github/skills/`) may be committed to the current branch.
