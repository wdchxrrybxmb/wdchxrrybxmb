#!/usr/bin/env bash

# --- System Update ---
echo ">>> Updating system..."
sudo pacman -Syu --noconfirm

# --- Essential Packages (Pacman) ---
ESSENTIAL_PACKAGES=(
  git base-devel gcc clang cmake make pkgconf
  python python-pip python-virtualenv
  nodejs npm
  rustup
  docker docker-compose
  kitty
  thunar thunar-archive-plugin thunar-volman tumbler
  wl-clipboard imv
  zsh zsh-syntax-highlighting zsh-autosuggestions
  htop tmux unzip wget curl man-db bash-completion
  openssh ufw pacman-contrib reflector
  btrfs-assistant yt-dlp
  hyprland waybar swaylock-effects wofi
  hyprpaper grim slurp swappy wf-recorder mako
)

echo ">>> Installing essential packages..."
sudo pacman -S --needed --noconfirm "${ESSENTIAL_PACKAGES[@]}"

# Remove code-oss if it exists (old VS Code package)
if pacman -Qs code-oss > /dev/null; then
  echo ">>> Removing code-oss..."
  sudo pacman -Rns --noconfirm code-oss
fi

# --- Terminal Setup ---
echo ">>> Setting up kitty as the default terminal..."

# Remove alacritty if installed
if pacman -Qs alacritty > /dev/null; then
  echo ">>> Removing alacritty..."
  sudo pacman -Rns --noconfirm alacritty
fi

# Set environment variable for terminal in shell configs
if ! grep -q "export TERMINAL=" ~/.bashrc; then
  echo 'export TERMINAL="kitty"' >> ~/.bashrc
fi
if ! grep -q "export TERMINAL=" ~/.zshrc; then
  echo 'export TERMINAL="kitty"' >> ~/.zshrc
fi

echo ">>> Kitty set as default terminal. Use $TERMINAL in scripts or keybindings."

# --- Rust Setup ---
echo ">>> Setting up Rust..."
rustup install stable
rustup default stable

# --- Docker Setup ---
echo ">>> Enabling Docker..."
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

# --- Default Editor Setup ---
echo ">>> Setting default editor to VSCodium..."
if ! grep -q "export EDITOR=" ~/.bashrc; then
  echo 'export EDITOR="codium --wait"' >> ~/.bashrc
fi
if ! grep -q "export VISUAL=" ~/.bashrc; then
  echo 'export VISUAL="codium --wait"' >> ~/.bashrc
fi

# --- Zsh Setup ---
echo ">>> Changing default shell to zsh..."
if [ "$SHELL" != "/bin/zsh" ]; then
  chsh -s /bin/zsh
fi

# --- Firewall Setup ---
echo ">>> Enabling UFW firewall..."
sudo systemctl enable --now ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh

# --- AUR Packages (via paru) ---
AUR_PACKAGES=(
  appimagelauncher-git
  vscodium-bin
)

echo ">>> Installing AUR packages with paru..."
if ! command -v paru &>/dev/null; then
  echo ">>> paru not found. Installing paru..."
  git clone https://aur.archlinux.org/paru.git /tmp/paru
  (cd /tmp/paru && makepkg -si --noconfirm)
fi

paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"

echo ">>> Setup complete."

# --- Reboot Prompt ---
read -p "Do you want to reboot now? (y/N): " REBOOT_CHOICE
case "$REBOOT_CHOICE" in
  [yY][eE][sS]|[yY])
    echo "Rebooting..."
    sudo reboot
    ;;
  *)
    echo "Reboot skipped. Please reboot later to apply all changes."
    ;;
esac
