FILENAME: deps.md
COMPLETE PATH: ./audit/deps.md
Auteur: Bruno DELNOZ
Email: bruno.delnoz@protonmail.com
Version: v1.0
Date: 2026-02-08 00:23:11

# Dependencies Inventory

## Runtime/System Dependencies
- bash (script interpreter). Evidence: shebang in `create_repo.sh`.
- git (required). Evidence: `check_prerequisites` and usage in `create_repo.sh`.
- gh (GitHub CLI, required). Evidence: `check_prerequisites`, `gh repo` usage.
- sudo, apt-get (optional, used by `--install`). Evidence: `install_prerequisites`.
- tar (required for local delete backup). Evidence: `delete_local` uses `tar`.

## External Services
- GitHub API via `gh` CLI (required for remote repo operations).

## Language/Package Managers
- None used within the repository; no package manager files present.

## Unknowns
- None.

Conclusion:

STATUS: SUCCESS
