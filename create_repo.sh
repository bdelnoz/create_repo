#!/bin/bash
################################################################################
# Auteur : Bruno DELNOZ | Email : bruno.delnoz@protonmail.com
# Script : create_repo.sh
# Version : v5.5 - Date : 2026-03-29
# Changelog v5.5 :
#   - Added mandatory AGENTS.md sync from script source directory to target repository
#   - AGENTS.md now always overwrites target copy and logs absolute source/target paths
#   - Fixed README behavior to prevent content duplication on repeated runs
#   - README existing content is preserved and only metadata header is normalized
# Changelog v5.4 :
#   - Updated visibility switch examples to use `pwd` notation as requested
#   - Kept path-based resolution behavior unchanged
# Changelog v5.3 :
#   - Added path-aware switch arguments: --switchtopublic <path|repo|owner/repo>
#   - Added auto-detection from local folder and origin remote URL when available
#   - Updated help/changelog/docs for local-path visibility switching
# Changelog v5.2 :
#   - Added --switchtopublic <repo> and --switchtoprivate <repo>
#   - Added non-destructive visibility switch using gh repo edit
#   - Help and changelog updated for visibility switch actions
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

SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
MASTER_AGENTS_PATH="${SCRIPT_DIR}/AGENTS.md"

LOG_FILE="log.create_repo.v5.5.log"
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
SWITCH_TARGET=""

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

print_help() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                    CREATE_REPO.SH v5.5 - HELP                              ║
╚════════════════════════════════════════════════════════════════════════════╝

USAGE: ./create_repo.sh [OPTIONS]

OPTIONS PRINCIPALES:
  --exec <chemin>               Crée dépôt local + distant
  --delete-local <chemin>       Supprime dépôt local (avec backup)
  --delete-remote <nom>         Supprime dépôt distant GitHub
  --switchtopublic <target>     Switch visibility to public (path|repo|owner/repo)
  --switchtoprivate <target>    Switch visibility to private (path|repo|owner/repo)

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

EXAMPLES:
  ./create_repo.sh --exec ~/dev/projet
  ./create_repo.sh --exec ~/dev/app --template python
  ./create_repo.sh --switchtopublic my-repo
  ./create_repo.sh --switchtoprivate owner/my-repo
  ./create_repo.sh --switchtopublic `pwd`

BEHAVIOR v5.5:
  • Répertoire local : créé si absent, conservé si existant
  • AGENTS.md master copié depuis le dossier source de create_repo.sh
  • AGENTS.md cible toujours écrasé par la version master
  • .git existant : CONSERVÉ (plus de suppression)
  • README/.gitignore gérés si activés
  • README existant : pas de duplication, contenu conservé, header normalisé
  • Commit auto sur main + git status en fin
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

v5.4 - 2026-03-29 : UPDATE
  • Updated examples to use `pwd` notation for local path input
  • Kept path-aware repo resolution and non-destructive switch behavior

v5.5 - 2026-03-29 : UPDATE
  • Added mandatory AGENTS.md synchronization from script source directory
  • Target AGENTS.md is always overwritten by the master version
  • Added absolute source/target path logging for AGENTS.md sync
  • Fixed README handling to avoid duplicated content on repeated runs
  • README existing content is preserved while metadata header is normalized

v5.3 - 2026-03-29 : UPDATE
  • Added support for --switchtopublic/--switchtoprivate with local path input
  • Added auto-detection of owner/repo from git remote origin when available
  • Added fallback to folder name as repository name for local path inputs

v5.2 - 2026-03-29 : UPDATE
  • Added --switchtopublic <repo> action
  • Added --switchtoprivate <repo> action
  • Added non-destructive visibility switch with gh repo edit

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

build_markdown_metadata_header() {
    local document_name="$1"
    local version="$2"
    local datetime="$3"
    cat << EOF
<!--
Document : ${document_name}
Auteur : Bruno DELNOZ
Email : bruno.delnoz@protonmail.com
Version : ${version}
Date : ${datetime}
-->
EOF
}

extract_markdown_metadata_value() {
    local file="$1"
    local key="$2"
    local default="$3"
    local value
    value=$(sed -n "s/^${key}[[:space:]]*:[[:space:]]*//p" "$file" | head -n 1)
    if [ -n "$value" ]; then
        echo "$value"
    else
        echo "$default"
    fi
}

extract_readme_body_without_metadata() {
    local file="$1"
    awk '
    BEGIN { in_metadata=0; metadata_consumed=0 }
    NR==1 && $0 ~ /^<!--$/ { in_metadata=1; metadata_consumed=1; next }
    in_metadata == 1 {
        if ($0 ~ /^-->$/) {
            in_metadata=0
            next
        }
        next
    }
    metadata_consumed == 1 && $0 ~ /^[[:space:]]*$/ { next }
    { print }
    ' "$file"
}

ensure_readme_header() {
    local readme_path="README.md"
    local tmp_file
    tmp_file=$(mktemp)
    local now_datetime
    now_datetime="$(date '+%Y-%m-%d %H:%M:%S')"

    if [ ! -f "$readme_path" ]; then
        build_markdown_metadata_header "README.md" "v1.0.0" "$now_datetime" > "$readme_path"
        printf "\n# %s\n" "$REPO_NAME" >> "$readme_path"
        log "✓ README.md créé"
        return
    fi

    local version
    local datetime
    version=$(extract_markdown_metadata_value "$readme_path" "Version" "v1.0.0")
    datetime=$(extract_markdown_metadata_value "$readme_path" "Date" "$now_datetime")

    build_markdown_metadata_header "README.md" "$version" "$datetime" > "$tmp_file"
    printf "\n" >> "$tmp_file"
    extract_readme_body_without_metadata "$readme_path" >> "$tmp_file"

    mv "$tmp_file" "$readme_path"
    log "✓ README.md existant normalisé (header metadata), contenu conservé sans duplication"
}

sync_master_agents_to_target_repo() {
    local target_agents_path="$LOCAL_PATH/AGENTS.md"
    local source_agents_absolute
    local target_agents_absolute

    source_agents_absolute=$(readlink -f "$MASTER_AGENTS_PATH")
    target_agents_absolute=$(readlink -m "$target_agents_path")

    if [ ! -f "$MASTER_AGENTS_PATH" ]; then
        log "✗ ERREUR : AGENTS.md master introuvable dans la source script ($MASTER_AGENTS_PATH)"
        exit 1
    fi

    cp -f "$MASTER_AGENTS_PATH" "$target_agents_path"
    log "✓ AGENTS.md synchronized from master: $source_agents_absolute -> $target_agents_absolute"
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
    
    # [2/8] Synchronisation AGENTS.md master
    log "[2/8] Synchronisation AGENTS.md master..."
    if [ "$DRY_RUN" = false ]; then
        sync_master_agents_to_target_repo
    else
        log "[DRY-RUN] AGENTS.md master sync ($MASTER_AGENTS_PATH -> $LOCAL_PATH/AGENTS.md)"
    fi

    # [3/8] Fichiers de base (README en priorité)
    log "[3/8] Fichiers de base (README en priorité)..."
    
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

    # [4/8] Vérification Git
    log "[4/8] Vérification Git..."
    if [ "$DRY_RUN" = false ]; then
        check_existing_git
    fi
    
    # [5/8] Dépôt distant
    log "[5/8] Dépôt distant GitHub..."
    if [ "$DRY_RUN" = false ]; then
        if ! gh repo view "$OWNER/$REPO_NAME" &>/dev/null; then
            gh repo create "$REPO_NAME" --"$VISIBILITY" --confirm || {
                log "✗ ERREUR création dépôt distant"
                exit 1
            }
        fi
    fi
    log "✓ Dépôt distant OK (VIDE)"
    
    # [6/8] Remote origin
    log "[6/8] Remote origin..."
    if [ "$DRY_RUN" = false ]; then
        git remote add origin "https://github.com/$OWNER/$REPO_NAME.git" || {
            log "✗ ERREUR remote"
            exit 1
        }
    fi
    log "✓ Remote configurée"
    
    # [7/8] Branche initial_branch
    log "[7/8] Branche initial_branch..."
    if [ "$DRY_RUN" = false ]; then
        if ! git show-ref --verify --quiet refs/heads/initial_branch; then
            git branch initial_branch
        fi
        git checkout initial_branch
    fi
    log "✓ Sur branche initial_branch"
    
    # [8/8] Commit et push main
    log "[8/8] Commit et push main..."
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

build_repo_target_from_switch_input() {
    local input_target="$1"
    local target_repo=""
    local candidate_path=""
    local origin_url=""
    
    if [ -z "$input_target" ]; then
        input_target="$(pwd)"
    fi
    
    if [ -d "$input_target" ]; then
        candidate_path="$input_target"
    elif [ "$input_target" = "." ]; then
        candidate_path="$(pwd)"
    fi
    
    if [ -n "$candidate_path" ]; then
        REPO_NAME="$(basename "$candidate_path")"
        
        if [ -d "$candidate_path/.git" ]; then
            origin_url=$(git -C "$candidate_path" remote get-url origin 2>/dev/null || true)
        fi
        
        if [[ "$origin_url" =~ github\.com[:/]([^/]+)/([^/.]+)(\.git)?$ ]]; then
            target_repo="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
        else
            target_repo="$OWNER/$REPO_NAME"
        fi
    else
        if [[ "$input_target" == */* ]]; then
            target_repo="$input_target"
            REPO_NAME="$(basename "$input_target")"
        else
            REPO_NAME="$input_target"
            target_repo="$OWNER/$REPO_NAME"
        fi
    fi
    
    echo "$target_repo"
}

switch_repo_visibility() {
    log "═══════════════════════════════════════════════════════════════════════════"
    log "VISIBILITY SWITCH (NON-DESTRUCTIVE)"
    log "═══════════════════════════════════════════════════════════════════════════"
    
    local target_repo
    target_repo=$(build_repo_target_from_switch_input "$SWITCH_TARGET")
    
    validate_repo_name
    
    log "[1/4] Input target: $SWITCH_TARGET"
    log "[2/4] Resolved repository: $target_repo"
    log "[3/4] Requested visibility: $VISIBILITY"
    
    if [ "$DRY_RUN" = false ]; then
        gh repo view "$target_repo" &>/dev/null || { log "✗ Repository does not exist or is not accessible"; exit 1; }
        gh repo edit "$target_repo" --visibility "$VISIBILITY" || { log "✗ Visibility switch failed"; exit 1; }
    else
        log "[DRY-RUN] gh repo edit $target_repo --visibility $VISIBILITY"
    fi
    
    log "[4/4] Verification"
    if [ "$DRY_RUN" = false ]; then
        gh repo view "$target_repo" --json visibility --jq .visibility | while read -r current_visibility; do
            log "✓ Current visibility: $current_visibility"
        done
    fi
    
    log "✓ Visibility switch completed without repository destruction"
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
        --switchtopublic)
            ACTION="switch_visibility"
            SWITCH_TARGET="$2"
            REPO_NAME=$(basename "$2")
            VISIBILITY="public"
            shift 2
            ;;
        --switchtoprivate)
            ACTION="switch_visibility"
            SWITCH_TARGET="$2"
            REPO_NAME=$(basename "$2")
            VISIBILITY="private"
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
    "switch_visibility") switch_repo_visibility ;;
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
