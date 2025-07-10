#!/bin/bash
################################
# Server - Forge               #
# Programiert Gerhard Pfeiffer #
# Version 1.3.0                #
# (c) Gerhard Pfeiffer         #
################################

# Modul: web.sh
# Enthält die Funktionalität zur Verwaltung des Webservers.

function show_web_menu() {
    local status
    if systemctl is-active --quiet apache2; then
        status="${COLOR_GREEN}$TXT_ONLINE${COLOR_NC}"
    else
        status="${COLOR_RED}$TXT_OFFLINE${COLOR_NC}"
    fi

    printf -v status_text "$TXT_WEB_STATUS" "$status"
    local choice=$(dialog_menu "$TXT_WEB_MENU_TITLE" "$status_text" \
        "1" "$TXT_WEB_START" \
        "2" "$TXT_WEB_STOP" \
        "3" "$TXT_WEB_RESTART" \
        "4" "$TXT_WEB_INSTALL_DEMO" \
        "0" "$TXT_BACK")

    case $choice in
        1) run_with_spinner "$TXT_WEB_START..." "sudo systemctl start apache2"; show_web_menu ;;
        2) run_with_spinner "$TXT_WEB_STOP..." "sudo systemctl stop apache2"; show_web_menu ;;
        3) run_with_spinner "$TXT_WEB_RESTART..." "sudo systemctl restart apache2"; show_web_menu ;;
        4) install_demo_page ;;
        0|*) show_main_menu ;;
    esac
}

function install_demo_page() {
    local web_root="/var/www/html"
    local source_dir="$SCRIPT_DIR/../web_content"

    printf -v confirm_text "$TXT_WEB_DEMO_CONFIRM" "$web_root"
    if dialog_yesno "$TXT_WEB_INSTALL_DEMO" "$confirm_text"; then
        (
            echo "0"; echo "# Copying web application files..."; sleep 1
            # Ensure the web root is clean and exists
            sudo rm -rf "$web_root"/*
            sudo mkdir -p "$web_root"
            # Copy the entire application, excluding the old assets dir if it exists
            sudo rsync -a --exclude 'assets' "$source_dir/" "$web_root/"
            # Set correct permissions for the web server
            sudo chown -R www-data:www-data "$web_root"
            sudo find "$web_root" -type d -exec chmod 755 {} \;
            sudo find "$web_root" -type f -exec chmod 644 {} \;
            echo "100"; echo "# Deployment complete."
        ) | dialog --clear --backtitle "Server Forge" --title "$TXT_WEB_INSTALL_DEMO" --gauge "..." 10 70 0
        
        printf -v success_text "$TXT_WEB_DEMO_SUCCESS" "$web_root"
        local final_message="$success_text\nPlease configure your database in $web_root/config.php and run $web_root/setup.php, then delete setup.php.\n\nIMPORTANT: This script does NOT manage domain names or DNS settings."
        dialog_msgbox "$TXT_OK" "$final_message"
    fi
    show_web_menu
}