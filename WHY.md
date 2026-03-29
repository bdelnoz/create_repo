<!--
Document : WHY.md
Auteur : Bruno DELNOZ
Email : bruno.delnoz@protonmail.com
Version : v5.5.0
Date : 2026-03-29 22:53
-->
# WHY

## Purpose
This project provides a single operational script to manage repository lifecycle tasks and reduce repetitive GitHub setup operations.

## Why visibility switch actions were added
- To avoid destructive operations when only repository visibility must change.
- To provide explicit, easy-to-remember commands for security posture changes.
- To keep repository history, issues, and settings intact while switching visibility.
- To support workflow parity with ``--exec `pwd` `` by allowing ``--switchtopublic `pwd` ``.

## Safety model
The new actions call GitHub CLI edit operations only:
- `gh repo edit <repo> --visibility public`
- `gh repo edit <repo> --visibility private`

No repository deletion is performed by these actions.

## Why AGENTS.md synchronization is enforced
- To guarantee every created repository starts with the same master instruction baseline.
- To prevent divergence caused by stale or manually edited `AGENTS.md` copies in target repositories.

## Why README normalization was changed
- To make repeated `--exec` runs idempotent for `README.md`.
- To preserve user-authored README body content while keeping metadata header compliant.
