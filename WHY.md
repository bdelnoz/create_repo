<!--
Document : WHY.md
Auteur : Bruno DELNOZ
Email : bruno.delnoz@protonmail.com
Version : v5.4.0
Date : 2026-03-29 00:45
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
