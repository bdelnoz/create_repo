FILENAME: INSTALL.md
COMPLETE PATH: ./audit/INSTALL.md
Auteur: Bruno DELNOZ
Email: bruno.delnoz@protonmail.com
Version: v1.0
Date: 2026-02-08 00:23:11

# Installation

## Requirements
- `bash`
- `git`
- `gh` (GitHub CLI)
- `tar`
- `sudo` + `apt-get` (only if using `--install`)

## Setup Steps
1. Clone or download the repository.
2. Ensure `create_repo.sh` is executable:
   ```bash
   chmod +x create_repo.sh
   ```
3. Authenticate GitHub CLI:
   ```bash
   gh auth login
   ```

## Optional: Install Prerequisites via Script
```bash
./create_repo.sh --install
```

Conclusion:

STATUS: SUCCESS
