#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to install necessary libraries
install_libraries() {
    echo "Installing necessary libraries..."
    sudo apt update
    sudo apt install -y software-properties-common apt-transport-https wget curl gpg || { echo "Failed to install necessary libraries"; exit 1; }
    echo "Libraries installed successfully."
}

# Function to add repositories and keys, then install packages
install_from_repo() {
    local REPO=$1
    local GPG_URL=$2
    local PACKAGE=$3

    if [[ -n "$GPG_URL" ]]; then
        curl -fsSL $GPG_URL | sudo apt-key add - || { echo "Failed to add GPG key for $PACKAGE"; exit 1; }
    fi

    if [[ -n "$REPO" ]]; then
        sudo add-apt-repository -y "$REPO" || { echo "Failed to add repository for $PACKAGE"; exit 1; }
    fi

    sudo apt update
    sudo apt install -y "$PACKAGE" || { echo "Failed to install $PACKAGE"; exit 1; }
}

# Install necessary libraries
install_libraries

# Codium
install_from_repo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" "https://packages.microsoft.com/keys/microsoft.asc" "codium"

# PyCharm
sudo snap install pycharm-community --classic || { echo "Failed to install PyCharm"; exit 1; }

# MS Teams
install_from_repo "https://packages.microsoft.com/repos/ms-teams stable main" "https://packages.microsoft.com/keys/microsoft.asc" "teams"

# Telegram
install_from_repo "ppa:atareao/telegram" "" "telegram-desktop"

# Signal
wget -O- https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add - || { echo "Failed to add Signal GPG key"; exit 1; }
echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee -a /etc/apt/sources.list.d/signal-xenial.list
sudo apt update && sudo apt install -y signal-desktop || { echo "Failed to install Signal"; exit 1; }

# Inkscape
install_from_repo "ppa:inkscape.dev/stable" "" "inkscape"

# RStudio
sudo apt install -y gdebi-core || { echo "Failed to install gdebi-core"; exit 1; }
wget https://download1.rstudio.org/desktop/bionic/amd64/rstudio-1.4.1717-amd64.deb || { echo "Failed to download RStudio"; exit 1; }
sudo gdebi -n rstudio-1.4.1717-amd64.deb || { echo "Failed to install RStudio"; exit 1; }

# Tor
install_from_repo "deb [arch=amd64] https://deb.torproject.org/torproject.org focal main" "https://deb.torproject.org/torproject.org/tor-archive-keyring.gpg" "tor deb.torproject.org-keyring"

# LibreWolf
wget -qO- https://deb.librewolf.net/keyring.gpg | sudo tee /usr/share/keyrings/librewolf.gpg || { echo "Failed to add LibreWolf GPG key"; exit 1; }
echo "deb [signed-by=/usr/share/keyrings/librewolf.gpg arch=amd64] https://deb.librewolf.net $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/librewolf.list
sudo apt update && sudo apt install -y librewolf || { echo "Failed to install LibreWolf"; exit 1; }

# Ghostwriter
install_from_repo "ppa:wereturtle/ppa" "" "ghostwriter"

# Obsidian
wget https://github.com/obsidianmd/obsidian-releases/releases/download/v0.12.19/obsidian_0.12.19_amd64.deb || { echo "Failed to download Obsidian"; exit 1; }
sudo gdebi -n obsidian_0.12.19_amd64.deb || { echo "Failed to install Obsidian"; exit 1; }

# LibreOffice
install_from_repo "ppa:libreoffice/ppa" "" "libreoffice"

# htop
sudo apt install -y htop || { echo "Failed to install htop"; exit 1; }

# MPV Player
sudo apt install -y mpv || { echo "Failed to install MPV Player"; exit 1; }

# Chromium
sudo apt install -y chromium-browser || { echo "Failed to install Chromium"; exit 1; }

# Transmission
sudo apt install -y transmission || { echo "Failed to install Transmission"; exit 1; }

# Audacity
sudo apt install -y audacity || { echo "Failed to install Audacity"; exit 1; }

# Firefox
sudo apt install -y firefox || { echo "Failed to install Firefox"; exit 1; }

# i3 window manager
sudo apt install -y i3 || { echo "Failed to install i3"; exit 1; }

# Dual monitor setup
# Detect and configure dual monitors using xrandr in i3 config file
cat <<EOT >> ~/.config/i3/config
# xrandr dual monitor setup
exec --no-startup-id xrandr --output HDMI-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1 --mode 1920x1080 --pos 1920x0 --rotate normal
EOT

# Conky
sudo apt install -y conky || { echo "Failed to install Conky"; exit 1; }

echo "Installation of all specified applications is complete."
