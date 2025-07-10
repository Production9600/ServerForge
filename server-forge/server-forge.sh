#!/bin/bash
################################
# Server - Forge               #
# Programiert Gerhard Pfeiffer #
# Version 1.3.0                #
# (c) Gerhard Pfeiffer         #
################################

# Server Forge - Hauptskript
# Version: 0.1

# Globale Variablen
# Ermittelt das tatsächliche Verzeichnis des Skripts, auch wenn es über einen Symlink aufgerufen wird.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
CONFIG_DIR="$SCRIPT_DIR/config"
MODULES_DIR="$SCRIPT_DIR/modules"
SERVERS_DIR="$SCRIPT_DIR/servers"
LOGS_DIR="$SCRIPT_DIR/logs"
LANG_DIR="$SCRIPT_DIR/lang"
CONFIG_FILE="$CONFIG_DIR/server-forge.conf"

# Standardkonfiguration erstellen, falls nicht vorhanden
if [ ! -f "$CONFIG_FILE" ]; then
    mkdir -p "$CONFIG_DIR"
    echo "LANGUAGE=en" > "$CONFIG_FILE"
fi

# Konfiguration laden
source "$CONFIG_FILE"

# Sprachdatei laden, mit Fallback auf Englisch
if [ -f "$LANG_DIR/$LANGUAGE.sh" ]; then
    source "$LANG_DIR/$LANGUAGE.sh"
else
    echo "Warnung: Sprachdatei für '$LANGUAGE' nicht gefunden. Lade Englisch."
    source "$LANG_DIR/en.sh"
fi

# Module einbinden
source "$MODULES_DIR/helpers.sh"
source "$MODULES_DIR/install.sh"
source "$MODULES_DIR/manage.sh"
source "$MODULES_DIR/delete.sh"
source "$MODULES_DIR/options.sh"
source "$MODULES_DIR/update.sh"
source "$MODULES_DIR/web.sh"
source "$MODULES_DIR/menu.sh"

# Hauptfunktion
function main() {
    check_requirements
    show_main_menu
}

# Überprüfen der Systemanforderungen
function check_requirements() {
    # Prüfen ob Bash mindestens Version 4.0
    if [ "${BASH_VERSINFO:-0}" -lt 4 ]; then
        echo "Fehler: Dieses Skript benötigt mindestens Bash 4.0"
        exit 1
    fi
    
    # Weitere Systemanforderungen prüfen können hier hinzugefügt werden
}

# Hauptmenü anzeigen
function show_main_menu() {
    local choice=$(dialog_menu "$TXT_MAIN_MENU_TITLE" "" \
        "1" "$TXT_MAIN_MENU_INSTALL" \
        "2" "$TXT_MAIN_MENU_MANAGE" \
        "3" "$TXT_MAIN_MENU_DELETE" \
        "4" "$TXT_MAIN_MENU_OPTIONS" \
        "5" "Webserver" \
        "6" "Update" \
        "0" "$TXT_MAIN_MENU_EXIT")

    case $choice in
        1) show_install_menu ;;
        2) show_manage_menu ;;
        3) show_delete_menu ;;
        4) show_options_menu ;;
        5) show_web_menu ;;
        6) show_update_menu ;;
        0) clear; exit 0 ;;
        *) clear; exit 0 ;; # Beenden bei ESC oder Cancel
    esac
}

# Programmstart
main "$@"

exit 0
