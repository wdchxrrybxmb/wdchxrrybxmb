#!/bin/bash

set -e

ZSHRC="$HOME/.zshrc"

echo ">>> Updating system..."
sudo pacman -Syu --noconfirm

echo ">>> Installing essential development tools..."
sudo pacman -S --needed --noconfirm \
  git base-devel gcc clang cmake make pkgconf \
  python python-pip python-virtualenv \
  nodejs npm rustup \
  docker docker-compose \
  alacritty code \
  thunar thunar-archive-plugin thunar-volman tumbler \
  wl-clipboard imv \
  zsh zsh-syntax-highlighting zsh-autosuggestions

echo ">>> Setting up Rust..."
rustup default stable

echo ">>> Enabling Docker..."
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

echo ">>> Setting default editor to Code - OSS..."
if command -v code &> /dev/null; then
  echo "export EDITOR=\"$(command -v code) --wait\"" >> "$ZSHRC"
  echo "export VISUAL=\"$(command -v code) --wait\"" >> "$ZSHRC"
fi

echo ">>> Ensuring Python venv tools..."
if ! command -v virtualenv &> /dev/null; then
  pip install --user virtualenv
fi


HYPR_CONFIG="$HOME/.config/hypr/config/keybinds.conf"

if [ -f "$HYPR_CONFIG" ]; then
  echo ">>> Checking Hyprland keybinds..."

  ADDED=false

  if ! grep -q "bind = SUPER, E, exec, thunar" "$HYPR_CONFIG"; then
    echo ">>> Adding Thunar keybind..."
    echo "bind = SUPER, E, exec, thunar" >> "$HYPR_CONFIG"
    ADDED=true
  fi

  if ! grep -q "bind = SUPER, C, exec, code" "$HYPR_CONFIG"; then
    echo ">>> Adding VS Code keybind..."
    echo "bind = SUPER, C, exec, code" >> "$HYPR_CONFIG"
    ADDED=true
  fi

  if [ "$ADDED" = false ]; then
    echo ">>> All keybinds already present — nothing to do."
  fi
else
  echo ">>> Hyprland config not found at $HYPR_CONFIG — skipping keybinds."
fi


# Aliases
echo ">>> Adding developer-friendly aliases to $ZSHRC"
{
  echo ""
  echo "# Custom Dev Aliases"
  echo "alias ..='cd ..'"
  echo "alias ...='cd ../..'"
  echo "alias gs='git status'"
  echo "alias ga='git add'"
  echo "alias gc='git commit -m'"
  echo "alias gp='git push'"
  echo "alias gl='git log --oneline --graph --decorate'"
  echo "alias venv='python -m venv venv && source venv/bin/activate'"
  echo "alias code='code --disable-gpu'"  # helps with Wayland issues
  echo "alias ll='ls -lah --color=auto'"
  echo "alias update='sudo pacman -Syu'"
} >> "$ZSHRC"

# Oh My Zsh installation
echo ">>> Ensuring Oh My Zsh..."
if [ -d "${ZSH:-$HOME/.oh-my-zsh}" ] || [ -d "/usr/share/oh-my-zsh" ]; then
  echo "Oh My Zsh already installed — skipping."
else
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Powerlevel10k theme setup
echo ">>> Installing Powerlevel10k manually (GitHub clone)..."
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  echo "Powerlevel10k already installed at $P10K_DIR"
fi

# Ensure plugins + theme in .zshrc
if ! grep -q 'zsh-syntax-highlighting' "$ZSHRC"; then
  {
    echo ""
    echo "# zsh plugins"
    echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
  } >> "$ZSHRC"
fi

if ! grep -q 'powerlevel10k' "$ZSHRC"; then
  {
    echo ""
    echo "# Powerlevel10k theme"
    echo "source \"$P10K_DIR/powerlevel10k.zsh-theme\""
    echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh'
  } >> "$ZSHRC"
fi

echo ">>> Setting zsh as default shell for $USER..."
chsh -s /bin/zsh $USER

echo ">>> Development environment setup complete!"
echo "➡ Restart your shell (or reboot) to enable Powerlevel10k, aliases, and plugins."
echo "➡ First time you open zsh, Powerlevel10k will guide you through configuration."
echo "➡ Log out/in for Docker group changes to take effect."
