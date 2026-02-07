# create_repo

Script unique pour gérer la création et la suppression de dépôts Git (local + GitHub) avec templates et génération de `.gitignore`.

## Prérequis
- `git`
- `gh` (GitHub CLI) + authentification (`gh auth login`)

## Usage
### Créer un dépôt complet
```bash
./create_repo.sh --exec ~/projets/mon-app
```

### Créer un dépôt public avec template Python
```bash
./create_repo.sh --exec ~/projets/mon-api --public --template python
```

### Créer un `.gitignore` multi-environnement
```bash
./create_repo.sh --gitignore python vscode macos
```
Le script demande une seule fois si un `.gitignore` existant doit être remplacé ou complété.

## Aide
```bash
./create_repo.sh --help
./create_repo.sh --adv-help
./create_repo.sh --list-gitignore
```
