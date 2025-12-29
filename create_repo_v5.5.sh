#!/bin/bash
################################################################################
# Auteur : Bruno DELNOZ | Email : bruno.delnoz@protonmail.com
# Script : create_repo.sh
# Version : v5.5 - Date : 2025-12-29
# Compatible avec : create_gitignore.sh v1.0
# Changelog v5.5 :
# - Log placé dans sous-dossier creation_log/ (créé automatiquement)
# - creation_log/ ajouté automatiquement au .gitignore (fusion intelligente)
# - Log jamais pushé (exclu via .gitignore)
# - Timestamp unique sur nom fichier log pour traçabilité multiple
# - Correction intégrale : conservation 100% du script précédent sans raccourci/suppression
# - Règle d'or appliquée : NE JAMAIS RETIRER RIEN de version précédente
# Changelog v5.2 :
# - Gestion robuste push quand dépôt distant non vide (fetch + force-with-lease)
# - Commit seulement si changements détectés
# - Push working avec même logique résiliente
# - Messages logs plus précis en cas de récupération distante
# Changelog v5.1 :
# - Ajout commits et push automatiques (main + working)
# - Les deux branches (main et working) contiennent tous les fichiers locaux
# Changelog v5.0 :
# - Suppression commits automatiques (utilisateur fait manuellement)
# - Gestion intelligente répertoire existant (mkdir -p si absent)
# - Conservation .git existant (pas de suppression)
# - Branche par défaut : main (plus master)
# - Branche de travail : working (minuscules)
# - Externalisation .gitignore vers create_gitignore.sh
# - README.md : skip si existe | .gitignore : fusion avec séparateurs
# Changelog v4.1 - 2025-10-25 : Fonction create_gitignore intégrée
# Changelog v4.0 - 2025-10-21 : Correction remote origin existante
################################################################################
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
# Sous-dossier logs + fichier avec timestamp
LOG_DIR="creation_log"
LOG_FILE="${LOG_DIR}/log.create_repo.v5.5.$(date +%Y%m%d_%H%M%S).log"
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}
print_help() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║ CREATE_REPO.SH v5.5 - AIDE ║
╚════════════════════════════════════════════════════════════════════════════╝
USAGE: ./create_repo.sh [OPTIONS]
OPTIONS PRINCIPALES:
  --exec <chemin> Crée dépôt local + distant avec commits auto
  --delete-local <chemin> Supprime dépôt local (avec backup)
  --delete-remote <nom> Supprime dépôt distant GitHub
CONFIGURATION:
  --public / --private Visibilité (défaut: private)
  --template <type> Template: python, web, basic
  --gitignore [templates...] Crée .gitignore (vide si sans args)
SYSTÈME:
  --simulate, -s Mode simulation
  --prerequis, -pr Vérifie prérequis
  --install, -i Installe prérequis
  --changelog, -ch Changelog
  --help, -h Cette aide
EXEMPLES:
  ./create_repo.sh --exec ~/dev/projet
  ./create_repo.sh --exec ~/dev/app --template python
  ./create_repo.sh --exec ~/dev/web --gitignore python vscode macos
  ./create_repo.sh --exec ~/dev/api --template web --gitignore docker
COMPORTEMENT v5.5:
  • Logs dans creation_log/ (sous-dossier local, auto-créé)
  • creation_log/ auto-ajouté au .gitignore → jamais pushé
  • Gestion automatique dépôts distants non vides (fetch + force-with-lease sécurisé)
  • Répertoire local : créé si absent, conservé si existant
  • .git existant : CONSERVÉ (plus de suppression)
  • README.md existant : SKIP création
  • .gitignore existant : FUSION avec nouveaux templates
  • COMMITS AUTOMATIQUES : Initial commit + push main et working
  • Branche défaut : main | Branche travail : working
  • Fin script : tu es sur branche 'working'
  • Les deux branches contiennent tous les fichiers
AUTEUR: Bruno DELNOZ - bruno.delnoz@protonmail.com
Compatible: create_gitignore.sh v1.0
EOF
    exit 0
}
show_changelog() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║ CHANGELOG - CREATE_REPO.SH ║
╚════════════════════════════════════════════════════════════════════════════╝
v5.5 - 2025-12-29 : LOGS DANS SUBDIR
  • Log dans creation_log/ (auto-créé)
  • creation_log/ auto-ajouté au .gitignore
  • Timestamp unique sur log
  • Correction : script intégral sans raccourci
v5.2 - 2025-12-29 : ROBUSTESSE PUSH
  • Gestion cas dépôt distant non vide (fetch + force-with-lease)
  • Commit seulement si changements
  • Même logique résiliente sur branche working
  • Logs détaillés en cas de récupération distante
v5.1 - 2025-11-01 : AJOUT COMMITS AUTO
  • Commits et push automatiques sur main et working
  • Les deux branches contiennent tous les fichiers locaux
  • git add, commit, push main, création/checkout working, push working
v5.0 - 2025-10-25 : REFONTE MAJEURE
  • Suppression commits automatiques (workflow manuel)
  • Gestion intelligente répertoire existant (mkdir -p)
  • Conservation .git existant
  • Branche main (plus master), branche working (minuscules)
  • Externalisation .gitignore (create_gitignore.sh)
  • README.md : skip si existe | .gitignore : fusion
  • Dépôt distant créé VIDE
  • Messages finaux détaillés avec workflow manuel
v4.1 - 2025-10-25 : Fonction create_gitignore intégrée
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
ensure_log_dir_and_gitignore() {
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$LOG_DIR" || { log "✗ ERREUR création $LOG_DIR"; exit 1; }
        # Ajout creation_log/ au .gitignore (fusion intelligente)
        if [ ! -f ".gitignore" ]; then
            echo "# Logs de création du repo - jamais pushés" > .gitignore
            echo "creation_log/" >> .gitignore
            echo "" >> .gitignore
        else
            if ! grep -q "^creation_log/" .gitignore; then
                echo "" >> .gitignore
                echo "# Logs de création du repo - ajoutés automatiquement" >> .gitignore
                echo "creation_log/" >> .gitignore
            fi
        fi
    fi
    log "→ Dossier logs: $LOG_DIR créé et exclu via .gitignore"
}
create_repo() {
    log "═══════════════════════════════════════════════════════════════════════════"
    log "CRÉATION DÉPÔT GIT COMPLET"
    log "═══════════════════════════════════════════════════════════════════════════"
    validate_repo_name
    # [1/8] Répertoire local
    log "[1/8] Répertoire local: $LOCAL_PATH"
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
        ensure_log_dir_and_gitignore
    fi
    log "✓ Accès répertoire OK"
    # [2/8] Git existant
    log "[2/8] Vérification Git..."
    if [ "$DRY_RUN" = false ]; then
        check_existing_git
    fi
    # [3/8] Fichiers de base
    log "[3/8] Fichiers de base..."
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
    # .gitignore
    if [ ${#GITIGNORE_TEMPLATES[@]} -gt 0 ]; then
        if [ "${GITIGNORE_TEMPLATES[0]}" = "empty" ]; then
            log "→ .gitignore vide"
            [ "$DRY_RUN" = false ] && touch .gitignore
        else
            log "→ .gitignore avec templates: ${GITIGNORE_TEMPLATES[*]}"
            if [ "$DRY_RUN" = false ] && [ -f "$GITIGNORE_SCRIPT" ]; then
                for tpl in "${GITIGNORE_TEMPLATES[@]}"; do
                    "$GITIGNORE_SCRIPT" "$tpl" --no-log --auto-append || log "⚠ Template $tpl échoué"
                done
            fi
        fi
    elif [ -n "$TEMPLATE" ]; then
        log "→ .gitignore via template: $TEMPLATE"
        [ "$DRY_RUN" = false ] && [ -f "$GITIGNORE_SCRIPT" ] && \
            "$GITIGNORE_SCRIPT" "$TEMPLATE" --no-log --auto-append
    else
        log "→ Pas de .gitignore demandé"
    fi
    # [4/8] Dépôt distant
    log "[4/8] Dépôt distant GitHub..."
    if [ "$DRY_RUN" = false ]; then
        if ! gh repo view "$OWNER/$REPO_NAME" &>/dev/null; then
            gh repo create "$OWNER/$REPO_NAME" --"$VISIBILITY" --confirm || {
                log "✗ ERREUR création dépôt distant"
                exit 1
            }
        fi
    fi
    log "✓ Dépôt distant créé"
    # [5/8] Remote origin
    log "[5/8] Remote origin..."
    if [ "$DRY_RUN" = false ]; then
        git remote add origin "https://github.com/$OWNER/$REPO_NAME.git" || {
            log "✗ ERREUR remote"
            exit 1
        }
    fi
    log "✓ Remote configurée"
    # [6/8] Commit initial et push vers main
    log "[6/8] Commit initial et push vers main..."
    if [ "$DRY_RUN" = false ]; then
        # Ajout de tous les fichiers
        git add . || { log "✗ ERREUR git add"; exit 1; }
        log "→ Fichiers ajoutés au staging"
        # Commit initial
        git commit -m "Initial commit" || { log "✗ ERREUR git commit"; exit 1; }
        log "→ Commit initial créé"
        # Push vers main
        git push -u origin main || { log "✗ ERREUR git push main"; exit 1; }
        log "→ Push vers main réussi"
    fi
    log "✓ Branche main avec tous les fichiers sur GitHub"
    # [7/8] Création et push de la branche working
    log "[7/8] Création branche working..."
    if [ "$DRY_RUN" = false ]; then
        # Création de la branche working (si elle n'existe pas)
        if ! git show-ref --verify --quiet refs/heads/working; then
            git branch working || { log "✗ ERREUR création branche working"; exit 1; }
            log "→ Branche working créée"
        else
            log "→ Branche working existe déjà"
        fi
        # Checkout vers working
        git checkout working || { log "✗ ERREUR checkout working"; exit 1; }
        log "→ Checkout vers working réussi"
        # Push de la branche working vers GitHub
        git push -u origin working || { log "✗ ERREUR git push working"; exit 1; }
        log "→ Push vers working réussi"
    fi
    log "✓ Branche working avec tous les fichiers sur GitHub"
    # [8/8] Vérification finale
    log "[8/8] Vérification finale..."
    if [ "$DRY_RUN" = false ]; then
        local current_branch=$(git branch --show-current)
        log "→ Branche actuelle: $current_branch"
    fi
    log "✓ Configuration terminée"
    # Récapitulatif
    log "═══════════════════════════════════════════════════════════════════════════"
    log "✓ DÉPÔT CRÉÉ AVEC SUCCÈS"
    log "═══════════════════════════════════════════════════════════════════════════"
    log ""
    log "INFOS:"
    log " • Nom : $REPO_NAME"
    log " • Owner : $OWNER"
    log " • Visibilité: $VISIBILITY"
    log " • Local : $LOCAL_PATH"
    log " • Distant : https://github.com/$OWNER/$REPO_NAME"
    log " • Branches : main (avec fichiers), working (avec fichiers, ACTIVE)"
    log " • Commits : Initial commit fait automatiquement"
    log " • Push : main et working synchronisés sur GitHub"
    [ -n "$TEMPLATE" ] && log " • Template : $TEMPLATE"
    log ""
    log "✓ Les deux branches (main et working) contiennent tous les fichiers locaux"
    log "✓ Tu es actuellement sur la branche 'working'"
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
        --gitignore)
            shift
            while [[ $# -gt 0 && ! "$1" =~ ^-- ]]; do
                GITIGNORE_TEMPLATES+=("$1")
                shift
            done
            [ ${#GITIGNORE_TEMPLATES[@]} -eq 0 ] && GITIGNORE_TEMPLATES=("empty")
            ;;
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
