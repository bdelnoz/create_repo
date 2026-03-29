<!--
Document : CHANGELOG.md
Auteur : Bruno DELNOZ
Email : bruno.delnoz@protonmail.com
Version : v5.4.0
Date : 2026-03-29 00:45
-->
# CHANGELOG

## v5.4.0 - 2026-03-29 00:45
Author: Bruno DELNOZ
- Updated usage examples to use `` `pwd` `` notation instead of `$(pwd)` for local path switching commands.
- Kept the same path-aware resolution behavior (folder-name fallback + origin auto-detection).

## v5.3.0 - 2026-03-29 00:30
Author: Bruno DELNOZ
- Updated `--switchtopublic` and `--switchtoprivate` to accept local path input (example: `$(pwd)`).
- Added auto-detection of `owner/repo` from local git `origin` remote URL when available.
- Added folder-name fallback behavior to resolve repository name for path targets.
- Updated README, INSTALL, WHY, and script help/changelog for path-based visibility switching.

## v5.2.0 - 2026-03-29 00:00
Author: Bruno DELNOZ
- Added `--switchtopublic <repo>` to switch repository visibility to public without deletion.
- Added `--switchtoprivate <repo>` to switch repository visibility to private without deletion.
- Updated help output with new visibility switch actions and examples.
- Updated script changelog output with v5.2.0 entry.
- Updated README, INSTALL, and WHY companion documentation files.
