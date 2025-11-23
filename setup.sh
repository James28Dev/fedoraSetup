#!/usr/bin/env bash
set -e

# ฟังก์ชันหน่วงเวลา 1 วินาที
wait1() {
    echo -e "🕒 รอ 1 วินาที..."
    sleep 1
}

# สีข้อความ
GREEN="\e[32m"
CYAN="\e[36m"
RESET="\e[0m"

echo -e "${CYAN}=== Fedora 43 One-Setup Started ===${RESET}"

### ---------------------------------------------------------
### 1. REMOVE USELESS PREINSTALLED GNOME APPS
### ---------------------------------------------------------
echo -e "${GREEN}---------------------------------------------------------${RESET}"
echo -e "${GREEN}1. REMOVE USELESS PREINSTALLED GNOME APPS${RESET}"
echo -e "${GREEN}---------------------------------------------------------${RESET}"

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
        echo "done."
    fi
done
wait1

### ---------------------------------------------------------
### 2. CONFIGURE DNF
### ---------------------------------------------------------
echo -e "${GREEN}---------------------------------------------------------${RESET}"
echo -e "${GREEN}2. CONFIGURE DNF${RESET}"
echo -e "${GREEN}---------------------------------------------------------${RESET}"

sudo tee /etc/dnf/dnf.conf >/dev/null <<'EOF'
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

echo "dnf.conf updated."
wait1

sudo dnf update -y
sudo dnf upgrade -y
echo "system updated and upgraded."
wait1

### ---------------------------------------------------------
### 3. INSTALL FLATPAK (IF NOT INSTALLED)
### ---------------------------------------------------------
echo -e "${GREEN}---------------------------------------------------------${RESET}"
echo -e "${GREEN}3. INSTALL FLATPAK${RESET}"
echo -e "${GREEN}---------------------------------------------------------${RESET}"

if ! command -v flatpak &>/dev/null; then
    sudo dnf install -y flatpak
    echo "Flatpak version:"
    flatpak --version
    wait1
else
    echo "Flatpak already installed."
    flatpak --version
    wait1
fi

### ---------------------------------------------------------
### 4. ADD FLATHUB SYSTEM-WIDE
### ---------------------------------------------------------
echo -e "${GREEN}---------------------------------------------------------${RESET}"
echo -e "${GREEN}4. ADD FLATHUB SYSTEM-WIDE${RESET}"
echo -e "${GREEN}---------------------------------------------------------${RESET}"

if ! flatpak remote-list --system | awk '{print $1}' | grep -qx "flathub"; then
    sudo flatpak remote-add --system flathub \
        https://flathub.org/repo/flathub.flatpakrepo
    echo "Flathub added."
    wait1
else
    echo "Flathub already exists."
    wait1
fi

### ---------------------------------------------------------
### 5. INSTALL FLATPAK APPS + SHOW VERSION
### ---------------------------------------------------------
echo -e "${GREEN}---------------------------------------------------------${RESET}"
echo -e "${GREEN}5. INSTALL FLATPAK APPS${RESET}"
echo -e "${GREEN}---------------------------------------------------------${RESET}"

FLATPAK_APPS=(
    com.visualstudio.code
    com.google.AndroidStudio
    com.brave.Browser
    org.onlyoffice.desktopeditors
    com.obsproject.Studio
    com.mattjakeman.ExtensionManager
    io.missioncenter.MissionCenter
)

for app in "${FLATPAK_APPS[@]}"; do
    if ! flatpak info "$app" &>/dev/null; then
        echo "Installing $app ..."
        sudo flatpak install -y flathub "$app"
        echo "=== Version info for $app ==="
        flatpak info "$app" | grep -E "Version|ID|Commit"
        echo "============================="
        wait1
    else
        echo "$app already installed."
        flatpak info "$app" | grep -E "Version|ID|Commit"
        wait1
    fi
done

### ---------------------------------------------------------
### 6. Setup SharedData Auto-Mount (Fedora ↔ Windows)
### ---------------------------------------------------------
echo -e "${GREEN}---------------------------------------------------------${RESET}"
echo -e "${GREEN}6. Setup SharedData Auto-Mount (Fedora ↔ Windows)${RESET}"
echo -e "${GREEN}---------------------------------------------------------${RESET}"

# 1️⃣ สร้างโฟลเดอร์เมานต์
MOUNT_DIR="$HOME/SharedData"
if [ ! -d "$MOUNT_DIR" ]; then
    echo -e "${GREEN}Creating mount directory at $MOUNT_DIR...${RESET}"
    mkdir -p "$MOUNT_DIR"
    echo "Directory created."
else
    echo -e "${GREEN}$MOUNT_DIR already exists.${RESET}"
fi

# 2️⃣ แสดงพาร์ติชัน NTFS และ UUID
echo -e "${GREEN}Detecting NTFS partitions...${RESET}"
sudo blkid | grep -i ntfs

echo -e "${CYAN}Please enter the UUID of your NTFS partition to mount:${RESET}"
read -r UUID_INPUT

# ตรวจสอบว่าผู้ใช้กรอก UUID หรือไม่
if [ -z "$UUID_INPUT" ]; then
    echo "❌ No UUID provided. Exiting."
    exit 1
fi

# 3️⃣ เพิ่ม entry ลงใน /etc/fstab
FSTAB_LINE="UUID=${UUID_INPUT}  ${MOUNT_DIR}  ntfs-3g  defaults,uid=$(id -u),gid=$(id -g),windows_names,locale=en_US.utf8 0 0"

# ตรวจสอบว่ามี entry อยู่แล้วหรือไม่
if grep -qxF "$FSTAB_LINE" /etc/fstab; then
    echo -e "${GREEN}Entry already exists in /etc/fstab.${RESET}"
else
    echo -e "${GREEN}Adding entry to /etc/fstab...${RESET}"
    echo "$FSTAB_LINE" | sudo tee -a /etc/fstab
    echo "Entry added."
fi

# 4️⃣ ทดสอบเมานต์
echo -e "${GREEN}Mounting $MOUNT_DIR...${RESET}"
sudo mount -a

echo -e "${CYAN}✅ SharedData setup completed!${RESET}"
echo "You can access it at: $MOUNT_DIR"

echo -e "${CYAN}=== Fedora Setup Completed Successfully ===${RESET}"
