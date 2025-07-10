#!/bin/bash
################################
# Server - Forge               #
# Programiert Gerhard Pfeiffer #
# Version 1.3.0                #
# (c) Gerhard Pfeiffer         #
################################

# Modul: delete.sh
# Enthält alle Löschfunktionen für Server Forge
function delete_server() {
    local server_id=$1
    local server_path="$SERVERS_DIR/$server_id"

    if [ ! -d "$server_path" ]; then
        dialog_msgbox "$TXT_ERROR" "$(printf "Server '%s' nicht gefunden." "$server_id")"
        return
    fi

    local warning_text=$(printf "$TXT_DELETE_CONFIRM1\n\n$TXT_DELETE_CONFIRM2" "$server_id")
    if dialog_yesno "$TXT_MAIN_MENU_DELETE" "$warning_text"; then
        (
            echo "0"; echo "# $(printf "$TXT_DELETING_SERVER" "$server_id")"; sleep 1
            rm -rf "$server_path"
            echo "100"
        ) | dialog --clear --backtitle "Server Forge" --title "$TXT_MAIN_MENU_DELETE" --gauge "..." 10 70 0
        dialog_msgbox "$TXT_MAIN_MENU_DELETE" "$(printf "$TXT_DELETE_SUCCESS" "$server_id")"
    else
        dialog_msgbox "$TXT_MAIN_MENU_DELETE" "$TXT_DELETE_CANCELLED"
    fi
}
function list_installed_servers() {
    local count=0
    local server_dirs=()
    
    if [ -d "$SERVERS_DIR" ]; then
        for dir in "$SERVERS_DIR"/*/; do
            if [ -d "$dir" ]; then
                ((count++))
                local dir_name=$(basename "$dir")
                server_dirs+=("$dir_name")
                echo "$count) $dir_name"
            fi
        done
    fi
    
    if [ $count -eq 0 ]; then
        echo "$TXT_DELETE_NO_SERVERS"
        return 1
    fi
    
    echo -e "${COLOR_YELLOW}0)${COLOR_NC} $TXT_MAIN_MENU_BACK"
    printf "$TXT_DELETE_PROMPT\n" "$count"
    echo -n "$TXT_PROMPT_CHOICE"
    read -r choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le $count ]; then
        local selected_dir="${server_dirs[$((choice-1))]}"
        delete_server "$selected_dir"
    elif [ "$choice" -eq 0 ]; then
        return 0
    else
        return 2
    fi
    return 0
}