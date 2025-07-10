# Server Forge

Ein umfassendes Bash-Skript zur einfachen Installation, Verwaltung und Wartung verschiedener dedizierter Spieleserver.

## Funktionen

- **Modulares Design:** Leicht erweiterbar für neue Spiele und Funktionen.
- **Interaktive Menüs:** Eine benutzerfreundliche, farbige und menügesteuerte Oberfläche für alle Operationen.
- **Multi-Game-Unterstützung:** Installieren und verwalten Sie mehrere Serverinstanzen für verschiedene Spiele.
- **Server-Verwaltung:**
  - Starten, Stoppen und Neustarten von Servern.
  - Verbinden mit der Live-Serverkonsole.
  - Einsehen von Server-Logs.
  - Aktualisieren von Servern (SteamCMD-Spiele und Minecraft).
  - Erstellen und Wiederherstellen von Backups für jede Serverinstanz.
- **Konfiguration:**
  - Bearbeiten von rohen Server-Konfigurationsdateien direkt aus dem Menü.
  - Benutzerfreundliche Einstellungsmenüs für bestimmte Spiele (Minecraft, Valheim).
- **FTP-Server-Integration:**
  - Installiert `vsftpd`, falls nicht vorhanden.
  - Verwaltet einen dedizierten, "eingesperrten" FTP-Benutzer für sicheren und einfachen Dateizugriff auf alle Serverinstanzen.
- **Plattformübergreifender Installer:** Ein intelligenter Installer, der das Betriebssystem erkennt und den passenden Paketmanager (`apt`, `dnf`, `yum`, `pacman`, `zypper`) verwendet, um alle Abhängigkeiten zu installieren.

## Unterstützte Spiele

- Minecraft (Java Edition)
- Minecraft (Bedrock Edition)
- 7 Days to Die
- Valheim
- ARK: Survival Ascended
- Rust
- Counter-Strike 2
- Project Zomboid

## Installation

Um Server Forge zu installieren, laden Sie das Skript `install_server_forge.sh` aus diesem Repository herunter und führen Sie es mit `sudo` aus.

**1. Installer herunterladen**

Sie können `wget` verwenden, um das Skript direkt herunterzuladen.
*Hinweis: Denken Sie daran, die URL durch die tatsächliche Raw-Datei-URL aus Ihrem GitHub-Repository zu ersetzen.*

```bash
wget https://raw.githubusercontent.com/user/ServerForge/main/install_server_forge.sh
```

**2. Installer ausführen**

Führen Sie das Skript mit `sudo` aus, um die systemweite Installation von Abhängigkeiten und Befehlen zu ermöglichen.

```bash
sudo bash install_server_forge.sh
```

Der Installer wird:
1.  Auf `sudo`-Rechte prüfen.
2.  Den Paketmanager Ihres Betriebssystems erkennen.
3.  Alle erforderlichen Abhängigkeiten installieren (`git`, `wget`, `pv`, `screen`, etc.).
4.  Das Server Forge-Repository nach `/opt/server-forge` klonen.
5.  Die notwendigen Berechtigungen setzen.
6.  Einen symbolischen Link nach `/usr/local/bin` erstellen, damit Sie das Skript von überall aus ausführen können.

## Benutzung

Nach einer erfolgreichen Installation können Sie Server Forge von jedem Verzeichnis aus mit folgendem Befehl starten:

```bash
server-forge
```

Dies startet das Hauptmenü, von wo aus Sie mit der Verwaltung Ihrer Spieleserver beginnen können.