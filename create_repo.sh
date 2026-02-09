#!/bin/bash
################################################################################
# Auteur : Bruno DELNOZ | Email : bruno.delnoz@protonmail.com
# Script : create_repo.sh
# Version : v5.0 - Date : 2025-10-25
# Changelog v5.0 :
#   - Suppression commits automatiques (utilisateur fait manuellement)
#   - Gestion intelligente répertoire existant (mkdir -p si absent)
#   - Conservation .git existant (pas de suppression)
#   - Branche par défaut : main (plus master)
#   - Branche de travail : working (minuscules)
#   - README.md : skip si existe
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

SYSTÈME:
  --simulate, -s                Mode simulation
  --prerequis, -pr              Vérifie prérequis
  --install, -i                 Installe prérequis
  --changelog, -ch              Changelog
  --help, -h                    Cette aide

EXEMPLES:
  ./create_repo.sh --exec ~/dev/projet
  ./create_repo.sh --exec ~/dev/app --template python

COMPORTEMENT v5.0:
  • Répertoire local : créé si absent, conservé si existant
  • .git existant : CONSERVÉ (plus de suppression)
  • README.md existant : SKIP création
  • AUCUN commit auto : tu fais add/commit/push manuellement
  • Branche défaut : main | Branche travail : working
  • Fin script : tu es sur branche 'working'

WORKFLOW MANUEL APRÈS CRÉATION:
  cd <chemin> && git status && git add . && git commit -m "Initial commit"
  git push -u origin working && git checkout main && git merge working
  git push -u origin main

AUTEUR: Bruno DELNOZ - bruno.delnoz@protonmail.com
EOF
    exit 0
}

show_changelog() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                    CHANGELOG - CREATE_REPO.SH                              ║
╚════════════════════════════════════════════════════════════════════════════╝

v5.0 - 2025-10-25 : REFONTE MAJEURE
  • Suppression commits automatiques (workflow manuel)
  • Gestion intelligente répertoire existant (mkdir -p)
  • Conservation .git existant
  • Branche main (plus master), branche working (minuscules)
  • README.md : skip si existe
  • Dépôt distant créé VIDE
  • Messages finaux détaillés avec workflow manuel

v4.0 - 2025-10-21 : Correction remote origin existante

AUTEUR: Bruno DELNOZ
EOF
    exit 0
}

check_prerequisites() {
    log "═══════════════════════════════════════════════════════════════════════════"
    log "VÉRIFICATION PRÉREQUIS"
    log "═══════════════════════════════════════════════════════════════════════════"
    
    log "[1/3] Git..."
    if ! command -v git &>/dev/null; then
        log "✗ ERREUR : Git non installé. Solution: ./create_repo.sh --install"
        exit 1
    fi
    log "✓ Git : $(git --version)"
    
    log "[2/3] GitHub CLI..."
    if ! command -v gh &>/dev/null; then
        log "✗ ERREUR : gh non installé. Solution: ./create_repo.sh --install"
        exit 1
    fi
    log "✓ gh : $(gh --version | head -n1)"
    
    log "[3/3] Authentification GitHub..."
    if ! gh auth status &>/dev/null; then
        log "✗ ERREUR : Non connecté. Solution: gh auth login"
        exit 1
    fi
    log "✓ Authentification active"
    log "═══════════════════════════════════════════════════════════════════════════"
    log "✓ TOUS PRÉREQUIS OK"
    log "═══════════════════════════════════════════════════════════════════════════"
}

install_prerequisites() {
    log "═══════════════════════════════════════════════════════════════════════════"
    log "INSTALLATION PRÉREQUIS"
    log "═══════════════════════════════════════════════════════════════════════════"
    
    if [ "$DRY_RUN" = false ]; then
        sudo apt-get update && sudo apt-get install -y git gh && gh auth login
    else
        log "[DRY-RUN] sudo apt-get update && install git gh && gh auth login"
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
        log "✗ ERREUR : Nom invalide '$REPO_NAME' (a-z A-Z 0-9 . _ - autorisés)"
        exit 1
    fi
    if [ ${#REPO_NAME} -gt 100 ]; then
        log "✗ ERREUR : Nom trop long (${#REPO_NAME} > 100)"
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
        log "→ Dépôt Git existant détecté, conservation historique"
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
    
    # [1/6] Répertoire local
    log "[1/6] Répertoire local: $LOCAL_PATH"
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
    
    # [2/6] Git existant
    log "[2/6] Vérification Git..."
    if [ "$DRY_RUN" = false ]; then
        check_existing_git
    fi
    
    # [3/6] Fichiers de base
    log "[3/6] Fichiers de base..."
    
    # README
    if [ -f "README.md" ]; then
        log "→ README.md existe, SKIP création"
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
    
    # [4/6] Dépôt distant
    log "[4/6] Dépôt distant GitHub..."
    if [ "$DRY_RUN" = false ]; then
        if ! gh repo view "$OWNER/$REPO_NAME" &>/dev/null; then
            gh repo create "$OWNER/$REPO_NAME" --"$VISIBILITY" --confirm || {
                log "✗ ERREUR création dépôt distant"
                exit 1
            }
        fi
    fi
    log "✓ Dépôt distant OK (VIDE)"
    
    # [5/6] Remote origin
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
    
    # Récapitulatif
    log "═══════════════════════════════════════════════════════════════════════════"
    log "✓ DÉPÔT CRÉÉ AVEC SUCCÈS"
    log "═══════════════════════════════════════════════════════════════════════════"
    log ""
    log "INFOS:"
    log "  • Nom      : $REPO_NAME"
    log "  • Owner    : $OWNER"
    log "  • Visibilité: $VISIBILITY"
    log "  • Local    : $LOCAL_PATH"
    log "  • Distant  : https://github.com/$OWNER/$REPO_NAME (VIDE)"
    log "  • Branches : main, working (locale ACTIVE)"
    log "  • Fichiers : Untracked (prêts pour commit manuel)"
    [ -n "$TEMPLATE" ] && log "  • Template : $TEMPLATE"
    log ""
    log "⚠ IMPORTANT: Dépôt distant VIDE, aucun commit auto"
    log ""
    log "PROCHAINES ÉTAPES (MANUEL):"
    log "  cd $LOCAL_PATH"
    log "  git status"
    log "  git add ."
    log "  git commit -m 'Initial commit'"
    log "  git push -u origin working"
    log "  git checkout main && git merge working"
    log "  git push -u origin main"
    log ""
    log "═══════════════════════════════════════════════════════════════════════════"
    
    REPO_CREATED=true
}

delete_local() {
    log "═══════════════════════════════════════════════════════════════════════════"
    log "SUPPRESSION DÉPÔT LOCAL"
    log "═══════════════════════════════════════════════════════════════════════════"
    
    validate_repo_name
    
    if [ "$DRY_RUN" = false ]; then
        read -p "Confirmer suppression? (taper 'oui'): " confirm
        [ "$confirm" != "oui" ] && exit 0
    fi
    
    [ ! -d "$LOCAL_PATH" ] && { log "✗ ERREUR: répertoire inexistant"; exit 1; }
    
    # Backup
    local backup="${REPO_NAME}_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    local backup_path="$(dirname "$LOCAL_PATH")/$backup"
    
    if [ "$DRY_RUN" = false ]; then
        tar -czf "$backup_path" -C "$(dirname "$LOCAL_PATH")" "$(basename "$LOCAL_PATH")" || exit 1
        log "✓ Backup: $backup_path"
        rm -rf "$LOCAL_PATH"
    fi
    
    log "✓ Suppression locale terminée"
}

delete_remote() {
    log "═══════════════════════════════════════════════════════════════════════════"
    log "SUPPRESSION DÉPÔT DISTANT"
    log "═══════════════════════════════════════════════════════════════════════════"
    
    if [ "$DRY_RUN" = false ]; then
        read -p "Confirmer suppression DISTANTE? (taper 'oui'): " confirm
        [ "$confirm" != "oui" ] && exit 0
        
        gh repo view "$OWNER/$REPO_NAME" &>/dev/null || { log "✗ Dépôt inexistant"; exit 1; }
        gh repo delete "$OWNER/$REPO_NAME" --yes || { log "✗ ERREUR suppression"; exit 1; }
    fi
    
    log "✓ Suppression distante terminée"
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
        --simulate|-s) DRY_RUN=true; log "⚠ MODE SIMULATION"; shift ;;
        --prerequis|-pr) check_prerequisites; exit 0 ;;
        --install|-i) install_prerequisites ;;
        --changelog|-ch) show_changelog ;;
        --help|-h) print_help ;;
        *)
            log "✗ ERREUR: Argument inconnu '$1'"
            exit 1
            ;;
    esac
done

load_config
check_prerequisites

case "$ACTION" in
    "exec") create_repo ;;
    "delete_local") delete_local ;;
    "delete_remote") delete_remote ;;
    *)
        log "✗ ERREUR: Aucune action spécifiée"
        exit 1
        ;;
esac

log ""
log "═══════════════════════════════════════════════════════════════════════════"
log "Script terminé: $(date '+%Y-%m-%d %H:%M:%S')"
log "═══════════════════════════════════════════════════════════════════════════"

exit 0
