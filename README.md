# settingFedora

คู่มือการตั้งค่า Fedora Linux หลังติดตั้งใหม่ พร้อมปรับการใช้งานร่วมกับ Windows

---

## 0. ตั้งค่า Windows
1. ปิด Fast Startup  
   - เปิด Control Panel > Power Options > Choose what the power buttons do > Change settings that are currently unavailable  
   - ยกเลิก `Turn on fast startup` > Save changes

2. ตรวจสอบพาร์ติชัน clean  
   - เปิด Command Prompt (Admin)  
   - รัน `chkdsk D: -f` (เปลี่ยน D: ตามไดฟ์)

---

## 1. ตั้งค่า DNF
แก้ไขไฟล์ `/etc/dnf/dnf.conf`:

```ini
max_parallel_downloads=20
fastestmirror=True
defaultyes=True
keepcache=True
best=True

