#!/bin/bash
################################################################################
# Auteur : Bruno DELNOZ | Email : bruno.delnoz@protonmail.com
# Script : create_repo.sh
# Version : v5.0 - Date : 2025-10-25
# Compatible avec : create_gitignore.sh v1.0
################################################################################

LOG_FILE="log.create_repo.v5.0.log"
DRY_RUN=false
REPO_CREATED=false
TEMPLATE=""
VISIBILITY="private"
OWNER=""
DEFAULT_BRANCH="main"
LOCAL_PATH=""
REPO_NAME=""
GITIGNORE_TEMPLATES=()
GITIGNORE_SCRIPT="$(dirname "$0")/create_gitignore.sh"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

print_help() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                    CREATE_REPO.SH v5.0 - AIDE                              ║
╚════════════════════════════════════════════════════════════════════════════╝

USAGE: ./create_repo.sh [OPTIONS]

OPTIONS PRINCIPALES:
  --exec <chemin>               Crée dépôt local + distant
  --delete-local <chemin>       Supprime dépôt local (avec backup)
  --delete-remote <nom>         Supprime dépôt distant GitHub

CONFIGURATION:
  --public / --private          Visibilité (défaut: private)
  --template <type>             Template: python, web, basic
  --gitignore [templates...]    Crée .gitignore (vide si sans args)

SYSTÈME:
  --simulate, -s                Mode simulation
  --prerequis, -pr              Vérifie prérequis
  --install, -i                 Installe prérequis
  --changelog, -ch              Changelog
  --help, -h                    Cette aide

EXEMPLES:
  ./create_repo.sh --exec ~/dev/projet
  ./create_repo.sh --exec ~/dev/app --template python
  ./create_repo.sh --exec ~/dev/web --gitignore python vscode macos

COMPORTEMENT v5.0:
  • Répertoire : créé si absent, conservé si existant
  • .git existant : CONSERVÉ
  • README.md existant : SKIP
  • .gitignore existant : FUSION
  • AUCUN commit auto : tu fais manuellement
  • Branches : main + working (minuscules)
  • Fin : tu es sur 'working'

WORKFLOW MANUEL:
  cd <chemin> && git add . && git commit -m "Initial"
  git push -u origin working && git checkout main
  git merge working && git push -u origin main

AUTEUR: Bruno DELNOZ
Compatible: create_gitignore.sh v1.0
EOF
    exit 0
}

show_changelog() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                         CHANGELOG v5.0                                     ║
╚════════════════════════════════════════════════════════════════════════════╝

v5.0 - 2025-10-25 : REFONTE MAJEURE
  • Suppression commits automatiques
  • Gestion répertoire existant (mkdir -p)
  • Conservation .git existant
  • Branche main (plus master)
  • Branche working (minuscules)
  • Externalisation .gitignore
  • README.md : skip si existe
  • .gitignore : fusion
EOF
    exit 0
}

check_prerequisites() {
    log "═══════════════════════════════════════════════════════════════════════════"
    log "VÉRIFICATION PRÉREQUIS"
    log "═══════════════════════════════════════════════════════════════════════════"
    
    log "[1/3] Git..."
    if ! command -v git &>/dev/null; then
        log "✗ ERREUR : Git non installé"
        exit 1
    fi
    log "✓ Git : $(git --version)"
    
    log "[2/3] GitHub CLI..."
    if ! command -v gh &>/dev/null; then
        log "✗ ERREUR : gh non installé"
        exit 1
    fi
    log "✓ gh : $(gh --version | head -n1)"
    
    log "[3/3] Authentification..."
    if ! gh auth status &>/dev/null; then
        log "✗ ERREUR : Non connecté à GitHub"
        exit 1
    fi
    log "✓ Authentification OK"
    log "═══════════════════════════════════════════════════════════════════════════"
}

install_prerequisites() {
    log "═══════════════════════════════════════════════════════════════════════════"
    log "INSTALLATION PRÉREQUIS"
    log "═══════════════════════════════════════════════════════════════════════════"
    
    if [ "$DRY_RUN" = false ]; then
        sudo apt-get update && sudo apt-get install -y git gh && gh auth login
    else
        log "[DRY-RUN] Installation simulée"
    fi
    
    log "✓ Installation terminée"
    exit 0
}

validate_repo_name() {
    if [ -z "$REPO_NAME" ]; then
        log "✗ ERREUR : Nom dépôt vide"
        exit 1
    fi
    if [[ ! "$REPO_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        log "✗ ERREUR : Nom invalide '$REPO_NAME'"
        exit 1
    fi
    if [ ${#REPO_NAME} -gt 100 ]; then
        log "✗ ERREUR : Nom trop long"
        exit 1
    fi
}

create_readme_from_template() {
    case "$1" in
        "python")
            cat > README.md << EOF
# $REPO_NAME

## Installation
\`\`\`bash
pip install -r requirements.txt
\`\`\`

## Utilisation
\`\`\`bash
python main.py
\`\`\`

Auteur: Bruno DELNOZ
EOF
            ;;
        "web")
            cat > README.md << EOF
# $REPO_NAME

## Installation
\`\`\`bash
npm install
\`\`\`

## Développement
\`\`\`bash
npm run dev
\`\`\`

Auteur: Bruno DELNOZ
EOF
            ;;
        *)
            echo "# $REPO_NAME" > README.md
            echo "" >> README.md
            echo "Auteur: Bruno DELNOZ" >> README.md
            ;;
    esac
}

check_existing_git() {
    if [ -d ".git" ]; then
        log "→ Dépôt Git existant, conservation historique"
        if git remote get-url origin &>/dev/null; then
            local existing=$(git remote get-url origin)
            log "⚠ Remote origin existe: $existing"
            log "→ Suppression ancienne remote"
            if [ "$DRY_RUN" = false ]; then
                git remote remove origin
            fi
        fi
    else
        log "→ Initialisation nouveau dépôt Git (branche main)"
        if [ "$DRY_RUN" = false ]; then
            git init -b main || { log "✗ ERREUR git init"; exit 1; }
        fi
    fi
}

create_repo() {
    log "═══════════════════════════════════════════════════════════════════════════"
    log "CRÉATION DÉPÔT GIT COMPLET"
    log "═══════════════════════════════════════════════════════════════════════════"
    
    validate_repo_name
    
    # [1/6] Répertoire
    log "[1/6] Répertoire: $LOCAL_PATH"
    if [ ! -d "$LOCAL_PATH" ]; then
        log "→ Création répertoire..."
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "$LOCAL_PATH" || { log "✗ ERREUR mkdir"; exit 1; }
        fi
    else
        log "→ Répertoire existe, conservation fichiers"
    fi
    
    if [ "$DRY_RUN" = false ]; then
        cd "$LOCAL_PATH" || { log "✗ ERREUR cd"; exit 1; }
    fi
    log "✓ Accès répertoire OK"
    
    # [2/6] Git
    log "[2/6] Vérification Git..."
    if [ "$DRY_RUN" = false ]; then
        check_existing_git
    fi
    
    # [3/6] Fichiers
    log "[3/6] Fichiers de base..."
    
    # README
    if [ -f "README.md" ]; then
        log "→ README.md existe, SKIP"
    else
        if [ "$DRY_RUN" = false ]; then
            if [ -n "$TEMPLATE" ]; then
                create_readme_from_template "$TEMPLATE"
            else
                echo "# $REPO_NAME" > README.md
            fi
        fi
        log "✓ README.md créé"
    fi
    
    # .gitignore
    if [ ${#GITIGNORE_TEMPLATES[@]} -gt 0 ]; then
        if [ "${GITIGNORE_TEMPLATES[0]}" = "empty" ]; then
            log "→ .gitignore vide"
            [ "$DRY_RUN" = false ] && touch .gitignore
        else
            log "→ .gitignore: ${GITIGNORE_TEMPLATES[*]}"
            if [ "$DRY_RUN" = false ] && [ -f "$GITIGNORE_SCRIPT" ]; then
                for tpl in "${GITIGNORE_TEMPLATES[@]}"; do
                    "$GITIGNORE_SCRIPT" "$tpl" --no-log --auto-append || log "⚠ $tpl échoué"
                done
            fi
        fi
    elif [ -n "$TEMPLATE" ]; then
        log "→ .gitignore via template: $TEMPLATE"
        [ "$DRY_RUN" = false ] && [ -f "$GITIGNORE_SCRIPT" ] && \
            "$GITIGNORE_SCRIPT" "$TEMPLATE" --no-log --auto-append
    else
        log "→ Pas de .gitignore"
    fi
    
    # [4/6] Dépôt distant
    log "[4/6] Dépôt distant..."
    if [ "$DRY_RUN" = false ]; then
        if ! gh repo view "$OWNER/$REPO_NAME" &>/dev/null; then
            gh repo create "$OWNER/$REPO_NAME" --"$VISIBILITY" --confirm || {
                log "✗ ERREUR création dépôt"
                exit 1
            }
        fi
    fi
    log "✓ Dépôt distant OK (VIDE)"
    
    # [5/6] Remote
    log "[5/6] Remote origin..."
    if [ "$DRY_RUN" = false ]; then
        git remote add origin "https://github.com/$OWNER/$REPO_NAME.git" || {
            log "✗ ERREUR remote"
            exit 1
        }
    fi
    log "✓ Remote configurée"
    
    # [6/6] Branche working
    log "[6/6] Branche working..."
    if [ "$DRY_RUN" = false ]; then
        if ! git show-ref --verify --quiet refs/heads/working; then
            git branch working
        fi
        git checkout working
    fi
    log "✓ Sur branche working"
    
    # Récap
    log "═══════════════════════════════════════════════════════════════════════════"
    log "✓ DÉPÔT CRÉÉ"
    log "═══════════════════════════════════════════════════════════════════════════"
    log ""
    log "INFOS:"
    log "  • Nom      : $REPO_NAME"
    log "  • Owner    : $OWNER"
    log "  • Visibilité: $VISIBILITY"
    log "  • Local    : $LOCAL_PATH"
    log "  • Distant  : https://github.com/$OWNER/$REPO_NAME (VIDE)"
    log "  • Branches : main, working (ACTIVE)"
    log "  • Fichiers : Untracked"
    [ -n "$TEMPLATE" ] && log "  • Template : $TEMPLATE"
    log ""
    log "⚠ Dépôt distant VIDE, aucun commit auto"
    log ""
    log "PROCHAINES ÉTAPES:"
    log "  cd $LOCAL_PATH"
    log "  git add . && git commit -m 'Initial'"
    log "  git push -u origin working"
    log "  git checkout main && git merge working"
    log "  git push -u origin main"
    log ""
    log "═══════════════════════════════════════════════════════════════════════════"
    
    REPO_CREATED=true
}

delete_local() {
    log "═══════════════════════════════════════════════════════════════════════════"
    log "SUPPRESSION LOCAL"
    log "═══════════════════════════════════════════════════════════════════════════"
    
    validate_repo_name
    
    if [ "$DRY_RUN" = false ]; then
        read -p "Confirmer? (oui): " confirm
        [ "$confirm" != "oui" ] && exit 0
    fi
    
    [ ! -d "$LOCAL_PATH" ] && { log "✗ Inexistant"; exit 1; }
    
    local backup="${REPO_NAME}_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    local backup_path="$(dirname "$LOCAL_PATH")/$backup"
    
    if [ "$DRY_RUN" = false ]; then
        tar -czf "$backup_path" -C "$(dirname "$LOCAL_PATH")" "$(basename "$LOCAL_PATH")" || exit 1
        log "✓ Backup: $backup_path"
        rm -rf "$LOCAL_PATH"
    fi
    
    log "✓ Suppression OK"
}

delete_remote() {
    log "═══════════════════════════════════════════════════════════════════════════"
    log "SUPPRESSION DISTANT"
    log "═══════════════════════════════════════════════════════════════════════════"
    
    if [ "$DRY_RUN" = false ]; then
        read -p "Confirmer? (oui): " confirm
        [ "$confirm" != "oui" ] && exit 0
        
        gh repo view "$OWNER/$REPO_NAME" &>/dev/null || { log "✗ Inexistant"; exit 1; }
        gh repo delete "$OWNER/$REPO_NAME" --yes || { log "✗ ERREUR"; exit 1; }
    fi
    
    log "✓ Suppression OK"
}

load_config() {
    OWNER=$(gh api user --jq .login 2>/dev/null)
    [ -z "$OWNER" ] && OWNER="bdelnoz"
}

# MAIN
[ $# -eq 0 ] && print_help

ACTION=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --exec|-exe)
            ACTION="exec"
            LOCAL_PATH="$2"
            REPO_NAME=$(basename "$2")
            shift 2
            ;;
        --delete-local)
            ACTION="delete_local"
            LOCAL_PATH="$2"
            REPO_NAME=$(basename "$2")
            shift 2
            ;;
        --delete-remote)
            ACTION="delete_remote"
            REPO_NAME="$2"
            shift 2
            ;;
        --public) VISIBILITY="public"; shift ;;
        --private) VISIBILITY="private"; shift ;;
        --template) TEMPLATE="$2"; shift 2 ;;
        --gitignore)
            shift
            while [[ $# -gt 0 && ! "$1" =~ ^-- ]]; do
                GITIGNORE_TEMPLATES+=("$1")
                shift
            done
            [ ${#GITIGNORE_TEMPLATES[@]} -eq 0 ] && GITIGNORE_TEMPLATES=("empty")
            ;;
        --simulate|-s) DRY_RUN=true; log "⚠ SIMULATION"; shift ;;
        --prerequis|-pr) check_prerequisites; exit 0 ;;
        --install|-i) install_prerequisites ;;
        --changelog|-ch) show_changelog ;;
        --help|-h) print_help ;;
        *) log "✗ Argument inconnu '$1'"; exit 1 ;;
    esac
done

load_config
check_prerequisites

case "$ACTION" in
    "exec") create_repo ;;
    "delete_local") delete_local ;;
    "delete_remote") delete_remote ;;
    *) log "✗ Aucune action"; exit 1 ;;
esac

log ""
log "═══════════════════════════════════════════════════════════════════════════"
log "Terminé: $(date '+%Y-%m-%d %H:%M:%S')"
log "═══════════════════════════════════════════════════════════════════════════"

exit 0
