#!/bin/bash
################################
# Server - Forge               #
# Programiert Gerhard Pfeiffer #
# Version 1.3.0                #
# (c) Gerhard Pfeiffer         #
################################

# Modul: update.sh
# Enthält die Selbst-Update-Funktionalität für Server Forge

function show_update_menu() {
    local choice=$(dialog_menu "$TXT_UPDATE_MENU_TITLE" "" \
        "1" "$TXT_UPDATE_SHOW_CHANGELOG" \
        "2" "$TXT_UPDATE_CHECK_FOR_UPDATE" \
        "0" "$TXT_BACK")

    case $choice in
        1) show_changelog ;;
        2) check_for_updates ;;
        0|*) show_main_menu ;;
    esac
}

function show_changelog() {
    local changelog_url="https://raw.githubusercontent.com/Production9600/ServerForge/main/CHANGELOG.md"
    local changelog_file=$(mktemp)
    
    wget -qO "$changelog_file" "$changelog_url"
    dialog --clear --backtitle "Server Forge" --title "$TXT_UPDATE_CHANGELOG_TITLE" --textbox "$changelog_file" 20 70
    rm "$changelog_file"
    show_update_menu
}

function check_for_updates() {
    local local_version=$(cat "$SCRIPT_DIR/../VERSION")
    local remote_version_url="https://raw.githubusercontent.com/Production9600/ServerForge/main/VERSION"
    
    clear
    echo "Checking for updates..."
    sleep 0.5
    
    # Führe wget aus und fange die gesamte Ausgabe (stdout & stderr) ab
    local wget_output
    wget_output=$(wget --no-cache --user-agent="Mozilla/5.0" -O- "$remote_version_url" 2>&1)
    local exit_code=$?

    # Extrahiere die reine Versionsnummer aus der Ausgabe
    local remote_version
    remote_version=$(echo "$wget_output" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$')

    # Überprüfe, ob wget erfolgreich war UND wir eine Version gefunden haben
    if [ $exit_code -ne 0 ] || [ -z "$remote_version" ]; then
        # Zeige eine Debug-Nachricht mit der vollen wget-Ausgabe an
        printf -v debug_msg "Wget Exit Code: %s\n\nFull Output:\n%s" "$exit_code" "$wget_output"
        dialog_msgbox "Update Debug Info" "$debug_msg"
        
        dialog_msgbox "$TXT_ERROR" "$TXT_UPDATE_FAILED_CONNECTION"
        show_update_menu
        return
    fi
    
    if [ "$local_version" == "$remote_version" ]; then
        dialog_msgbox "$TXT_UPDATE_CHECK_TITLE" "$(printf "$TXT_UPDATE_LATEST_VERSION" "$local_version")"
        show_update_menu
    else
        printf -v prompt "$TXT_UPDATE_PROMPT" "$local_version" "$remote_version"
        if dialog_yesno "$TXT_UPDATE_AVAILABLE" "$prompt"; then
            (
                echo "0"; echo "# $TXT_UPDATE_STARTING"; sleep 1
                cd "$SCRIPT_DIR/.."
                git pull
                local pull_exit_code=$?
                echo "100"
                exit $pull_exit_code
            ) | dialog --clear --backtitle "Server Forge" --title "Updating..." --gauge "..." 10 70 0
            
            if [ ${PIPESTATUS[0]} -eq 0 ]; then
                dialog_msgbox "$TXT_UPDATE_SUCCESS" "$TXT_UPDATE_SUCCESS"
                exec "$SCRIPT_DIR/server-forge.sh"
            else
                printf -v error_msg "$TXT_UPDATE_FAILED" "$(dirname "$SCRIPT_DIR")"
                dialog_msgbox "$TXT_ERROR" "$error_msg"
                show_update_menu
            fi
        else
            show_update_menu
        fi
    fi
}