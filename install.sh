#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting the i3wm dotfiles restoration for juipo..."

# 1. Take ownership of the current repository directory
# Using -R to ensure all subdirectories and files are owned by juipo
echo "Setting permissions..."
sudo chown -R juipo:juipo ~/

# 2. Add Chaotic AUR keys and keyrings
echo "Configuring Chaotic AUR..."
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# 3. Safely append Chaotic AUR to pacman.conf if it doesn't already exist
if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    echo "Adding [chaotic-aur] repository to /etc/pacman.conf..."
    # Using tee to append with sudo privileges
    sudo tee -a /etc/pacman.conf > /dev/null <<EOT

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOT
else
    echo "Chaotic AUR is already in /etc/pacman.conf. Skipping..."
fi

# 4. Update the system and install yay
echo "Syncing repositories and installing yay..."
sudo pacman -Syu --noconfirm yay

# 5. Install all packages from pkglist.txt
# --needed prevents reinstalling packages that are already up to date
if [ -f "pkglist.txt" ]; then
    echo "Installing packages from pkglist.txt..."
    yay -S --needed --noconfirm - < pkglist.txt
else
    echo "Warning: pkglist.txt not found. Skipping package installation."
fi

# 6. Copy .config and Pictures to the home directory
echo "Restoring dotfiles and Pictures..."
# -a (archive) preserves permissions and structure, -v is verbose so you can see it working
cp -av .config /home/juipo/
cp -av Pictures /home/juipo/

echo "Activating lemurs"

sudo systemctl enable lemurs

echo "Installation complete! Enjoy your i3 setup."
