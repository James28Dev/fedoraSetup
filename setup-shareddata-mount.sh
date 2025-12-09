echo -e "${GREEN}---------------------------------------------------------${RESET}"
echo -e "${GREEN}Setup SharedData Auto-Mount (Linux ↔ Windows)${RESET}"
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
