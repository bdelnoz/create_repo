#!/bin/bash
################################################################################
# Auteur : Bruno DELNOZ | Email : bruno.delnoz@protonmail.com
# Script : create_repo.sh
# Version : v6.0 - Date : 2025-10-25
# Description : Gestion complète des dépôts Git (création locale/distante,
#               suppression, templates, .gitignore, logs)
################################################################################

LOG_FILE="log.create_repo.v6.0.log"
CONFIG_FILE="$HOME/.create_repo_config"
DRY_RUN=false
REPO_CREATED=false
TEMPLATE=""
VISIBILITY="private"
OWNER=""
DEFAULT_BRANCH="main"
LOCAL_PATH=""
REPO_NAME=""
GITIGNORE_TEMPLATES=()

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

print_help() {
    cat << 'EOF_HELP'
╔════════════════════════════════════════════════════════════════════════════╗
║                    CREATE_REPO.SH - AIDE COMPLÈTE                          ║
╚════════════════════════════════════════════════════════════════════════════╝

USAGE:
  ./create_repo.sh [OPTIONS]

OPTIONS PRINCIPALES:
  --exec <chemin/local>          Crée un dépôt local et distant
                                 Exemple: --exec ~/projets/mon-app

  --delete-local <chemin/local>  Supprime UNIQUEMENT le dépôt local
                                 (avec sauvegarde automatique .tar.gz)
                                 Exemple: --delete-local ~/projets/mon-app

  --delete-remote <nom-dépôt>    Supprime UNIQUEMENT le dépôt distant GitHub
                                 Exemple: --delete-remote mon-app

  --gitignore <types...>         Crée un fichier .gitignore dans le répertoire courant
                                 (un ou plusieurs types)
                                 Exemple: --gitignore python vscode macos

  --list-gitignore               Liste tous les templates .gitignore disponibles

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

  --adv-help, --advanced-help    Aide avancée (cas d'usage, exemples détaillés)

  --help, -h                     Affiche cette aide détaillée

EXEMPLES D'UTILISATION:

1. Créer un dépôt privé basique:
   ./create_repo.sh --exec ~/projets/mon-nouveau-projet

2. Créer un dépôt public avec template Python:
   ./create_repo.sh --exec ~/dev/api-python --public --template python

3. Créer un .gitignore multi-environnement (Python + VSCode + macOS):
   ./create_repo.sh --gitignore python vscode macos

4. Vérifier les prérequis avant utilisation:
   ./create_repo.sh --prerequis

AUTEUR:
  Bruno DELNOZ - bruno.delnoz@protonmail.com

VERSION: v6.0 - 2025-10-25
EOF_HELP
    exit 0
}

show_changelog() {
    cat << 'EOF_CHANGELOG'
╔════════════════════════════════════════════════════════════════════════════╗
║                    CHANGELOG COMPLET - CREATE_REPO.SH                      ║
╚════════════════════════════════════════════════════════════════════════════╝

VERSION v6.0 - 2025-10-25
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[MAJEUR] Fusion de toutes les versions en un seul script stable
  • Fonctionnalités unifiées (création dépôt, suppression, gitignore, templates)
  • Suppression de la création automatique de la branche Working
  • Suppression des commits automatiques (workflow manuel)
  • Ajout du support multi-templates .gitignore

VERSION v4.1 - 2025-10-25
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[NOUVELLE FONCTIONNALITÉ] Création de fichiers .gitignore standalone
  • Ajout de la fonction create_gitignore() avec 25+ templates prédéfinis
  • Nouvelle option --gitignore <type> pour créer un .gitignore sans créer de dépôt
  • Support de multiples langages et environnements
  • Détection intelligente des .gitignore existants avec fusion optionnelle
  • Templates disponibles : Python, Node/Web, Java, C++, Rust, Go, Ruby, PHP,
    .NET, Swift, Android, Unity, LaTeX, Jekyll, Hugo, macOS, Linux, Windows,
    VSCode, JetBrains, Vim, Sublime, Docker, Terraform, Laravel, Django, Rails

VERSION v5.0 - 2025-10-25
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[AMÉLIORATION] Ajustements workflow
  • Conservation des dépôts Git existants
  • .gitignore : fusion avec séparateurs
  • README.md : skip si existe
EOF_CHANGELOG
    exit 0
}

print_advanced_help() {
    cat << 'EOF_ADV'
╔════════════════════════════════════════════════════════════════════════════╗
║                       AIDE AVANCÉE - CREATE_REPO.SH                        ║
╚════════════════════════════════════════════════════════════════════════════╝

1. COMPRENDRE L'OPTION --gitignore
  L'option --gitignore permet de créer un fichier .gitignore SANS créer de
  dépôt Git complet. C'est utile pour ajouter un .gitignore à un projet existant.

  Exemple :
    ./create_repo.sh --gitignore python

  → Crée un .gitignore dans le répertoire courant (pwd)
  → AUCUN dépôt Git n'est créé, juste le fichier .gitignore

  MULTI-ENVIRONNEMENT (Fusion de plusieurs .gitignore) :
    ./create_repo.sh --gitignore python vscode macos

  RÉSULTAT FINAL : Un seul fichier .gitignore contenant Python + VSCode + macOS

2. DIFFÉRENCE ENTRE --exec / --template ET --gitignore
  --exec + --template : crée un dépôt complet avec README + .gitignore
  --gitignore         : crée UNIQUEMENT un fichier .gitignore

3. PROBLÈME : "gitignore patterns not working"
  CAUSE : fichiers déjà trackés dans Git avant le .gitignore
  SOLUTION :
    git rm -r --cached .
    git add .
    git commit -m "Apply .gitignore"

4. AIDE SUPPLÉMENTAIRE
  --help           Aide standard (syntaxe et exemples de base)
  --adv-help       Aide avancée (concepts et cas d'usage)
  --list-gitignore Liste TOUS les templates .gitignore disponibles
  --changelog      Historique des versions du script

AUTEUR : Bruno DELNOZ
VERSION : v6.0 - 2025-10-25
EOF_ADV
    exit 0
}

load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        # shellcheck disable=SC1090
        source "$CONFIG_FILE"
        log "Configuration chargée depuis $CONFIG_FILE"
    else
        OWNER=$(gh api user --jq .login 2>/dev/null)
        [ -z "$OWNER" ] && OWNER="bdelnoz"
    fi
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

    log "[3/3] Authentification GitHub..."
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
    log "Validation du nom du dépôt : '$REPO_NAME'"

    if [ -z "$REPO_NAME" ]; then
        log "✗ ERREUR : Le nom du dépôt est vide ou manquant."
        exit 1
    fi

    if [[ ! "$REPO_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        log "✗ ERREUR : Nom de dépôt invalide : '$REPO_NAME'"
        log "  → Seuls les caractères suivants sont autorisés : a-z A-Z 0-9 . _ -"
        exit 1
    fi

    if [ ${#REPO_NAME} -gt 100 ]; then
        log "✗ ERREUR : Le nom du dépôt est trop long (${#REPO_NAME} > 100 caractères)."
        exit 1
    fi

    log "✓ Nom du dépôt valide"
}

list_gitignore_templates() {
    cat << 'EOF_TEMPLATES'
╔════════════════════════════════════════════════════════════════════════════╗
║                    TEMPLATES .GITIGNORE DISPONIBLES                        ║
╚════════════════════════════════════════════════════════════════════════════╝

LANGAGES DE PROGRAMMATION
  python, web/node/javascript, java, cpp/c++, rust, go, ruby, php, dotnet/csharp,
  swift/ios

PLATEFORMES & ENVIRONNEMENTS
  android, unity, latex, jekyll, hugo

SYSTÈMES D'EXPLOITATION
  macos, linux, windows

IDE & ÉDITEURS
  vscode, jetbrains/idea, vim, sublime

AUTRES
  docker, terraform, laravel, django, rails

USAGE:
  ./create_repo.sh --gitignore <type>
  ./create_repo.sh --gitignore python vscode macos

EOF_TEMPLATES
    exit 0
}

create_gitignore() {
    local type="$1"
    local gitignore_path=".gitignore"

    if [ -z "$type" ]; then
        log "✗ ERREUR : Type de .gitignore manquant"
        exit 1
    fi

    log "╔════════════════════════════════════════════════════════════════════════════╗"
    log "║                    CRÉATION DU FICHIER .GITIGNORE                         ║"
    log "╚════════════════════════════════════════════════════════════════════════════╝"
    log ""
    log "Type demandé : $type"
    log "Répertoire   : $(pwd)"
    log ""

    if [ -f "$gitignore_path" ]; then
        log "⚠ Un fichier .gitignore existe déjà dans ce répertoire"

        if [ "$DRY_RUN" = false ]; then
            read -p "Voulez-vous [a]jouter au fichier existant ou [r]emplacer ? (a/r) : " choice
            case "$choice" in
                a|A)
                    log "→ Mode : Ajout au fichier existant"
                    gitignore_path=".gitignore.new"
                    ;;
                r|R)
                    log "→ Mode : Remplacement du fichier"
                    mv ".gitignore" ".gitignore.backup.$(date +%Y%m%d_%H%M%S)"
                    log "✓ Backup créé : .gitignore.backup.$(date +%Y%m%d_%H%M%S)"
                    ;;
                *)
                    log "✗ Choix invalide. Opération annulée."
                    exit 1
                    ;;
            esac
        else
            log "[DRY-RUN] La question [a]jouter ou [r]emplacer serait posée"
        fi
    fi

    log "→ Génération du contenu .gitignore pour : $type"

    if [ "$DRY_RUN" = false ]; then
        case "$type" in
            "python")
                cat > "$gitignore_path" << 'GITIGNORE'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.venv
.env
pip-log.txt
pip-delete-this-directory.txt
.coverage
.pytest_cache/
dist/
build/
*.egg-info/
GITIGNORE
                log "✓ .gitignore Python créé"
                ;;
            "web"|"node"|"javascript")
                cat > "$gitignore_path" << 'GITIGNORE'
# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnpm-debug.log*
.npm
.eslintcache

# Build outputs
dist/
build/
*.tgz
*.tar.gz

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
GITIGNORE
                log "✓ .gitignore Web/Node.js créé"
                ;;
            "java")
                cat > "$gitignore_path" << 'GITIGNORE'
# Java
*.class
*.jar
*.war
*.ear
*.iml
*.log

# Maven
target/

# Gradle
.gradle/
build/

# Eclipse
.project
.classpath
.settings/

# IntelliJ
.idea/
GITIGNORE
                log "✓ .gitignore Java créé"
                ;;
            "cpp"|"c++")
                cat > "$gitignore_path" << 'GITIGNORE'
# C/C++
*.o
*.obj
*.exe
*.dll
*.so
*.dylib
*.a
*.lib
*.out

# CMake
CMakeFiles/
CMakeCache.txt
cmake_install.cmake
Makefile

# Visual Studio
*.sln
*.vcxproj
*.vcxproj.user
*.vcxproj.filters
*.vcxproj.local
GITIGNORE
                log "✓ .gitignore C++ créé"
                ;;
            "rust")
                cat > "$gitignore_path" << 'GITIGNORE'
# Rust
/target/
**/*.rs.bk
Cargo.lock

# Rustfmt
rustfmt.toml
GITIGNORE
                log "✓ .gitignore Rust créé"
                ;;
            "go")
                cat > "$gitignore_path" << 'GITIGNORE'
# Go
/bin/
/pkg/
*.exe
*.test
*.prof

# IDE
.idea/
.vscode/
GITIGNORE
                log "✓ .gitignore Go créé"
                ;;
            "ruby")
                cat > "$gitignore_path" << 'GITIGNORE'
# Ruby
*.gem
*.rbc
/.bundle
/vendor/bundle
/.ruby-version
/.ruby-gemset
/.bundle/
/log/
/tmp/
GITIGNORE
                log "✓ .gitignore Ruby créé"
                ;;
            "php")
                cat > "$gitignore_path" << 'GITIGNORE'
# PHP
/vendor/
composer.lock
*.log
.env

# PHPUnit
.phpunit.result.cache
GITIGNORE
                log "✓ .gitignore PHP créé"
                ;;
            "dotnet"|"csharp")
                cat > "$gitignore_path" << 'GITIGNORE'
# .NET / C#
/bin/
/obj/
*.user
*.suo
*.userosscache
*.sln.docstates

# Visual Studio
.vs/
GITIGNORE
                log "✓ .gitignore .NET/C# créé"
                ;;
            "swift"|"ios")
                cat > "$gitignore_path" << 'GITIGNORE'
# Swift / iOS
*.xcworkspace
*.xcodeproj
*.xcuserdata
DerivedData/
*.ipa
*.dSYM.zip
*.dSYM
GITIGNORE
                log "✓ .gitignore Swift/iOS créé"
                ;;
            "android")
                cat > "$gitignore_path" << 'GITIGNORE'
# Android
*.iml
.gradle/
/local.properties
/.idea/
/build/
/captures/
.externalNativeBuild/
GITIGNORE
                log "✓ .gitignore Android créé"
                ;;
            "unity")
                cat > "$gitignore_path" << 'GITIGNORE'
# Unity
[Ll]ibrary/
[Tt]emp/
[Oo]bj/
[Bb]uild/
[Bb]uilds/
[Ll]ogs/
UserSettings/
MemoryCaptures/
GITIGNORE
                log "✓ .gitignore Unity créé"
                ;;
            "latex")
                cat > "$gitignore_path" << 'GITIGNORE'
# LaTeX
*.aux
*.log
*.out
*.toc
*.synctex.gz
*.fdb_latexmk
*.fls
*.bbl
*.blg
GITIGNORE
                log "✓ .gitignore LaTeX créé"
                ;;
            "jekyll")
                cat > "$gitignore_path" << 'GITIGNORE'
# Jekyll
_site/
.jekyll-cache/
.jekyll-metadata
.bundle/
GITIGNORE
                log "✓ .gitignore Jekyll créé"
                ;;
            "hugo")
                cat > "$gitignore_path" << 'GITIGNORE'
# Hugo
/public/
/resources/_gen/
.hugo_build.lock
GITIGNORE
                log "✓ .gitignore Hugo créé"
                ;;
            "macos")
                cat > "$gitignore_path" << 'GITIGNORE'
# macOS
.DS_Store
.AppleDouble
.LSOverride
Icon
._*
.Spotlight-V100
.Trashes
GITIGNORE
                log "✓ .gitignore macOS créé"
                ;;
            "linux")
                cat > "$gitignore_path" << 'GITIGNORE'
# Linux
*~
.fuse_hidden*
.directory
.Trash-*
.nfs*
GITIGNORE
                log "✓ .gitignore Linux créé"
                ;;
            "windows")
                cat > "$gitignore_path" << 'GITIGNORE'
# Windows
Thumbs.db
Thumbs.db:encryptable
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/
*.lnk
GITIGNORE
                log "✓ .gitignore Windows créé"
                ;;
            "vscode")
                cat > "$gitignore_path" << 'GITIGNORE'
# VSCode
.vscode/
*.code-workspace
GITIGNORE
                log "✓ .gitignore VSCode créé"
                ;;
            "jetbrains"|"idea")
                cat > "$gitignore_path" << 'GITIGNORE'
# JetBrains IDEs
.idea/
*.iml
*.ipr
*.iws
GITIGNORE
                log "✓ .gitignore JetBrains créé"
                ;;
            "vim")
                cat > "$gitignore_path" << 'GITIGNORE'
# Vim
*.swp
*.swo
*.swn
*~

# Session
Session.vim
GITIGNORE
                log "✓ .gitignore Vim créé"
                ;;
            "sublime")
                cat > "$gitignore_path" << 'GITIGNORE'
# Sublime Text
*.sublime-workspace
*.sublime-project
GITIGNORE
                log "✓ .gitignore Sublime Text créé"
                ;;
            "docker")
                cat > "$gitignore_path" << 'GITIGNORE'
# Docker
*.env

# Docker build cache
.docker/
GITIGNORE
                log "✓ .gitignore Docker créé"
                ;;
            "terraform")
                cat > "$gitignore_path" << 'GITIGNORE'
# Terraform
.terraform/
*.tfstate
*.tfstate.*
crash.log
crash.*.log
.terraform.lock.hcl
GITIGNORE
                log "✓ .gitignore Terraform créé"
                ;;
            "laravel")
                cat > "$gitignore_path" << 'GITIGNORE'
# Laravel
/vendor/
/node_modules/
/public/storage
/storage/*.key
.env
GITIGNORE
                log "✓ .gitignore Laravel créé"
                ;;
            "django")
                cat > "$gitignore_path" << 'GITIGNORE'
# Django
*.log
*.pot
*.pyc
__pycache__/
local_settings.py
db.sqlite3
media/
staticfiles/
GITIGNORE
                log "✓ .gitignore Django créé"
                ;;
            "rails")
                cat > "$gitignore_path" << 'GITIGNORE'
# Rails
/.bundle
/log/
/tmp/
/db/*.sqlite3
/node_modules/
/public/assets
/public/packs
GITIGNORE
                log "✓ .gitignore Rails créé"
                ;;
            *)
                log "✗ ERREUR : Type de .gitignore inconnu : '$type'"
                log "  → Utilise --list-gitignore pour afficher les templates disponibles"
                exit 1
                ;;
        esac

        if [ "$gitignore_path" = ".gitignore.new" ]; then
            cat .gitignore.new >> .gitignore
            rm .gitignore.new
            log "✓ Contenu ajouté au .gitignore existant"
        fi
    else
        log "[DRY-RUN] Simulation : Création du fichier $gitignore_path de type $type"
    fi

    log ""
    log "RÉCAPITULATIF"
    log "  • Fichier    : $(pwd)/.gitignore"
    if [ -f .gitignore ]; then
        log "  • Taille     : $(wc -l < .gitignore) lignes"
    fi
    log ""
    log "PROCHAINES ÉTAPES :"
    log "  1. Vérifie le contenu : cat .gitignore"
    log "  2. Ajoute-le à Git : git add .gitignore"
    log "  3. Commit le fichier : git add .gitignore && git commit -m 'Add .gitignore'"
    log ""
}

create_from_template() {
    local template="$1"
    log "Application du template : '$template'"

    case "$template" in
        "python")
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

            log "→ Création du .gitignore Python via create_gitignore"
            create_gitignore "python"
            log "✓ Template Python appliqué"
            ;;

        "web")
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

            log "→ Création du .gitignore Web via create_gitignore"
            create_gitignore "web"
            log "✓ Template Web appliqué"
            ;;

        "basic"|*)
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

check_existing_git() {
    if [ -d ".git" ]; then
        log "→ Dépôt Git existant détecté, conservation historique"
        if git remote get-url origin &>/dev/null; then
            local existing
            existing=$(git remote get-url origin)
            log "⚠ Remote origin existe: $existing"
            log "→ Suppression ancienne remote"
            if [ "$DRY_RUN" = false ]; then
                git remote remove origin
            else
                log "[DRY-RUN] Simulation : git remote remove origin"
            fi
        fi
    else
        log "→ Initialisation nouveau dépôt Git (branche $DEFAULT_BRANCH)"
        if [ "$DRY_RUN" = false ]; then
            git init -b "$DEFAULT_BRANCH" || { log "✗ ERREUR git init"; exit 1; }
        else
            log "[DRY-RUN] Simulation : git init -b $DEFAULT_BRANCH"
        fi
    fi
}

create_repo() {
    log "╔════════════════════════════════════════════════════════════════════════════╗"
    log "║                    CRÉATION DU DÉPÔT GIT COMPLET                          ║"
    log "╚════════════════════════════════════════════════════════════════════════════╝"

    validate_repo_name

    log "[1/6] Répertoire local : $LOCAL_PATH"
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

    log "[2/6] Vérification Git..."
    if [ "$DRY_RUN" = false ]; then
        check_existing_git
    else
        log "[DRY-RUN] Simulation : check_existing_git"
    fi

    log "[3/6] Fichiers de base..."
    if [ -f "README.md" ]; then
        log "→ README.md existe, SKIP"
    else
        if [ "$DRY_RUN" = false ]; then
            if [ -n "$TEMPLATE" ]; then
                create_from_template "$TEMPLATE"
            else
                echo "# $REPO_NAME" > README.md
            fi
        else
            log "[DRY-RUN] Simulation : création README.md"
        fi
        log "✓ README.md prêt"
    fi

    if [ ${#GITIGNORE_TEMPLATES[@]} -gt 0 ]; then
        for tpl in "${GITIGNORE_TEMPLATES[@]}"; do
            create_gitignore "$tpl"
        done
    elif [ -n "$TEMPLATE" ]; then
        log "→ .gitignore via template: $TEMPLATE"
    else
        log "→ Pas de .gitignore demandé"
    fi

    log "[4/6] Dépôt distant GitHub..."
    if [ "$DRY_RUN" = false ]; then
        if ! gh repo view "$OWNER/$REPO_NAME" &>/dev/null; then
            gh repo create "$OWNER/$REPO_NAME" --"$VISIBILITY" --confirm || {
                log "✗ ERREUR création dépôt distant"
                exit 1
            }
        fi
    else
        log "[DRY-RUN] Simulation : création dépôt distant"
    fi
    log "✓ Dépôt distant OK (VIDE)"

    log "[5/6] Remote origin..."
    if [ "$DRY_RUN" = false ]; then
        git remote add origin "https://github.com/$OWNER/$REPO_NAME.git" || {
            log "✗ ERREUR remote"
            exit 1
        }
    else
        log "[DRY-RUN] Simulation : git remote add origin"
    fi
    log "✓ Remote configurée"

    log "[6/6] Récapitulatif..."
    log "════════════════════════════════════════════════════════════════════════════"
    log "✓ DÉPÔT CRÉÉ AVEC SUCCÈS"
    log "════════════════════════════════════════════════════════════════════════════"
    log ""
    log "INFOS :"
    log "  • Nom       : $REPO_NAME"
    log "  • Owner     : $OWNER"
    log "  • Visibilité: $VISIBILITY"
    log "  • Local     : $LOCAL_PATH"
    log "  • Distant   : https://github.com/$OWNER/$REPO_NAME (VIDE)"
    log "  • Branche   : $DEFAULT_BRANCH"
    if [ -n "$TEMPLATE" ]; then
        log "  • Template  : $TEMPLATE"
    fi
    log ""
    log "⚠ IMPORTANT: Dépôt distant VIDE, aucun commit auto"
    log ""
    log "PROCHAINES ÉTAPES (MANUEL):"
    log "  cd $LOCAL_PATH"
    log "  git status"
    log "  git add ."
    log "  git commit -m 'Initial commit'"
    log "  git push -u origin $DEFAULT_BRANCH"
    log ""
    log "════════════════════════════════════════════════════════════════════════════"

    REPO_CREATED=true
}

delete_local() {
    log "╔════════════════════════════════════════════════════════════════════════════╗"
    log "║                    SUPPRESSION DU DÉPÔT LOCAL                             ║"
    log "╚════════════════════════════════════════════════════════════════════════════╝"

    validate_repo_name

    log "ATTENTION : Suppression du dépôt LOCAL uniquement"
    log "  • Chemin : $LOCAL_PATH"
    log ""

    if [ "$DRY_RUN" = false ]; then
        read -p "Confirmer la suppression ? (taper 'oui') : " confirm
        if [ "$confirm" != "oui" ]; then
            log "✗ Suppression annulée."
            exit 0
        fi
    fi

    if [ ! -d "$LOCAL_PATH" ]; then
        log "✗ ERREUR : Le répertoire n'existe pas."
        exit 1
    fi

    log "[1/2] Création de la sauvegarde..."
    local backup_name="${REPO_NAME}_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    local backup_path="$(dirname "$LOCAL_PATH")/$backup_name"

    if [ "$DRY_RUN" = false ]; then
        tar -czf "$backup_path" -C "$(dirname "$LOCAL_PATH")" "$(basename "$LOCAL_PATH")" || { log "✗ ERREUR : Impossible de créer la sauvegarde."; exit 1; }
        log "✓ Sauvegarde créée : $backup_path"
    fi

    log "[2/2] Suppression du répertoire local..."
    if [ "$DRY_RUN" = false ]; then
        rm -rf "$LOCAL_PATH" || { log "✗ ERREUR : Impossible de supprimer le répertoire."; exit 1; }
        log "✓ Répertoire local supprimé"
    fi

    log "════════════════════════════════════════════════════════════════════════════"
    log "✓ SUPPRESSION LOCALE TERMINÉE"
    log "════════════════════════════════════════════════════════════════════════════"
}

delete_remote() {
    log "╔════════════════════════════════════════════════════════════════════════════╗"
    log "║                    SUPPRESSION DU DÉPÔT DISTANT                           ║"
    log "╚════════════════════════════════════════════════════════════════════════════╝"

    if [ "$DRY_RUN" = false ]; then
        read -p "Confirmer suppression DISTANTE? (taper 'oui'): " confirm
        [ "$confirm" != "oui" ] && exit 0

        gh repo view "$OWNER/$REPO_NAME" &>/dev/null || { log "✗ Dépôt inexistant"; exit 1; }
        gh repo delete "$OWNER/$REPO_NAME" --yes || { log "✗ ERREUR suppression"; exit 1; }
    fi

    log "✓ Suppression distante terminée"
}

if [ $# -eq 0 ]; then
    print_help
fi

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
        --gitignore)
            shift
            while [[ $# -gt 0 && ! "$1" =~ ^-- ]]; do
                GITIGNORE_TEMPLATES+=("$1")
                shift
            done
            if [ ${#GITIGNORE_TEMPLATES[@]} -eq 0 ]; then
                log "✗ ERREUR : --gitignore nécessite au moins un type"
                exit 1
            fi
            if [ -z "$ACTION" ]; then
                ACTION="gitignore"
            fi
            ;;
        --list-gitignore)
            list_gitignore_templates
            ;;
        --public)
            VISIBILITY="public"
            shift
            ;;
        --private)
            VISIBILITY="private"
            shift
            ;;
        --template)
            TEMPLATE="$2"
            shift 2
            ;;
        --simulate|-s)
            DRY_RUN=true
            log "⚠ MODE SIMULATION ACTIVÉ - Aucune action réelle ne sera effectuée"
            shift
            ;;
        --prerequis|-pr)
            check_prerequisites
            log ""
            log "✓ Tous les prérequis sont satisfaits. Tu peux utiliser le script."
            exit 0
            ;;
        --install|-i)
            install_prerequisites
            ;;
        --changelog|-ch)
            show_changelog
            ;;
        --adv-help|--advanced-help)
            print_advanced_help
            ;;
        --help|-h)
            print_help
            ;;
        *)
            log "✗ ERREUR : Argument inconnu '$1'."
            log "  → Utilise --help pour l'aide de base"
            log "  → Utilise --adv-help pour l'aide avancée détaillée"
            exit 1
            ;;
    esac
done

load_config

if [ "$ACTION" != "gitignore" ] && [ "$ACTION" != "delete_local" ]; then
    check_prerequisites
fi

case "$ACTION" in
    "exec")
        create_repo
        ;;
    "delete_local")
        delete_local
        ;;
    "delete_remote")
        delete_remote
        ;;
    "gitignore")
        for tpl in "${GITIGNORE_TEMPLATES[@]}"; do
            create_gitignore "$tpl"
        done
        ;;
    *)
        log "✗ ERREUR : Aucune action spécifiée."
        log "  → Utilise --exec, --delete-local, --delete-remote, ou --gitignore"
        log "  → Utilise --help pour l'aide de base"
        log "  → Utilise --adv-help pour l'aide avancée détaillée"
        exit 1
        ;;
 esac

log ""
log "════════════════════════════════════════════════════════════════════════════"
log "Script terminé à $(date '+%Y-%m-%d %H:%M:%S')"
log "════════════════════════════════════════════════════════════════════════════"

exit 0
