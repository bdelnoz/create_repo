<!--
Document : INSTALL.md
Auteur : Bruno DELNOZ
Email : bruno.delnoz@protonmail.com
Version : v5.4.0
Date : 2026-03-29 00:45
-->
# INSTALL

## Prerequisites
- Linux shell environment
- `git`
- `gh` (GitHub CLI)
- Authenticated GitHub session with repository edit permissions

## Installation steps
1. Clone this repository.
2. Make the script executable:
   ```bash
   chmod +x create_repo.sh
   ```
3. Authenticate GitHub CLI if needed:
   ```bash
   gh auth login
   ```

## Quick verification
```bash
./create_repo.sh --prerequis
```

## Visibility switch usage
```bash
./create_repo.sh --switchtopublic my-repo
./create_repo.sh --switchtoprivate my-repo
./create_repo.sh --switchtopublic `pwd`
```

## Path target behavior
- A path target uses the local folder name as repository name.
- If the path contains a git repository with `origin` on GitHub, `owner/repo` is auto-detected.
