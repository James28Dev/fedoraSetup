# settingFedora

คู่มือการตั้งค่า Fedora Linux หลังติดตั้งใหม่ พร้อมปรับการใช้งานร่วมกับ Windows

---

## ตั้งค่า Windows
### ปิด Fast Startup
   - เปิด `Control Panel` > `Power Options` > `Choose what the power buttons do` > `Change settings that are currently unavailable`
   - ยกเลิก `Turn on fast startup` > `Save changes`

### ตรวจสอบพาร์ติชัน clean
   - เปิด `Command Prompt (Admin)`
   - รัน (เปลี่ยน D: ตามไดฟ์)
```ini
chkdsk D: -f
```
## ลบโปรแกรมที่ไม่ได้ใช้งาน
```ini
sudo dnf remove -y gnome-contacts gnome-weather gnome-maps gnome-tour gnome-color-manager simple-scan gnome-font-viewer gnome-system-monitor gnome-calendar gnome-connections mediawriter
```

## ตั้งค่า DNF
   - แก้ไขไฟล์ `dnf.conf`:
```ini
sudo nano /etc/dnf/dnf.conf
```
   - เพิ่มข้อมูลในไฟล์ `dnf.conf`
```ini
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
```

## ติดตั้ง NVIDIA Driver
   - ติดตั้ง Nvidia packages 
```ini
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda
```
   - ตรวจสอบการติดตั้ง
```ini
nvidia-smi
```

## ติดตั้งเครื่องมือพื้นฐาน
```ini
sudo dnf install wget curl git gcc make python3 python3-pip gnome-tweaks backintime-gnome zsh
```
## อัปเดทและอัปเกตระบบ
```ini
sudo dnf update  || sudo dnf upgrade
```

## ทำความสะอาด DNF Cache
   - ล้าง cache ของ DNF ทั้งหมด
```ini
sudo dnf clean all
```

## ตั้งค่า ZSH
### ตรวจสอบ Shell ปัจจุบัน
```ini
echo $SHELL
```

### ติดตั้ง Oh-My-Zsh
```ini
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
   - ให้ zsh เป็นค่าเริ่มต้น
```ini
chsh -s $(which zsh)
```

### ติดตั้ง Plugins
   - zsh-syntax-highlighting plugin
```ini
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```
   - zsh-autocomplete plugin 
```ini
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete
```

### แก้ไขไฟล์ ~/.zshrc 
เปิดไฟล์ ~/.zshrc 
```ini
sudo nano ~/.zshrc
```
จาก plugins=(git) เป็น 
```ini
plugins=(git zsh-autocomplete zsh-syntax-highlighting)
```

### ติดตั้ง Oh-My-Posh
```ini
curl -s https://ohmyposh.dev/install.sh | bash -s
```
   - ติดตั้ง font fira-mono
```ini
oh-my-posh font install FiraMono
```   
   - ติดตั้ง Themes
สร้างโฟลเดอร์เก็บ theme
```ini
mkdir -p ~/.poshthemes
```
โหลด .omp.json ของ theme เก็บใน ~/.poshthemes
```ini
curl -o ~/.poshthemes/cloud-native-azure.omp.json https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/cloud-native-azure.omp.json
```
แก้ไขไฟล์ ~/.zshrc โหลด theme:
เปิดไฟล์ ~/.zshrc 
```ini
sudo nano ~/.zshrc
```
```ini
export POSH_THEMES_PATH="$HOME/.poshthemes"
eval "$(oh-my-posh init zsh --config $POSH_THEMES_PATH/cloud-native-azure.omp.json)"
```
