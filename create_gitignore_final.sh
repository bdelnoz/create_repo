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