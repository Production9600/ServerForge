#!/bin/bash
################################
# Server - Forge               #
# Programiert Gerhard Pfeiffer #
# Version 1.3.0                #
# (c) Gerhard Pfeiffer         #
################################

# Modul: options.sh
# Enthält alle Optionsfunktionen für Server Forge
# Sprachauswahl
function change_language() {
    local choice=$(dialog_menu "$TXT_OPTIONS_CHANGE_LANG" "" \
        "de" "Deutsch" \
        "en" "English" \
        "it" "Italiano" \
        "pl" "Polski" \
        "hr" "Hrvatski" \
        "es" "Español")

    if [ -n "$choice" ]; then
        set_language "$choice"
    else
        show_options_menu
    fi
}

# Sprache setzen und Skript neu starten
function set_language() {
    local lang=$1
    change_property "$CONFIG_FILE" "LANGUAGE" "$lang"
    dialog_msgbox "$TXT_OPTIONS_CHANGE_LANG" "Language set to '$lang'.\nRestarting script to apply changes..."
    # Das Skript mit sich selbst neu ausführen
    exec "$SCRIPT_DIR/server-forge.sh"
}

# Pfade verwalten
function manage_paths() {
    print_header "$TXT_OPTIONS_PATH_TITLE"
    printf "$TXT_OPTIONS_PATH_CURRENT\n" "$SERVERS_DIR"
    echo
    echo -e "${COLOR_YELLOW}1)${COLOR_NC} $TXT_OPTIONS_PATH_CHANGE"
    echo -e "${COLOR_YELLOW}0)${COLOR_NC} $TXT_BACK"
    echo
    echo -n "$TXT_PROMPT_CHOICE"
    
    read -r choice
    case $choice in
        1) change_install_path ;;
        0) show_options_menu ;;
        *) manage_paths ;;
    esac
}

# Installationspfad ändern
function change_install_path() {
    print_header "$TXT_OPTIONS_PATH_CHANGE_TITLE"
    printf "$TXT_OPTIONS_PATH_CURRENT\n" "$SERVERS_DIR"
    echo -n "$TXT_OPTIONS_PATH_PROMPT_NEW"
    read -r new_path
    
    if [ -z "$new_path" ]; then
        echo "$TXT_OPTIONS_PATH_ERROR_INVALID"
        sleep 1
        manage_paths
        return
    fi
    
    # Pfad erweitern, wenn er relativ ist
    if [[ "$new_path" != /* ]]; then
        new_path="$SCRIPT_DIR/$new_path"
    fi
    
    # Prüfen, ob das Verzeichnis existiert
    if [ ! -d "$new_path" ]; then
        printf "$TXT_OPTIONS_PATH_PROMPT_CREATE" "$TXT_YES_NO"
        read -r create_dir
        if [ "$create_dir" = "j" ] || [ "$create_dir" = "J" ]; then
            mkdir -p "$new_path" || {
                echo "$TXT_OPTIONS_PATH_ERROR_CREATE";
                sleep 1;
                manage_paths;
                return;
            }
        else
            manage_paths
            return
        fi
    fi
    
    # Alte Server verschieben, falls vorhanden
    if [ "$(ls -A "$SERVERS_DIR" 2>/dev/null)" ]; then
        printf "$TXT_OPTIONS_PATH_PROMPT_MOVE" "$TXT_YES_NO"
        read -r move_servers
        if [ "$move_servers" = "j" ] || [ "$move_servers" = "J" ]; then
            mv "$SERVERS_DIR"/* "$new_path/" 2>/dev/null
            if [ $? -ne 0 ]; then
                echo "$TXT_OPTIONS_PATH_ERROR_MOVE"
                sleep 1
                manage_paths
                return
            fi
        fi
    fi
    
    # Konfiguration aktualisieren
    echo "SERVERS_DIR=\"$new_path\"" > "$CONFIG_DIR/paths.conf"
    source "$CONFIG_DIR/paths.conf"
    
    echo "$TXT_OPTIONS_PATH_SUCCESS"
    sleep 1
    manage_paths
}

# FTP-Einstellungen
function ftp_settings() {
    print_header "$TXT_OPTIONS_FTP_TITLE"
    
    # Prüfen, ob vsftpd installiert ist
    if ! command -v vsftpd &> /dev/null; then
        echo "$TXT_OPTIONS_FTP_NOT_INSTALLED"
        printf "$TXT_OPTIONS_FTP_PROMPT_INSTALL" "$TXT_YES_NO"
        read -r install_ftp
        if [ "$install_ftp" == "j" ]; then
            # Installationsbefehl für Debian/Ubuntu. Muss für andere Distros angepasst werden.
            run_with_spinner "$TXT_OPTIONS_FTP_INSTALLING" "sudo apt-get update && sudo apt-get install -y vsftpd"
            if [ $? -ne 0 ]; then
                echo "$TXT_OPTIONS_FTP_ERROR_INSTALL"
                sleep 2
                show_options_menu
                return
            fi
        else
            show_options_menu
            return
        fi
    fi

    echo "$TXT_OPTIONS_FTP_INSTALLED"
    echo -e "${COLOR_YELLOW}1)${COLOR_NC} $TXT_OPTIONS_FTP_MANAGE_USER"
    echo -e "${COLOR_YELLOW}2)${COLOR_NC} $TXT_OPTIONS_FTP_EDIT_CONFIG"
    echo -e "${COLOR_YELLOW}3)${COLOR_NC} $TXT_OPTIONS_FTP_RESTART"
    echo -e "${COLOR_YELLOW}0)${COLOR_NC} $TXT_OPTIONS_FTP_BACK"
    echo
    echo -n "$TXT_PROMPT_CHOICE"

    read -r choice
    case $choice in
        1) manage_ftp_user ;;
        2) sudo nano /etc/vsftpd.conf ;;
        3) run_with_spinner "Starte FTP-Server neu..." "sudo systemctl restart vsftpd" ;;
        0) ;;
    esac
    
    show_options_menu
}
function manage_ftp_user() {
    local ftp_user="serverforge"

    print_header "$TXT_OPTIONS_FTP_USER_TITLE"
    
    if ! id "$ftp_user" &>/dev/null; then
        printf "$TXT_OPTIONS_FTP_USER_NOT_EXISTS\n" "$ftp_user"
        printf "$TXT_OPTIONS_FTP_USER_PROMPT_CREATE" "$TXT_YES_NO"
        read -r create_user
        if [ "$create_user" == "j" ]; then
            # Benutzer ohne Login-Shell erstellen, Heimatverzeichnis ist das Server-Verzeichnis
            sudo adduser --home "$SERVERS_DIR" --no-create-home --shell /usr/sbin/nologin "$ftp_user"
            printf "$TXT_OPTIONS_FTP_USER_CREATED\n" "$ftp_user"
            echo "$TXT_OPTIONS_FTP_USER_PROMPT_PASSWORD"
            sudo passwd "$ftp_user"
        fi
    else
        printf "$TXT_OPTIONS_FTP_USER_EXISTS\n" "$ftp_user"
        printf "$TXT_OPTIONS_FTP_USER_HINT_PATH\n" "$SERVERS_DIR"
        echo
        printf "${COLOR_YELLOW}1)${COLOR_NC} $TXT_OPTIONS_FTP_USER_CHANGE_PW\n" "$ftp_user"
        echo -e "${COLOR_YELLOW}0)${COLOR_NC} $TXT_BACK"
        echo
        echo -n "$TXT_PROMPT_CHOICE"
        read -r choice
        if [ "$choice" -eq 1 ]; then
            sudo passwd "$ftp_user"
        fi
    fi

    echo
    echo "$TXT_OPTIONS_FTP_USER_CHROOT_HINT1"
    echo "$TXT_OPTIONS_FTP_USER_CHROOT_HINT2"
    echo
    echo "$TXT_PRESS_ANY_KEY"
    read -n 1 -s -r
}