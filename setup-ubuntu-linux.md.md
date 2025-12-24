# 🧠 Ubuntu Dev Workstation Setup (UEFI + BTRFS + Hybrid GPU)

> README นี้ใช้เป็น checklist สำหรับการติดตั้ง **Ubuntu GNOME** เพื่อใช้งานเป็นเครื่องเขียนโค้ด (Flutter / Android)
> โฟกัส: **เสถียร เร็ว rollback ได้ และไม่กินทรัพยากรโดยไม่จำเป็น**

---

## 0. แนวคิดก่อนติดตั้ง (Philosophy)

- Ubuntu = เครื่องทำงานหลัก (Workstation)
- Arch / OmarchyOS = Sandbox / Playground
- ไม่ปรับแต่งจนระบบรบกวนสมาธิ
- ทุกอย่างต้อง rollback ได้

---

## 1. โครงสร้างพาร์ทิชัน (UEFI)

### 1.1 Partition Layout (ตัวอย่าง SSD 512GB)

| Partition | Size | FS | Mount | หมายเหตุ |
|---------|------|----|------|---------|
| EFI | ~1GB | FAT32 | /boot/efi | ใช้ร่วมทุก OS |
| Root | ~180GB | BTRFS | / | Ubuntu |
| Swap | 16GB | SWAP | swap | รองรับ build + emulator |
| SHAREDDATA | ตามแผน | NTFS | /mnt/SHAREDDATA | ใช้ข้าม OS |

> ❌ ไม่ต้อง Overwrite data ตอน format (ถ้าไม่ขาย SSD)

---

## 2. ขั้นตอนระหว่างติดตั้ง Ubuntu

- Installation type: **Manual partitioning**
- เลือก `/boot/efi` ที่มีอยู่แล้ว (ไม่ต้อง format)
- Root (`/`) → BTRFS
- Swap → 16GB

### Account Setup
- ✅ Require my password to log in
- ❌ Use Active Directory

---

## 3. หลังติดตั้ง: ขั้นพื้นฐาน

### 3.1 เร่งความเร็ว APT

เลือก mirror ที่เร็ว:
```bash
software-properties-gtk
```

เพิ่ม parallel download:
```bash
sudo nano /etc/apt/apt.conf.d/99parallel
```
```conf
Acquire::Queue-Mode "access";
Acquire::http::Pipeline-Depth "5";
Acquire::http::Timeout "10";
Acquire::Retries "3";
```

Update ระบบ:
```bash
sudo apt update && sudo apt upgrade
```

---

### 3.2 Microcode (AMD)

```bash
sudo apt install amd64-microcode
sudo reboot
```

---

### 3.3 Power Management (Laptop)

```bash
sudo apt install tlp tlp-rdw
sudo systemctl enable tlp
sudo systemctl start tlp
```

ตรวจสอบ:
```bash
tlp-stat -s
```

---

### 3.4 NVIDIA Hybrid (On-demand)

ติดตั้ง driver:
```bash
sudo ubuntu-drivers autoinstall
sudo reboot
```

ตั้งค่าโหมด:
```bash
sudo prime-select on-demand
```

ตรวจสอบ:
```bash
prime-select query
nvidia-smi
```

---

## 4. บังคับใช้ NVIDIA กับแอปสำคัญ

> แนวคิด: **AMD iGPU แสดงผล / NVIDIA ใช้เฉพาะแอปหนัก**

### 4.1 VS Code (User-level launcher)

```bash
mkdir -p ~/.local/share/applications
cp /usr/share/applications/code.desktop ~/.local/share/applications/
nano ~/.local/share/applications/code.desktop
```

แก้บรรทัด `Exec=`:
```ini
Exec=env __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia /usr/share/code/code %F
```

---

### 4.2 Android Studio

```bash
cp /usr/share/applications/android-studio.desktop ~/.local/share/applications/
nano ~/.local/share/applications/android-studio.desktop
```

```ini
Exec=env __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia /opt/android-studio/bin/studio.sh
```

Logout / Login ใหม่

ตรวจสอบ:
```bash
nvidia-smi
```

---

## 5. BTRFS Snapshot (Rollback)

```bash
sudo apt install timeshift
```

ตั้งค่า:
- Snapshot type: **BTRFS**
- Location: `/`
- ทำ snapshot ก่อน:
  - update ใหญ่
  - ลง Android Studio
  - อัปเดต SDK/NDK

---

## 6. Firewall (เบาแต่ควรมี)

```bash
sudo apt install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
```

---

## 7. Dev Tools ขั้นพื้นฐาน

```bash
sudo apt install git curl unzip zip \
  build-essential cmake pkg-config
```

ZSH / Oh-my-zsh / Oh-my-posh → ตั้งตามสไตล์ส่วนตัว

---

## 8. SHAREDDATA (NTFS)

### Mount ผ่าน fstab

```bash
lsblk -f
sudo nano /etc/fstab
```

ตัวอย่าง:
```fstab
UUID=XXXX-XXXX /mnt/SHAREDDATA ntfs defaults,uid=1000,gid=1000 0 0
```

ตรวจสอบ:
```bash
mount -a
```

---

## 9. Checklist สุดท้าย

ใช้เช็คก่อนเริ่มลงงานจริง (Flutter / Android)

- [ ] ระบบบูตแบบ UEFI ปกติ ไม่มี error
- [ ] `apt update && apt upgrade` ผ่าน ไม่มี held package
- [ ] Swap 16GB active (`swapon --show`)
- [ ] BTRFS mount ถูกต้อง (`mount | grep btrfs`)
- [ ] Timeshift เปิดได้ และสร้าง snapshot ทดลองได้
- [ ] NVIDIA driver ทำงาน (`nvidia-smi` ไม่ error)
- [ ] VS Code / Android Studio โผล่ใน `nvidia-smi`
- [ ] Emulator เปิดได้ ไม่ค้าง ไม่ freeze
- [ ] SHAREDDATA mount อัตโนมัติหลัง reboot
- [ ] เครื่องไม่ throttle ตอน build (พัดลม / ความร้อนปกติ)

---

## 10. สรุป

Ubuntu ที่ดีสำหรับ dev ไม่ใช่ Ubuntu ที่แต่งเยอะ
แต่คือ Ubuntu ที่ **ไม่ขัดจังหวะความคิด**

> Workstation ต้องนิ่ง
> Sandbox ค่อยเล่น

---

📌 ใช้ README นี้ซ้ำได้ทุกครั้งที่ติดตั้งใหม่
📌 ปรับเฉพาะเวอร์ชัน Ubuntu ตามปี
