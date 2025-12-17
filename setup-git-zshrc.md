# ฟังก์ชัน git-change สำหรับสลับโปรไฟล์ผู้ใช้

### วิธีนำไปใช้

เปิดไฟล์: 
```bash
nano ~/.zshrc
```

### คัดลอก Code นี้ไปวางไว้บนสุดของไฟล์
```bash
# ---------- Global github User Config  ----------
git-change() {
  # กำหนดรหัสสี
  local CYAN='\033[0;36m'
  local GREEN='\033[0;32m'
  local YELLOW='\033[1;33m'
  local RED='\033[0;31m'
  local NC='\033[0m' # ล้างสี

  # แสดง git user ปัจจุบัน
  echo "${CYAN}================================${NC}"
  echo " Current Git User: ${GREEN}$(git config --global user.name)${NC}"
  echo " Email: ${GREEN}$(git config --global user.email)${NC}"
  echo "${CYAN}================================${NC}"
  # แสดงตัวเลือก
  echo "Select Git User Profile to Switch:"
  echo "1) James (James28Dev)"
  echo "2) Ople (Ople03DevUi)"
  echo "3) Other (Manual Input)"
  echo -n "Enter choice [1-3]: "
  # รับค่าตัวเลือก
  read choice

  case $choice in
    1) git config --global user.name "James28Dev" && git config --global user.email "James28.Dev@gmail.com" ;;
    2) git config --global user.name "Ople03DevUi" && git config --global user.email "ople.uidesign@gmail.com" ;;
    3) echo -n "Name: "; read uname; echo -n "Email: "; read umail; git config --global user.name "$uname"; git config --global user.email "$umail" ;;
    # แสดงตัวเลือกไม่ถูกต้อง
    *) echo -e "${RED}Invalid option. No changes made.${NC}"; return 1 ;;
  esac

  # แสดงผลลัพธ์หลังเปลี่ยน
  echo "${CYAN}--------------------------------${NC}"
  echo "${GREEN}Successfully switched to:${NC}"
  echo "Current: ${YELLOW}$(git config user.name)${NC} <${YELLOW}$(git config user.email)${NC}>"
}
```

### บันทึกแล้วรัน: 
```bash
source ~/.zshrc
```
