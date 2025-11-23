# การติดตั้งและตั้งค่า GRUB Themes บน Fedora 43

ไฟล์นี้สรุปขั้นตอนการติดตั้งและตั้งค่า **GRUB Theme** เพื่อปรับหน้าตาเมนูบูตบน Fedora 43

---

## 1. ดาวน์โหลด GRUB Theme

1. ไปที่เว็บไซต์รวมธีม เช่น [Gnome-Look GRUB Themes](https://www.gnome-look.org/browse/cat/109/)  
2. ดาวน์โหลดธีมที่ต้องการเป็นไฟล์ `.zip` หรือ `.tar.gz`  

---

## 2. แตกไฟล์ Theme

สำหรับไฟล์ `.zip`:
```bash
unzip starfield.zip -d ~/starfield
```

สำหรับไฟล์ `.tar.gz` หรือ `.tar.xz:`
```bash
tar -xvzf starfield.tar.gz -C ~/starfield
# หรือ
tar -xvf starfield.tar.xz -C ~/starfield
```

---

## 3. ย้าย Theme ไปยัง GRUB

```bash
sudo mkdir -p /boot/grub2/themes
sudo cp -r ~/starfield /boot/grub2/themes/
```

ตรวจสอบว่าโฟลเดอร์ theme ถูกคัดลอกเรียบร้อย:
```bash
sudo ls /boot/grub2/themes/
# ควรเห็นโฟลเดอร์ theme เช่น Starfield
```

---

## 4. แก้ไขไฟล์ GRUB Config รวม Kernel Menu ไว้ใน Advanced Options

เปิดไฟล์ `/etc/default/grub` ด้วยสิทธิ์ root:
```bash
sudo nano /etc/default/grub
```

ถ้า GRUB ของคุณมีหลาย kernel และต้องการรวมไว้ใน Advanced Options ให้เปิดไฟล์ /etc/default/grub และตั้งค่า:
```bash
GRUB_THEME="/boot/grub2/themes/starfield/theme.txt"
GRUB_GFXMODE=1920x1080
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="gfxterm"
GRUB_ENABLE_BLSCFG=true
GRUB_TIMEOUT=30
```

---

## 5. สร้าง GRUB Config ใหม่

สำหรับ BIOS:
```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

สำหรับ UEFI:
```bash
sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
```

---

## 6. รีบูตและตรวจสอบผล
```bash
sudo reboot
```
