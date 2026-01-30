#!/bin/bash
################################################################################
# Auteur : Bruno DELNOZ
# Email : bruno.delnoz@protonmail.com
# Nom du script avec path complet : ~/Security/scripts/divers/utility_tools/create_repo.sh
# Target usage : Gestion complète des dépôts Git (création locale/distante, suppression, templates, logs)
# Version : v4.0 - Date : 2025-10-21
# Changelog :
#   v4.0 - 2025-10-21 : Correction gestion remote origin existante + nettoyage Git avant réinit
#   v3.9 - 2025-10-21 : Vérification renforcée de la création du dépôt distant
################################################################################

################################################################################
# VARIABLES GLOBALES
################################################################################
# Fichier de log avec versioning pour traçabilité complète des opérations
LOG_FILE="log.create_repo.v4.0.log"
# Fichier de configuration utilisateur pour stocker les préférences
CONFIG_FILE="$HOME/.create_repo_config"
# Mode simulation (dry-run) : false = exécution réelle, true = simulation
DRY_RUN=false
# Flag indiquant si le dépôt a été créé avec succès
REPO_CREATED=false
# Type de template à utiliser (python, web, basic, ou vide)
TEMPLATE=""
# Visibilité du dépôt GitHub (private ou public)
VISIBILITY="private"
# Propriétaire du dépôt GitHub (username)
OWNER=""
# Branche par défaut du dépôt Git
DEFAULT_BRANCH="main"
# Chemin local complet du dépôt
LOCAL_PATH=""
# Nom du dépôt (extrait du chemin local)
REPO_NAME=""

################################################################################
# FONCTION : log
# Description : Enregistre un message dans le fichier log avec timestamp
# Paramètres :
#   $1 : Message à logger
# Retour : Aucun
################################################################################
log() {
    # Affiche le message avec timestamp à l'écran ET dans le fichier log
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

################################################################################
# FONCTION : print_help
# Description : Affiche l'aide complète du script avec tous les arguments
#               et exemples d'utilisation détaillés
# Paramètres : Aucun
# Retour : Sort du script avec code 0
################################################################################
print_help() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                    CREATE_REPO.SH - AIDE COMPLÈTE                          ║
╚════════════════════════════════════════════════════════════════════════════╝

USAGE:
  ./create_repo.sh [OPTIONS]

OPTIONS OBLIGATOIRES:
  --exec <chemin/local>          Crée un dépôt local et distant
                                 Exemple: --exec ~/projets/mon-app

  --delete-local <chemin/local>  Supprime UNIQUEMENT le dépôt local
                                 (avec sauvegarde automatique .tar.gz)
                                 Exemple: --delete-local ~/projets/mon-app

  --delete-remote <nom-dépôt>    Supprime UNIQUEMENT le dépôt distant GitHub
                                 Exemple: --delete-remote mon-app

OPTIONS DE CONFIGURATION:
  --public                       Visibilité publique du dépôt
                                 (Par défaut: privé)

  --private                      Visibilité privée du dépôt
                                 (Valeur par défaut)

  --template <type>              Utilise un template prédéfini
                                 Types disponibles:
                                   - python : Template Python (.gitignore, README)
                                   - web    : Template Web (node_modules, etc.)
                                   - basic  : Template basique (README uniquement)
                                 Exemple: --template python

OPTIONS SYSTEME:
  --simulate, -s                 Mode simulation (dry-run)
                                 Aucune action réelle n'est effectuée
                                 Affiche uniquement ce qui serait fait

  --prerequis, -pr               Vérifie les prérequis système
                                 (git, gh, authentification GitHub)

  --install, -i                  Installe les prérequis manquants
                                 (git, gh via apt-get)

  --changelog, -ch               Affiche le changelog complet du script

  --help, -h                     Affiche cette aide détaillée

EXEMPLES D'UTILISATION:

1. Créer un dépôt privé basique:
   ./create_repo.sh --exec ~/projets/mon-nouveau-projet

2. Créer un dépôt public avec template Python:
   ./create_repo.sh --exec ~/dev/api-python --public --template python

3. Créer un dépôt privé web en mode simulation:
   ./create_repo.sh --exec ~/sites/portfolio --template web --simulate

4. Vérifier les prérequis avant utilisation:
   ./create_repo.sh --prerequis

5. Supprimer uniquement le dépôt local (avec backup):
   ./create_repo.sh --delete-local ~/projets/ancien-projet

6. Supprimer uniquement le dépôt distant GitHub:
   ./create_repo.sh --delete-remote ancien-projet

7. Supprimer les deux (local + distant):
   ./create_repo.sh --delete-local ~/projets/projet
   ./create_repo.sh --delete-remote projet

VALEURS PAR DÉFAUT:
  - Visibilité : private
  - Template : aucun (README.md uniquement)
  - Branche principale : main
  - Branche de travail : Working
  - Owner : Détecté automatiquement via 'gh api user'

PRÉREQUIS:
  - git (installé et configuré)
  - gh (GitHub CLI, installé et authentifié)
  - Connexion GitHub active (gh auth status)

FICHIERS CRÉÉS:
  - log.create_repo.v4.0.log : Log complet de toutes les opérations
  - README.md : Fichier README du dépôt
  - .gitignore : Fichier d'exclusion Git (selon template)

NOTES IMPORTANTES:
  - Le script gère automatiquement les remotes Git existantes
  - En cas de réexécution, le script nettoie l'état Git avant recréation
  - Les suppressions locales créent TOUJOURS une sauvegarde .tar.gz
  - Les suppressions distantes demandent TOUJOURS confirmation

AUTEUR:
  Bruno DELNOZ - bruno.delnoz@protonmail.com

VERSION: v4.0 - 2025-10-21
EOF
    exit 0
}

################################################################################
# FONCTION : show_changelog
# Description : Affiche l'historique complet des versions du script
# Paramètres : Aucun
# Retour : Sort du script avec code 0
################################################################################
show_changelog() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                    CHANGELOG COMPLET - CREATE_REPO.SH                      ║
╚════════════════════════════════════════════════════════════════════════════╝

VERSION v4.0 - 2025-10-21
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[CORRECTIF MAJEUR] Correction de la gestion des remotes Git existantes
  • Ajout de la suppression automatique de la remote 'origin' si elle existe
  • Nettoyage complet du dépôt Git avant réinitialisation
  • Suppression des fichiers .git si présents lors de la réexécution
  • Gestion robuste des erreurs lors de l'ajout de remote
  • Amélioration des logs pour traçabilité complète

[AMÉLIORATION] Gestion des réexécutions du script
  • Détection intelligente de l'état Git existant
  • Nettoyage automatique avant recréation
  • Prévention des conflits de remote origin

[OPTIMISATION] Messages d'erreur plus explicites
  • Indications claires sur l'état du dépôt Git
  • Suggestions d'actions correctives en cas d'erreur

VERSION v3.9 - 2025-10-21
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[AMÉLIORATION] Vérification renforcée de la création du dépôt distant
  • Ajout d'une vérification post-création via 'gh repo view'
  • Message d'erreur détaillé si le dépôt distant n'existe pas
  • Logs améliorés pour debugging

VERSIONS ANTÉRIEURES DISPONIBLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Pour l'historique complet des versions v1.0 à v3.8, consulter le fichier
changelog.md ou les archives du dépôt Git.

AUTEUR: Bruno DELNOZ - bruno.delnoz@protonmail.com
EOF
    exit 0
}

################################################################################
# FONCTION : check_prerequisites
# Description : Vérifie que tous les prérequis système sont présents
#               (git, gh CLI, authentification GitHub)
# Paramètres : Aucun
# Retour : Sort du script avec code 1 si un prérequis manque
################################################################################
check_prerequisites() {
    log "╔════════════════════════════════════════════════════════════════════════════╗"
    log "║             VÉRIFICATION DES PRÉREQUIS SYSTÈME                            ║"
    log "╚════════════════════════════════════════════════════════════════════════════╝"

    # Vérification de la présence de Git
    log "[1/3] Vérification de Git..."
    if ! command -v git &>/dev/null; then
        log "✗ ERREUR : Git n'est pas installé sur le système."
        log "  → Solution : Exécute './create_repo.sh --install' pour l'installer"
        log "  → Ou manuellement : sudo apt-get install git"
        exit 1
    fi
    log "✓ Git détecté : $(git --version)"

    # Vérification de la présence de GitHub CLI
    log "[2/3] Vérification de GitHub CLI (gh)..."
    if ! command -v gh &>/dev/null; then
        log "✗ ERREUR : GitHub CLI (gh) n'est pas installé."
        log "  → Solution : Exécute './create_repo.sh --install' pour l'installer"
        log "  → Ou manuellement : sudo apt-get install gh"
        exit 1
    fi
    log "✓ GitHub CLI détecté : $(gh --version | head -n1)"

    # Vérification de l'authentification GitHub
    log "[3/3] Vérification de l'authentification GitHub..."
    if ! gh auth status &>/dev/null; then
        log "✗ ERREUR : Non connecté à GitHub via CLI."
        log "  → Solution : Exécute 'gh auth login' pour t'authentifier"
        log "  → Assure-toi d'avoir les scopes 'repo' et 'delete_repo'"
        exit 1
    fi
    log "✓ Authentification GitHub active"

    log "════════════════════════════════════════════════════════════════════════════"
    log "✓ TOUS LES PRÉREQUIS SONT SATISFAITS"
    log "════════════════════════════════════════════════════════════════════════════"
}

################################################################################
# FONCTION : install_prerequisites
# Description : Installe automatiquement les prérequis manquants
#               (git, gh) et lance l'authentification GitHub
# Paramètres : Aucun
# Retour : Sort du script avec code 0 après installation
################################################################################
install_prerequisites() {
    log "╔════════════════════════════════════════════════════════════════════════════╗"
    log "║               INSTALLATION DES PRÉREQUIS SYSTÈME                          ║"
    log "╚════════════════════════════════════════════════════════════════════════════╝"

    # Mise à jour de la liste des paquets
    log "[1/4] Mise à jour de la liste des paquets apt..."
    if [ "$DRY_RUN" = false ]; then
        sudo apt-get update || { log "✗ ERREUR : Impossible de mettre à jour apt."; exit 1; }
    else
        log "[DRY-RUN] Simulation : sudo apt-get update"
    fi
    log "✓ Liste des paquets mise à jour"

    # Installation de Git
    log "[2/4] Installation de Git..."
    if [ "$DRY_RUN" = false ]; then
        sudo apt-get install -y git || { log "✗ ERREUR : Impossible d'installer git."; exit 1; }
    else
        log "[DRY-RUN] Simulation : sudo apt-get install -y git"
    fi
    log "✓ Git installé"

    # Installation de GitHub CLI
    log "[3/4] Installation de GitHub CLI (gh)..."
    if [ "$DRY_RUN" = false ]; then
        sudo apt-get install -y gh || { log "✗ ERREUR : Impossible d'installer gh."; exit 1; }
    else
        log "[DRY-RUN] Simulation : sudo apt-get install -y gh"
    fi
    log "✓ GitHub CLI installé"

    # Authentification GitHub
    log "[4/4] Lancement de l'authentification GitHub..."
    if [ "$DRY_RUN" = false ]; then
        log "→ Suis les instructions à l'écran pour t'authentifier"
        gh auth login || { log "✗ ERREUR : Échec de l'authentification GitHub."; exit 1; }
    else
        log "[DRY-RUN] Simulation : gh auth login"
    fi
    log "✓ Authentification GitHub complétée"

    log "════════════════════════════════════════════════════════════════════════════"
    log "✓ INSTALLATION TERMINÉE AVEC SUCCÈS"
    log "════════════════════════════════════════════════════════════════════════════"
    exit 0
}

################################################################################
# FONCTION : validate_repo_name
# Description : Valide le nom du dépôt selon les règles GitHub
#               (caractères autorisés, longueur maximale)
# Paramètres : Aucun (utilise la variable globale REPO_NAME)
# Retour : Sort du script avec code 1 si le nom est invalide
################################################################################
validate_repo_name() {
    log "Validation du nom du dépôt : '$REPO_NAME'"

    # Vérification que le nom n'est pas vide
    if [ -z "$REPO_NAME" ]; then
        log "✗ ERREUR : Le nom du dépôt est vide ou manquant."
        log "  → Fournis un chemin local valide avec --exec"
        exit 1
    fi

    # Vérification du format du nom (alphanumériques, points, tirets, underscores)
    if [[ ! "$REPO_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        log "✗ ERREUR : Nom de dépôt invalide : '$REPO_NAME'"
        log "  → Seuls les caractères suivants sont autorisés : a-z A-Z 0-9 . _ -"
        exit 1
    fi

    # Vérification de la longueur maximale (GitHub limite à 100 caractères)
    if [ ${#REPO_NAME} -gt 100 ]; then
        log "✗ ERREUR : Le nom du dépôt est trop long (${#REPO_NAME} > 100 caractères)."
        log "  → Réduis la longueur du nom du dépôt"
        exit 1
    fi

    log "✓ Nom du dépôt valide"
}

################################################################################
# FONCTION : create_from_template
# Description : Crée les fichiers de base selon le template choisi
#               (README.md, .gitignore personnalisés)
# Paramètres :
#   $1 : Type de template (python, web, basic)
# Retour : Aucun
################################################################################
create_from_template() {
    local template="$1"
    log "Application du template : '$template'"

    case "$template" in
        "python")
            # Template Python : README + .gitignore Python standard
            log "→ Création du README.md pour projet Python"
            cat > README.md << EOF
# $REPO_NAME

## Description
Projet Python.

## Installation
\`\`\`bash
pip install -r requirements.txt
\`\`\`

## Utilisation
\`\`\`bash
python main.py
\`\`\`

## Auteur
Bruno DELNOZ - bruno.delnoz@protonmail.com
EOF

            log "→ Création du .gitignore Python"
            cat > .gitignore << EOF
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual Environment
venv/
ENV/
env/

# IDE
.vscode/
.idea/
*.swp
*.swo

# Environment
.env
.env.local

# Logs
*.log
EOF
            log "✓ Template Python appliqué"
            ;;

        "web")
            # Template Web : README + .gitignore Web/Node standard
            log "→ Création du README.md pour projet Web"
            cat > README.md << EOF
# $REPO_NAME

## Description
Projet Web.

## Installation
\`\`\`bash
npm install
\`\`\`

## Développement
\`\`\`bash
npm run dev
\`\`\`

## Build
\`\`\`bash
npm run build
\`\`\`

## Auteur
Bruno DELNOZ - bruno.delnoz@protonmail.com
EOF

            log "→ Création du .gitignore Web/Node"
            cat > .gitignore << EOF
# Dependencies
node_modules/
bower_components/

# Build
dist/
build/
.cache/

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Environment
.env
.env.local
.env.*.local
EOF
            log "✓ Template Web appliqué"
            ;;

        "basic"|*)
            # Template basique : README.md simple uniquement
            log "→ Création du README.md basique"
            cat > README.md << EOF
# $REPO_NAME

## Description
Projet créé avec create_repo.sh

## Auteur
Bruno DELNOZ - bruno.delnoz@protonmail.com
EOF
            log "✓ Template basique appliqué"
            ;;
    esac
}

################################################################################
# FONCTION : clean_existing_git
# Description : Nettoie complètement un dépôt Git existant
#               Supprime le répertoire .git et toutes les remotes
# Paramètres : Aucun
# Retour : Aucun
################################################################################
clean_existing_git() {
    log "Nettoyage du dépôt Git existant..."

    # Vérification de l'existence d'un dépôt Git
    if [ -d ".git" ]; then
        log "→ Dépôt Git détecté dans $(pwd)"

        # Suppression de la remote origin si elle existe
        if git remote get-url origin &>/dev/null; then
            log "→ Suppression de la remote 'origin' existante"
            if [ "$DRY_RUN" = false ]; then
                git remote remove origin 2>/dev/null || log "⚠ Impossible de supprimer la remote (peut-être déjà supprimée)"
            else
                log "[DRY-RUN] Simulation : git remote remove origin"
            fi
        fi

        # Suppression complète du répertoire .git
        log "→ Suppression complète du répertoire .git"
        if [ "$DRY_RUN" = false ]; then
            rm -rf .git || { log "✗ ERREUR : Impossible de supprimer .git"; exit 1; }
        else
            log "[DRY-RUN] Simulation : rm -rf .git"
        fi

        log "✓ Nettoyage Git terminé"
    else
        log "→ Aucun dépôt Git existant détecté"
    fi
}

################################################################################
# FONCTION : create_repo
# Description : Fonction principale de création du dépôt Git
#               Crée le répertoire local, initialise Git, crée les fichiers,
#               crée le dépôt distant GitHub, et configure les branches
# Paramètres : Aucun
# Retour : Sort du script avec code 1 en cas d'erreur
################################################################################
create_repo() {
    log "╔════════════════════════════════════════════════════════════════════════════╗"
    log "║                    CRÉATION DU DÉPÔT GIT COMPLET                          ║"
    log "╚════════════════════════════════════════════════════════════════════════════╝"

    # Validation du nom du dépôt
    validate_repo_name

    # Étape 1 : Création du répertoire local
    log "[1/9] Création du répertoire local : $LOCAL_PATH"
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$LOCAL_PATH" || {
            log "✗ ERREUR : Impossible de créer le répertoire $LOCAL_PATH."
            log "  → Vérifie les permissions du répertoire parent"
            exit 1
        }
        cd "$LOCAL_PATH" || {
            log "✗ ERREUR : Impossible d'accéder au répertoire $LOCAL_PATH."
            exit 1
        }
    else
        log "[DRY-RUN] Simulation : mkdir -p $LOCAL_PATH && cd $LOCAL_PATH"
    fi
    log "✓ Répertoire local créé et accessible"

    # Étape 2 : Nettoyage du Git existant (si présent)
    log "[2/9] Nettoyage du dépôt Git existant (si présent)..."
    if [ "$DRY_RUN" = false ]; then
        clean_existing_git
    else
        log "[DRY-RUN] Simulation : clean_existing_git"
    fi

    # Étape 3 : Initialisation du dépôt Git local
    log "[3/9] Initialisation du nouveau dépôt Git local..."
    if [ "$DRY_RUN" = false ]; then
        git init || {
            log "✗ ERREUR : Impossible d'initialiser le dépôt Git."
            exit 1
        }
    else
        log "[DRY-RUN] Simulation : git init"
    fi
    log "✓ Dépôt Git initialisé"

    # Étape 4 : Création des fichiers de base (README, .gitignore)
    log "[4/9] Création des fichiers de base..."
    if [ "$DRY_RUN" = false ]; then
        if [ -n "$TEMPLATE" ]; then
            create_from_template "$TEMPLATE"
        else
            log "→ Aucun template spécifié, création d'un README.md basique"
            echo "# $REPO_NAME" > README.md
        fi
    else
        log "[DRY-RUN] Simulation : Création des fichiers selon template '$TEMPLATE'"
    fi
    log "✓ Fichiers créés"

    # Étape 5 : Premier commit
    log "[5/9] Création du commit initial..."
    if [ "$DRY_RUN" = false ]; then
        git add . || {
            log "✗ ERREUR : Impossible d'ajouter les fichiers au staging."
            exit 1
        }
        git commit -m "Initial commit - Created with create_repo.sh v4.0" || {
            log "✗ ERREUR : Impossible de créer le commit initial."
            exit 1
        }
    else
        log "[DRY-RUN] Simulation : git add . && git commit -m 'Initial commit'"
    fi
    log "✓ Commit initial créé"

    # Étape 6 : Création du dépôt distant sur GitHub
    log "[6/9] Création du dépôt distant sur GitHub..."
    if [ "$DRY_RUN" = false ]; then
        # Vérification si le dépôt existe déjà sur GitHub
        if gh repo view "$OWNER/$REPO_NAME" &>/dev/null; then
            log "⚠ Le dépôt distant $OWNER/$REPO_NAME existe déjà sur GitHub."
            log "→ Utilisation du dépôt existant"

            # Ajout de la remote vers le dépôt existant
            log "→ Configuration de la remote 'origin'"
            git remote add origin "https://github.com/$OWNER/$REPO_NAME.git" || {
                log "✗ ERREUR : Impossible d'ajouter la remote 'origin'."
                log "  → La remote existe peut-être déjà (situation anormale après nettoyage)"
                exit 1
            }
        else
            # Création d'un nouveau dépôt sur GitHub
            log "→ Création d'un nouveau dépôt distant avec 'gh repo create'..."
            log "  • Owner : $OWNER"
            log "  • Nom : $REPO_NAME"
            log "  • Visibilité : $VISIBILITY"

            if ! gh repo create "$OWNER/$REPO_NAME" --"$VISIBILITY" --push --source=. --remote=origin; then
                log "✗ ERREUR : Impossible de créer le dépôt distant avec 'gh repo create'."
                log ""
                log "CAUSES POSSIBLES :"
                log "  1. Problème d'authentification GitHub"
                log "     → Vérifie : gh auth status"
                log "  2. Nom de dépôt invalide ou déjà pris"
                log "     → Vérifie sur https://github.com/$OWNER/$REPO_NAME"
                log "  3. Token sans les permissions nécessaires"
                log "     → Scopes requis : 'repo', 'delete_repo'"
                log "     → Régénère le token : gh auth refresh -h github.com -s repo,delete_repo"
                log "  4. Limite de dépôts atteinte (compte gratuit)"
                log "     → Vérifie tes quotas GitHub"
                log ""
                exit 1
            fi
        fi
    else
        log "[DRY-RUN] Simulation : Création/connexion au dépôt distant $OWNER/$REPO_NAME"
    fi
    log "✓ Dépôt distant configuré"

    # Étape 7 : Vérification de l'existence du dépôt distant
    log "[7/9] Vérification de l'existence du dépôt distant..."
    if [ "$DRY_RUN" = false ]; then
        if ! gh repo view "$OWNER/$REPO_NAME" &>/dev/null; then
            log "✗ ERREUR : Le dépôt distant n'a pas été créé correctement."
            log "  → Vérifie manuellement : https://github.com/$OWNER/$REPO_NAME"
            log "  → Causes possibles :"
            log "    - Problème réseau lors de la création"
            log "    - GitHub API temporairement indisponible"
            log "    - Permissions insuffisantes"
            exit 1
        fi
        log "✓ Dépôt distant confirmé : https://github.com/$OWNER/$REPO_NAME"
    else
        log "[DRY-RUN] Simulation : Vérification de l'existence du dépôt distant"
    fi

    # Étape 8 : Création de la branche 'Working'
    log "[8/9] Création de la branche 'Working'..."
    if [ "$DRY_RUN" = false ]; then
        # Vérification si la branche Working existe déjà localement
        if ! git show-ref --verify --quiet refs/heads/Working; then
            log "→ Création de la nouvelle branche 'Working'"
            git checkout -b Working || {
                log "✗ ERREUR : Impossible de créer la branche 'Working'."
                exit 1
            }
            log "→ Push de la branche 'Working' vers le dépôt distant"
            git push --set-upstream origin Working || {
                log "✗ ERREUR : Impossible de pousser la branche 'Working'."
                exit 1
            }
        else
            log "→ Branche 'Working' existe déjà localement"
            git checkout Working || {
                log "✗ ERREUR : Impossible de basculer sur la branche 'Working'."
                exit 1
            }
            log "→ Mise à jour de la branche 'Working' sur le dépôt distant"
            git push origin Working || {
                log "⚠ Avertissement : Impossible de mettre à jour la branche 'Working'."
                log "  → La branche existe peut-être déjà sur le distant"
            }
        fi
    else
        log "[DRY-RUN] Simulation : Création et push de la branche 'Working'"
    fi
    log "✓ Branche 'Working' configurée"

    # Étape 9 : Retour sur la branche principale
    log "[9/9] Retour sur la branche principale ($DEFAULT_BRANCH)..."
    if [ "$DRY_RUN" = false ]; then
        git checkout "$DEFAULT_BRANCH" 2>/dev/null || git checkout main 2>/dev/null || git checkout master || {
            log "⚠ Impossible de basculer sur la branche principale"
            log "  → Tu es actuellement sur : $(git branch --show-current)"
        }
    else
        log "[DRY-RUN] Simulation : git checkout $DEFAULT_BRANCH"
    fi

    # Récapitulatif final
    log "════════════════════════════════════════════════════════════════════════════"
    log "✓ DÉPÔT CRÉÉ AVEC SUCCÈS"
    log "════════════════════════════════════════════════════════════════════════════"
    log ""
    log "INFORMATIONS DU DÉPÔT :"
    log "  • Nom          : $REPO_NAME"
    log "  • Owner        : $OWNER"
    log "  • Visibilité   : $VISIBILITY"
    log "  • Local        : $LOCAL_PATH"
    log "  • Distant      : https://github.com/$OWNER/$REPO_NAME"
    log "  • Branches     : $DEFAULT_BRANCH (principale), Working (développement)"
    if [ -n "$TEMPLATE" ]; then
        log "  • Template     : $TEMPLATE"
    fi
    log ""
    log "PROCHAINES ÉTAPES :"
    log "  1. cd $LOCAL_PATH"
    log "  2. git checkout Working  # Pour travailler sur la branche de développement"
    log "  3. # Commence ton développement !"
    log ""
    log "════════════════════════════════════════════════════════════════════════════"

    # Marquage du dépôt comme créé avec succès
    REPO_CREATED=true
}

################################################################################
# FONCTION : delete_local
# Description : Supprime le dépôt local avec création automatique d'une sauvegarde
#               Demande confirmation avant suppression
# Paramètres : Aucun
# Retour : Sort du script avec code 1 en cas d'erreur
################################################################################
delete_local() {
    log "╔════════════════════════════════════════════════════════════════════════════╗"
    log "║                    SUPPRESSION DU DÉPÔT LOCAL                             ║"
    log "╚════════════════════════════════════════════════════════════════════════════╝"

    # Validation du nom du dépôt
    validate_repo_name

    log "ATTENTION : Suppression du dépôt LOCAL uniquement"
    log "  • Chemin : $LOCAL_PATH"
    log "  • Nom    : $REPO_NAME"
    log ""
    log "Une sauvegarde sera créée avant suppression :"
    log "  → ${REPO_NAME}_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    log ""

    # Demande de confirmation (sauf en mode simulation)
    if [ "$DRY_RUN" = false ]; then
        read -p "Confirmer la suppression LOCALE de $LOCAL_PATH ? (taper 'oui' pour confirmer) : " confirm
        if [ "$confirm" != "oui" ]; then
            log "✗ Suppression annulée par l'utilisateur."
            exit 0
        fi
    else
        log "[DRY-RUN] Mode simulation : la confirmation serait demandée"
    fi

    # Vérification de l'existence du répertoire
    if [ ! -d "$LOCAL_PATH" ]; then
        log "✗ ERREUR : Le répertoire $LOCAL_PATH n'existe pas."
        log "  → Vérifie le chemin fourni"
        exit 1
    fi

    # Création de la sauvegarde
    log "[1/2] Création de la sauvegarde..."
    local backup_name="${REPO_NAME}_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    local backup_path="$(dirname "$LOCAL_PATH")/$backup_name"

    if [ "$DRY_RUN" = false ]; then
        log "→ Compression en cours : $backup_path"
        tar -czf "$backup_path" -C "$(dirname "$LOCAL_PATH")" "$(basename "$LOCAL_PATH")" || {
            log "✗ ERREUR : Impossible de créer la sauvegarde."
            log "  → Vérifie l'espace disque disponible"
            log "  → Vérifie les permissions d'écriture"
            exit 1
        }
        log "✓ Sauvegarde créée : $backup_path"
        log "  • Taille : $(du -h "$backup_path" | cut -f1)"
    else
        log "[DRY-RUN] Simulation : tar -czf $backup_path"
    fi

    # Suppression du répertoire local
    log "[2/2] Suppression du répertoire local..."
    if [ "$DRY_RUN" = false ]; then
        rm -rf "$LOCAL_PATH" || {
            log "✗ ERREUR : Impossible de supprimer le répertoire $LOCAL_PATH."
            log "  → Vérifie les permissions"
            log "  → Vérifie qu'aucun processus n'utilise le répertoire"
            exit 1
        }
        log "✓ Répertoire local supprimé"
    else
        log "[DRY-RUN] Simulation : rm -rf $LOCAL_PATH"
    fi

    # Récapitulatif
    log "════════════════════════════════════════════════════════════════════════════"
    log "✓ SUPPRESSION LOCALE TERMINÉE"
    log "════════════════════════════════════════════════════════════════════════════"
    log ""
    log "RÉSUMÉ :"
    log "  • Dépôt local supprimé   : $LOCAL_PATH"
    log "  • Sauvegarde créée       : $backup_path"
    log "  • Dépôt distant conservé : https://github.com/$OWNER/$REPO_NAME"
    log ""
    log "RESTAURATION (si nécessaire) :"
    log "  tar -xzf $backup_path -C $(dirname "$LOCAL_PATH")"
    log ""
    log "════════════════════════════════════════════════════════════════════════════"
}

################################################################################
# FONCTION : delete_remote
# Description : Supprime le dépôt distant sur GitHub uniquement
#               Demande confirmation avant suppression
# Paramètres : Aucun
# Retour : Sort du script avec code 1 en cas d'erreur
################################################################################
delete_remote() {
    log "╔════════════════════════════════════════════════════════════════════════════╗"
    log "║                   SUPPRESSION DU DÉPÔT DISTANT                            ║"
    log "╚════════════════════════════════════════════════════════════════════════════╝"

    log "ATTENTION : Suppression du dépôt DISTANT uniquement (GitHub)"
    log "  • Owner : $OWNER"
    log "  • Nom   : $REPO_NAME"
    log "  • URL   : https://github.com/$OWNER/$REPO_NAME"
    log ""
    log "⚠ CETTE ACTION EST IRRÉVERSIBLE !"
    log ""

    # Demande de confirmation (sauf en mode simulation)
    if [ "$DRY_RUN" = false ]; then
        read -p "Confirmer la suppression DISTANTE de $OWNER/$REPO_NAME ? (taper 'oui' pour confirmer) : " confirm
        if [ "$confirm" != "oui" ]; then
            log "✗ Suppression annulée par l'utilisateur."
            exit 0
        fi
    else
        log "[DRY-RUN] Mode simulation : la confirmation serait demandée"
    fi

    # Vérification de l'existence du dépôt distant
    log "[1/2] Vérification de l'existence du dépôt distant..."
    if [ "$DRY_RUN" = false ]; then
        if ! gh repo view "$OWNER/$REPO_NAME" &>/dev/null; then
            log "✗ ERREUR : Le dépôt $OWNER/$REPO_NAME n'existe pas sur GitHub."
            log "  → Vérifie l'orthographe du nom"
            log "  → Vérifie que tu as accès au dépôt"
            exit 1
        fi
        log "✓ Dépôt distant trouvé"
    else
        log "[DRY-RUN] Simulation : gh repo view $OWNER/$REPO_NAME"
    fi

    # Suppression du dépôt distant
    log "[2/2] Suppression du dépôt distant sur GitHub..."
    if [ "$DRY_RUN" = false ]; then
        if ! gh repo delete "$OWNER/$REPO_NAME" --yes; then
            log "✗ ERREUR : Impossible de supprimer le dépôt distant."
            log ""
            log "CAUSES POSSIBLES :"
            log "  1. Permissions insuffisantes"
            log "     → Ton token doit avoir le scope 'delete_repo'"
            log "     → Régénère : gh auth refresh -h github.com -s delete_repo"
            log "  2. Tu n'es pas propriétaire du dépôt"
            log "     → Seul le propriétaire peut supprimer un dépôt"
            log "  3. Problème de connexion GitHub"
            log "     → Vérifie : gh auth status"
            log ""
            exit 1
        fi
        log "✓ Dépôt distant supprimé"
    else
        log "[DRY-RUN] Simulation : gh repo delete $OWNER/$REPO_NAME --yes"
    fi

    # Récapitulatif
    log "════════════════════════════════════════════════════════════════════════════"
    log "✓ SUPPRESSION DISTANTE TERMINÉE"
    log "════════════════════════════════════════════════════════════════════════════"
    log ""
    log "RÉSUMÉ :"
    log "  • Dépôt distant supprimé : https://github.com/$OWNER/$REPO_NAME"
    log "  • Dépôt local conservé   : $LOCAL_PATH (si existant)"
    log ""
    log "NOTE : Si tu as un dépôt local, il n'est PAS affecté par cette suppression."
    log "       Pour le supprimer aussi, utilise : --delete-local $LOCAL_PATH"
    log ""
    log "════════════════════════════════════════════════════════════════════════════"
}

################################################################################
# FONCTION : load_config
# Description : Charge la configuration utilisateur
#               Récupère automatiquement le username GitHub via 'gh api user'
# Paramètres : Aucun
# Retour : Aucun
################################################################################
load_config() {
    log "Chargement de la configuration utilisateur..."

    # Récupération automatique du username GitHub
    OWNER=$(gh api user --jq .login 2>/dev/null)

    # Fallback sur 'bdelnoz' si la récupération échoue
    if [ -z "$OWNER" ]; then
        log "⚠ Impossible de récupérer le username GitHub automatiquement"
        log "  → Utilisation du fallback : bdelnoz"
        OWNER="bdelnoz"
    else
        log "✓ Owner GitHub détecté : $OWNER"
    fi
}

################################################################################
# FONCTION : print_actions_summary
# Description : Affiche un récapitulatif numéroté de toutes les actions effectuées
# Paramètres : Aucun
# Retour : Aucun
################################################################################
print_actions_summary() {
    log ""
    log "╔════════════════════════════════════════════════════════════════════════════╗"
    log "║                    RÉCAPITULATIF DES ACTIONS EFFECTUÉES                   ║"
    log "╚════════════════════════════════════════════════════════════════════════════╝"
    log ""

    if [ "$REPO_CREATED" = true ]; then
        log "ACTIONS RÉALISÉES (CRÉATION DE DÉPÔT) :"
        log "  1. Vérification des prérequis système (git, gh, auth)"
        log "  2. Validation du nom du dépôt : '$REPO_NAME'"
        log "  3. Création du répertoire local : $LOCAL_PATH"
        log "  4. Nettoyage du dépôt Git existant (si présent)"
        log "  5. Initialisation du nouveau dépôt Git local"
        log "  6. Création des fichiers de base (README.md, .gitignore)"
        log "  7. Commit initial des fichiers"
        log "  8. Création/connexion au dépôt distant GitHub"
        log "  9. Vérification de l'existence du dépôt distant"
        log "  10. Création et push de la branche 'Working'"
        log "  11. Retour sur la branche principale '$DEFAULT_BRANCH'"
    fi

    log ""
    log "FICHIERS CRÉÉS/MODIFIÉS :"
    log "  • $LOG_FILE (log complet des opérations)"
    if [ "$REPO_CREATED" = true ]; then
        log "  • $LOCAL_PATH/README.md"
        if [ -n "$TEMPLATE" ] && [ "$TEMPLATE" != "basic" ]; then
            log "  • $LOCAL_PATH/.gitignore"
        fi
        log "  • $LOCAL_PATH/.git/ (dépôt Git)"
    fi

    log ""
    log "════════════════════════════════════════════════════════════════════════════"
}

################################################################################
# BLOC PRINCIPAL D'EXÉCUTION
################################################################################

# Si aucun argument n'est passé, afficher l'aide
if [ $# -eq 0 ]; then
    print_help
fi

# Variable pour stocker l'action à effectuer
ACTION=""

# Parsing des arguments de la ligne de commande
while [[ $# -gt 0 ]]; do
    case "$1" in
        --exec|-exe)
            # Action : Créer un dépôt local et distant
            ACTION="exec"
            LOCAL_PATH="$2"
            REPO_NAME=$(basename "$2")
            shift 2
            ;;
        --delete-local)
            # Action : Supprimer uniquement le dépôt local
            ACTION="delete_local"
            LOCAL_PATH="$2"
            REPO_NAME=$(basename "$2")
            shift 2
            ;;
        --delete-remote)
            # Action : Supprimer uniquement le dépôt distant
            ACTION="delete_remote"
            REPO_NAME="$2"
            shift 2
            ;;
        --public)
            # Option : Dépôt public
            VISIBILITY="public"
            shift
            ;;
        --private)
            # Option : Dépôt privé (par défaut)
            VISIBILITY="private"
            shift
            ;;
        --template)
            # Option : Template à utiliser (python, web, basic)
            TEMPLATE="$2"
            shift 2
            ;;
        --simulate|-s)
            # Option : Mode simulation (dry-run)
            DRY_RUN=true
            log "⚠ MODE SIMULATION ACTIVÉ - Aucune action réelle ne sera effectuée"
            shift
            ;;
        --prerequis|-pr)
            # Action : Vérifier les prérequis
            check_prerequisites
            log ""
            log "✓ Tous les prérequis sont satisfaits. Tu peux utiliser le script."
            exit 0
            ;;
        --install|-i)
            # Action : Installer les prérequis
            install_prerequisites
            ;;
        --changelog|-ch)
            # Action : Afficher le changelog
            show_changelog
            ;;
        --help|-h)
            # Action : Afficher l'aide
            print_help
            ;;
        *)
            # Argument inconnu
            log "✗ ERREUR : Argument inconnu '$1'."
            log "  → Utilise --help pour voir les arguments disponibles"
            print_help
            exit 1
            ;;
    esac
done

# Chargement de la configuration utilisateur (récupération du username GitHub)
load_config

# Vérification des prérequis avant toute action
check_prerequisites

# Exécution de l'action demandée
case "$ACTION" in
    "exec")
        # Création du dépôt (local + distant)
        create_repo
        print_actions_summary
        ;;
    "delete_local")
        # Suppression du dépôt local uniquement
        delete_local
        ;;
    "delete_remote")
        # Suppression du dépôt distant uniquement
        delete_remote
        ;;
    *)
        # Aucune action spécifiée
        log "✗ ERREUR : Aucune action spécifiée."
        log "  → Utilise --exec, --delete-local, ou --delete-remote"
        print_help
        exit 1
        ;;
esac

# Fin du script
log ""
log "════════════════════════════════════════════════════════════════════════════"
log "Script terminé à $(date '+%Y-%m-%d %H:%M:%S')"
log "════════════════════════════════════════════════════════════════════════════"

exit 0
