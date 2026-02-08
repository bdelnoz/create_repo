FILENAME: ARCHITECTURE.md
COMPLETE PATH: ./audit/ARCHITECTURE.md
Auteur: Bruno DELNOZ
Email: bruno.delnoz@protonmail.com
Version: v1.0
Date: 2026-02-08 00:23:11

# Architecture

## Overview
The repository contains a single Bash script (`create_repo.sh`) plus a short README. The script is monolithic, with functions grouped by behavior (logging, help output, prereq checks, gitignore generation, repo lifecycle operations).

## Components
- **CLI Parsing & Dispatch**: Parses command-line arguments, sets `ACTION`, and dispatches to appropriate functions.
- **Logging**: `log()` writes to stdout and a log file.
- **Prerequisites**: `check_prerequisites()` and `install_prerequisites()` handle external tool requirements.
- **Repository Operations**: `create_repo()`, `delete_local()`, `delete_remote()`, `check_existing_git()`, and `validate_repo_name()`.
- **Templates & Gitignore**: `create_from_template()` and `create_gitignore()`.
- **Help & Metadata**: `print_help()`, `print_advanced_help()`, `show_changelog()`.

## Data Flow
Inputs:
- CLI arguments.
- User prompts in destructive operations or gitignore merge decisions.
- GitHub user identity via `gh api user`.

Outputs:
- Local filesystem changes (directories, README, `.gitignore`, backups).
- Remote GitHub repository operations (create/delete).
- Log file `log.create_repo.v6.0.log` in working directory when script is run.

## External Dependencies
- `git`, `gh`, `sudo`, `apt-get`, `tar`, standard Unix utilities.

## Assumptions
- User has GitHub CLI configured and authenticated.
- User has permissions to create/delete repositories for the configured owner.

Conclusion:

STATUS: SUCCESS
