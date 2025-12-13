#!/bin/bash
set -e

echo "=== Checking for yay ==="

if ! command -v yay &>/dev/null; then
    echo "→ yay not found, installing..."

    sudo pacman -S --needed --noconfirm git base-devel

    TMP_DIR="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay.git "$TMP_DIR/yay"
    cd "$TMP_DIR/yay"

    makepkg -si --noconfirm

    cd ~
    rm -rf "$TMP_DIR"

    echo "✔ yay installed"
else
    echo "✔ yay is already installed"
fi

echo "=== Installing dependencies ==="
sudo pacman -S --needed --noconfirm \
    hyprland \
    hyprpaper \
    hyprlock \
    hypridle \
    hyprpicker \
    alacritty \
    kvantum \
    kvantum-theme-materia \
    qt5ct qt6ct \
    nwg-look \
    gtk4 \
    gtk3 \
    python \
    sassc

echo "=== Installing Hyprpanel ==="
yay -S --needed --noconfirm ags-hyprpanel-git

echo "=== Creating config backup ==="
BACKUP_DIR="$HOME/.config/backup_$(date +%F_%H-%M)"
mkdir -p "$BACKUP_DIR"

backup_if_exists() {
    if [ -d "$HOME/.config/$1" ]; then
        echo "→ Бэкап $1"
        cp -r "$HOME/.config/$1" "$BACKUP_DIR/"
    fi
}

backup_if_exists hypr
backup_if_exists hyprpanel
backup_if_exists alacritty
backup_if_exists gtk-4.0
backup_if_exists gtk-5.0
backup_if_exists Kvantum

echo "=== Copying new configs ==="

copy_cfg() {
    SRC="$1"
    DEST="$HOME/.config/$2"
    mkdir -p "$DEST"
    echo "→ Copying $SRC → $DEST"
    cp -r "$SRC"/* "$DEST"/
}

copy_cfg hypr hypr
copy_cfg hyprpanel hyprpanel
copy_cfg alacritty alacritty
copy_cfg gtk-4.0 gtk-4.0
copy_cfg gtk-5.0 gtk-5.0

if [ -d kvantum ]; then
    mkdir -p "$HOME/.config/Kvantum"
    echo "→ Copying Kvantum themes"
    cp -r kvantum/* "$HOME/.config/Kvantum/"
fi

echo "=== Activating Kvantum themes ==="
if command -v kvantummanager &>/dev/null; then
    THEME=$(ls kvantum 2>/dev/null | head -n 1)
    if [ -n "$THEME" ]; then
        kvantummanager --set "$THEME"
    fi
fi

echo "=== DONE ==="
echo "Your backups are in: $BACKUP_DIR"
echo "Reboot your PC for changes to appear!"
