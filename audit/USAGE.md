FILENAME: USAGE.md
COMPLETE PATH: ./audit/USAGE.md
Auteur: Bruno DELNOZ
Email: bruno.delnoz@protonmail.com
Version: v1.0
Date: 2026-02-08 00:23:11

# Usage

## Create a Repository (Local + Remote)
```bash
./create_repo.sh --exec ~/projects/my-app
```

## Create a Public Repository with Python Template
```bash
./create_repo.sh --exec ~/projects/my-api --public --template python
```

## Generate a Multi-Environment `.gitignore`
```bash
./create_repo.sh --gitignore python vscode macos
```

## List Available `.gitignore` Templates
```bash
./create_repo.sh --list-gitignore
```

## Delete Local Repository (with backup)
```bash
./create_repo.sh --delete-local ~/projects/my-app
```

## Delete Remote Repository
```bash
./create_repo.sh --delete-remote my-app
```

## Dry-Run / Simulation Mode
```bash
./create_repo.sh --simulate --exec ~/projects/my-app
```

Conclusion:

STATUS: SUCCESS
