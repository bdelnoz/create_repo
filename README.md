<!--
Document : README.md
Auteur : Bruno DELNOZ
Email : bruno.delnoz@protonmail.com
Version : v1.1.0
Date : 2026-04-20 11:26
-->
# create_repo

Shell utility to create and manage GitHub repositories with local initialization, optional README/.gitignore management, and deletion helpers.

## Overview

`create_repo.sh` automates these workflows:

- prerequisite verification (`git`, `gh`, `gh auth status`)
- local repository creation (or reuse of existing directory)
- README metadata header creation/update
- `.gitignore` creation/update with predefined entries
- Git initialization and remote configuration
- GitHub repository creation with selected visibility
- branch bootstrap (`main` and `initial_branch`)
- automatic `git add`, `git commit`, `git push -u origin main`
- optional local backup + delete and remote delete operations

## Main Features

### 1) Create a repository (`--exec`)

When using `--exec <path>`, the script currently:

1. validates the repository name
2. creates the local directory if it does not exist
3. manages `README.md` and `.gitignore`
4. initializes Git if `.git` is missing
5. removes existing `origin` remote when needed
6. creates the remote GitHub repository if missing
7. adds `origin` and creates/checks out `initial_branch`
8. checks out `main`, commits staged content (if any), and pushes to `origin/main`

### 2) Delete local repository (`--delete-local`)

- asks interactive confirmation (`oui`)
- creates a timestamped `.tar.gz` backup
- removes the local directory

### 3) Delete remote repository (`--delete-remote`)

- asks interactive confirmation (`oui`)
- checks existence with `gh repo view`
- deletes the GitHub repository with `gh repo delete --yes`

### 4) Utility modes

- `--prerequis` / `-pr`: prerequisite check only
- `--install` / `-i`: installs required packages (APT) and starts `gh auth login`
- `--simulate` / `-s`: dry-run mode for destructive operations
- `--changelog` / `-ch`: in-script changelog output
- `--help` / `-h`: help output

## Command Reference

```bash
./create_repo.sh --exec /path/to/project
./create_repo.sh --exec /path/to/project --public
./create_repo.sh --exec /path/to/project --private --no-readme
./create_repo.sh --delete-local /path/to/project
./create_repo.sh --delete-remote my-repo-name
./create_repo.sh --prerequis
./create_repo.sh --install
./create_repo.sh --simulate --exec /path/to/project
```

## Options

- `--exec`, `-exe` `<path>`: create/sync local+remote repository
- `--delete-local` `<path>`: backup and remove local repository directory
- `--delete-remote` `<repo_name>`: remove remote GitHub repository
- `--public`: set GitHub visibility to public
- `--private`: set GitHub visibility to private (default)
- `--template` `<name>`: accepted argument (stored) for template selection
- `--readme` / `--no-readme`: enable/disable README handling
- `--gitignore` / `--no-gitignore`: enable/disable `.gitignore` handling
- `--simulate`, `-s`: dry-run mode
- `--prerequis`, `-pr`: check prerequisites and exit
- `--install`, `-i`: install prerequisites and exit
- `--changelog`, `-ch`: print changelog and exit
- `--help`, `-h`: print help and exit

## Requirements

- Linux environment with Bash
- `git`
- `gh` (GitHub CLI)
- authenticated GitHub CLI session (`gh auth login`)
- `sudo` rights for `--install`

## Logs

The script writes log output to:

- `log.create_repo.v5.1.log`

## Important Behavioral Notes (Current Script)

- The script currently performs automatic commit/push on `main` during `--exec`.
- The script asks for interactive confirmation on delete operations.
- `.gitignore` update logic is called twice in `create_repo()`; second call is unconditional when not in dry-run.
- Default branch constants use `main`; an additional local branch `initial_branch` is managed.

## Repository Contents

- `create_repo.sh`: main executable script
- `README.md`: project reference (this file)
- `INSTALL.md`: installation and setup guide
- `WHY.md`: rationale and use-cases
- `CHANGELOG.md`: repository documentation changelog
- `.gitignore`: ignore rules
- `AGENTS.md`: repository operating instructions for AI agents

## Author

- Bruno DELNOZ
- bruno.delnoz@protonmail.com
