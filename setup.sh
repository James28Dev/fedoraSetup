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

echo -e "\n=== Completed initial steps ==="
echo "Check setup_log.txt for details."
