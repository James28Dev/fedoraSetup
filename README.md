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
max_parallel_downloads=20
fastestmirror=True
defaultyes=True
keepcache=True
best=True
```
   - ตัวอย่าง
```
# see `man dnf.conf` for defaults and possible options

[main]
max_parallel_downloads=20
fastestmirror=True
defaultyes=True
keepcache=True
best=True
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
   - ตัวอย่าง
```ini
Sun Nov 16 21:47:18 2025       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 580.105.08             Driver Version: 580.105.08     CUDA Version: 13.0     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce GTX 1650 Ti     Off |   00000000:01:00.0 Off |                  N/A |
| N/A   37C    P8              1W /   41W |       4MiB /   4096MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A            3380      G   /usr/bin/gnome-shell                      1MiB |
+-----------------------------------------------------------------------------------------+
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
