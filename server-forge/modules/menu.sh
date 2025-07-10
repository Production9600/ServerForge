#!/bin/bash
################################
# Server - Forge               #
# Programiert Gerhard Pfeiffer #
# Version 1.3.0                #
# (c) Gerhard Pfeiffer         #
################################

# Modul: menu.sh
# Enthält alle Menüfunktionen für Server Forge

# Installationsmenü anzeigen
function show_install_menu() {
    local choice=$(dialog_menu "$TXT_INSTALL_MENU_TITLE" "$TXT_INSTALL_MENU_PROMPT" \
        "1" "Minecraft (Java Edition)" \
        "2" "Minecraft (Bedrock Edition)" \
        "3" "7 Days to Die" \
        "4" "Valheim" \
        "5" "ARK: Survival Ascended" \
        "6" "Rust" \
        "7" "Counter-Strike 2" \
        "8" "Project Zomboid" \
        "0" "$TXT_INSTALL_MENU_BACK")

    case $choice in
        1) install_minecraft_java ;;
        2) install_minecraft_bedrock ;;
        3) install_7d2d ;;
        4) install_valheim ;;
        5) install_arksa ;;
        6) install_rust ;;
        7) install_cs2 ;;
        8) install_zomboid ;;
        0|*) show_main_menu ;;
    esac
}

function show_manage_menu() {
    if [ -z "$(ls -A "$SERVERS_DIR" 2>/dev/null)" ]; then
        dialog_msgbox "$TXT_MANAGE_MENU_TITLE" "$TXT_MANAGE_MENU_NO_SERVERS"
        show_main_menu
        return
    fi

    local menu_options=()
    local server_dirs=()
    local count=1
    for dir in "$SERVERS_DIR"/*/; do
        if [ -d "$dir" ]; then
            local server_name=$(basename "$dir")
            local conf_file="$dir/server.conf"
            local game_type="?"
            if [ -f "$conf_file" ]; then
                game_type=$(grep "GAME_TYPE" "$conf_file" | cut -d'=' -f2 | tr -d '"')
            fi
            local status=$(get_server_status "$dir")
            
            menu_options+=("$count" "[$game_type] $server_name - $status")
            server_dirs+=("$server_name")
            ((count++))
        fi
    done

    local choice=$(dialog_menu "$TXT_MANAGE_MENU_TITLE" "$TXT_MANAGE_MENU_PROMPT" "${menu_options[@]}")

    if [ -z "$choice" ]; then
        show_main_menu
    else
        local selected_dir="${server_dirs[$((choice-1))]}"
        show_server_actions_menu "$selected_dir"
    fi
}

# Löschmenü anzeigen
function show_delete_menu() {
    print_header "$TXT_MAIN_MENU_DELETE"
    list_installed_servers
    local choice=$?
    
    if [ $choice -eq 2 ]; then
        show_delete_menu
    else
        echo "$TXT_PRESS_ANY_KEY"
        read -n 1 -s -r
        show_main_menu
    fi
}

function show_options_menu() {
    local choice=$(dialog_menu "$TXT_OPTIONS_MENU_TITLE" "" \
        "1" "$TXT_OPTIONS_CHANGE_LANG" \
        "2" "$TXT_OPTIONS_MANAGE_PATHS" \
        "3" "$TXT_OPTIONS_FTP" \
        "0" "$TXT_BACK")

    case $choice in
        1) change_language ;;
        2) manage_paths ;;
        3) ftp_settings ;;
        0|*) show_main_menu ;;
    esac
}

