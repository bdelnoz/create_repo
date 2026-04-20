<!--
Document : WHY.md
Auteur : Bruno DELNOZ
Email : bruno.delnoz@protonmail.com
Version : v1.0.0
Date : 2026-04-20 11:26
-->
# Why this project exists

## Problem

Creating a new repository repeatedly involves many manual steps:

- create folder
- initialize Git
- create or normalize baseline files
- create GitHub repository
- configure remote
- prepare first branches
- push initial commit

Doing this manually for each project is repetitive and error-prone.

## Goal

`create_repo.sh` centralizes this workflow into one CLI command with guardrails:

- prerequisite checks before execution
- dry-run mode for safer planning
- explicit logging
- unified defaults (`main`, visibility, base files)
- optional cleanup commands for local/remote repositories

## Intended users

- developers creating repositories frequently
- users preferring scripted repository bootstrap
- users who want consistent local and GitHub repository setup

## Design choices (current behavior)

- **Bash-first**: no heavy framework required
- **GitHub CLI dependency**: native integration with GitHub account/session
- **Automated bootstrap**: includes branch creation and push flow
- **Defensive checks**: validates name, verifies tools, handles existing remotes

## Scope

This script focuses on repository lifecycle bootstrap and cleanup, not full project scaffolding.

## Expected benefits

- faster repository setup
- fewer setup omissions
- reproducible initialization workflow
- easier onboarding for repeatable project creation
