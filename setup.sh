#!/usr/bin/env bash

log_file="setup_log.txt"
echo "=== Fedora One-File Setup Log ($(date)) ===" > "$log_file"

step() {
    echo -e "\n--- $1 ---"
    echo "--- $1 ---" >> "$log_file"
}

error_check() {
    if [ $? -ne 0 ]; then
        echo "[FAILED] $1"
        echo "[FAILED] $1" >> "$log_file"
    else
        echo "[OK] $1"
        echo "[OK] $1" >> "$log_file"
    fi
}

show_version() {
    cmd=$1
    ver_cmd=$2
    if command -v "$cmd" &> /dev/null; then
        echo -n "$cmd version: "
        $ver_cmd
        sleep 10
    fi
}

#############################################
# 0. OPEN RPM FUSION
#############################################
step "Enable RPM Fusion repos"

sudo dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-43.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-43.noarch.rpm || true

error_check "Enable RPM Fusion repos"

#############################################
# 1. CLEAN UNUSED PACKAGES
#############################################
step "Clean default Fedora apps"

sudo dnf remove -y \
    gnome-contacts \
    gnome-weather \
    gnome-maps \
    gnome-tour \
    gnome-color-manager \
    simple-scan \
    gnome-font-viewer \
    gnome-system-monitor \
    gnome-calendar \
    gnome-connections \
    mediawriter \
    || true

error_check "Removing unused apps"

#############################################
# 2. DNF CONFIG
#############################################
step "Configure DNF"

sudo tee /etc/dnf/dnf.conf > /dev/null <<EOF
[main]
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

error_check "Apply DNF config"

#############################################
# 3. INSTALL STARTER PACK
#############################################
step "Install starter packages"

starter_packages=(
    akmod-nvidia
    xorg-x11-drv-nvidia-cuda
    wget
    curl
    git
    gcc
    make
    python3
    python3-pip
    gnome-tweaks
    backintime-gnome
    zsh
)

sudo dnf install -y "${starter_packages[@]}" || true
error_check "Install starter packages"

for pkg in "${starter_packages[@]}"; do
    show_version "$pkg" "$pkg --version || $pkg -V || echo 'version not available'"
done

#############################################
# 4. ZSH CONFIG
#############################################
step "Configure Zsh and Oh-My-Zsh"

chsh -s "$(which zsh)" || true
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting || true
git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete || true
sed -i 's/^plugins=.*/plugins=(git zsh-autocomplete zsh-syntax-highlighting)/' ~/.zshrc

curl -s https://ohmyposh.dev/install.sh | bash -s
oh-my-posh font install FiraMono || true
mkdir -p ~/.poshthemes
curl -o ~/.poshthemes/cloud-native-azure.omp.json https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/cloud-native-azure.omp.json

grep -qxF 'export POSH_THEMES_PATH="$HOME/.poshthemes"' ~/.zshrc || echo 'export POSH_THEMES_PATH="$HOME/.poshthemes"' >> ~/.zshrc
grep -qxF 'eval "$(oh-my-posh init zsh --config $POSH_THEMES_PATH/cloud-native-azure.omp.json)"' ~/.zshrc || echo 'eval "$(oh-my-posh init zsh --config $POSH_THEMES_PATH/cloud-native-azure.omp.json)"' >> ~/.zshrc

error_check "Configure Zsh theme and plugins"

#############################################
# 5. INSTALL GENERAL PACK (Flatpak apps)
#############################################
step "Install general apps (Flatpak)"

general_apps=(
    com.visualstudio.code
    com.google.AndroidStudio
    com.brave.Browser
    org.onlyoffice.desktopeditors
    com.obsproject.Studio
    com.mattjakeman.ExtensionManager
    io.missioncenter.MissionCenter
)

for app in "${general_apps[@]}"; do
    flatpak install -y flathub "$app" || true
    flatpak info "$app" || echo "$app info not available"
    sleep 10
done

error_check "Install general apps"

#############################################
# 6. INSTALL FLUTTER
#############################################
step "Install Flutter SDK"

# ดาวน์โหลด Flutter SDK ล่าสุด
cd ~/Downloads || exit
wget -c -P ~/Downloads https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.9-stable.tar.xz
tar xf ~/Downloads/flutter_linux_3.13.9-stable.tar.xz -C ~
grep -qxF 'export PATH="$HOME/flutter/bin:$PATH"' ~/.zshrc || echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc

error_check "Install Flutter SDK"

echo -e "\n=== Completed all steps ==="
echo "Check setup_log.txt for details."
