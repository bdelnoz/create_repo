#!/bin/bash
################################################################################
# Auteur : Bruno DELNOZ
# Email : bruno.delnoz@protonmail.com
# Nom du script avec path complet : ~/Security/scripts/divers/utility_tools/create_repo.sh
# Target usage : Gestion complète des dépôts Git (création locale/distante, suppression, templates, logs)
# Version : v4.1 - Date : 2025-10-25
# Changelog :
#   v4.1 - 2025-10-25 : Ajout fonction create_gitignore et option --gitignore
#   v4.0 - 2025-10-21 : Correction gestion remote origin existante + nettoyage Git avant réinit
################################################################################

################################################################################
# VARIABLES GLOBALES
################################################################################
LOG_FILE="log.create_repo.v4.1.log"
CONFIG_FILE="$HOME/.create_repo_config"
DRY_RUN=false
REPO_CREATED=false
TEMPLATE=""
VISIBILITY="private"
OWNER=""
DEFAULT_BRANCH="main"
LOCAL_PATH=""
REPO_NAME=""
GITIGNORE_TYPE=""

################################################################################
# FONCTION : log
# Description : Enregistre un message dans le fichier log avec timestamp
# Paramètres :
#   $1 : Message à logger
# Retour : Aucun
################################################################################
log() {
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

  --gitignore <type>             Crée un fichier .gitignore dans le répertoire courant
                                 Types disponibles:
                                   - python
                                   - web / node / javascript
                                   - java
                                   - cpp / c++
                                   - rust
                                   - go
                                   - ruby
                                   - php
                                   - dotnet / csharp
                                   - swift / ios
                                   - android
                                   - unity
                                   - latex
                                   - jekyll
                                   - hugo
                                   - macos
                                   - linux
                                   - windows
                                   - vscode
                                   - jetbrains / idea
                                   - vim
                                 Exemple: --gitignore python

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

3. Créer seulement un .gitignore Python dans le répertoire courant:
   ./create_repo.sh --gitignore python

4. Créer un .gitignore Node.js:
   ./create_repo.sh --gitignore web

5. Créer un .gitignore multi-environnement (Python + VSCode + macOS):
   ./create_repo.sh --gitignore python
   ./create_repo.sh --gitignore vscode
   ./create_repo.sh --gitignore macos

6. Vérifier les prérequis avant utilisation:
   ./create_repo.sh --prerequis

7. Supprimer uniquement le dépôt local (avec backup):
   ./create_repo.sh --delete-local ~/projets/ancien-projet

VALEURS PAR DÉFAUT:
  - Visibilité : private
  - Template : aucun (README.md uniquement)
  - Branche principale : main
  - Branche de travail : Working
  - Owner : Détecté automatiquement via 'gh api user'

AUTEUR:
  Bruno DELNOZ - bruno.delnoz@protonmail.com

VERSION: v4.1 - 2025-10-25
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

VERSION v4.1 - 2025-10-25
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[NOUVELLE FONCTIONNALITÉ] Création de fichiers .gitignore standalone
  • Ajout de la fonction create_gitignore() avec 25+ templates prédéfinis
  • Nouvelle option --gitignore <type> pour créer un .gitignore sans créer de dépôt
  • Support de multiples langages et environnements
  • Détection intelligente des .gitignore existants avec fusion optionnelle
  • Templates disponibles :
    - Langages : Python, Node/Web, Java, C++, Rust, Go, Ruby, PHP, .NET, Swift
    - Plateformes : Android, Unity, iOS
    - CMS/Frameworks : Jekyll, Hugo, Laravel, Django, Rails
    - OS : macOS, Linux, Windows
    - IDE : VSCode, JetBrains, Vim, Sublime
    - Autres : LaTeX, Docker, Terraform

[AMÉLIORATION] Fonction list_gitignore_templates()
  • Affichage catégorisé de tous les templates disponibles
  • Descriptions détaillées pour chaque type

[AMÉLIORATION] Intégration dans le workflow existant
  • Les templates python/web créent maintenant automatiquement un .gitignore via create_gitignore()
  • Réduction de la duplication de code

VERSION v4.0 - 2025-10-21
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[CORRECTIF MAJEUR] Correction de la gestion des remotes Git existantes
  • Ajout de la suppression automatique de la remote 'origin' si elle existe
  • Nettoyage complet du dépôt Git avant réinitialisation
  • Gestion robuste des erreurs lors de l'ajout de remote

AUTEUR: Bruno DELNOZ - bruno.delnoz@protonmail.com
EOF
    exit 0
}

################################################################################
# FONCTION : list_gitignore_templates
# Description : Affiche la liste complète des templates .gitignore disponibles
#               avec descriptions et catégories
# Paramètres : Aucun
# Retour : Sort du script avec code 0
################################################################################
list_gitignore_templates() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                    TEMPLATES .GITIGNORE DISPONIBLES                        ║
╚════════════════════════════════════════════════════════════════════════════╝

LANGAGES DE PROGRAMMATION
━━━━━━━━━━━━━━━━━━━━━━━━━
  python              Python (__pycache__, venv, .pyc)
  web, node, js       JavaScript/Node.js (node_modules, dist)
  java                Java (.class, target/, .jar)
  cpp, c++            C++ (*.o, *.exe, build/)
  rust                Rust (target/, Cargo.lock)
  go                  Go (*.exe, vendor/)
  ruby                Ruby (*.gem, .bundle/)
  php                 PHP (vendor/, composer.lock)
  dotnet, csharp      .NET/C# (bin/, obj/, *.dll)
  swift, ios          Swift/iOS (*.xcworkspace, Pods/)

PLATEFORMES MOBILES & GAMING
━━━━━━━━━━━━━━━━━━━━━━━━━━━
  android             Android Studio (*.apk, build/)
  unity               Unity 3D (Library/, Temp/)

CMS & FRAMEWORKS WEB
━━━━━━━━━━━━━━━━━━━━━━━━━
  jekyll              Jekyll (_site/, .jekyll-cache/)
  hugo                Hugo (public/, resources/)
  laravel             Laravel (vendor/, storage/)
  django              Django (*.pyc, db.sqlite3)
  rails               Ruby on Rails (log/, tmp/)

SYSTÈMES D'EXPLOITATION
━━━━━━━━━━━━━━━━━━━━━━━━━
  macos               macOS (.DS_Store, ._*)
  linux               Linux (*~, .directory)
  windows             Windows (Thumbs.db, Desktop.ini)

ENVIRONNEMENTS DE DÉVELOPPEMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  vscode              Visual Studio Code (.vscode/)
  jetbrains, idea     JetBrains IDEs (.idea/, *.iml)
  vim                 Vim (*.swp, *.swo)
  sublime             Sublime Text (*.sublime-*)

OUTILS & AUTRES
━━━━━━━━━━━━━━━━━━━
  latex               LaTeX (*.aux, *.log, *.pdf)
  docker              Docker (.dockerignore patterns)
  terraform           Terraform (*.tfstate, .terraform/)

USAGE:
  ./create_repo.sh --gitignore <type>

EXEMPLES:
  ./create_repo.sh --gitignore python
  ./create_repo.sh --gitignore web
  ./create_repo.sh --gitignore macos

NOTE:
  Tu peux créer plusieurs .gitignore successivement pour combiner les patterns.
  Le script détectera les fichiers existants et proposera de fusionner.

EOF
    exit 0
}

################################################################################
# FONCTION : create_gitignore
# Description : Crée un fichier .gitignore selon le type spécifié
#               Gère la fusion avec un .gitignore existant
# Paramètres :
#   $1 : Type de .gitignore à créer
# Retour : Aucun
################################################################################
create_gitignore() {
    local type="$1"
    local gitignore_path=".gitignore"
    
    log "╔════════════════════════════════════════════════════════════════════════════╗"
    log "║                   SUPPRESSION DU DÉPÔT DISTANT                            ║"
    log "╚════════════════════════════════════════════════════════════════════════════╝"

    log "ATTENTION : Suppression du dépôt DISTANT uniquement (GitHub)"
    log "  • Owner : $OWNER"
    log "  • Nom   : $REPO_NAME"
    log ""

    if [ "$DRY_RUN" = false ]; then
        read -p "Confirmer la suppression DISTANTE ? (taper 'oui') : " confirm
        if [ "$confirm" != "oui" ]; then
            log "✗ Suppression annulée."
            exit 0
        fi
    fi

    log "[1/2] Vérification de l'existence du dépôt distant..."
    if [ "$DRY_RUN" = false ]; then
        if ! gh repo view "$OWNER/$REPO_NAME" &>/dev/null; then
            log "✗ ERREUR : Le dépôt n'existe pas sur GitHub."
            exit 1
        fi
        log "✓ Dépôt distant trouvé"
    fi

    log "[2/2] Suppression du dépôt distant..."
    if [ "$DRY_RUN" = false ]; then
        if ! gh repo delete "$OWNER/$REPO_NAME" --yes; then
            log "✗ ERREUR : Impossible de supprimer le dépôt distant."
            exit 1
        fi
        log "✓ Dépôt distant supprimé"
    fi

    log "════════════════════════════════════════════════════════════════════════════"
    log "✓ SUPPRESSION DISTANTE TERMINÉE"
    log "════════════════════════════════════════════════════════════════════════════"
}

################################################################################
# FONCTION : load_config
# Description : Charge la configuration utilisateur
# Paramètres : Aucun
# Retour : Aucun
################################################################################
load_config() {
    log "Chargement de la configuration utilisateur..."

    OWNER=$(gh api user --jq .login 2>/dev/null)

    if [ -z "$OWNER" ]; then
        log "⚠ Impossible de récupérer le username GitHub"
        log "  → Utilisation du fallback : bdelnoz"
        OWNER="bdelnoz"
    else
        log "✓ Owner GitHub détecté : $OWNER"
    fi
}

################################################################################
# FONCTION : print_actions_summary
# Description : Affiche un récapitulatif des actions effectuées
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
        log "  2. Validation du nom du dépôt"
        log "  3. Création du répertoire local"
        log "  4. Nettoyage du dépôt Git existant"
        log "  5. Initialisation du nouveau dépôt Git"
        log "  6. Création des fichiers de base"
        log "  7. Commit initial"
        log "  8. Création/connexion au dépôt distant"
        log "  9. Vérification du dépôt distant"
        log "  10. Création de la branche 'Working'"
        log "  11. Retour sur la branche principale"
    fi

    log ""
    log "════════════════════════════════════════════════════════════════════════════"
}

################################################################################
# FONCTION : print_advanced_help
# Description : Affiche l'aide avancée avec explications détaillées
#               et cas d'usage complexes
# Paramètres : Aucun
# Retour : Sort du script avec code 0
################################################################################
print_advanced_help() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                  CREATE_REPO.SH - AIDE AVANCÉE DÉTAILLÉE                   ║
╚════════════════════════════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════════════════════════
 1. COMPRENDRE L'OPTION --gitignore
═══════════════════════════════════════════════════════════════════════════

CONCEPT :
  L'option --gitignore permet de créer un fichier .gitignore SANS créer de
  dépôt Git complet. C'est utile pour ajouter un .gitignore à un projet
  existant ou pour créer un .gitignore personnalisé.

UTILISATION SIMPLE :
  ./create_repo.sh --gitignore python
  
  → Crée un .gitignore dans le répertoire courant (pwd)
  → Contient les patterns Python standards (__pycache__, *.pyc, venv/, etc.)
  → AUCUN dépôt Git n'est créé, juste le fichier .gitignore

MULTI-ENVIRONNEMENT (Fusion de plusieurs .gitignore) :
  Tu peux COMBINER plusieurs types de .gitignore en les exécutant successivement :
  
  ./create_repo.sh --gitignore python    # Crée le .gitignore Python
  ./create_repo.sh --gitignore vscode    # AJOUTE les patterns VSCode
  ./create_repo.sh --gitignore macos     # AJOUTE les patterns macOS
  
  RÉSULTAT FINAL : Un seul fichier .gitignore contenant :
    - Patterns Python (__pycache__, venv/, *.pyc)
    - Patterns VSCode (.vscode/, *.code-workspace)
    - Patterns macOS (.DS_Store, ._*, .AppleDouble)

POURQUOI FAIRE ÇA ?
  Parce qu'un projet réel a souvent besoin de plusieurs types de .gitignore :
  
  EXEMPLE 1 : Projet Python développé sur macOS avec VSCode
    → Patterns Python (pour le langage)
    → Patterns macOS (pour le système d'exploitation)
    → Patterns VSCode (pour l'éditeur de code)
  
  EXEMPLE 2 : Application web Node.js avec Docker
    ./create_repo.sh --gitignore web
    ./create_repo.sh --gitignore docker
    ./create_repo.sh --gitignore linux
  
  EXEMPLE 3 : Projet Java avec IntelliJ IDEA sur Windows
    ./create_repo.sh --gitignore java
    ./create_repo.sh --gitignore jetbrains
    ./create_repo.sh --gitignore windows

GESTION DES CONFLITS :
  Si un .gitignore existe DÉJÀ, le script te demande :
    [a] Ajouter au fichier existant (fusion intelligente)
    [r] Remplacer le fichier (backup automatique créé)

═══════════════════════════════════════════════════════════════════════════
 2. DIFFÉRENCE ENTRE --exec --template ET --gitignore
═══════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────────┐
│ OPTION : --exec --template python                                       │
└─────────────────────────────────────────────────────────────────────────┘
  ACTION COMPLÈTE :
    ✓ Crée le répertoire local
    ✓ Initialise le dépôt Git
    ✓ Crée un README.md Python
    ✓ Crée un .gitignore Python (via create_gitignore)
    ✓ Commit initial
    ✓ Crée le dépôt distant GitHub
    ✓ Crée la branche 'Working'
  
  USAGE : Créer un NOUVEAU projet Python complet

┌─────────────────────────────────────────────────────────────────────────┐
│ OPTION : --gitignore python                                             │
└─────────────────────────────────────────────────────────────────────────┘
  ACTION LIMITÉE :
    ✓ Crée UNIQUEMENT un fichier .gitignore
    ✗ AUCUN dépôt Git créé
    ✗ AUCUN fichier README
    ✗ AUCUNE action GitHub
  
  USAGE : Ajouter un .gitignore à un projet EXISTANT

═══════════════════════════════════════════════════════════════════════════
 3. TEMPLATES .GITIGNORE DISPONIBLES - GUIDE DÉTAILLÉ
═══════════════════════════════════════════════════════════════════════════

╔═══════════════════════════════════════════════════════════════════════╗
║ LANGAGES DE PROGRAMMATION                                             ║
╚═══════════════════════════════════════════════════════════════════════╝

python
  ├─ __pycache__/, *.pyc, *.pyo          # Bytecode Python
  ├─ venv/, env/, ENV/                   # Environnements virtuels
  ├─ dist/, build/, *.egg-info/          # Distribution/packaging
  ├─ .pytest_cache/, .coverage           # Tests et coverage
  └─ .env, .venv                         # Variables d'environnement

web / node / javascript / js
  ├─ node_modules/                       # Dépendances npm/yarn
  ├─ dist/, build/, .next/, .nuxt/       # Builds des frameworks
  ├─ *.log                               # Logs npm/yarn
  ├─ .env, .env.local                    # Variables d'environnement
  └─ package-lock.json (optionnel)       # Lock files

java
  ├─ *.class                             # Bytecode compilé
  ├─ target/ (Maven), build/ (Gradle)    # Répertoires de build
  ├─ *.jar, *.war                        # Archives Java
  └─ .idea/, *.iml (IntelliJ)           # IDE

cpp / c++
  ├─ *.o, *.obj                          # Fichiers objets
  ├─ *.exe, *.out, *.app                 # Exécutables
  ├─ build/, cmake-build-*/              # Répertoires de build
  └─ CMakeCache.txt, CMakeFiles/         # CMake

rust
  ├─ target/                             # Répertoire de build Cargo
  ├─ Cargo.lock                          # Lock file (projets bin)
  └─ **/*.rs.bk                          # Backups rustfmt

go
  ├─ *.exe, *.dll, *.so, *.dylib         # Binaires compilés
  ├─ vendor/                             # Dépendances vendorées
  └─ go.work                             # Workspace Go

ruby
  ├─ *.gem                               # Gems packagés
  ├─ .bundle/, vendor/bundle/            # Bundler
  └─ Gemfile.lock                        # Lock file

php
  ├─ vendor/                             # Dépendances Composer
  ├─ composer.lock                       # Lock file Composer
  └─ .env (Laravel, Symfony)             # Configuration

dotnet / csharp
  ├─ bin/, obj/                          # Répertoires de build
  ├─ *.dll, *.exe                        # Assemblies .NET
  └─ .vs/, *.user                        # Visual Studio

swift / ios
  ├─ *.xcworkspace, *.xcuserstate        # Xcode
  ├─ Pods/                               # CocoaPods
  └─ .build/, .swiftpm/                  # Swift Package Manager

╔═══════════════════════════════════════════════════════════════════════╗
║ PLATEFORMES & GAMING                                                  ║
╚═══════════════════════════════════════════════════════════════════════╝

android
  ├─ *.apk, *.aab                        # Applications compilées
  ├─ build/, .gradle/                    # Build Android/Gradle
  ├─ local.properties                    # Config locale
  └─ *.keystore, *.jks                   # Keystores de signature

unity
  ├─ Library/, Temp/                     # Cache Unity
  ├─ *.unitypackage                      # Packages Unity
  └─ UserSettings/                       # Paramètres utilisateur

╔═══════════════════════════════════════════════════════════════════════╗
║ CMS & FRAMEWORKS WEB                                                  ║
╚═══════════════════════════════════════════════════════════════════════╝

jekyll
  ├─ _site/                              # Site généré
  ├─ .jekyll-cache/                      # Cache Jekyll
  └─ Gemfile.lock                        # Lock file Ruby

hugo
  ├─ public/                             # Site généré
  ├─ resources/_gen/                     # Ressources générées
  └─ .hugo_build.lock                    # Lock file build

laravel
  ├─ vendor/                             # Dépendances PHP
  ├─ node_modules/                       # Dépendances Node
  ├─ storage/*.key                       # Clés de chiffrement
  └─ .env                                # Configuration

django
  ├─ __pycache__/, *.pyc                 # Bytecode Python
  ├─ db.sqlite3                          # Base de données locale
  ├─ media/, staticfiles/                # Fichiers statiques
  └─ .env                                # Configuration

rails
  ├─ log/, tmp/                          # Logs et fichiers temp
  ├─ storage/                            # Uploads Active Storage
  ├─ config/master.key                   # Clé de chiffrement
  └─ node_modules/                       # Webpacker

╔═══════════════════════════════════════════════════════════════════════╗
║ SYSTÈMES D'EXPLOITATION                                               ║
╚═══════════════════════════════════════════════════════════════════════╝

macos
  ├─ .DS_Store                           # Métadonnées Finder
  ├─ ._*                                 # Resource forks
  ├─ .AppleDouble, .LSOverride           # Métadonnées Apple
  └─ .Spotlight-V100, .fseventsd         # Indexation système

linux
  ├─ *~                                  # Fichiers de backup
  ├─ .directory                          # Dolphin (KDE)
  └─ .nfs*                               # NFS temporaires

windows
  ├─ Thumbs.db                           # Miniatures Windows
  ├─ Desktop.ini                         # Configuration dossier
  ├─ $RECYCLE.BIN/                       # Corbeille
  └─ *.lnk                               # Raccourcis Windows

╔═══════════════════════════════════════════════════════════════════════╗
║ ENVIRONNEMENTS DE DÉVELOPPEMENT (IDE)                                 ║
╚═══════════════════════════════════════════════════════════════════════╝

vscode
  ├─ .vscode/                            # Configuration VSCode
  │  ├─ settings.json (conservé)         # Paramètres partagés
  │  ├─ launch.json (conservé)           # Configuration debug
  │  └─ extensions.json (conservé)       # Extensions recommandées
  ├─ .history/                           # Historique local
  └─ *.vsix                              # Extensions compilées

jetbrains / idea
  ├─ .idea/                              # Configuration IntelliJ/PyCharm
  ├─ *.iml                               # Module IntelliJ
  └─ cmake-build-*/                      # Builds CLion

vim
  ├─ *.swp, *.swo                        # Fichiers swap Vim
  ├─ *.un~                               # Undo persistant
  └─ Session.vim                         # Sessions Vim

sublime
  ├─ *.sublime-workspace                 # Workspace Sublime
  ├─ sftp-config.json                    # Configuration SFTP
  └─ Package Control.cache/              # Cache extensions

╔═══════════════════════════════════════════════════════════════════════╗
║ OUTILS & INFRASTRUCTURE                                               ║
╚═══════════════════════════════════════════════════════════════════════╝

docker
  ├─ .dockerignore                       # Patterns Docker
  ├─ docker-compose.override.yml         # Override local
  └─ volumes/, secrets/                  # Données locales

terraform
  ├─ *.tfstate, *.tfstate.*              # État Terraform (sensible!)
  ├─ .terraform/                         # Providers téléchargés
  ├─ *.tfvars                            # Variables (sensibles!)
  └─ *.tfplan                            # Plans d'exécution

latex
  ├─ *.aux, *.log, *.toc                 # Fichiers auxiliaires LaTeX
  ├─ *.pdf (optionnel)                   # PDF compilé
  └─ *.synctex.gz                        # Synchronisation éditeur

═══════════════════════════════════════════════════════════════════════════
 4. CAS D'USAGE PRATIQUES - EXEMPLES RÉELS
═══════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────────┐
│ CAS 1 : Nouveau projet Python professionnel                             │
└─────────────────────────────────────────────────────────────────────────┘
  BESOIN :
    - Dépôt Git complet avec branches
    - .gitignore Python
    - .gitignore pour ton IDE (VSCode)
    - .gitignore pour ton OS (macOS/Linux/Windows)
  
  SOLUTION :
    # Créer le dépôt complet avec template Python
    ./create_repo.sh --exec ~/dev/mon-api-python --template python
    
    # Ajouter les patterns IDE et OS
    cd ~/dev/mon-api-python
    ./create_repo.sh --gitignore vscode
    ./create_repo.sh --gitignore macos     # ou linux ou windows
    
    # Commit les modifications
    git add .gitignore
    git commit -m "Add IDE and OS specific gitignore patterns"
    git push

┌─────────────────────────────────────────────────────────────────────────┐
│ CAS 2 : Ajouter un .gitignore à un projet existant                      │
└─────────────────────────────────────────────────────────────────────────┘
  SITUATION :
    Tu as un projet Python sans .gitignore et plein de fichiers indésirables
    sont trackés (__pycache__, .DS_Store, etc.)
  
  SOLUTION :
    cd /chemin/vers/ton/projet
    
    # Créer le .gitignore
    ./create_repo.sh --gitignore python
    ./create_repo.sh --gitignore vscode
    ./create_repo.sh --gitignore macos
    
    # Nettoyer le cache Git (important !)
    git rm -r --cached .
    git add .
    git commit -m "Add comprehensive .gitignore and clean cache"

┌─────────────────────────────────────────────────────────────────────────┐
│ CAS 3 : Application web full-stack (Node + Docker)                      │
└─────────────────────────────────────────────────────────────────────────┘
  COMMANDES :
    ./create_repo.sh --exec ~/dev/app-fullstack --template web --public
    cd ~/dev/app-fullstack
    ./create_repo.sh --gitignore docker
    ./create_repo.sh --gitignore linux
    git add . && git commit -m "Add Docker and Linux patterns" && git push

┌─────────────────────────────────────────────────────────────────────────┐
│ CAS 4 : Tester avant d'exécuter (mode simulation)                       │
└─────────────────────────────────────────────────────────────────────────┘
  COMMANDES :
    # Simuler la création d'un dépôt
    ./create_repo.sh --exec ~/dev/test --template python --simulate
    
    # Simuler la création d'un .gitignore
    ./create_repo.sh --gitignore python --simulate
    
  RÉSULTAT :
    Aucune action réelle, juste l'affichage de ce qui SERAIT fait

┌─────────────────────────────────────────────────────────────────────────┐
│ CAS 5 : Supprimer proprement un projet (local + distant)                │
└─────────────────────────────────────────────────────────────────────────┘
  COMMANDES :
    # Supprimer le dépôt local (backup automatique créé)
    ./create_repo.sh --delete-local ~/dev/ancien-projet
    
    # Supprimer le dépôt distant sur GitHub
    ./create_repo.sh --delete-remote ancien-projet
  
  NOTES :
    - La suppression locale crée TOUJOURS un .tar.gz de backup
    - La suppression distante demande TOUJOURS confirmation
    - Les deux opérations sont INDÉPENDANTES

═══════════════════════════════════════════════════════════════════════════
 5. MODE SIMULATION (--simulate / -s)
═══════════════════════════════════════════════════════════════════════════

CONCEPT :
  Le mode simulation (dry-run) te permet de voir TOUTES les actions qui
  seraient effectuées SANS rien exécuter réellement.

USAGE :
  Ajoute --simulate ou -s à N'IMPORTE QUELLE commande :
  
  ./create_repo.sh --exec ~/dev/test --simulate
  ./create_repo.sh --gitignore python --simulate
  ./create_repo.sh --delete-local ~/dev/test --simulate

AVANTAGES :
  ✓ Tester une commande avant de l'exécuter
  ✓ Vérifier les chemins et paramètres
  ✓ Comprendre ce que fait le script
  ✓ Former de nouveaux utilisateurs

═══════════════════════════════════════════════════════════════════════════
 6. FICHIERS DE LOG
═══════════════════════════════════════════════════════════════════════════

FICHIER : log.create_repo.v4.1.log

CONTENU :
  - Toutes les opérations effectuées avec timestamp
  - Messages d'erreur détaillés
  - Résultats des commandes Git et GitHub

USAGE :
  # Voir les logs en temps réel
  tail -f log.create_repo.v4.1.log
  
  # Rechercher des erreurs
  grep "ERREUR" log.create_repo.v4.1.log
  
  # Voir les dernières opérations
  tail -n 50 log.create_repo.v4.1.log

═══════════════════════════════════════════════════════════════════════════
 7. RÉSOLUTION DE PROBLÈMES COURANTS
═══════════════════════════════════════════════════════════════════════════

PROBLÈME : "remote origin already exists"
  CAUSE : Tu réexécutes le script dans un dépôt Git existant
  SOLUTION : Le script nettoie automatiquement depuis la v4.0
  
PROBLÈME : "Unable to create repository"
  CAUSE : Token GitHub sans permissions ou nom déjà pris
  SOLUTION : 
    gh auth refresh -h github.com -s repo,delete_repo
    gh repo view owner/nom  # Vérifier si le nom existe

PROBLÈME : ".gitignore patterns not working"
  CAUSE : Fichiers déjà trackés dans Git avant le .gitignore
  SOLUTION :
    git rm -r --cached .
    git add .
    git commit -m "Apply .gitignore"

PROBLÈME : "gh: command not found"
  CAUSE : GitHub CLI pas installé
  SOLUTION :
    ./create_repo.sh --install

═══════════════════════════════════════════════════════════════════════════

BESOIN D'AIDE SUPPLÉMENTAIRE ?
  --help                Aide standard (syntaxe et exemples de base)
  --adv-help            Cette aide avancée (concepts et cas d'usage)
  --list-gitignore      Liste TOUS les templates .gitignore disponibles
  --changelog           Historique des versions du script

AUTEUR : Bruno DELNOZ - bruno.delnoz@protonmail.com
VERSION : v4.1 - 2025-10-25
EOF
    exit 0
}

################################################################################
# BLOC PRINCIPAL D'EXÉCUTION
################################################################################

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
            ACTION="gitignore"
            GITIGNORE_TYPE="$2"
            shift 2
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

# Vérification des prérequis sauf pour l'action gitignore (pas besoin de gh)
if [ "$ACTION" != "gitignore" ]; then
    check_prerequisites
fi

case "$ACTION" in
    "exec")
        create_repo
        print_actions_summary
        ;;
    "delete_local")
        delete_local
        ;;
    "delete_remote")
        delete_remote
        ;;
    "gitignore")
        create_gitignore "$GITIGNORE_TYPE"
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

exit 0════════════════════════════════════════════════════════════════════════╗"
    log "║                    CRÉATION DU FICHIER .GITIGNORE                         ║"
    log "╚════════════════════════════════════════════════════════════════════════════╝"
    log ""
    log "Type demandé : $type"
    log "Répertoire   : $(pwd)"
    log ""

    # Vérification de l'existence d'un .gitignore
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
                    mv "$gitignore_path" "${gitignore_path}.backup.$(date +%Y%m%d_%H%M%S)"
                    log "✓ Backup créé : ${gitignore_path}.backup.$(date +%Y%m%d_%H%M%S)"
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

    # Génération du contenu selon le type
    log "→ Génération du contenu .gitignore pour : $type"
    
    if [ "$DRY_RUN" = false ]; then
        case "$type" in
            "python")
                cat > "$gitignore_path" << 'GITIGNORE'
# Python - Bytecode
__pycache__/
*.py[cod]
*$py.class
*.so

# Distribution / packaging
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
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/
cover/

# Translations
*.mo
*.pot

# Django
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask
instance/
.webassets-cache

# Scrapy
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
.pybuilder/
target/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
.python-version

# pipenv
Pipfile.lock

# poetry
poetry.lock

# pdm
.pdm.toml

# PEP 582
__pypackages__/

# Celery
celerybeat-schedule
celerybeat.pid

# SageMath
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder
.spyderproject
.spyproject

# Rope
.ropeproject

# mkdocs
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre
.pyre/

# pytype
.pytype/

# Cython
cython_debug/
GITIGNORE
                log "✓ .gitignore Python créé"
                ;;

            "web"|"node"|"javascript"|"js")
                cat > "$gitignore_path" << 'GITIGNORE'
# Node.js - Dependencies
node_modules/
jspm_packages/
bower_components/

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.pnpm-debug.log*

# Diagnostic reports
report.[0-9]*.[0-9]*.[0-9]*.[0-9]*.json

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Directory for instrumented libs
lib-cov/

# Coverage directory
coverage/
*.lcov

# nyc test coverage
.nyc_output/

# Grunt intermediate storage
.grunt/

# Bower dependency directory
bower_components/

# node-waf configuration
.lock-wscript

# Compiled binary addons
build/Release

# Dependency directories
node_modules/

# TypeScript cache
*.tsbuildinfo

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Optional stylelint cache
.stylelintcache

# Microbundle cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn
.yarn-integrity
.yarn/cache/
.yarn/unplugged/
.yarn/build-state.yml
.yarn/install-state.gz
.pnp.*

# parcel-bundler cache
.cache
.parcel-cache

# Next.js
.next/
out/

# Nuxt.js
.nuxt/
dist/

# Gatsby
.cache/
public/

# vuepress
.vuepress/dist/

# vuepress v2.x temp and cache
.temp/

# Docusaurus
.docusaurus/

# Serverless
.serverless/

# FuseBox
.fusebox/

# DynamoDB Local
.dynamodb/

# TernJS
.tern-port

# Stores VSCode versions
.vscode-test

# yarn v2
.yarn/cache
.yarn/unplugged
.yarn/build-state.yml
.yarn/install-state.gz
.pnp.*

# Environment variables
.env
.env.local
.env.*.local

# Build outputs
dist/
build/
GITIGNORE
                log "✓ .gitignore Web/Node.js créé"
                ;;

            "java")
                cat > "$gitignore_path" << 'GITIGNORE'
# Java - Compiled class files
*.class

# Log files
*.log

# BlueJ files
*.ctxt

# Mobile Tools for Java (J2ME)
.mtj.tmp/

# Package Files
*.jar
*.war
*.nar
*.ear
*.zip
*.tar.gz
*.rar

# Virtual machine crash logs
hs_err_pid*
replay_pid*

# Maven
target/
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
pom.xml.next
release.properties
dependency-reduced-pom.xml
buildNumber.properties
.mvn/timing.properties
.mvn/wrapper/maven-wrapper.jar

# Gradle
.gradle/
build/
!gradle/wrapper/gradle-wrapper.jar
!**/src/main/**/build/
!**/src/test/**/build/

# IntelliJ IDEA
.idea/
*.iws
*.iml
*.ipr
out/

# Eclipse
.apt_generated/
.classpath
.factorypath
.project
.settings/
.springBeans
.sts4-cache
bin/

# NetBeans
/nbproject/private/
/nbbuild/
/dist/
/nbdist/
/.nb-gradle/

# VS Code
.vscode/

# Mac
.DS_Store
GITIGNORE
                log "✓ .gitignore Java créé"
                ;;

            "cpp"|"c++")
                cat > "$gitignore_path" << 'GITIGNORE'
# C++ - Prerequisites
*.d

# Compiled Object files
*.slo
*.lo
*.o
*.obj

# Precompiled Headers
*.gch
*.pch

# Compiled Dynamic libraries
*.so
*.dylib
*.dll

# Fortran module files
*.mod
*.smod

# Compiled Static libraries
*.lai
*.la
*.a
*.lib

# Executables
*.exe
*.out
*.app

# CMake
CMakeLists.txt.user
CMakeCache.txt
CMakeFiles/
CMakeScripts/
Testing/
Makefile
cmake_install.cmake
install_manifest.txt
compile_commands.json
CTestTestfile.cmake
_deps/

# Build directories
build/
Build/
out/
debug/
release/

# Visual Studio
.vs/
*.vcxproj.user
*.suo
*.user
*.sln.docstates

# Qt
*.pro.user
*.pro.user.*
moc_*.cpp
qrc_*.cpp
ui_*.h
Makefile*
*build-*

# Conan
conanfile.txt.user
conaninfo.txt
conanbuildinfo.*
GITIGNORE
                log "✓ .gitignore C++ créé"
                ;;

            "rust")
                cat > "$gitignore_path" << 'GITIGNORE'
# Rust - Compilation files
target/
Cargo.lock

# Remove Cargo.lock from gitignore if creating an executable
# Cargo.lock

# These are backup files generated by rustfmt
**/*.rs.bk

# MSVC Windows builds of rustc generate these
*.pdb

# Flamegraph profiler
flamegraph.svg
perf.data
perf.data.old
GITIGNORE
                log "✓ .gitignore Rust créé"
                ;;

            "go")
                cat > "$gitignore_path" << 'GITIGNORE'
# Go - Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary
*.test

# Output of the go coverage tool
*.out

# Dependency directories
vendor/

# Go workspace file
go.work

# Build output
bin/
pkg/
GITIGNORE
                log "✓ .gitignore Go créé"
                ;;

            "ruby")
                cat > "$gitignore_path" << 'GITIGNORE'
# Ruby - Gem files
*.gem
*.rbc
/.config
/coverage/
/InstalledFiles
/pkg/
/spec/reports/
/spec/examples.txt
/test/tmp/
/test/version_tmp/
/tmp/

# Documentation
/.yardoc/
/_yardoc/
/doc/
/rdoc/

# Environment
/.bundle/
/vendor/bundle
/lib/bundler/man/

# RVM
/.rvmrc

# rbenv
.ruby-version
.ruby-gemset

# RSpec
.rspec

# Simplecov
/coverage/

# Rails
*.rbc
capybara-*.html
.rspec
/db/*.sqlite3
/db/*.sqlite3-journal
/db/*.sqlite3-*
/log/*
/tmp/*
!/log/.keep
!/tmp/.keep
/storage/*
!/storage/.keep
/public/system
/public/uploads
.byebug_history
config/master.key
GITIGNORE
                log "✓ .gitignore Ruby créé"
                ;;

            "php")
                cat > "$gitignore_path" << 'GITIGNORE'
# PHP - Composer
/vendor/
composer.lock

# Laravel
/node_modules
/public/hot
/public/storage
/storage/*.key
.env
.env.backup
.phpunit.result.cache
Homestead.json
Homestead.yaml
npm-debug.log
yarn-error.log

# Symfony
/var/
/vendor/

# WordPress
wp-config.php
wp-content/uploads/
wp-content/cache/
GITIGNORE
                log "✓ .gitignore PHP créé"
                ;;

            "dotnet"|"csharp")
                cat > "$gitignore_path" << 'GITIGNORE'
# .NET - Build results
[Dd]ebug/
[Dd]ebugPublic/
[Rr]elease/
[Rr]eleases/
x64/
x86/
[Ww][Ii][Nn]32/
[Aa][Rr][Mm]/
[Aa][Rr][Mm]64/
bld/
[Bb]in/
[Oo]bj/
[Ll]og/
[Ll]ogs/

# Visual Studio
.vs/
*.suo
*.user
*.userosscache
*.sln.docstates

# ReSharper
_ReSharper*/
*.[Rr]e[Ss]harper
*.DotSettings.user

# NuGet
*.nupkg
*.snupkg
**/packages/*
!**/packages/build/
*.nuget.props
*.nuget.targets
project.lock.json
project.fragment.lock.json
artifacts/

# ASP.NET
*_i.c
*_p.c
*_h.h
*.ilk
*.meta
*.obj
*.iobj
*.pch
*.pdb
*.ipdb
*.pgc
*.pgd
*.rsp
*.sbr
*.tlb
*.tli
*.tlh
*.tmp
*.tmp_proj
*_wpftmp.csproj
*.log
*.vspscc
*.vssscc
.builds
*.pidb
*.svclog
*.scc
GITIGNORE
                log "✓ .gitignore .NET/C# créé"
                ;;

            "swift"|"ios")
                cat > "$gitignore_path" << 'GITIGNORE'
# Swift/iOS - Xcode
build/
DerivedData/
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
xcuserdata/
*.xccheckout
*.moved-aside
*.xcuserstate
*.xcscmblueprint
*.xcworkspace
!default.xcworkspace

# CocoaPods
Pods/

# Carthage
Carthage/Build/

# Swift Package Manager
.build/
.swiftpm/

# fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# Code Injection
iOSInjectionProject/
GITIGNORE
                log "✓ .gitignore Swift/iOS créé"
                ;;

            "android")
                cat > "$gitignore_path" << 'GITIGNORE'
# Android - Gradle
.gradle/
/local.properties
/.idea/caches
/.idea/libraries
/.idea/modules.xml
/.idea/workspace.xml
/.idea/navEditor.xml
/.idea/assetWizardSettings.xml
.DS_Store
/build
/captures
.externalNativeBuild
.cxx

# Android Studio
*.iml
.idea/

# NDK
obj/

# Built application files
*.apk
*.ap_
*.aab

# Files for the ART/Dalvik VM
*.dex

# Java class files
*.class

# Generated files
bin/
gen/
out/

# Keystore files
*.jks
*.keystore

# Proguard
proguard/

# Log Files
*.log

# IntelliJ
*.iml
.idea/

# Lint
lint/intermediates/
lint/generated/
lint/outputs/
lint/tmp/
GITIGNORE
                log "✓ .gitignore Android créé"
                ;;

            "unity")
                cat > "$gitignore_path" << 'GITIGNORE'
# Unity - Library folder
/[Ll]ibrary/
/[Tt]emp/
/[Oo]bj/
/[Bb]uild/
/[Bb]uilds/
/[Ll]ogs/
/[Uu]ser[Ss]ettings/

# MemoryCaptures folder
/[Mm]emoryCaptures/

# Asset meta data
*.pidb.meta
*.pdb.meta
*.mdb.meta

# Unity3D generated meta files
*.pidb
*.booproj
*.svd
*.pdb
*.mdb
*.opendb
*.VC.db

# Unity3D generated file on crash reports
sysinfo.txt

# Builds
*.apk
*.aab
*.unitypackage

# Crashlytics generated file
crashlytics-build.properties

# Packed Addressables
/[Aa]ssets/[Aa]ddressable[Aa]ssets[Dd]ata/*/*.bin*

# Temporary auto-generated Android Assets
/[Aa]ssets/[Ss]treamingAssets/aa.meta
/[Aa]ssets/[Ss]treamingAssets/aa/*
GITIGNORE
                log "✓ .gitignore Unity créé"
                ;;

            "latex")
                cat > "$gitignore_path" << 'GITIGNORE'
# LaTeX - Core
*.aux
*.lof
*.log
*.lot
*.fls
*.out
*.toc
*.fmt
*.fot
*.cb
*.cb2
.*.lb

# Intermediate documents
*.dvi
*.xdv
*-converted-to.*

# Bibliography
*.bbl
*.bcf
*.blg
*-blx.aux
*-blx.bib
*.run.xml

# Build tool auxiliary files
*.fdb_latexmk
*.synctex
*.synctex(busy)
*.synctex.gz
*.synctex.gz(busy)
*.pdfsync

# Build tool directories
latex.out/

# Glossaries
*.acn
*.acr
*.glg
*.glo
*.gls
*.glsdefs
*.lzo
*.lzs

# Uncomment to ignore the final PDF
# *.pdf
GITIGNORE
                log "✓ .gitignore LaTeX créé"
                ;;

            "jekyll")
                cat > "$gitignore_path" << 'GITIGNORE'
# Jekyll - Site builds
_site/
.sass-cache/
.jekyll-cache/
.jekyll-metadata

# Bundler
.bundle/
vendor/

# Ruby
Gemfile.lock
GITIGNORE
                log "✓ .gitignore Jekyll créé"
                ;;

            "hugo")
                cat > "$gitignore_path" << 'GITIGNORE'
# Hugo - Generated files
/public/
/resources/_gen/
/assets/jsconfig.json
hugo_stats.json

# Executable
hugo.exe
hugo.darwin
hugo.linux

# Lock files
.hugo_build.lock
GITIGNORE
                log "✓ .gitignore Hugo créé"
                ;;

            "macos")
                cat > "$gitignore_path" << 'GITIGNORE'
# macOS - System files
.DS_Store
.AppleDouble
.LSOverride

# Icon must end with two \r
Icon

# Thumbnails
._*

# Files that might appear in the root of a volume
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent

# Directories potentially created on remote AFP share
.AppleDB
.AppleDesktop
Network Trash Folder
Temporary Items
.apdisk
GITIGNORE
                log "✓ .gitignore macOS créé"
                ;;

            "linux")
                cat > "$gitignore_path" << 'GITIGNORE'
# Linux - Backup files
*~

# Temporary files
.fuse_hidden*
.directory
.Trash-*

# KDE directory preferences
.directory

# Linux trash folder
.Trash-*

# .nfs files
.nfs*
GITIGNORE
                log "✓ .gitignore Linux créé"
                ;;

            "windows")
                cat > "$gitignore_path" << 'GITIGNORE'
# Windows - Thumbnails
Thumbs.db
Thumbs.db:encryptable
ehthumbs.db
ehthumbs_vista.db

# Dump file
*.stackdump

# Folder config file
[Dd]esktop.ini

# Recycle Bin
$RECYCLE.BIN/

# Windows Installer files
*.cab
*.msi
*.msix
*.msm
*.msp

# Windows shortcuts
*.lnk
GITIGNORE
                log "✓ .gitignore Windows créé"
                ;;

            "vscode")
                cat > "$gitignore_path" << 'GITIGNORE'
# Visual Studio Code
.vscode/
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
!.vscode/*.code-snippets

# Local History for Visual Studio Code
.history/

# Built Visual Studio Code Extensions
*.vsix
GITIGNORE
                log "✓ .gitignore VSCode créé"
                ;;

            "jetbrains"|"idea")
                cat > "$gitignore_path" << 'GITIGNORE'
# JetBrains IDEs (IntelliJ, PyCharm, WebStorm, etc.)
.idea/
*.iws
*.iml
*.ipr

# CMake
cmake-build-*/

# Gradle
.gradle/

# JIRA plugin
atlassian-ide-plugin.xml

# Crashlytics plugin (for Android Studio and IntelliJ)
com_crashlytics_export_strings.xml
crashlytics.properties
crashlytics-build.properties
fabric.properties

# Editor-based Rest Client
.idea/httpRequests

# Android Studio
.idea/caches
.idea/libraries
.idea/modules.xml
.idea/workspace.xml
.idea/navEditor.xml
.idea/assetWizardSettings.xml
GITIGNORE
                log "✓ .gitignore JetBrains créé"
                ;;

            "vim")
                cat > "$gitignore_path" << 'GITIGNORE'
# Vim - Swap files
[._]*.s[a-v][a-z]
!*.svg
[._]*.sw[a-p]
[._]s[a-rt-v][a-z]
[._]ss[a-gi-z]
[._]sw[a-p]

# Session
Session.vim
Sessionx.vim

# Temporary
.netrwhist
*~

# Auto-generated tag files
tags

# Persistent undo
[._]*.un~
GITIGNORE
                log "✓ .gitignore Vim créé"
                ;;

            "sublime")
                cat > "$gitignore_path" << 'GITIGNORE'
# Sublime Text - Cache files
*.tmlanguage.cache
*.tmPreferences.cache
*.stTheme.cache

# Workspace files
*.sublime-workspace

# Project files (optional - uncomment to ignore)
# *.sublime-project

# SFTP configuration file
sftp-config.json
sftp-config-alt*.json

# Package control installed packages
Package Control.last-run
Package Control.ca-list
Package Control.ca-bundle
Package Control.system-ca-bundle
Package Control.cache/
Package Control.ca-certs/
Package Control.merged-ca-bundle
Package Control.user-ca-bundle
oscrypto-ca-bundle.crt
bh_unicode_properties.cache

# Sublime-github package stores
GitHub.sublime-settings
GITIGNORE
                log "✓ .gitignore Sublime Text créé"
                ;;

            "docker")
                cat > "$gitignore_path" << 'GITIGNORE'
# Docker - Build context
.dockerignore

# Docker Compose override
docker-compose.override.yml

# Docker volumes
volumes/

# Docker secrets
secrets/
*.secret

# Environment variables
.env
.env.local
GITIGNORE
                log "✓ .gitignore Docker créé"
                ;;

            "terraform")
                cat > "$gitignore_path" << 'GITIGNORE'
# Terraform - State files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files
*.tfvars
*.tfvars.json

# Ignore override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore CLI configuration files
.terraformrc
terraform.rc

# Terraform directories
.terraform/
.terraform.lock.hcl

# Plan output
*.tfplan
GITIGNORE
                log "✓ .gitignore Terraform créé"
                ;;

            "laravel")
                cat > "$gitignore_path" << 'GITIGNORE'
# Laravel - Dependencies
/vendor/
/node_modules/

# Environment
.env
.env.backup
.env.production

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# Laravel specific
/storage/*.key
/public/hot
/public/storage
Homestead.json
Homestead.yaml
npm-debug.log
yarn-error.log

# Testing
.phpunit.result.cache
/phpunit.xml

# Build
/public/build
/public/mix-manifest.json
GITIGNORE
                log "✓ .gitignore Laravel créé"
                ;;

            "django")
                cat > "$gitignore_path" << 'GITIGNORE'
# Django - Python bytecode
*.py[cod]
__pycache__/

# Database
*.sqlite3
db.sqlite3
db.sqlite3-journal

# Django migrations
**/migrations/*.py
!**/migrations/__init__.py

# Static files
/static/
/staticfiles/
/media/

# Environment
.env
*.env

# Logs
*.log

# Local settings
local_settings.py

# Cache
.cache/

# Coverage
htmlcov/
.coverage
.coverage.*
GITIGNORE
                log "✓ .gitignore Django créé"
                ;;

            "rails")
                cat > "$gitignore_path" << 'GITIGNORE'
# Ruby on Rails - Dependencies
/vendor/bundle/

# Logs
/log/*
!/log/.keep

# Temporary files
/tmp/*
!/tmp/.keep
/tmp/pids/*
!/tmp/pids/.keep
/tmp/cache/*
!/tmp/cache/.keep
/tmp/sockets/*
!/tmp/sockets/.keep

# Storage
/storage/*
!/storage/.keep
/public/uploads

# Database
*.sqlite3
*.sqlite3-*

# Environment
.env
.env.local

# Rails specific
/config/master.key
/config/credentials.yml.enc

# Assets
/public/assets
/public/packs
/public/packs-test

# Node modules
/node_modules
/yarn-error.log
yarn-debug.log*

# System files
.byebug_history
.DS_Store
GITIGNORE
                log "✓ .gitignore Rails créé"
                ;;

            *)
                log "✗ ERREUR : Type de .gitignore inconnu : '$type'"
                log ""
                log "Types disponibles :"
                log "  Langages    : python, web/node/js, java, cpp/c++, rust, go, ruby, php, dotnet/csharp, swift/ios"
                log "  Plateformes : android, unity"
                log "  CMS/FW      : jekyll, hugo, laravel, django, rails"
                log "  OS          : macos, linux, windows"
                log "  IDE         : vscode, jetbrains/idea, vim, sublime"
                log "  Autres      : latex, docker, terraform"
                log ""
                log "Pour voir tous les templates disponibles :"
                log "  ./create_repo.sh --list-gitignore"
                exit 1
                ;;
        esac

        # Si on a créé un fichier .gitignore.new (ajout), fusion avec l'existant
        if [ "$gitignore_path" = ".gitignore.new" ]; then
            log ""
            log "→ Fusion avec le fichier existant..."
            cat .gitignore.new >> .gitignore
            rm .gitignore.new
            log "✓ Contenu ajouté au .gitignore existant"
        fi
    else
        log "[DRY-RUN] Simulation : Création du fichier $gitignore_path de type $type"
    fi

    # Récapitulatif
    log ""
    log "════════════════════════════════════════════════════════════════════════════"
    log "✓ FICHIER .GITIGNORE CRÉÉ AVEC SUCCÈS"
    log "════════════════════════════════════════════════════════════════════════════"
    log ""
    log "INFORMATIONS :"
    log "  • Type       : $type"
    log "  • Fichier    : $(pwd)/.gitignore"
    if [ "$DRY_RUN" = false ]; then
        log "  • Taille     : $(wc -l < .gitignore) lignes"
    fi
    log ""
    log "PROCHAINES ÉTAPES :"
    log "  1. Vérifie le contenu : cat .gitignore"
    log "  2. Personnalise si nécessaire"
    log "  3. Commit le fichier : git add .gitignore && git commit -m 'Add .gitignore'"
    log ""
    log "NOTE : Tu peux ajouter d'autres patterns en exécutant à nouveau :"
    log "  ./create_repo.sh --gitignore <autre-type>"
    log ""
    log "════════════════════════════════════════════════════════════════════════════"
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

    log "[1/3] Vérification de Git..."
    if ! command -v git &>/dev/null; then
        log "✗ ERREUR : Git n'est pas installé sur le système."
        log "  → Solution : Exécute './create_repo.sh --install' pour l'installer"
        exit 1
    fi
    log "✓ Git détecté : $(git --version)"

    log "[2/3] Vérification de GitHub CLI (gh)..."
    if ! command -v gh &>/dev/null; then
        log "✗ ERREUR : GitHub CLI (gh) n'est pas installé."
        log "  → Solution : Exécute './create_repo.sh --install' pour l'installer"
        exit 1
    fi
    log "✓ GitHub CLI détecté : $(gh --version | head -n1)"

    log "[3/3] Vérification de l'authentification GitHub..."
    if ! gh auth status &>/dev/null; then
        log "✗ ERREUR : Non connecté à GitHub via CLI."
        log "  → Solution : Exécute 'gh auth login' pour t'authentifier"
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
# Paramètres : Aucun
# Retour : Sort du script avec code 0 après installation
################################################################################
install_prerequisites() {
    log "╔════════════════════════════════════════════════════════════════════════════╗"
    log "║               INSTALLATION DES PRÉREQUIS SYSTÈME                          ║"
    log "╚════════════════════════════════════════════════════════════════════════════╝"

    log "[1/4] Mise à jour de la liste des paquets apt..."
    if [ "$DRY_RUN" = false ]; then
        sudo apt-get update || { log "✗ ERREUR : Impossible de mettre à jour apt."; exit 1; }
    else
        log "[DRY-RUN] Simulation : sudo apt-get update"
    fi
    log "✓ Liste des paquets mise à jour"

    log "[2/4] Installation de Git..."
    if [ "$DRY_RUN" = false ]; then
        sudo apt-get install -y git || { log "✗ ERREUR : Impossible d'installer git."; exit 1; }
    else
        log "[DRY-RUN] Simulation : sudo apt-get install -y git"
    fi
    log "✓ Git installé"

    log "[3/4] Installation de GitHub CLI (gh)..."
    if [ "$DRY_RUN" = false ]; then
        sudo apt-get install -y gh || { log "✗ ERREUR : Impossible d'installer gh."; exit 1; }
    else
        log "[DRY-RUN] Simulation : sudo apt-get install -y gh"
    fi
    log "✓ GitHub CLI installé"

    log "[4/4] Lancement de l'authentification GitHub..."
    if [ "$DRY_RUN" = false ]; then
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
# Paramètres : Aucun (utilise la variable globale REPO_NAME)
# Retour : Sort du script avec code 1 si le nom est invalide
################################################################################
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

################################################################################
# FONCTION : create_from_template
# Description : Crée les fichiers de base selon le template choisi
# Paramètres :
#   $1 : Type de template (python, web, basic)
# Retour : Aucun
################################################################################
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

################################################################################
# FONCTION : clean_existing_git
# Description : Nettoie complètement un dépôt Git existant
# Paramètres : Aucun
# Retour : Aucun
################################################################################
clean_existing_git() {
    log "Nettoyage du dépôt Git existant..."

    if [ -d ".git" ]; then
        log "→ Dépôt Git détecté dans $(pwd)"

        if git remote get-url origin &>/dev/null; then
            log "→ Suppression de la remote 'origin' existante"
            if [ "$DRY_RUN" = false ]; then
                git remote remove origin 2>/dev/null || log "⚠ Impossible de supprimer la remote"
            else
                log "[DRY-RUN] Simulation : git remote remove origin"
            fi
        fi

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
# Paramètres : Aucun
# Retour : Sort du script avec code 1 en cas d'erreur
################################################################################
create_repo() {
    log "╔════════════════════════════════════════════════════════════════════════════╗"
    log "║                    CRÉATION DU DÉPÔT GIT COMPLET                          ║"
    log "╚════════════════════════════════════════════════════════════════════════════╝"

    validate_repo_name

    log "[1/9] Création du répertoire local : $LOCAL_PATH"
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$LOCAL_PATH" || { log "✗ ERREUR : Impossible de créer le répertoire."; exit 1; }
        cd "$LOCAL_PATH" || { log "✗ ERREUR : Impossible d'accéder au répertoire."; exit 1; }
    else
        log "[DRY-RUN] Simulation : mkdir -p $LOCAL_PATH && cd $LOCAL_PATH"
    fi
    log "✓ Répertoire local créé et accessible"

    log "[2/9] Nettoyage du dépôt Git existant (si présent)..."
    if [ "$DRY_RUN" = false ]; then
        clean_existing_git
    else
        log "[DRY-RUN] Simulation : clean_existing_git"
    fi

    log "[3/9] Initialisation du nouveau dépôt Git local..."
    if [ "$DRY_RUN" = false ]; then
        git init || { log "✗ ERREUR : Impossible d'initialiser le dépôt Git."; exit 1; }
    else
        log "[DRY-RUN] Simulation : git init"
    fi
    log "✓ Dépôt Git initialisé"

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

    log "[5/9] Création du commit initial..."
    if [ "$DRY_RUN" = false ]; then
        git add . || { log "✗ ERREUR : Impossible d'ajouter les fichiers."; exit 1; }
        git commit -m "Initial commit - Created with create_repo.sh v4.1" || { log "✗ ERREUR : Impossible de créer le commit."; exit 1; }
    else
        log "[DRY-RUN] Simulation : git add . && git commit"
    fi
    log "✓ Commit initial créé"

    log "[6/9] Création du dépôt distant sur GitHub..."
    if [ "$DRY_RUN" = false ]; then
        if gh repo view "$OWNER/$REPO_NAME" &>/dev/null; then
            log "⚠ Le dépôt distant existe déjà"
            git remote add origin "https://github.com/$OWNER/$REPO_NAME.git" || { log "✗ ERREUR : Impossible d'ajouter la remote."; exit 1; }
        else
            if ! gh repo create "$OWNER/$REPO_NAME" --"$VISIBILITY" --push --source=. --remote=origin; then
                log "✗ ERREUR : Impossible de créer le dépôt distant."
                exit 1
            fi
        fi
    else
        log "[DRY-RUN] Simulation : Création du dépôt distant"
    fi
    log "✓ Dépôt distant configuré"

    log "[7/9] Vérification de l'existence du dépôt distant..."
    if [ "$DRY_RUN" = false ]; then
        if ! gh repo view "$OWNER/$REPO_NAME" &>/dev/null; then
            log "✗ ERREUR : Le dépôt distant n'a pas été créé correctement."
            exit 1
        fi
        log "✓ Dépôt distant confirmé : https://github.com/$OWNER/$REPO_NAME"
    else
        log "[DRY-RUN] Simulation : Vérification du dépôt distant"
    fi

    log "[8/9] Création de la branche 'Working'..."
    if [ "$DRY_RUN" = false ]; then
        if ! git show-ref --verify --quiet refs/heads/Working; then
            git checkout -b Working || { log "✗ ERREUR : Impossible de créer la branche Working."; exit 1; }
            git push --set-upstream origin Working || { log "✗ ERREUR : Impossible de pousser la branche Working."; exit 1; }
        else
            git checkout Working || { log "✗ ERREUR : Impossible de basculer sur Working."; exit 1; }
        fi
    else
        log "[DRY-RUN] Simulation : Création de la branche Working"
    fi
    log "✓ Branche 'Working' configurée"

    log "[9/9] Retour sur la branche principale ($DEFAULT_BRANCH)..."
    if [ "$DRY_RUN" = false ]; then
        git checkout "$DEFAULT_BRANCH" 2>/dev/null || git checkout main 2>/dev/null || git checkout master
    else
        log "[DRY-RUN] Simulation : git checkout $DEFAULT_BRANCH"
    fi

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
    log "════════════════════════════════════════════════════════════════════════════"

    REPO_CREATED=true
}

################################################################################
# FONCTION : delete_local
# Description : Supprime le dépôt local avec création automatique d'une sauvegarde
# Paramètres : Aucun
# Retour : Sort du script avec code 1 en cas d'erreur
################################################################################
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

################################################################################
# FONCTION : delete_remote
# Description : Supprime le dépôt distant sur GitHub uniquement
# Paramètres : Aucun
# Retour : Sort du script avec code 1 en cas d'erreur
################################################################################
delete_remote() {
    log "╔════