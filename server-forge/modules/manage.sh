#!/bin/bash
################################
# Server - Forge               #
# Programiert Gerhard Pfeiffer #
# Version 1.3.0                #
# (c) Gerhard Pfeiffer         #
################################

# Modul: manage.sh
# Enthält alle Verwaltungsfunktionen für Server Forge
# Zeigt das Aktionsmenü für einen einzelnen, ausgewählten Server an.
# Verwendung: show_server_actions_menu "server_id"
function show_server_actions_menu() {
    local server_id=$1
    local server_path="$SERVERS_DIR/$server_id"
    
    # Spielname und Status erneut abrufen für die Anzeige
    local game_type=$(grep "GAME_TYPE" "$server_path/server.conf" | cut -d'=' -f2 | tr -d '"')
    local status=$(get_server_status "$server_path")

    printf -v title "$TXT_ACTION_MENU_TITLE" "$server_id" "$game_type" "$status"
    
    local choice=$(dialog_menu "$title" "" \
        "1" "$TXT_ACTION_START" \
        "2" "$TXT_ACTION_STOP" \
        "3" "$TXT_ACTION_RESTART" \
        "4" "$TXT_ACTION_CONSOLE" \
        "5" "$TXT_ACTION_LOG" \
        "6" "$TXT_ACTION_CONFIG" \
        "7" "$TXT_ACTION_SETTINGS" \
        "8" "$TXT_ACTION_UPDATE" \
        "9" "$TXT_ACTION_BACKUP" \
        "0" "$TXT_ACTION_BACK_TO_LIST")

    case $choice in
        1) start_server "$server_id" ;;
        2) stop_server "$server_id" ;;
        3) restart_server "$server_id" ;;
        4) attach_to_console "$server_id" ;;
        5) view_log "$server_id" ;;
        6) edit_server_config "$server_id" ;;
        7) show_settings_menu "$server_id" ;;
        8) update_server "$server_id" ;;
        9) manage_backups "$server_id" ;;
        0|*) show_manage_menu ;;
    esac
}
function start_server() {
    local server_id=$1
    local server_path="$SERVERS_DIR/$server_id"
    local status=$(get_server_status "$server_path")

    if [[ "$status" == *$TXT_ONLINE* ]]; then
        dialog_msgbox "$TXT_ERROR" "$(printf "$TXT_SERVER_ALREADY_RUNNING" "$server_id")"
        show_server_actions_menu "$server_id"
        return
    fi

    # Prüfen, ob 'screen' installiert ist
    if ! command -v screen &> /dev/null; then
        dialog_msgbox "$TXT_ERROR" "$TXT_ERROR_SCREEN_NEEDED\n$TXT_ERROR_SCREEN_INSTALL_HINT"
        show_server_actions_menu "$server_id"
        return
    fi

    local game_type=$(grep "GAME_TYPE" "$server_path/server.conf" | cut -d'=' -f2 | tr -d '"')
    local start_command=""

    # Spiel-spezifische Startbefehle
    case $game_type in
        "minecraft_java")
            local server_jar=$(grep "SERVER_JAR" "$server_path/server.conf" | cut -d'=' -f2 | tr -d '"')
            start_command="java -Xmx1024M -Xms1024M -jar $server_jar nogui"
            ;;
        "minecraft_bedrock")
            start_command="./bedrock_server"
            ;;
        "7daystodie")
            start_command="./7DaysToDieServer.x86_64 -configfile=serverconfig.xml"
            ;;
        "valheim")
            # Lese die Parameter aus der server.conf
            local server_name=$(grep "SERVER_NAME=" "$server_path/server.conf" | cut -d'=' -f2 | tr -d '"')
            local world_name=$(grep "WORLD_NAME=" "$server_path/server.conf" | cut -d'=' -f2 | tr -d '"')
            local password=$(grep "PASSWORD=" "$server_path/server.conf" | cut -d'=' -f2 | tr -d '"')
            local port=$(grep "PORT=" "$server_path/server.conf" | cut -d'=' -f2 | tr -d '"')
            start_command="./valheim_server.x86_64 -name \"$server_name\" -port $port -world \"$world_name\" -password \"$password\""
            ;;
        "arksa")
            # ARK: SA hat einen komplexeren Startbefehl
            start_command="./ShooterGame/Binaries/Linux/ShooterGameServer TheIsland_WP?listen?SessionName=MyArkServer?ServerPassword=secret -server -log"
            ;;
        "rust")
            # Der Startbefehl für Rust liest die Konfiguration aus der server.cfg
            start_command="./RustDedicated -batchmode +server.identity \"${server_id}\""
            ;;
        "counter-strike2")
            start_command="./game/cs2.sh -dedicated +game_type 0 +game_mode 1 +map de_dust2"
            ;;
        "projectzomboid")
            start_command="./start-server.sh"
            ;;
        *)
            printf "$TXT_ERROR_UNKNOWN_GAME_START\n" "$game_type"
            sleep 3
            show_server_actions_menu "$server_id"
            return
            ;;
    esac

    printf "$TXT_STARTING_SERVER\n" "$server_id"
    cd "$server_path"
    # Server in einer detached screen-Sitzung starten
    screen -dmS "$server_id" bash -c "$start_command"
    cd "$SCRIPT_DIR"

    # PID der screen-Sitzung abrufen und speichern
    local pid=$(screen -list | grep "$server_id" | cut -f1 -d'.' | sed 's/\s//g')
    echo "$pid" > "$server_path/.server.pid"

    sleep 2 # Kurz warten, damit der Server-Status aktualisiert wird
    printf "$TXT_SERVER_STARTED\n" "$server_id"
    sleep 2
    show_server_actions_menu "$server_id"
}

function stop_server() {
    local server_id=$1
    local server_path="$SERVERS_DIR/$server_id"
    local pid_file="$server_path/.server.pid"
    local status=$(get_server_status "$server_path")

    if [[ "$status" == *$TXT_OFFLINE* ]]; then
        dialog_msgbox "$TXT_ERROR" "$(printf "$TXT_SERVER_NOT_RUNNING" "$server_id")"
        show_server_actions_menu "$server_id"
        return
    fi

    printf "$TXT_STOPPING_SERVER\n" "$server_id"
    local pid=$(cat "$pid_file")
    
    # Befehl zum Beenden an die screen-Sitzung senden
    # Für viele Server ist "stop" oder "quit" der Befehl zum sauberen Herunterfahren.
    # Wir senden hier ein "quit", was für die meisten screen-Anwendungen funktioniert.
    # Eine spiel-spezifische Logik wäre hier noch besser.
    screen -S "$pid" -X quit

    # Warten, bis der Prozess beendet ist
    run_with_spinner "$TXT_WAITING_SHUTDOWN" "while kill -0 $pid 2>/dev/null; do sleep 0.5; done"
    
    rm -f "$pid_file"
    
    printf "$TXT_SERVER_STOPPED\n" "$server_id"
    sleep 2
    show_server_actions_menu "$server_id"
}

function restart_server() {
    local server_id=$1
    printf "$TXT_RESTARTING_SERVER\n" "$server_id"
    stop_server "$server_id"
    start_server "$server_id"
}

function attach_to_console() {
    local server_id=$1
    local server_path="$SERVERS_DIR/$server_id"
    local status=$(get_server_status "$server_path")

    if [[ "$status" == *$TXT_OFFLINE* ]]; then
        dialog_msgbox "$TXT_ERROR" "$(printf "$TXT_CONSOLE_ERROR_OFFLINE" "$server_id")"
        show_server_actions_menu "$server_id"
        return
    fi

    printf "$TXT_CONSOLE_OPENING_HINT\n" "$server_id"
    sleep 2
    # Verbindet sich mit der laufenden screen-Sitzung
    screen -r "$server_id"
    
    # Nach dem Verlassen der Konsole zurück zum Menü
    show_server_actions_menu "$server_id"
}

function view_log() {
    local server_id=$1
    local server_path="$SERVERS_DIR/$server_id"
    local game_type=$(grep "GAME_TYPE" "$server_path/server.conf" | cut -d'=' -f2 | tr -d '"')
    local log_file=""

    # Spiel-spezifische Log-Dateien
    # Wir suchen nach der neuesten Log-Datei, falls es mehrere gibt.
    case $game_type in
        "minecraft_java")
            log_file=$(find "$server_path/logs" -name "latest.log" 2>/dev/null)
            ;;
        "7daystodie")
            # 7D2D hat einen spezifischen Log-Pfad
            log_file=$(find "$HOME/.local/share/7DaysToDie/logs" -name "output_log_*" -print0 | xargs -0 ls -t | head -n 1)
            ;;
        "valheim")
            # Valheim gibt Logs oft nur in der Konsole aus, aber wir können den Pfad hier für dedizierte Logs definieren
            log_file="$server_path/valheim_log.txt" # Annahme, muss im Startbefehl so konfiguriert werden
            ;;
        "arksa")
            log_file="$server_path/ShooterGame/Saved/Logs/ShooterGame.log"
            ;;
        "rust")
            log_file=$(find "$server_path/server/$server_id/logs" -name "log.*.txt" -print0 | xargs -0 ls -t | head -n 1 2>/dev/null)
            ;;
        *)
            printf "$TXT_LOG_PATH_UNKNOWN\n" "$game_type"
            sleep 3
            show_server_actions_menu "$server_id"
            return
            ;;
    esac

    if [ -z "$log_file" ] || [ ! -f "$log_file" ]; then
        printf "$TXT_LOG_NOT_FOUND\n" "$server_id"
        echo "$TXT_HINT_START_SERVER_TO_GENERATE"
        sleep 4
        show_server_actions_menu "$server_id"
        return
    fi

    printf "$TXT_LOG_OPENING\n" "$log_file"
    echo "$TXT_HINT_QUIT_LESS"
    sleep 2
    less "$log_file"
    
    show_server_actions_menu "$server_id"
}

function edit_server_config() {
    local server_id=$1
    local server_path="$SERVERS_DIR/$server_id"
    local game_type=$(grep "GAME_TYPE" "$server_path/server.conf" | cut -d'=' -f2 | tr -d '"')
    local config_file=""

    # Spiel-spezifische Konfigurationsdateien
    case $game_type in
        "minecraft_java")
            config_file="$server_path/server.properties"
            ;;
        "minecraft_bedrock")
            config_file="$server_path/server.properties"
            ;;
        "7daystodie")
            config_file="$server_path/serverconfig.xml"
            ;;
        "arksa")
            config_file="$server_path/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini"
            ;;
        "rust")
            config_file="$server_path/server/$server_id/cfg/server.cfg"
            ;;
        "counter-strike2")
            config_file="$server_path/game/csgo/cfg/server.cfg"
            ;;
        "projectzomboid")
            # Der Name der INI-Datei ist oft dynamisch, wir suchen nach der ersten.
            config_file=$(find "$HOME/Zomboid/Server" -name "${server_id}_*.ini" -print -quit 2>/dev/null)
            ;;
        *)
            printf "$TXT_CONFIG_PATH_UNKNOWN\n" "$game_type"
            sleep 3
            show_server_actions_menu "$server_id"
            return
            ;;
    esac

    if [ ! -f "$config_file" ]; then
        printf "$TXT_CONFIG_NOT_FOUND\n" "$config_file"
        echo "$TXT_HINT_START_SERVER_TO_GENERATE"
        sleep 4
        show_server_actions_menu "$server_id"
        return
    fi

    printf "$TXT_CONFIG_OPENING_NANO\n" "$config_file"
    sleep 1
    nano "$config_file"
    
    show_server_actions_menu "$server_id"
}

function show_settings_menu() {
    local server_id=$1
    local server_path="$SERVERS_DIR/$server_id"
    local game_type=$(grep "GAME_TYPE" "$server_path/server.conf" | cut -d'=' -f2 | tr -d '"')

    case $game_type in
        "minecraft_java" | "minecraft_bedrock")
            show_minecraft_settings_menu "$server_id"
            ;;
        "valheim")
            show_valheim_settings_menu "$server_id"
            ;;
        "7daystodie" | "rust" | "counter-strike2" | "arksa" | "projectzomboid")
            edit_server_config "$server_id"
            ;;
        *)
            printf "$TXT_SETTINGS_UNAVAILABLE\n" "$game_type"
            sleep 2
            show_server_actions_menu "$server_id"
            ;;
    esac
}
function update_server() {
    local server_id=$1
    local server_path="$SERVERS_DIR/$server_id"
    local status=$(get_server_status "$server_path")

    if [[ "$status" == *$TXT_ONLINE* ]]; then
        dialog_msgbox "$TXT_ERROR" "$TXT_UPDATE_SERVER_STOP_HINT"
        show_server_actions_menu "$server_id"
        return
    fi

    local game_type=$(grep "GAME_TYPE" "$server_path/server.conf" | cut -d'=' -f2 | tr -d '"')
    local app_id=$(grep "APP_ID" "$server_path/server.conf" | cut -d'=' -f2 | tr -d '"' 2>/dev/null)

    printf "$TXT_UPDATE_STARTING\n" "$server_id"

    if [ -n "$app_id" ]; then
        # SteamCMD-basiertes Update
        printf "$TXT_UPDATE_STEAMCMD\n" "$app_id"
        local steamcmd_exe="$SCRIPT_DIR/steamcmd/steamcmd.sh"
        local steam_command="$steamcmd_exe +force_install_dir $server_path +login anonymous +app_update $app_id validate +quit"
        eval "$steam_command"
    else
        # Manuelles Update für Nicht-Steam-Spiele
        case $game_type in
            "minecraft_java")
                update_minecraft_java "$server_path"
                ;;
            "minecraft_bedrock")
                update_minecraft_bedrock "$server_path"
                ;;
            *)
                printf "$TXT_UPDATE_PATH_UNKNOWN\n" "$game_type"
                sleep 3
                ;;
        esac
    fi

    printf "$TXT_UPDATE_COMPLETE\n" "$server_id"
    sleep 2
    show_server_actions_menu "$server_id"
}

function manage_backups() {
    local server_id=$1
    
    printf -v title "$TXT_BACKUP_MENU_TITLE" "$server_id"
    local choice=$(dialog_menu "$title" "" \
        "1" "$TXT_BACKUP_CREATE" \
        "2" "$TXT_BACKUP_LIST_RESTORE" \
        "0" "$TXT_BACK_TO_SERVER_MENU")

    case $choice in
        1) create_backup "$server_id" ;;
        2) list_and_restore_backups "$server_id" ;;
        0|*) show_server_actions_menu "$server_id" ;;
    esac
}
function create_backup() {
    local server_id=$1
    local server_path="$SERVERS_DIR/$server_id"
    local backup_dir="$server_path/backups"
    mkdir -p "$backup_dir"

    local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    local backup_file="$backup_dir/backup_${server_id}_${timestamp}.tar.gz"

    printf "$TXT_BACKUP_CREATING\n" "$server_id"
    printf "$TXT_BACKUP_TARGET_FILE\n" "$backup_file"

    # Wir müssen das Backup-Verzeichnis selbst vom Backup ausschließen
    run_with_spinner "$TXT_BACKUP_COMPRESSING" "tar --exclude='$backup_dir' -czf '$backup_file' -C '$SERVERS_DIR' '$server_id'"

    if [ $? -eq 0 ]; then
        echo "$TXT_BACKUP_CREATE_SUCCESS"
    else
        echo "$TXT_BACKUP_CREATE_ERROR"
        rm -f "$backup_file" # Lösche unvollständiges Backup
    fi
    
    sleep 2
    manage_backups "$server_id"
}

function list_and_restore_backups() {
    local server_id=$1
    local server_path="$SERVERS_DIR/$server_id"
    local backup_dir="$server_path/backups"

    if [ ! -d "$backup_dir" ] || [ -z "$(ls -A "$backup_dir" 2>/dev/null)" ]; then
        dialog_msgbox "$TXT_BACKUP_LIST_TITLE" "$(printf "$TXT_BACKUP_NO_BACKUPS_FOUND" "$server_id")"
        manage_backups "$server_id"
        return
    fi

    printf -v title "$TXT_BACKUP_LIST_TITLE" "$server_id"
    
    local backup_options=()
    local backup_files=()
    local count=1
    for file in "$backup_dir"/*.tar.gz; do
        if [ -f "$file" ]; then
            backup_options+=("$count" "$(basename "$file")")
            backup_files+=("$file")
            ((count++))
        fi
    done

    local choice=$(dialog_menu "$title" "" "${backup_options[@]}")

    if [ -n "$choice" ]; then
        local selected_backup="${backup_files[$((choice-1))]}"
        
        local warning_text=$(printf "$TXT_BACKUP_RESTORE_WARNING1\n$TXT_BACKUP_RESTORE_WARNING2\n\n$TXT_BACKUP_RESTORE_WARNING3" "$server_id" "$(basename "$selected_backup")")
        if dialog_yesno "$TXT_BACKUP_LIST_RESTORE" "$warning_text"; then
            (
                echo "0"; echo "# $TXT_BACKUP_RESTORING"; sleep 1
                find "$server_path" -mindepth 1 -maxdepth 1 ! -name "backups" -exec rm -rf {} +
                echo "50"; echo "# Unpacking..."; sleep 1
                tar -xzf "$selected_backup" -C "$SERVERS_DIR"
                echo "100"; echo "# $TXT_BACKUP_RESTORE_SUCCESS"
            ) | dialog --clear --backtitle "Server Forge" --title "$TXT_BACKUP_LIST_RESTORE" --gauge "$TXT_BACKUP_RESTORING" 10 70 0
        else
            dialog_msgbox "$TXT_BACKUP_LIST_RESTORE" "$TXT_BACKUP_RESTORE_CANCELLED"
        fi
    fi
    manage_backups "$server_id"
}
function show_minecraft_settings_menu() {
    local server_id=$1
    local server_path="$SERVERS_DIR/$server_id"
    local config_file="$server_path/server.properties"

    if [ ! -f "$config_file" ]; then
        printf "$TXT_CONFIG_NOT_FOUND\n" "server.properties"
        echo "$TXT_HINT_START_SERVER_TO_GENERATE"
        sleep 3
        show_server_actions_menu "$server_id"
        return
    fi

    # Aktuelle Werte auslesen
    local motd=$(grep "motd=" "$config_file" | cut -d'=' -f2)
    local max_players=$(grep "max-players=" "$config_file" | cut -d'=' -f2)

    printf -v title "$TXT_SETTINGS_MC_TITLE" "$server_id"
    print_header "$title"
    printf "${COLOR_YELLOW}1)${COLOR_NC} $TXT_SETTINGS_MC_MOTD\n" "$motd"
    printf "${COLOR_YELLOW}2)${COLOR_NC} $TXT_SETTINGS_MC_MAX_PLAYERS\n" "$max_players"
    echo -e "${COLOR_YELLOW}0)${COLOR_NC} $TXT_BACK_TO_SERVER_MENU"
    echo
    echo -n "$TXT_PROMPT_CHOICE"

    read -r choice
    case $choice in
        1) change_minecraft_motd "$server_id" ;;
        2) change_minecraft_max_players "$server_id" ;;
        0) show_server_actions_menu "$server_id" ;;
        *) show_minecraft_settings_menu "$server_id" ;;
    esac
}

function change_minecraft_motd() {
    local server_id=$1
    local config_file="$SERVERS_DIR/$server_id/server.properties"
    echo -n "$TXT_SETTINGS_MC_PROMPT_MOTD"
    read -r new_motd
    change_property "$config_file" "motd" "$new_motd"
    echo "$TXT_SETTINGS_MC_SUCCESS_MOTD"
    sleep 1
    show_minecraft_settings_menu "$server_id"
}

function change_minecraft_max_players() {
    local server_id=$1
    local config_file="$SERVERS_DIR/$server_id/server.properties"
    echo -n "$TXT_SETTINGS_MC_PROMPT_MAX_PLAYERS"
    read -r new_max_players
    if [[ "$new_max_players" =~ ^[0-9]+$ ]]; then
        change_property "$config_file" "max-players" "$new_max_players"
        echo "$TXT_SETTINGS_MC_SUCCESS_MAX_PLAYERS"
    else
        echo "$TXT_ERROR_INVALID_NUMBER"
    fi
    sleep 1
    show_minecraft_settings_menu "$server_id"
}
function show_valheim_settings_menu() {
    local server_id=$1
    local config_file="$SERVERS_DIR/$server_id/server.conf"

    # Aktuelle Werte auslesen
    local server_name=$(grep "SERVER_NAME=" "$config_file" | cut -d'=' -f2 | tr -d '"')
    local world_name=$(grep "WORLD_NAME=" "$config_file" | cut -d'=' -f2 | tr -d '"')
    local password=$(grep "PASSWORD=" "$config_file" | cut -d'=' -f2 | tr -d '"')

    printf -v title "$TXT_SETTINGS_VALHEIM_TITLE" "$server_id"
    print_header "$title"
    printf "${COLOR_YELLOW}1)${COLOR_NC} $TXT_SETTINGS_VALHEIM_SERVER_NAME\n" "$server_name"
    printf "${COLOR_YELLOW}2)${COLOR_NC} $TXT_SETTINGS_VALHEIM_WORLD_NAME\n" "$world_name"
    printf "${COLOR_YELLOW}3)${COLOR_NC} $TXT_SETTINGS_VALHEIM_PASSWORD\n" "$password"
    echo -e "${COLOR_YELLOW}0)${COLOR_NC} $TXT_BACK_TO_SERVER_MENU"
    echo
    echo -n "$TXT_PROMPT_CHOICE"

    read -r choice
    case $choice in
        1) change_valheim_setting "$server_id" "SERVER_NAME" "$TXT_SETTINGS_VALHEIM_SERVER_NAME" ;;
        2) change_valheim_setting "$server_id" "WORLD_NAME" "$TXT_SETTINGS_VALHEIM_WORLD_NAME" ;;
        3) change_valheim_setting "$server_id" "PASSWORD" "$TXT_SETTINGS_VALHEIM_PASSWORD" ;;
        0) show_server_actions_menu "$server_id" ;;
        *) show_valheim_settings_menu "$server_id" ;;
    esac
}

function change_valheim_setting() {
    local server_id=$1
    local key=$2
    local prompt=$3
    local config_file="$SERVERS_DIR/$server_id/server.conf"
    
    printf -v prompt_text "$TXT_SETTINGS_GENERIC_PROMPT" "$key"
    echo -n "$prompt_text"
    read -r new_value
    change_property "$config_file" "$key" "\"$new_value\"" # In Anführungszeichen setzen
    printf "$TXT_SETTINGS_GENERIC_SUCCESS\n" "$key"
    sleep 1
    show_valheim_settings_menu "$server_id"
}

function show_rust_settings_menu() {
    local server_id=$1
    local config_file="$SERVERS_DIR/$server_id/server/$server_id/cfg/server.cfg"
    
    echo "$TXT_SETTINGS_RUST_NANO_HINT1"
    echo "$TXT_SETTINGS_RUST_NANO_HINT2"
    sleep 3
    nano "$config_file"
    show_server_actions_menu "$server_id"
}
function update_minecraft_java() {
    local server_path=$1
    printf "$TXT_UPDATE_STARTING\n" "Minecraft (Java)"

    # Server-Informationen von Mojang API abrufen
    echo "$TXT_INSTALL_GETTING_INFO"
    local version_manifest_url=$(wget -qO- https://launchermeta.mojang.com/mc/game/version_manifest.json | grep -oP '"url": "\K[^"]+' | head -1)
    local latest_version_url=$(wget -qO- $version_manifest_url | grep -oP '"url": "\K[^"]+' | head -1)
    local server_jar_url=$(wget -qO- $latest_version_url | grep -oP '"server": {"sha1": "[^"]+", "size": \d+, "url": "\K[^"]+')
    local latest_version=$(wget -qO- $version_manifest_url | grep -oP '"latest": {"release": "\K[^"]+')
    
    local current_version=$(grep "SERVER_VERSION" "$server_path/server.conf" | cut -d'=' -f2 | tr -d '"')

    if [ "$current_version" == "$latest_version" ]; then
        printf "$TXT_UPDATE_ALREADY_LATEST\n" "$latest_version"
        return
    fi

    printf "$TXT_INSTALL_LATEST_VERSION. Aktualisiere von %s.\n" "$latest_version" "$current_version"
    
    # Neue server.jar herunterladen
    download_with_progress "$server_jar_url" "$server_path/server.jar.new"
    if [ $? -ne 0 ]; then
        echo "$TXT_INSTALL_ERROR"
        rm -f "$server_path/server.jar.new"
        return
    fi

    # Alte jar ersetzen und Versionsnummer aktualisieren
    mv "$server_path/server.jar.new" "$server_path/server.jar"
    change_property "$server_path/server.conf" "SERVER_VERSION" "\"$latest_version\""
    echo "$TXT_OK"
}

function update_minecraft_bedrock() {
    local server_path=$1
    printf "$TXT_UPDATE_STARTING\n" "Minecraft (Bedrock)"

    # Download-URL von der offiziellen Seite extrahieren
    local bedrock_server_url=$(wget -qO- https://www.minecraft.net/en-us/download/server/bedrock | grep -oP 'https://minecraft.azureedge.net/bin-linux/[^"]+' | head -n 1)
    
    local temp_dir=$(mktemp -d)
    local server_archive="$temp_dir/bedrock-server.zip"

    # Neues Archiv herunterladen
    download_with_progress "$bedrock_server_url" "$server_archive"
    if [ $? -ne 0 ]; then
        echo "$TXT_INSTALL_ERROR"
        rm -rf "$temp_dir"
        return
    fi

    # Entpacken und kopieren, ohne Welten und Konfigs zu überschreiben
    unzip -o "$server_archive" -d "$server_path" -x "*server.properties*" "*permissions.json*" "*worlds/*"
    rm -rf "$temp_dir"
    echo "$TXT_OK"
}