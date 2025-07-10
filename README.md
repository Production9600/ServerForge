# Server Forge

A comprehensive bash script to install, manage, and maintain various dedicated game servers with ease.

## Features

- **Modular Design:** Easily extendable for new games and features.
- **Interactive Menus:** A user-friendly, colorful, menu-driven interface for all operations.
- **Multi-Game Support:** Install and manage multiple server instances for various games.
- **Server Management:**
  - Start, stop, and restart servers.
  - Attach to the live server console.
  - View server logs.
  - Update servers (SteamCMD games and Minecraft).
  - Create and restore backups for each server instance.
- **Configuration:**
  - Edit raw server config files directly from the menu.
  - User-friendly settings menus for specific games (Minecraft, Valheim).
- **FTP Server Integration:**
  - Install `vsftpd` if not present.
  - Manage a dedicated, jailed FTP user for secure and easy file access to all server instances.
- **Cross-Platform Installer:** A smart installer that detects the OS and uses the appropriate package manager (`apt`, `dnf`, `yum`, `pacman`, `zypper`) to install all dependencies.

## Supported Games

- Minecraft (Java Edition)
- Minecraft (Bedrock Edition)
- 7 Days to Die
- Valheim
- ARK: Survival Ascended
- Rust
- Counter-Strike 2
- Project Zomboid

## Installation

To install Server Forge, download the `install_server_forge.sh` script from this repository and run it with `sudo`.

**1. Download the Installer**

You can use `wget` to download the script directly.
*Note: Remember to replace the URL with the actual raw file URL from your GitHub repository.*

```bash
wget https://raw.githubusercontent.com/user/ServerForge/main/install_server_forge.sh
```

**2. Run the Installer**

Execute the script with `sudo` to allow system-wide installation of dependencies and commands.

```bash
sudo bash install_server_forge.sh
```

The installer will:
1.  Check for `sudo` privileges.
2.  Detect your operating system's package manager.
3.  Install all required dependencies (`git`, `wget`, `pv`, `screen`, etc.).
4.  Clone the Server Forge repository into `/opt/server-forge`.
5.  Set the necessary permissions.
6.  Create a symbolic link to `/usr/local/bin`, allowing you to run the script from anywhere.

## Usage

After a successful installation, you can run Server Forge from any directory by simply typing:

```bash
server-forge
```

This will launch the main menu, where you can start managing your game servers.