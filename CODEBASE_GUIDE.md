# Guide néophyte de la base de code

## Vue d’ensemble

Ce dépôt est volontairement minimaliste : il contient **un script Bash principal** (`create_repo.sh`) qui automatise des opérations de gestion de dépôts Git/GitHub.

Le script sait :
- vérifier les prérequis (Git, GitHub CLI, authentification),
- créer un dépôt local + distant,
- générer/mettre à jour `README.md` et `.gitignore`,
- préparer des branches (`main` et `initial_branch`),
- supprimer un dépôt local (avec backup) ou distant.

## Structure actuelle

- `create_repo.sh` : cœur fonctionnel du projet.
- `CODEBASE_GUIDE.md` : ce document d’orientation.
- `.git/` : métadonnées Git du dépôt (historique, index, configuration locale).

## Carte mentale de `create_repo.sh`

Le script est organisé en **blocs logiques** :

1. **Configuration globale** (variables au début)
   - nom du fichier de log,
   - drapeaux d’exécution (simulation, options README/.gitignore),
   - paramètres du dépôt (nom, chemin, visibilité).

2. **Fonctions utilitaires**
   - `log()` pour tracer les actions,
   - `print_help()` / `show_changelog()` pour l’interface CLI.

3. **Fonctions système**
   - `check_prerequisites()` et `install_prerequisites()`.

4. **Fonctions métier**
   - `validate_repo_name()` : protège contre des noms invalides,
   - `ensure_readme_header()` : normalise l’en-tête README,
   - `ensure_gitignore()` : crée/complète `.gitignore`,
   - `check_existing_git()` : gère dépôt existant et remote `origin`,
   - `create_repo()`, `delete_local()`, `delete_remote()`.

5. **Point d’entrée (main)**
   - parse les arguments (`while case`),
   - charge la configuration (`load_config`),
   - vérifie les prérequis,
   - déclenche l’action choisie.

## Comportement important à connaître

- **Action obligatoire** : sans argument, le script affiche l’aide.
- **Authentification GitHub requise** : même en local, le flux standard vérifie `gh auth status`.
- **Mode simulation** (`--simulate`) : utile pour comprendre ce que ferait le script sans exécuter les opérations sensibles.
- **Sécurité suppression locale** : archive `.tar.gz` avant suppression.
- **Suppression distante** : destructive et confirmée, utilise `gh repo delete --yes` après vérification.

## Points de repère pour apprendre progressivement

### Étape 1 — Comprendre l’interface CLI
Commencer par lire et exécuter :
```bash
./create_repo.sh --help
./create_repo.sh --changelog
```
Objectif : voir les options et le vocabulaire du script.

### Étape 2 — Lire les fonctions dans l’ordre
Ordre conseillé :
1. `log` → 2. `check_prerequisites` → 3. `validate_repo_name` → 4. `create_repo` → 5. bloc `main`.

### Étape 3 — Tester sans risque
Faire des essais en simulation :
```bash
./create_repo.sh --simulate --exec ~/tmp/mon-test
```
Puis comparer avec un test réel dans un répertoire jetable.

### Étape 4 — Identifier les zones à améliorer
Pour un prochain cycle d’apprentissage, surveiller :
- cohérence des messages (certaines lignes parlent à la fois de commit auto et manuel),
- duplication potentielle (`ensure_gitignore` appelée deux fois dans `create_repo`),
- factorisation possible de la logique de logs/erreurs,
- ajout de tests automatisés (au moins tests de parsing/options).

## Conseils pratiques pour la suite

- Utiliser `shellcheck create_repo.sh` pour repérer les risques Bash.
- Ajouter des scénarios de test documentés : création neuve, dossier déjà existant, dépôt déjà initialisé, simulation.
- Si le projet grossit, découper en plusieurs fichiers (`lib/log.sh`, `lib/git.sh`, etc.) pour faciliter la maintenance.
