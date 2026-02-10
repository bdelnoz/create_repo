#!/bin/bash
################################################################################
# Auteur : Bruno DELNOZ | Email : bruno.delnoz@protonmail.com
# Script : create_repo.sh
# Version : v5.1 - Date : 2026-02-09
# Changelog v5.1 :
#   - README.md standardisé (header DOCUMENT INFORMATION)
#   - .gitignore créé/complété après README
#   - Branche de travail : initial_branch
#   - Commit/push auto sur main + git status en fin
#   - README/.gitignore traités avant le reste
# Changelog v5.0 :
#   - Suppression commits automatiques (utilisateur fait manuellement)
#   - Gestion intelligente répertoire existant (mkdir -p si absent)
#   - Conservation .git existant (pas de suppression)
#   - Branche par défaut : main (plus master)
#   - Branche de travail : initial_branch (minuscules)
#   - README.md : skip si existe
################################################################################

LOG_FILE="log.create_repo.v5.1.log"
DRY_RUN=false
REPO_CREATED=false
TEMPLATE=""
VISIBILITY="private"
OWNER=""
DEFAULT_BRANCH="main"
LOCAL_PATH=""
REPO_NAME=""
DO_README=true
DO_GITIGNORE=true

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

print_help() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                    CREATE_REPO.SH v5.1 - AIDE                              ║
╚════════════════════════════════════════════════════════════════════════════╝

USAGE: ./create_repo.sh [OPTIONS]

OPTIONS PRINCIPALES:
  --exec <chemin>               Crée dépôt local + distant
  --delete-local <chemin>       Supprime dépôt local (avec backup)
  --delete-remote <nom>         Supprime dépôt distant GitHub

CONFIGURATION:
  --public / --private          Visibilité (défaut: private)
  --template <type>             Template: python, web, basic
  --readme / --no-readme        Activer/désactiver actions README
  --gitignore / --no-gitignore  Activer/désactiver actions .gitignore

SYSTÈME:
  --simulate, -s                Mode simulation
  --prerequis, -pr              Vérifie prérequis
  --install, -i                 Installe prérequis
  --changelog, -ch              Changelog
  --help, -h                    Cette aide

EXEMPLES:
  ./create_repo.sh --exec ~/dev/projet
  ./create_repo.sh --exec ~/dev/app --template python

COMPORTEMENT v5.1:
  • Répertoire local : créé si absent, conservé si existant
  • .git existant : CONSERVÉ (plus de suppression)
  • README/.gitignore gérés si activés
  • Commit auto sur main + git status en fin
  • README.md existant : SKIP création
  • AUCUN commit auto : tu fais add/commit/push manuellement
  • Branche défaut : main | Branche travail : initial_branch
  • Fin script : tu es sur branche 'main'

WORKFLOW AUTOMATIQUE APRÈS CRÉATION:
  cd <chemin> && git add . && git commit -m "init repo - FIRST COMMIT"
  git push -u origin main
  git status

AUTEUR: Bruno DELNOZ - bruno.delnoz@protonmail.com
EOF
    exit 0
}

show_changelog() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                    CHANGELOG - CREATE_REPO.SH                              ║
╚════════════════════════════════════════════════════════════════════════════╝

v5.1 - 2026-02-09 : MISE À JOUR
  • README standardisé (DOCUMENT INFORMATION)
  • .gitignore créé/complété après README
  • Branche initial_branch + commit/push auto sur main
  • README/.gitignore traités avant le reste

v5.0 - 2025-10-25 : REFONTE MAJEURE
  • Suppression commits automatiques (workflow manuel)
  • Gestion intelligente répertoire existant (mkdir -p)
  • Conservation .git existant
  • Branche main (plus master), branche initial_branch (minuscules)
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

build_readme_header() {
    local document_name="$1"
    local document_path="$2"
    local author="$3"
    local email="$4"
    local version="$5"
    local datetime="$6"
    local project="$7"
    local description="$8"
    cat << EOF
################################################################################
# DOCUMENT INFORMATION
################################################################################
# Document Name    : ${document_name}
# Document Full Path & name : ${document_path}
# Author         : ${author}
# Email          : ${email}
# Version        : ${version}
# Date  / Time   : ${datetime}
# Project : ${project}
# Short description : ${description}
################################################################################
EOF
}

get_readme_header_value() {
    local file="$1"
    local key="$2"
    local default="$3"
    local value
    value=$(sed -n "s/^# ${key}[[:space:]]*: //p" "$file" | head -n 1)
    if [ -n "$value" ]; then
        echo "$value"
    else
        echo "$default"
    fi
}

strip_existing_header() {
    local file="$1"
    awk '
    BEGIN { skip=0 }
    {
        if (!skip && $0 ~ /^################################################################################$/) {
            hash_line = $0
            if (getline next_line) {
                if (next_line ~ /^# DOCUMENT INFORMATION$/) {
                    skip = 1
                    while (getline line) {
                        if (line ~ /^################################################################################$/) {
                            skip = 0
                            break
                        }
                    }
                    next
                } else {
                    print hash_line
                    print next_line
                    next
                }
            }
        }
        if (!skip) {
            print
        }
    }
    ' "$file"
}

ensure_readme_header() {
    local readme_path="README.md"
    local tmp_file
    tmp_file=$(mktemp)

    if [ ! -f "$readme_path" ]; then
        build_readme_header "README.md" "README.md" "Bruno DELNOZ" \
            "bruno.delnoz@protonmail.com" "V1.0" "2026-02-09 19:22:16" \
            "$REPO_NAME" "Project overview" > "$readme_path"
        log "✓ README.md créé"
        return
    fi

    local document_name
    local document_path
    local author
    local email
    local version
    local datetime
    local project
    local description

    document_name=$(get_readme_header_value "$readme_path" "Document Name" "README.md")
    document_path=$(get_readme_header_value "$readme_path" "Document Full Path & name" "README.md")
    author=$(get_readme_header_value "$readme_path" "Author" "Bruno DELNOZ")
    email=$(get_readme_header_value "$readme_path" "Email" "bruno.delnoz@protonmail.com")
    version=$(get_readme_header_value "$readme_path" "Version" "V1.0")
    datetime=$(get_readme_header_value "$readme_path" "Date  / Time" "2026-02-09 19:22:16")
    project=$(get_readme_header_value "$readme_path" "Project" "$REPO_NAME")
    description=$(get_readme_header_value "$readme_path" "Short description" "Project overview")

    build_readme_header "$document_name" "$document_path" "$author" "$email" \
        "$version" "$datetime" "$project" "$description" > "$tmp_file"

    if grep -q "^# DOCUMENT INFORMATION$" "$readme_path"; then
        strip_existing_header "$readme_path" >> "$tmp_file"
    else
        cat "$readme_path" >> "$tmp_file"
    fi

    mv "$tmp_file" "$readme_path"
    log "✓ README.md mis à jour"
}

ensure_gitignore() {
    local gitignore_path=".gitignore"
    local gitignore_content=(
        "# PROJECT SPECIFIC"
        "uploads"
        "*.pid"
        "__pycache__"
        "*.log"
        "*.db"
        "creation_log"
        "*-swp"
        "*.tmp"
        "*.log"
        "*.bak"
        "*.pid"
        "# ========================================"
        "# Template: shell"
        "# Added: 2026-02-04 22:19:59"
        "# ========================================"
        "logs/"
        "output/"
        "infos/"
        "result/"
        "results/"
        "backup/"
        "*.log"
        "*.zip"
        "*.tar.gz"
        "*.rar"
        "certs/"
        "secrets/"
    )

    if [ ! -f "$gitignore_path" ]; then
        printf "%s\n" "${gitignore_content[@]}" > "$gitignore_path"
        log "✓ .gitignore créé"
        return
    fi

    local missing_entries=0
    for entry in "${gitignore_content[@]}"; do
        if ! grep -Fxq "$entry" "$gitignore_path"; then
            echo "$entry" >> "$gitignore_path"
            missing_entries=$((missing_entries + 1))
        fi
    done

    if [ "$missing_entries" -gt 0 ]; then
        log "✓ .gitignore mis à jour ($missing_entries entrées ajoutées)"
    else
        log "→ .gitignore déjà à jour"
    fi
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
    
    # [1/7] Répertoire local
    log "[1/7] Répertoire local: $LOCAL_PATH"
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
    
    # [2/7] Fichiers de base (avant toute autre opération)
    log "[2/7] Fichiers de base (README en priorité)..."
    
    if [ "$DO_README" = true ]; then
        if [ "$DRY_RUN" = false ]; then
            ensure_readme_header
        else
            log "[DRY-RUN] README.md"
        fi
    fi

    if [ "$DO_GITIGNORE" = true ]; then
        if [ "$DRY_RUN" = false ]; then
            ensure_gitignore
        else
            log "[DRY-RUN] .gitignore"
        fi
    fi

    # .gitignore
    if [ "$DRY_RUN" = false ]; then
        ensure_gitignore
    fi
    
    # [3/7] Vérification Git
    log "[3/7] Vérification Git..."
    if [ "$DRY_RUN" = false ]; then
        check_existing_git
    fi
    
    # [4/7] Dépôt distant
    log "[4/7] Dépôt distant GitHub..."
    if [ "$DRY_RUN" = false ]; then
        if ! gh repo view "$OWNER/$REPO_NAME" &>/dev/null; then
            gh repo create "$OWNER/$REPO_NAME" --"$VISIBILITY" --confirm || {
                log "✗ ERREUR création dépôt distant"
                exit 1
            }
        fi
    fi
    log "✓ Dépôt distant OK (VIDE)"
    
    # [5/7] Remote origin
    log "[5/7] Remote origin..."
    if [ "$DRY_RUN" = false ]; then
        git remote add origin "https://github.com/$OWNER/$REPO_NAME.git" || {
            log "✗ ERREUR remote"
            exit 1
        }
    fi
    log "✓ Remote configurée"
    
    # [6/7] Branche initial_branch
    log "[6/7] Branche initial_branch..."
    if [ "$DRY_RUN" = false ]; then
        if ! git show-ref --verify --quiet refs/heads/initial_branch; then
            git branch initial_branch
        fi
        git checkout initial_branch
    fi
    log "✓ Sur branche initial_branch"
    
    # [7/7] Commit et push main
    log "[7/7] Commit et push main..."
    if [ "$DRY_RUN" = false ]; then
        git checkout main
        git add .
        if ! git diff --cached --quiet; then
            git commit -m "init repo - FIRST COMMIT"
        else
            log "→ Aucun changement à commit"
        fi
        git push -u origin main
        git status
    fi
    log "✓ Push main OK"
    
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
    log "  • Branches : main, initial_branch (locale ACTIVE: main)"
    log "  • Fichiers : Suivis et poussés sur main"
    [ -n "$TEMPLATE" ] && log "  • Template : $TEMPLATE"
    log ""
    log "⚠ IMPORTANT: Dépôt distant initialisé avec commit auto"
    log ""
    log "PROCHAINES ÉTAPES:"
    log "  cd $LOCAL_PATH"
    log "  git status"
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
        --readme) DO_README=true; shift ;;
        --no-readme) DO_README=false; shift ;;
        --gitignore) DO_GITIGNORE=true; shift ;;
        --no-gitignore) DO_GITIGNORE=false; shift ;;
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
