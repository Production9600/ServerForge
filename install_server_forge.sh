#!/bin/bash
################################
# Server - Forge               #
# Programiert Gerhard Pfeiffer #
# Version 1.3.0                #
# (c) Gerhard Pfeiffer         #
################################

# Installationsskript für Server Forge V3

# --- Konfiguration ---
GIT_REPO_URL="https://github.com/Production9600/ServerForge.git"
INSTALL_DIR="/opt/server-forge"
SYMLINK_PATH="/usr/local/bin/server-forge"
LOG_FILE="/tmp/server_forge_install.log"

# --- Farben ---
COLOR_BLUE='\033[1;34m'
COLOR_GREEN='\033[1;32m'
COLOR_RED='\033[1;31m'
COLOR_YELLOW='\033[1;33m'
COLOR_NC='\033[0m'

# --- Sprachdefinitionen direkt im Skript ---
load_translations() {
    case $1 in
        de)
            TXT_WAIT="Bitte warten, Server Forge wird eingerichtet..."
            TXT_LOG_HINT="Ein detailliertes Log wird nach '%s' geschrieben."
            TXT_SUCCESS_TITLE="Server Forge wurde erfolgreich installiert!"
            TXT_SUCCESS_HINT="Sie können das Skript nun von überall mit dem Befehl aufrufen:"
            TXT_ERROR_TITLE="Ein Fehler ist bei der Installation aufgetreten."
            TXT_ERROR_HINT="Bitte überprüfen Sie die Log-Datei für weitere Details:"
            ;;
        it)
            TXT_WAIT="Attendere prego, Server Forge è in fase di configurazione..."
            TXT_LOG_HINT="Un registro dettagliato verrà scritto in '%s'."
            TXT_SUCCESS_TITLE="Server Forge è stato installato con successo!"
            TXT_SUCCESS_HINT="Ora puoi eseguire lo script da qualsiasi luogo con il comando:"
            TXT_ERROR_TITLE="Si è verificato un errore durante l'installazione."
            TXT_ERROR_HINT="Controlla il file di registro per maggiori dettagli:"
            ;;
        pl)
            TXT_WAIT="Proszę czekać, trwa konfigurowanie Server Forge..."
            TXT_LOG_HINT="Szczegółowy dziennik zostanie zapisany w '%s'."
            TXT_SUCCESS_TITLE="Server Forge został pomyślnie zainstalowany!"
            TXT_SUCCESS_HINT="Możesz teraz uruchomić skrypt z dowolnego miejsca za pomocą polecenia:"
            TXT_ERROR_TITLE="Wystąpił błąd podczas instalacji."
            TXT_ERROR_HINT="Sprawdź plik dziennika, aby uzyskać więcej szczegółów:"
            ;;
        hr)
            TXT_WAIT="Molimo pričekajte, Server Forge se postavlja..."
            TXT_LOG_HINT="Detaljan zapisnik bit će zapisan u '%s'."
            TXT_SUCCESS_TITLE="Server Forge je uspješno instaliran!"
            TXT_SUCCESS_HINT="Sada možete pokrenuti skriptu s bilo kojeg mjesta pomoću naredbe:"
            TXT_ERROR_TITLE="Došlo je do pogreške tijekom instalacije."
            TXT_ERROR_HINT="Provjerite datoteku zapisnika za više detalja:"
            ;;
        es)
            TXT_WAIT="Por favor espere, Server Forge se está configurando..."
            TXT_LOG_HINT="Se escribirá un registro detallado en '%s'."
            TXT_SUCCESS_TITLE="¡Server Forge se ha instalado correctamente!"
            TXT_SUCCESS_HINT="Ahora puede ejecutar el script desde cualquier lugar con el comando:"
            TXT_ERROR_TITLE="Ocurrió un error durante la instalación."
            TXT_ERROR_HINT="Consulte el archivo de registro para obtener más detalles:"
            ;;
        *) # Fallback auf Englisch
            TXT_WAIT="Please wait, Server Forge is being set up..."
            TXT_LOG_HINT="A detailed log will be written to '%s'."
            TXT_SUCCESS_TITLE="Server Forge has been installed successfully!"
            TXT_SUCCESS_HINT="You can now run the script from anywhere with the command:"
            TXT_ERROR_TITLE="An error occurred during installation."
            TXT_ERROR_HINT="Please check the log file for more details:"
            ;;
    esac
}

# Funktion, die alle Installationsschritte im Hintergrund ausführt
run_installation() {
    exec > "$LOG_FILE" 2>&1
    echo "=== Installation Log for Server Forge ==="; date
    PACKAGES="git wget pv unzip screen nano openjdk-17-jre-headless dialog apache2 php libapache2-mod-php mariadb-server php-mysql"
    if command -v apt-get &> /dev/null; then
        dpkg --add-architecture i386; apt-get update -y; apt-get install -y $PACKAGES lib32gcc-s1
    elif command -v dnf &> /dev/null; then
        dnf install -y $PACKAGES glibc.i686 libstdc++.i686
    elif command -v yum &> /dev/null; then
        yum install -y $PACKAGES glibc.i686 libstdc++.i686
    elif command -v pacman &> /dev/null; then
        pacman -Syu --noconfirm $PACKAGES lib32-gcc-libs
    elif command -v zypper &> /dev/null; then
        zypper install -y $PACKAGES libgcc_s1-32bit
    else
        echo "Error: Could not find a supported package manager." >&2; exit 1
    fi
    rm -rf "$INSTALL_DIR"; git clone "$GIT_REPO_URL" "$INSTALL_DIR"
    STEAMCMD_DIR="$INSTALL_DIR/steamcmd"; mkdir -p "$STEAMCMD_DIR"
    wget -qO "$STEAMCMD_DIR/steamcmd_linux.tar.gz" "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
    tar -xzf "$STEAMCMD_DIR/steamcmd_linux.tar.gz" -C "$STEAMCMD_DIR"; rm "$STEAMCMD_DIR/steamcmd_linux.tar.gz"
    bash "$STEAMCMD_DIR/steamcmd.sh" +quit
    chmod +x "$INSTALL_DIR/server-forge.sh"
    ln -sf "$INSTALL_DIR/server-forge.sh" "$SYMLINK_PATH"
}

# --- Hauptskript ---
if [ "$EUID" -ne 0 ]; then 
  echo -e "${COLOR_RED}Error: Please run this script with sudo or as root.${COLOR_NC}"
  exit 1
fi

clear
echo "Please select a language for the installation:"
echo "1) English (default)"
echo "2) Deutsch"
echo "3) Italiano"
echo "4) Polski"
echo "5) Hrvatski"
echo "6) Español"
echo -n "Choice: "
read -r lang_choice

case $lang_choice in
    2) lang="de" ;;
    3) lang="it" ;;
    4) lang="pl" ;;
    5) lang="hr" ;;
    6) lang="es" ;;
    *) lang="en" ;;
esac

load_translations "$lang"

clear
echo -e "${COLOR_BLUE}${TXT_WAIT}${COLOR_NC}"
printf "${TXT_LOG_HINT}\n" "$LOG_FILE"

run_installation &
pid=$!
spinner="-\|/"
i=0
while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) %4 )); echo -ne "\r[${spinner:$i:1}]"; sleep 0.1
done

wait $pid
exit_code=$?

clear
if [ $exit_code -eq 0 ]; then
    echo -e "${COLOR_GREEN}=====================================================${COLOR_NC}"
    echo -e "${COLOR_GREEN}  ${TXT_SUCCESS_TITLE}        ${COLOR_NC}"
    echo -e "${COLOR_GREEN}=====================================================${COLOR_NC}"
    echo; echo "${TXT_SUCCESS_HINT}"; echo
    echo -e "  ${COLOR_YELLOW}server-forge${COLOR_NC}"; echo
else
    echo -e "${COLOR_RED}=====================================================${COLOR_NC}"
    echo -e "${COLOR_RED}  ${TXT_ERROR_TITLE}   ${COLOR_NC}"
    echo -e "${COLOR_RED}=====================================================${COLOR_NC}"
    echo; echo "${TXT_ERROR_HINT}"; echo
    echo -e "  ${COLOR_YELLOW}cat $LOG_FILE${COLOR_NC}"; echo
fi