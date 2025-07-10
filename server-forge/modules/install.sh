#!/bin/bash
################################
# Server - Forge               #
# Programiert Gerhard Pfeiffer #
# Version 1.3.0                #
# (c) Gerhard Pfeiffer         #
################################

# Modul: install.sh
# Enthält alle Installationsfunktionen für Server Forge

function install_minecraft_java() {
    local log_file="/tmp/minecraft_install.log"
    (
        exec > >(tee "$log_file") 2>&1
        echo "0"; echo "# $TXT_INSTALL_CHECKING_DEPS"; sleep 1
        command -v wget &>/dev/null || { echo "100"; echo "# $(printf "$TXT_INSTALL_ERROR_DEP_NOT_FOUND" "wget")"; exit 1; }
        command -v pv &>/dev/null || { echo "100"; echo "# $(printf "$TXT_INSTALL_ERROR_DEP_NOT_FOUND" "pv")"; exit 1; }
        command -v java &>/dev/null || { echo "100"; echo "# $(printf "$TXT_INSTALL_ERROR_DEP_NOT_FOUND" "java")"; exit 1; }
        
        echo "10"; echo "# $TXT_INSTALL_GETTING_INFO"
        local version_manifest_url=$(wget -qO- https://launchermeta.mojang.com/mc/game/version_manifest.json | grep -oP '"url": "\K[^"]+' | head -1)
        local latest_version_url=$(wget -qO- $version_manifest_url | grep -oP '"url": "\K[^"]+' | head -1)
        local server_jar_url=$(wget -qO- $latest_version_url | grep -oP '"server": {"sha1": "[^"]+", "size": \d+, "url": "\K[^"]+')
        local latest_version=$(wget -qO- $version_manifest_url | grep -oP '"latest": {"release": "\K[^"]+')
        
        local i=1
        while [ -d "$SERVERS_DIR/minecraft-java_$i" ]; do i=$((i+1)); done
        local server_id="minecraft-java_$i"
        local server_path="$SERVERS_DIR/$server_id"
        mkdir -p "$server_path"
        
        echo "20"; echo "# $(printf "$TXT_INSTALL_DOWNLOADING" "Minecraft" "$latest_version")"
        download_with_progress "$server_jar_url" "$server_path/server.jar" || exit 1
        
        echo "80"; echo "# $TXT_INSTALL_ACCEPTING_EULA"
        echo "eula=true" > "$server_path/eula.txt"
        
        echo "90"; echo "# $TXT_INSTALL_CREATING_CONF"
        cat > "$server_path/server.conf" <<EOL
# Server Forge Konfiguration
GAME_TYPE="minecraft_java"
SERVER_ID="$server_id"
SERVER_VERSION="$latest_version"
SERVER_JAR="server.jar"
EOL
        echo "100"; echo "# $(printf "$TXT_INSTALL_SUCCESS" "$server_id")"
    ) | dialog --clear --backtitle "Server Forge" --title "$(printf "$TXT_INSTALL_TITLE" "Minecraft (Java)")" --gauge "..." 10 70 0

    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        dialog --clear --backtitle "Server Forge" --title "$TXT_ERROR" --textbox "$log_file" 20 80
    else
        dialog_msgbox "$TXT_INSTALL_SUCCESS" "$TXT_INSTALL_MANAGE_HINT"
    fi
    show_install_menu
}
export -f install_minecraft_java

function install_minecraft_bedrock() {
    local log_file="/tmp/minecraft_install.log"
    (
        exec > >(tee "$log_file") 2>&1
        echo "0"; echo "# $TXT_INSTALL_CHECKING_DEPS"; sleep 1
        command -v wget &>/dev/null || { echo "100"; echo "# $(printf "$TXT_INSTALL_ERROR_DEP_NOT_FOUND" "wget")"; exit 1; }
        command -v unzip &>/dev/null || { echo "100"; echo "# $(printf "$TXT_INSTALL_ERROR_DEP_NOT_FOUND" "unzip")"; exit 1; }
        
        echo "10"; echo "# $TXT_INSTALL_BEDROCK_GETTING_URL"
        local bedrock_server_url=$(wget -qO- https://www.minecraft.net/en-us/download/server/bedrock | grep -oP 'https://minecraft.azureedge.net/bin-linux/[^"]+' | head -n 1)
        [ -z "$bedrock_server_url" ] && { echo "100"; echo "# $TXT_INSTALL_BEDROCK_URL_NOT_FOUND"; exit 1; }
        
        local i=1
        while [ -d "$SERVERS_DIR/minecraft-bedrock_$i" ]; do i=$((i+1)); done
        local server_id="minecraft-bedrock_$i"
        local server_path="$SERVERS_DIR/$server_id"
        mkdir -p "$server_path"
        
        echo "20"; echo "# $TXT_INSTALL_BEDROCK_DOWNLOADING"
        download_with_progress "$bedrock_server_url" "$server_path/bedrock-server.zip" || exit 1
        
        echo "80"; echo "# $TXT_INSTALL_BEDROCK_UNZIPPING"
        unzip -q "$server_path/bedrock-server.zip" -d "$server_path"
        rm "$server_path/bedrock-server.zip"
        
        echo "90"; echo "# $TXT_INSTALL_CREATING_CONF"
        cat > "$server_path/server.conf" <<EOL
# Server Forge Konfiguration
GAME_TYPE="minecraft_bedrock"
SERVER_ID="$server_id"
EOL
        echo "100"; echo "# $(printf "$TXT_INSTALL_SUCCESS" "$server_id")"
    ) | dialog --clear --backtitle "Server Forge" --title "$(printf "$TXT_INSTALL_TITLE" "Minecraft (Bedrock)")" --gauge "..." 10 70 0

    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        dialog --clear --backtitle "Server Forge" --title "$TXT_ERROR" --textbox "$log_file" 20 80
    else
        dialog_msgbox "$TXT_INSTALL_SUCCESS" "$TXT_INSTALL_MANAGE_HINT"
    fi
    show_install_menu
}
export -f install_minecraft_bedrock

function install_7d2d() {
    install_steam_game "7 Days to Die" "294420"
}
export -f install_7d2d

function install_valheim() {
    install_steam_game "Valheim" "896660"
}
export -f install_valheim

function install_arksa() {
    install_steam_game "ARK: Survival Ascended" "2430930"
}
export -f install_arksa

function install_rust() {
    install_steam_game "Rust" "258550"
}
export -f install_rust

function install_cs2() {
    install_steam_game "Counter-Strike 2" "730"
}
export -f install_cs2

function install_zomboid() {
    install_steam_game "Project Zomboid" "380870" "validate"
}
export -f install_zomboid