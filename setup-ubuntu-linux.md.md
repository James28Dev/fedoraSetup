# Linux Workstation Setup (Ubuntu 24.04 LTS GNOME)

## 1. Overview

README นี้ใช้เป็นเอกสารอ้างอิงสำหรับการติดตั้งและดูแล **เครื่องทำงานหลักด้านการพัฒนา Flutter / Android** โดยเน้น

* เสถียรภาพระยะยาว
* ประสิทธิภาพ
* ลดเวลาปรับแต่งซ้ำ

ระบบถูกออกแบบให้ **งานเป็นศูนย์กลาง** และแยก sandbox สำหรับทดลองออกจากสภาพแวดล้อมทำงานจริง

---

## 2. OS & Environment

* OS: Ubuntu 24.04 LTS
* Desktop: GNOME
* Firmware: UEFI

### ตรวจสอบ

```bash
lsb_release -a
```

### ตัวอย่างผลลัพธ์ที่ถูกต้อง

```text
Distributor ID: Ubuntu
Description:    Ubuntu 24.04 LTS
Release:        24.04
Codename:       noble
```

---

## 3. Hardware Specification

* CPU: AMD Ryzen 7 4800HS
* RAM: 16GB (ใช้งานจริง ~12GB)
* Storage: NVMe SSD 512GB
* GPU:

  * AMD iGPU (แสดงผลหลัก)
  * NVIDIA GTX 1650 Ti (on-demand)

### ตรวจสอบ

```bash
free -h
lsblk -d -o name,rota,tran
```

### ตัวอย่างผลลัพธ์ที่ถูกต้อง

```text
Mem: 15Gi 12Gi
nvme0n1  0  nvme
```

---

## 4. Disk Layout & Filesystem

* /boot/efi  → FAT32 (~1GB)
* /          → BTRFS
* swap       → 16GB (partition)
* SHAREDDATA → NTFS (ใช้งานข้าม OS)

### ตรวจสอบ

```bash
lsblk -f
```

### ตัวอย่างผลลัพธ์ที่ถูกต้อง

```text
nvme0n1p1 vfat    /boot/efi
nvme0n1p2 btrfs   /
nvme0n1p3 swap    [SWAP]
nvme0n1p4 ntfs    /mnt/SHAREDDATA
```

---

## 5. Swap & Memory Policy

* ใช้ swap แบบ partition
* ปิด hibernation
* swap ใช้เพื่อรองรับ workload หนัก (Flutter build / Emulator)

### ตรวจสอบ

```bash
swapon --show
```

### ตัวอย่างผลลัพธ์ที่ถูกต้อง

| NAME | TYPE | SIZE | USED | PRIO |
| ----- | ---- | ----- | ----- | ----- |
| /dev/nvme0n1p3 | partition | 16G | 0B | -2 |

---

## 6. Package Management Optimization (APT)

* ใช้ mirror ที่เร็ว
* เปิด parallel download

### ตรวจสอบ mirror

```bash
grep ^deb /etc/apt/sources.list
```

### ตรวจสอบการอัปเดต

```bash
sudo apt update
```

---

## 7. CPU Microcode

* ติดตั้ง AMD microcode เพื่อความเสถียร

### ตรวจสอบ

```bash
dpkg -l | grep microcode
```

### ตัวอย่างผลลัพธ์ที่ถูกต้อง

```text
ii  amd64-microcode
```

---

## 8. Power Management

* ใช้ TLP สำหรับ laptop

### ตรวจสอบสถานะ

```bash
tlp-stat -s
```

### ตัวอย่างผลลัพธ์ที่ถูกต้อง

```text
State: enabled
```

---

## 9. GPU Strategy (Hybrid NVIDIA)

* PRIME on-demand
* AMD iGPU แสดงผลหลัก
* NVIDIA ใช้เฉพาะ app ที่กำหนด

### ตรวจสอบ PRIME mode

```bash
prime-select query
```

### ตัวอย่างผลลัพธ์ที่ถูกต้อง

```text
on-demand
```

### App ที่บังคับใช้ NVIDIA

* Visual Studio Code
* Android Studio

### ตรวจสอบการใช้งานจริง

```bash
nvidia-smi
```

---

## 10. Filesystem Safety (BTRFS Snapshot)

* ใช้ Timeshift แบบ BTRFS
* Snapshot ก่อน:

  * system update ใหญ่
  * ติดตั้ง Android Studio / SDK

### ตรวจสอบ

```bash
timeshift --list
```

---

## 11. Development Environment

* git
* build-essential
* Flutter SDK
* Android Studio + Emulator

### ตรวจสอบ Flutter

```bash
flutter doctor
```

### ตัวอย่างผลลัพธ์ที่ถูกต้อง

```text
[✓] Flutter
[✓] Android toolchain
```

---

## 12. Sandbox Strategy

* Arch GNOME / OmarchyOS ใช้เป็น sandbox
* แยกจากเครื่องทำงานหลัก
* ไม่ mount SHAREDDATA

เป้าหมาย:

* ทดลอง WM (Hyprland)
* ทดลอง config
* ไม่กระทบงานจริง

---

## 13. Design Decisions (Intentional Choices)

* ไม่ใช้ rolling release บนเครื่องงาน
* ไม่ force NVIDIA ทั้งระบบ
* ไม่ tweak kernel ลึก
* แยก data / sandbox / production ออกจากกัน

---

## 14. Philosophy

ระบบที่ดีคือระบบที่:

* Update ได้โดยไม่กลัว
* พังแล้วย้อนกลับได้
* ไม่แย่งสมาธิจากการเขียนโค้ด

README นี้มีไว้เพื่อให้ **ตัวเองในอนาคต** เข้าใจว่า

> ทำไมระบบนี้ถึงถูกตั้งค่าแบบนี้
