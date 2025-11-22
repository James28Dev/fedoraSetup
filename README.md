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

## ตั้งค่า DNF
   - แก้ไขไฟล์ `dnf.conf`:
```ini
sudo nano /etc/dnf/dnf.conf
```
   - เพิ่มข้อมูลในไฟล์ล่าง [Main]
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
sudo dnf install wget curl git gcc make python3 python3-pip gnome-tweaks backintime-gnome timeshift zsh
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

### ติดตั้ง ZSH
```ini
sudo dnf install zsh
```
   - ให้ zsh เป็นค่าเริ่มต้น
```ini
chsh -s $(which zsh)
```
   - ปิด terminal / console หรือพิมพ์
```ini
zsh
```
