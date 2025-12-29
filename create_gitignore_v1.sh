#!/bin/bash
################################################################################
# Auteur : Bruno DELNOZ
# Email : bruno.delnoz@protonmail.com
# Nom du script : create_gitignore.sh
# Target usage : Création et gestion de fichiers .gitignore à partir de templates
# Version : v1.0 - Date : 2025-10-25
# Compatible avec : create_repo.sh v5.0
################################################################################

################################################################################
# VARIABLES GLOBALES
################################################################################
LOG_FILE="log.create_gitignore.v1.0.log"
DRY_RUN=false
TEMPLATES_DIR="$(dirname "$0")/gitignore_templates"
NO_LOG=false
AUTO_APPEND=false

################################################################################
# FONCTION : log
################################################################################
log() {
    if [ "$NO_LOG" = false ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
    fi
}

################################################################################
# FONCTION : print_help
################################################################################
print_help() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                  CREATE_GITIGNORE.SH - AIDE                                ║
╚════════════════════════════════════════════════════════════════════════════╝

USAGE:
  ./create_gitignore.sh <template> [OPTIONS]

EXEMPLES:
  ./create_gitignore.sh python
  ./create_gitignore.sh python vscode macos

OPTIONS:
  --list                Liste tous les templates disponibles
  --simulate, -s        Mode simulation (dry-run)
  --no-log              Désactive le logging
  --auto-append         Ajoute automatiquement sans confirmation
  --help, -h            Affiche cette aide

TEMPLATES:
  Langages : python, web, node, java, cpp, rust, go, ruby, php, dotnet, swift
  OS       : macos, linux, windows
  IDE      : vscode, jetbrains, vim, sublime
  Outils   : docker, terraform, django, laravel, rails, unity, android

AUTEUR: Bruno DELNOZ - bruno.delnoz@protonmail.com
VERSION: v1.0 (compatible create_repo.sh v5.0)
EOF
    exit 0
}

################################################################################
# FONCTION : list_templates
################################################################################
list_templates() {
    log "╔════════════════════════════════════════════════════════════════════════════╗"
    log "║                    TEMPLATES DISPONIBLES                                   ║"
    log "╚════════════════════════════════════════════════════════════════════════════╝"
    log ""
    
    if [ ! -d "$TEMPLATES_DIR" ]; then
        log "✗ ERREUR : Dossier $TEMPLATES_DIR introuvable"
        exit 1
    fi
    
    log "LANGAGES DE PROGRAMMATION:"
    for template in python web node java cpp rust go ruby php dotnet swift android; do
        [ -f "$TEMPLATES_DIR/${template}.gitignore" ] && log "  • $template"
    done
    
    log ""
    log "FRAMEWORKS/CMS:"
    for template in django laravel rails unity; do
        [ -f "$TEMPLATES_DIR/${template}.gitignore" ] && log "  • $template"
    done
    
    log ""
    log "SYSTÈMES D'EXPLOITATION:"
    for template in macos linux windows; do
        [ -f "$TEMPLATES_DIR/${template}.gitignore" ] && log "  • $template"
    done
    
    log ""
    log "IDE:"
    for template in vscode jetbrains vim sublime; do
        [ -f "$TEMPLATES_DIR/${template}.gitignore" ] && log "  • $template"
    done
    
    log ""
    log "OUTILS:"
    for template in docker terraform; do
        [ -f "$TEMPLATES_DIR/${template}.gitignore" ] && log "  • $template"
    done
    
    exit 0
}

################################################################################
# FONCTION : check_template_exists
################################################################################
check_template_exists() {
    local template="$1"
    local template_file="$TEMPLATES_DIR/${template}.gitignore"
    
    if [ ! -f "$template_file" ]; then
        log "✗ ERREUR : Template '$template' introuvable"
        log "  Fichier attendu : $template_file"
        log "  Utilise --list pour voir les templates disponibles"
        return 1
    fi
    
    return 0
}

################################################################################
# FONCTION : create_gitignore
################################################################################
create_gitignore() {
    local template="$1"
    local gitignore_path=".gitignore"
    local template_file="$TEMPLATES_DIR/${template}.gitignore"
    
    log "════════════════════════════════════════════════════════════════════════════"
    log "Création/ajout du template : $template"
    log "════════════════════════════════════════════════════════════════════════════"
    
    # Vérification template
    if ! check_template_exists "$template"; then
        return 1
    fi
    
    # Gestion .gitignore existant
    if [ -f "$gitignore_path" ]; then
        log "⚠ .gitignore existe déjà"
        
        if [ "$AUTO_APPEND" = true ]; then
            log "→ Mode auto-append : ajout au fichier existant"
        elif [ "$DRY_RUN" = false ]; then
            read -p "Action : [a]jouter ou [r]emplacer ? (a/r) : " choice
            case "$choice" in
                r|R)
                    local backup="${gitignore_path}.backup.$(date +%Y%m%d_%H%M%S)"
                    mv "$gitignore_path" "$backup"
                    log "✓ Backup créé : $backup"
                    ;;
                a|A)
                    log "→ Ajout au fichier existant"
                    ;;
                *)
                    log "✗ Choix invalide. Opération annulée."
                    return 1
                    ;;
            esac
        fi
    fi
    
    # Création/ajout du contenu
    if [ "$DRY_RUN" = false ]; then
        if [ -f "$gitignore_path" ]; then
            # Ajout avec séparateur
            echo "" >> "$gitignore_path"
            echo "# ========================================" >> "$gitignore_path"
            echo "# $(grep "^# Template :" "$template_file" | cut -d: -f2-)" >> "$gitignore_path"
            echo "# ========================================" >> "$gitignore_path"
            # Exclure les lignes de métadonnées (qui commencent par # Template, # Description, etc.)
            grep -v "^# Template :" "$template_file" | \
            grep -v "^# Description :" | \
            grep -v "^# Maintainer :" | \
            grep -v "^# Last update :" | \
            grep -v "^# Compatible with :" >> "$gitignore_path"
            log "✓ Template '$template' ajouté au .gitignore existant"
        else
            # Création nouveau fichier
            cat "$template_file" > "$gitignore_path"
            log "✓ .gitignore créé avec template '$template'"
        fi
    else
        log "[DRY-RUN] Simulation : création/ajout du template '$template'"
    fi
    
    return 0
}

################################################################################
# BLOC PRINCIPAL
################################################################################

if [ $# -eq 0 ]; then
    print_help
fi

# Parsing des arguments
TEMPLATES=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --list)
            list_templates
            ;;
        --simulate|-s)
            DRY_RUN=true
            log "⚠ MODE SIMULATION ACTIVÉ"
            shift
            ;;
        --no-log)
            NO_LOG=true
            shift
            ;;
        --auto-append)
            AUTO_APPEND=true
            shift
            ;;
        --help|-h)
            print_help
            ;;
        *)
            TEMPLATES+=("$1")
            shift
            ;;
    esac
done

# Vérification templates
if [ ${#TEMPLATES[@]} -eq 0 ]; then
    log "✗ ERREUR : Aucun template spécifié"
    log "  Utilise --help pour voir l'aide"
    exit 1
fi

# Vérification dossier templates
if [ ! -d "$TEMPLATES_DIR" ]; then
    log "✗ ERREUR : Dossier templates introuvable : $TEMPLATES_DIR"
    log "  Assure-toi que gitignore_templates/ existe dans le même dossier que ce script"
    exit 1
fi

# Création des .gitignore
for template in "${TEMPLATES[@]}"; do
    create_gitignore "$template" || exit 1
done

log "════════════════════════════════════════════════════════════════════════════"
log "✓ Opération terminée avec succès"
log "════════════════════════════════════════════════════════════════════════════"

exit 0
