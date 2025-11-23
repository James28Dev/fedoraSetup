#!/usr/bin/env bash
set -e

wait5() {
    echo "🕒 รอ 5 วินาที..."
    sleep 5
}

echo "=== Fedora 43 One-Setup Started ==="

### ---------------------------------------------------------
### 1. REMOVE USELESS PREINSTALLED GNOME APPS
### ---------------------------------------------------------
REMOVE_PKGS=(
    gnome-contacts
    gnome-weather
    gnome-maps
    showtime
    mediawriter
    gnome-connections
    gnome-calendar
    gnome-system-monitor
    gnome-font-viewer
    gnome-tour
    gnome-color-manager
    simple-scan
)

echo "--- Removing unwanted GNOME packages..."
for pkg in "${REMOVE_PKGS[@]}"; do
    if rpm -q "$pkg" &>/dev/null; then
        echo "Removing $pkg ..."
        sudo rpm -e --nodeps "$pkg" || true
        echo "$pkg removed."
        wait5
    fi
done

### ---------------------------------------------------------
### 2. CONFIGURE DNF
### ---------------------------------------------------------
echo "--- Applying optimized dnf.conf settings..."
sudo tee /etc/dnf/dnf.conf >/dev/null <<'EOF'
fastestmirror=True
defaultyes=True
gpgcheck=1
best=True
clean_requirements_on_remove=True
installonly_limit=3
max_parallel_downloads=20
keepcache=False
retries=5
color=always
EOF
echo "dnf.conf updated."
wait5

sudo dnf update -y
sudo dnf upgrade -y
wait5

### ---------------------------------------------------------
### 3. INSTALL STARTER PACK
### ---------------------------------------------------------
STARTER_PACK=(
    wget curl git gcc make python3 python3-pip gnome-tweaks backintime-gnome zsh akmod-nvidia xorg-x11-drv-nvidia-cuda
)
echo "--- Installing starter packages..."
for pkg in "${STARTER_PACK[@]}"; do
    if ! rpm -q "$pkg" &>/dev/null; then
        echo "Installing $pkg ..."
        sudo dnf install -y "$pkg"
        echo "=== Version info for $pkg ==="
        if command -v "$pkg" &>/dev/null; then
            "$pkg" --version 2>/dev/null || "$pkg" -V 2>/dev/null || echo "Version not available"
        fi
        echo "============================="
        wait5
    else
        echo "$pkg already installed."
        if command -v "$pkg" &>/dev/null; then
            "$pkg" --version 2>/dev/null || "$pkg" -V 2>/dev/null || echo "Version not available"
        fi
        wait5
    fi
done

### ---------------------------------------------------------
### 4. CONFIGURE ZSH + OH-MY-ZSH + OH-MY-POSH
### ---------------------------------------------------------
echo "--- Configuring Zsh + Oh-My-Zsh + Oh-My-Posh..."
chsh -s "$(which zsh)" || true
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || true
git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git "$ZSH_CUSTOM/plugins/zsh-autocomplete" || true
sed -i 's/^plugins=.*/plugins=(git zsh-autocomplete zsh-syntax-highlighting)/' ~/.zshrc

curl -s https://ohmyposh.dev/install.sh | bash -s
oh-my-posh font install FiraMono || true
mkdir -p ~/.poshthemes
curl -o ~/.poshthemes/cloud-native-azure.omp.json https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/cloud-native-azure.omp.json

grep -qxF 'export POSH_THEMES_PATH="$HOME/.poshthemes"' ~/.zshrc || echo 'export POSH_THEMES_PATH="$HOME/.poshthemes"' >> ~/.zshrc
grep -qxF 'eval "$(oh-my-posh init zsh --config $POSH_THEMES_PATH/cloud-native-azure.omp.json)"' ~/.zshrc || echo 'eval "$(oh-my-posh init zsh --config $POSH_THEMES_PATH/cloud-native-azure.omp.json)"' >> ~/.zshrc
wait5

### ---------------------------------------------------------
### 5. INSTALL GENERAL FLATPAK APPS
### ---------------------------------------------------------
FLATPAK_APPS=(
    com.visualstudio.code
    com.google.AndroidStudio
    com.brave.Browser
    org.onlyoffice.desktopeditors
    com.obsproject.Studio
    com.mattjakeman.ExtensionManager
    io.missioncenter.MissionCenter
)

echo "--- Installing Flatpak apps..."
for app in "${FLATPAK_APPS[@]}"; do
    if ! flatpak info "$app" &>/dev/null; then
        echo "Installing $app ..."
        sudo flatpak install -y flathub "$app"
        echo "=== Version info for $app ==="
        flatpak info "$app" | grep -E "Version|ID|Commit"
        echo "============================="
        wait5
    else
        echo "$app already installed."
        flatpak info "$app" | grep -E "Version|ID|Commit"
        wait5
    fi
done

### ---------------------------------------------------------
### 6. INSTALL FLUTTER SDK
### ---------------------------------------------------------
echo "--- Installing Flutter SDK..."
cd ~/Downloads || exit
wget -c https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.9-stable.tar.xz
tar xf flutter_linux_3.13.9-stable.tar.xz -C ~
grep -qxF 'export PATH="$HOME/flutter/bin:$PATH"' ~/.zshrc || echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc

echo "Flutter version:"
~/flutter/bin/flutter --version
wait5

### ---------------------------------------------------------
### 7. FINAL UPDATE, UPGRADE AND CLEAN
### ---------------------------------------------------------
echo "--- Final system update, upgrade, autoremove, clean..."
sudo dnf update -y
sudo dnf upgrade -y
sudo dnf autoremove -y
sudo dnf clean all
wait5

echo "=== Fedora Setup Completed Successfully ==="
