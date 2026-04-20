<!--
Document : INSTALL.md
Auteur : Bruno DELNOZ
Email : bruno.delnoz@protonmail.com
Version : v1.0.0
Date : 2026-04-20 11:26
-->
# Installation Guide

## 1) Clone repository

```bash
git clone <your-repository-url>
cd create_repo
```

## 2) Install dependencies

### Ubuntu / Debian

```bash
sudo apt-get update
sudo apt-get install -y git gh
```

## 3) Authenticate GitHub CLI

```bash
gh auth login
```

Verify authentication:

```bash
gh auth status
```

## 4) Make script executable

```bash
chmod +x create_repo.sh
```

## 5) Quick verification

```bash
./create_repo.sh --prerequis
```

## 6) First usage examples

```bash
./create_repo.sh --exec ~/dev/my-new-repo
./create_repo.sh --exec ~/dev/my-public-repo --public
./create_repo.sh --simulate --exec ~/dev/my-test-repo
```

## Optional: auto-install mode via script

The script includes:

```bash
./create_repo.sh --install
```

This mode runs package installation and GitHub authentication flow.

## Notes

- For deletion commands (`--delete-local`, `--delete-remote`), the script asks confirmation in interactive mode.
- During `--exec`, the script currently commits and pushes to `main` automatically.
