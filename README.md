# 🚀 คู่มือตั้งค่า **Fedora Linux 43** หลังติดตั้งใหม่

ปรับระบบให้ลื่น ใช้งานร่วมกับ Windows ได้ดี พร้อมสำหรับสาย Dev เต็มรูปแบบ

---

## 🎯 1) เตรียม Windows ให้พร้อมสำหรับ Dual‑Boot

### ⚡ ปิด Fast Startup

ช่วยป้องกัน NTFS ค้างสถานะ ทำให้ Fedora เขียนข้อมูลไม่ได้

```
Control Panel → Power Options → Choose what the power buttons do
Change settings that are currently unavailable
ปิด ✔ Turn on fast startup
```

### 🧹 ตรวจสอบไดรฟ์ Windows ให้ clean

```
chkdsk D: -f
```

เปลี่ยน `D:` ตามไดรฟ์ที่แชร์ร่วมกัน

---

## 🧽 2) ลบแอป GNOME ที่ไม่จำเป็น

```
sudo dnf remove -y \
  gnome-contacts gnome-weather gnome-maps gnome-tour gnome-color-manager \
  simple-scan gnome-font-viewer gnome-system-monitor gnome-calendar \
  gnome-connections mediawriter
```

---

## ⚙️ 3) ปรับแต่ง DNF ให้เร็วขึ้น

เปิดไฟล์คอนฟิก:

```
sudo nano /etc/dnf/dnf.conf
```

เพิ่ม:

```
fastestmirror=True
max_parallel_downloads=20
best=True
clean_requirements_on_remove=True
installonly_limit=3
retries=5
color=always
```

---

## 🟩 4) ติดตั้งไดรเวอร์ NVIDIA

```
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda
```

ตรวจสอบ:

```
nvidia-smi
```

---

## 📦 5) ติดตั้งเครื่องมือพื้นฐาน

```
sudo dnf install wget curl git gcc make python3 /
  python3-pip gnome-tweaks backintime-gnome zsh
```

---

## 🔄 6) อัปเดตระบบ

```
sudo dnf update || sudo dnf clean all
```

---

## 🐚 7) ตั้งค่า ZSH + Oh‑My‑Zsh

ตรวจสอบ Shell:

```
echo $SHELL
```

ติดตั้ง Oh‑My‑Zsh:

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

ตั้งให้เป็นค่าเริ่มต้น:

```
chsh -s $(which zsh)
```

---

## 🔌 8) ปลั๊กอินสำคัญของ ZSH

### zsh-syntax-highlighting

```
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```

### zsh-autocomplete

```
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete
```

เพิ่มใน `~/.zshrc`:

```
plugins=(git zsh-autocomplete zsh-syntax-highlighting)
```

---

## 🎨 9) Oh‑My‑Posh + ฟอนต์สวย ๆ

ติดตั้ง:

```
curl -s https://ohmyposh.dev/install.sh | bash -s
```

ฟอนต์:

```
oh-my-posh font install FiraMono
```

ธีม:

สร้าง folder เก็บ themes

```
mkdir -p ~/.poshthemes
```

โหลด Theme จาก GitHub

```
curl -o ~/.poshthemes/cloud-native-azure.omp.json \
  https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/cloud-native-azure.omp.json
```

ตั้งค่าใน `~/.zshrc`:

```
export POSH_THEMES_PATH="$HOME/.poshthemes"
eval "$(oh-my-posh init zsh --config $POSH_THEMES_PATH/cloud-native-azure.omp.json)"
```

---

# 📁 ตั้งค่า SharedData ให้เมานต์อัตโนมัติแบบอ่าน‑เขียน

เหมาะมากสำหรับการแชร์ไฟล์ระหว่าง Fedora ↔ Windows

## 📌 สร้างตำแหน่งเมานต์ใน Home

```
mkdir -p ~/SharedData
```

## 🔍 หา UUID ของพาร์ติชัน NTFS

```
sudo blkid
```

ตัวอย่าง:

```
/dev/nvme0n1p5: UUID="1234-ABCD" TYPE="ntfs"
```

## 📝 เพิ่มใน /etc/fstab เพื่อเมานต์อัตโนมัติ

```
sudo nano /etc/fstab
```

เพิ่มบรรทัด:

```
UUID=1234-ABCD  /home/user/SharedData  ntfs-3g  defaults,uid=1000,gid=1000,windows_names,locale=en_US.utf8 0 0
```

## 🔧 ทดสอบเมานต์

```
sudo mount -a
```

ทดสอบเขียนไฟล์:

```
touch ~/SharedData/testfile
```

ถ้าสร้างได้ = พร้อมใช้งาน

---

# 🎉 พร้อมใช้งานเต็มที่!
