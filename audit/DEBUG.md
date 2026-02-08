FILENAME: DEBUG.md
COMPLETE PATH: ./audit/DEBUG.md
Auteur: Bruno DELNOZ
Email: bruno.delnoz@protonmail.com
Version: v1.0
Date: 2026-02-08 00:23:11

# Debugging

## Log File
- The script writes logs to `log.create_repo.v6.0.log` in the current working directory.

## Common Issues
- **Missing dependencies**: Ensure `git` and `gh` are installed and available in PATH.
- **Authentication errors**: Run `gh auth login` and verify `gh auth status`.
- **Repository name validation**: Names must match `^[a-zA-Z0-9._-]+$` and be <= 100 chars.

## Debug Steps
1. Run with `--simulate` to see intended actions without changes.
2. Check the log file for detailed steps.
3. Verify connectivity/authentication to GitHub.

Conclusion:

STATUS: SUCCESS
