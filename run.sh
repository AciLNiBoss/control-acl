#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#   ACL XCODE - TERMUX FULL CONTROL
#   BY Acl XCODE (No Firebase, No Website)
# ==========================================

# Konfigurasi
WEBHOOK_URL="https://discord.com/api/webhooks/..."  # Isi webhook lo
LINK_PS="https://www.roblox.com/games/..."          # Isi link PS lo
APPS=($(pm list packages | grep "com.roblox" | cut -d ":" -f2))
SCRIPT_LYNX="loadstring(game:HttpGet('https://raw.githubusercontent.com/4LynxX/Lynx/refs/heads/main/LynxxMain.lua'))()"

# Warna biar keren
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fungsi kirim notifikasi Discord
send_discord() {
    if [ -n "$WEBHOOK_URL" ]; then
        curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"$1\"}" "$WEBHOOK_URL" &> /dev/null &
    fi
}

# Fungsi matiin semua Roblox
kill_all() {
    echo -e "${YELLOW}[STOP] Mematikan semua akun...${NC}"
    for KILL in "${APPS[@]}"; do
        su -c "am force-stop $KILL" 2>/dev/null
    done
    send_discord "🔴 **STOP**: Semua akun dimatikan"
}

# Fungsi inject script
inject_autoexec() {
    for PKG in "${APPS[@]}"; do
        su -c "mkdir -p /data/data/$PKG/files/auth/scripts/autoexec" 2>/dev/null
        su -c "echo \"$SCRIPT_LYNX\" > /data/data/$PKG/files/auth/scripts/autoexec/main.lua" 2>/dev/null
        su -c "chmod 777 /data/data/$PKG/files/auth/scripts/autoexec/main.lua" 2>/dev/null
    done
    echo -e "${GREEN}[INJECT] Script terpasang di ${#APPS[@]} akun${NC}"
}

# Fungsi buka split screen
rebuild_layout() {
    echo -e "${BLUE}[START] Membuka ${#APPS[@]} akun...${NC}"
    
    # Inject script dulu
    inject_autoexec
    
    # Buka semua akun
    for PKG in "${APPS[@]}"; do
        su -c "monkey -p $PKG -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
        sleep 3
    done
    
    # Tunggu bentar
    sleep 5
    
    # Buka link PS
    for PKG in "${APPS[@]}"; do
        su -c "am start -a android.intent.action.VIEW -d '$LINK_PS' -p $PKG" > /dev/null 2>&1
        sleep 2
    done
    
    echo -e "${GREEN}[SUCCESS] ${#APPS[@]} akun aktif!${NC}"
    send_discord "🟢 **START**: ${#APPS[@]} akun berjalan"
}

# Fungsi setting ulang
set_webhook() {
    read -p "Masukkan Webhook Discord: " new_webhook
    WEBHOOK_URL="$new_webhook"
    sed -i "s|WEBHOOK_URL=.*|WEBHOOK_URL=\"$new_webhook\"|" "$0"
    echo -e "${GREEN}Webhook tersimpan!${NC}"
}

set_link() {
    read -p "Masukkan Link PS: " new_link
    LINK_PS="$new_link"
    sed -i "s|LINK_PS=.*|LINK_PS=\"$new_link\"|" "$0"
    echo -e "${GREEN}Link PS tersimpan!${NC}"
}

# Menu utama
show_menu() {
    clear
    echo "╔════════════════════════════════════╗"
    echo "║    ACL XCODE - TERMUX CONTROLLER   ║"
    echo "╠════════════════════════════════════╣"
    echo "║ 1. 🚀 START ALL AKUN               ║"
    echo "║ 2. 🛑 STOP ALL AKUN                 ║"
    echo "║ 3. 📦 INJECT ULANG SCRIPT           ║"
    echo "║ 4. 🔧 SET WEBHOOK DISCORD           ║"
    echo "║ 5. 🔗 SET LINK PS                    ║"
    echo "║ 6. 📊 CEK STATUS                      ║"
    echo "║ 7. 📜 LIHAT LOG                        ║"
    echo "║ 8. 🔄 RESTART SCRIPT                   ║"
    echo "║ 0. ❌ KELUAR                             ║"
    echo "╚════════════════════════════════════╝"
    echo ""
    echo -e "Webhook: ${YELLOW}$WEBHOOK_URL${NC}"
    echo -e "Link PS: ${YELLOW}$LINK_PS${NC}"
    echo -e "Akun terdeteksi: ${GREEN}${#APPS[@]}${NC}"
    echo ""
    echo -n "Pilih menu [0-8]: "
}

# Loop utama
while true; do
    show_menu
    read choice
    case $choice in
        1)
            if [ "$LINK_PS" = "https://www.roblox.com/games/..." ]; then
                echo -e "${RED}Link PS belum diisi!${NC}"
                sleep 2
                continue
            fi
            rebuild_layout
            echo ""
            read -p "Tekan Enter untuk lanjut..."
            ;;
        2)
            kill_all
            echo ""
            read -p "Tekan Enter untuk lanjut..."
            ;;
        3)
            inject_autoexec
            echo ""
            read -p "Tekan Enter untuk lanjut..."
            ;;
        4)
            set_webhook
            echo ""
            read -p "Tekan Enter untuk lanjut..."
            ;;
        5)
            set_link
            echo ""
            read -p "Tekan Enter untuk lanjut..."
            ;;
        6)
            echo -e "${BLUE}[INFO] Script berjalan sejak: $(ps -o lstart= -p $$)${NC}"
            echo -e "${BLUE}[INFO] PID: $$${NC}"
            echo ""
            read -p "Tekan Enter untuk lanjut..."
            ;;
        7)
            if [ -f "nohup.out" ]; then
                tail -20 nohup.out
            else
                echo -e "${YELLOW}Belum ada log${NC}"
            fi
            echo ""
            read -p "Tekan Enter untuk lanjut..."
            ;;
        8)
            echo -e "${YELLOW}Restarting...${NC}"
            exec "$0"
            ;;
        0)
            echo -e "${GREEN}Dadah! 👋${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan salah!${NC}"
            sleep 1
            ;;
    esac
done
