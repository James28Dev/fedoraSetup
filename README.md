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
```ini
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda
```
ตรวจสอบการติดตั้ง
```ini
nvidia-smi
```
