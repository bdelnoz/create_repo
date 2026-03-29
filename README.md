################################################################################
# DOCUMENT INFORMATION
################################################################################
# Document Name    : README.md
# Document Full Path & name : README.md
# Author         : Bruno DELNOZ
# Email          : bruno.delnoz@protonmail.com
# Version        : V1.0
# Date  / Time   : 2026-02-09 19:22:16
# Project : create_repo
# Short description : Project overview
################################################################################

<!--
Document : README.md
Auteur : Bruno DELNOZ
Email : bruno.delnoz@protonmail.com
Version : v5.5.0
Date : 2026-03-29 22:53
-->
# create_repo.sh

## Overview
`create_repo.sh` automates local and remote GitHub repository operations, including non-destructive visibility switching.

## New AGENTS.md synchronization behavior
- On repository creation, the script now copies the master `AGENTS.md` from the `create_repo.sh` source directory into the target repository.
- If `AGENTS.md` already exists in the target repository, it is overwritten by the master version.
- The operation log now includes absolute source and target paths for this synchronization.

## README idempotency fix
- Re-running `--exec` no longer duplicates `README.md` content.
- If `README.md` already exists, the script updates only the metadata header block and preserves the full remaining content as-is.

## New visibility switch actions
- `--switchtopublic <repo>`: changes an existing repository visibility to public.
- `--switchtoprivate <repo>`: changes an existing repository visibility to private.

Both commands are non-destructive and only call `gh repo edit --visibility`.

## Usage examples
```bash
./create_repo.sh --switchtopublic my-repo
./create_repo.sh --switchtoprivate my-repo
./create_repo.sh --switchtopublic owner/my-repo
./create_repo.sh --switchtopublic `pwd`
```

## Local path behavior for visibility switch
- If the target is a local path (for example `` `pwd` ``), the script uses the folder name as repository name.
- If an `origin` remote exists in that folder and points to GitHub, the script auto-detects `owner/repo` from the remote URL.
- If no remote is found, the script falls back to `<authenticated_owner>/<folder_name>`.

## Requirements
- Git
- GitHub CLI (`gh`)
- Authenticated GitHub CLI session (`gh auth login`)
