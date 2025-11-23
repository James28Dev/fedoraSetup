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

sudo dnf install -y \
    akmod-nvidia \
    xorg-x11-drv-nvidia-cuda \
    wget \
    curl \
    git \
    gcc \
    make \
    python3 \
    python3-pip \
    gnome-tweaks \
    backintime-gnome \
    zsh \
    || true

error_check "Install starter packages"

#############################################
# 4. ZSH CONFIG
#############################################
step "Configure Zsh and Oh-My-Zsh"

# เปลี่ยน zsh เป็นค่าเริ่มต้น
chsh -s "$(which zsh)" || true

# Install Oh-My-Zsh
export RUNZSH=no         # ป้องกัน shell รีสตาร์ทอัตโนมัติ
export CHSH=no           # ป้องกันเปลี่ยน shell อัตโนมัติ

# ดาวน์โหลดและติดตั้ง Oh My Zsh แบบ non-interactive
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

error_check "Install Oh-My-Zsh"

# Install plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting || true
git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete || true

# Update ~/.zshrc plugins
sed -i 's/^plugins=.*/plugins=(git zsh-autocomplete zsh-syntax-highlighting)/' ~/.zshrc

# Install Oh-My-Posh
curl -s https://ohmyposh.dev/install.sh | bash -s
oh-my-posh font install FiraMono || true
mkdir -p ~/.poshthemes
curl -o ~/.poshthemes/cloud-native-azure.omp.json https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/cloud-native-azure.omp.json

# Load theme in ~/.zshrc
grep -qxF 'export POSH_THEMES_PATH="$HOME/.poshthemes"' ~/.zshrc || echo 'export POSH_THEMES_PATH="$HOME/.poshthemes"' >> ~/.zshrc
grep -qxF 'eval "$(oh-my-posh init zsh --config $POSH_THEMES_PATH/cloud-native-azure.omp.json)"' ~/.zshrc || echo 'eval "$(oh-my-posh init zsh --config $POSH_THEMES_PATH/cloud-native-azure.omp.json)"' >> ~/.zshrc

error_check "Configure Zsh theme and plugins"

echo -e "\n=== Completed all steps ==="
echo "Check setup_log.txt for details."
