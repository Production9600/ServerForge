#!/bin/bash
################################
# Server - Forge               #
# Programiert Gerhard Pfeiffer #
# Version 1.3.0                #
# (c) Gerhard Pfeiffer         #
################################

# Modul: helpers.sh
# Enthält Hilfsfunktionen für Server Forge
# Führt einen Befehl mit einem Spinner aus und zeigt das Ergebnis an.
# Verwendung: run_with_spinner "Nachricht" "Befehl"
function run_with_spinner() {
    local message=$1
    local command_to_run=$2
    local pid
    local spinner="-\|/"
    local i=0

    # Nachricht ohne Zeilenumbruch ausgeben
    echo -n "$message "

    # Befehl im Hintergrund ausführen und Ausgabe umleiten
    eval "$command_to_run" &> /dev/null &
    pid=$!

    # Spinner anzeigen, während der Befehl läuft
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        echo -ne "\r$message ${spinner:$i:1}"
        sleep 0.1
    done

    # Auf das Ende des Befehls warten und den Exit-Code abrufen
    wait $pid
    local exit_code=$?

    # Ergebnis basierend auf dem Exit-Code anzeigen
    if [ $exit_code -eq 0 ]; then
        echo -e "\r$message [\e[32mOK\e[0m]      "
    else
        echo -e "\r$message [${COLOR_RED}$TXT_ERROR${COLOR_NC}]"
    fi

    return $exit_code
}
# Lädt eine Datei von einer URL mit einer Fortschrittsanzeige herunter.
# Benötigt 'pv' und 'wget'.
# Verwendung: download_with_progress "URL" "Zieldatei"
function download_with_progress() {
    local url=$1
    local destination_file=$2

    printf "$TXT_INSTALL_DOWNLOADING\n" "$url" ""

    # Dateigröße vorab ermitteln
    local file_size=$(wget --spider "$url" 2>&1 | grep "Length" | awk '{print $2}')

    # Prüfen, ob die Dateigröße ermittelt werden konnte
    if [[ "$file_size" =~ ^[0-9]+$ ]] && [ "$file_size" -gt 0 ]; then
        # Mit Prozentanzeige, wenn Größe bekannt ist
        wget -qO- "$url" | pv -lep -s "$file_size" > "$destination_file"
    else
        # Ohne Prozentanzeige (nur Spinner), wenn Größe unbekannt ist
        echo "File size unknown, showing simple progress."
        wget -qO- "$url" | pv -lep > "$destination_file"
    fi
    
    # Exit-Codes sicher abrufen
    local wget_ec=${PIPESTATUS[0]}
    local pv_ec=${PIPESTATUS[1]}

    # Sicherstellen, dass die Variablen nicht leer sind, bevor sie numerisch verglichen werden.
    [ -z "$wget_ec" ] && wget_ec=1
    [ -z "$pv_ec" ] && pv_ec=1

    if [ "$wget_ec" -eq 0 ] && [ "$pv_ec" -eq 0 ] && [ -s "$destination_file" ]; then
        return 0
    else
        echo
        printf "${COLOR_RED}$TXT_ERROR_DOWNLOAD_FAILED${COLOR_NC}\n" "$wget_ec" "$pv_ec"
        # Im Fehlerfall die unvollständige Datei löschen
        rm -f "$destination_file"
        return 1
    fi
}
# Stellt sicher, dass SteamCMD vorhanden ist.
function ensure_steamcmd_installed() {
    local steamcmd_exe="$SCRIPT_DIR/steamcmd/steamcmd.sh"

    if [ ! -f "$steamcmd_exe" ]; then
        echo -e "${COLOR_RED}$TXT_STEAMCMD_NOT_FOUND${COLOR_NC}"
        echo "$TXT_STEAMCMD_HINT_RERUN_INSTALLER"
        sleep 4
        return 1
    fi
    return 0
}
# Installiert ein Steam-Spiel mit einer gegebenen App-ID.
# Verwendung: install_steam_game "Spielname" "App-ID" ["Zusätzliche Parameter"]
function install_steam_game() {
    local game_name=$1
    local app_id=$2
    local extra_params=$3
    local steamcmd_exe="$SCRIPT_DIR/steamcmd/steamcmd.sh"

    clear
    printf -v title "$TXT_INSTALL_TITLE" "$game_name"
    print_header "$title"

    # SteamCMD sicherstellen
    ensure_steamcmd_installed || { sleep 2; show_install_menu; return; }
    echo

    # Eindeutige Server-ID generieren
    local i=1
    local game_id_safe=$(echo "$game_name" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]' | tr -d ':')
    while [ -d "$SERVERS_DIR/${game_id_safe}_$i" ]; do
        i=$((i+1))
    done
    local server_id="${game_id_safe}_$i"
    local server_path="$SERVERS_DIR/$server_id"

    printf "$TXT_INSTALL_PATH\n" "$server_path"
    mkdir -p "$server_path"

    # Serverdateien herunterladen
    # Serverdateien mit gefilterter Fortschrittsanzeige herunterladen
    local steam_command="$steamcmd_exe +force_install_dir $server_path +login anonymous +app_update $app_id $extra_params +quit"
    local log_file="/tmp/steamcmd_install.log"

    printf "$TXT_STEAMCMD_DOWNLOADING\n" "$game_name" "$app_id"
    
    # Starte den Filter im Hintergrund
    (tail -f "$log_file" 2>/dev/null &) | grep --line-buffered -oP 'progress: \K[0-9.]+' | while read -r progress; do
        printf "\r${COLOR_YELLOW}$TXT_STEAMCMD_PROGRESS${COLOR_NC}   " "$progress"
    done &
    local filter_pid=$!

    # Führe den eigentlichen Befehl aus und leite die Ausgabe in die Log-Datei
    eval "$steam_command" > "$log_file" 2>&1
    local exit_code=$?

    # Beende den Hintergrund-Filterprozess
    kill $filter_pid
    wait $filter_pid 2>/dev/null
    
    echo # Finale neue Zeile

    if [ "$exit_code" -ne 0 ]; then
        dialog --clear --backtitle "Server Forge" --title "$TXT_ERROR" --textbox "$log_file" 20 80
        rm -rf "$server_path"
        show_install_menu
        return
    fi
    echo

    # server.conf erstellen
    echo "$TXT_INSTALL_CREATING_CONF"
    cat > "$server_path/server.conf" <<EOL
# Server Forge Konfiguration
GAME_TYPE="$game_id_safe"
SERVER_ID="$server_id"
APP_ID="$app_id"
EOL

    # Spiel-spezifische Standard-Startparameter hinzufügen
    case $game_id_safe in
        "valheim")
            cat >> "$server_path/server.conf" <<EOL
# Valheim Startparameter
SERVER_NAME="My Valheim Server"
WORLD_NAME="Dedicated"
PASSWORD="secret"
PORT="2456"
EOL
            ;;
        "7daystodie")
            # Keine zusätzlichen Parameter mehr, da wir die XML direkt bearbeiten.
            ;;
        "rust")
            # Rust-Parameter für server.cfg
            local rust_cfg_dir="$server_path/server/${server_id}"
            mkdir -p "$rust_cfg_dir/cfg"
            cat > "$rust_cfg_dir/cfg/server.cfg" <<EOL
server.hostname "My Rust Server"
server.port 28015
server.identity "${server_id}"
server.level "Procedural Map"
server.seed 12345
server.worldsize 3000
server.maxplayers 10
server.saveinterval 300
EOL
            ;;
        "counter-strike2")
            mkdir -p "$server_path/game/csgo/cfg"
            cat > "$server_path/game/csgo/cfg/server.cfg" <<EOL
hostname "My CS2 Server"
sv_cheats 0
sv_lan 0
EOL
            ;;
        "projectzomboid")
            # Project Zomboid erstellt seine INI-Datei beim ersten Start.
            # Wir können hier eine Vorlage erstellen, falls gewünscht.
            # Vorerst verlassen wir uns auf die automatische Erstellung.
            ;;
        "arksa")
            # ARK erstellt seine INI-Dateien ebenfalls beim ersten Start.
            # Wir können hier eine Vorlage erstellen, falls gewünscht.
            ;;
    esac
    echo "$TXT_INSTALL_CONF_CREATED"
    echo

    printf "$TXT_INSTALL_SUCCESS\n" "$server_id"
    echo "$TXT_INSTALL_MANAGE_HINT"
    echo
    echo "$TXT_PRESS_ANY_KEY"
    read -n 1 -s -r
    show_install_menu
}
# Überprüft den Status eines Servers anhand seiner PID-Datei.
# Gibt "ONLINE" oder "OFFLINE" zurück.
# Verwendung: get_server_status "server_path"
function get_server_status() {
    local server_path=$1
    local pid_file="$server_path/.server.pid"

    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        # Prüft, ob ein Prozess mit dieser PID existiert
        if ps -p $pid > /dev/null; then
            echo -e "${COLOR_GREEN}$TXT_ONLINE${COLOR_NC}"
        else
            # Die PID-Datei ist verwaist, also entfernen wir sie
            rm "$pid_file"
            echo -e "${COLOR_RED}$TXT_OFFLINE${COLOR_NC}"
        fi
    else
        echo -e "${COLOR_RED}$TXT_OFFLINE${COLOR_NC}"
    fi
}
# Ändert einen Wert in einer Java-Properties-Datei.
# Verwendung: change_property "datei.properties" "schlüssel" "neuer_wert"
function change_property() {
    local file=$1
    local key=$2
    local value=$3

    # Wenn der Schlüssel bereits existiert, ersetze die Zeile.
    if grep -q "^$key=" "$file"; then
        sed -i "s/^$key=.*/$key=$value/" "$file"
    # Sonst füge den Schlüssel am Ende der Datei hinzu.
    else
        echo "$key=$value" >> "$file"
    fi
}
# --- Farb- und Design-Funktionen ---

# Farbvariablen
COLOR_BLUE='\033[1;34m'
COLOR_GREEN='\033[1;32m'
COLOR_RED='\033[1;31m'
COLOR_YELLOW='\033[1;33m'
COLOR_NC='\033[0m' # No Color

# Druckt einen standardisierten, farbigen Header
# Verwendung: print_header "Titel des Menüs"
function print_header() {
    local title=$1
    clear
    echo -e "${COLOR_BLUE}==============================================================${COLOR_NC}"
    echo -e "${COLOR_BLUE}== ${title} ${COLOR_NC}"
    echo -e "${COLOR_BLUE}==============================================================${COLOR_NC}"
    echo
}
# --- TUI (dialog) Funktionen ---

# Zeigt ein Menü mit dialog an und gibt die Auswahl zurück.
# Verwendung: dialog_menu "Titel" "Text" "Menüoption1" "Beschreibung1" "Menüoption2" "Beschreibung2" ...
function dialog_menu() {
    local title="$1"
    local text="$2"
    shift 2
    local options=("$@")
    
    dialog --clear --backtitle "Server Forge" --title "$title" --menu "$text" 15 60 8 "${options[@]}" 2>&1 >/dev/tty
}

# Zeigt eine Nachrichtenbox an.
# Verwendung: dialog_msgbox "Titel" "Text"
function dialog_msgbox() {
    local title="$1"
    local text="$2"
    dialog --clear --backtitle "Server Forge" --title "$title" --msgbox "$text" 8 50
}

# Zeigt eine Ja/Nein-Box an.
# Verwendung: dialog_yesno "Titel" "Text"
function dialog_yesno() {
    local title="$1"
    local text="$2"
    dialog --clear --backtitle "Server Forge" --title "$title" --yesno "$text" 8 50
    return $?
}

# Zeigt eine Input-Box an und gibt die Eingabe zurück.
# Verwendung: dialog_inputbox "Titel" "Text" "Standardwert"
function dialog_inputbox() {
    local title="$1"
    local text="$2"
    local init="$3"
    dialog --clear --backtitle "Server Forge" --title "$title" --inputbox "$text" 8 50 "$init" 2>&1 >/dev/tty
}