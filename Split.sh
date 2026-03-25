#!/bin/bash
# ACL XCODE - Ultimate Manager (Swipe, Reopen & Cleaner)

# Warna
GREY='\033[90m'
BOLD='\033[1m'
GREEN='\033[92m'
CYAN='\033[96m'
YELLOW='\033[93m'
RED='\033[91m'
NC='\033[0m'

# Cek akses Root
if [ "$(id -u)" = "0" ]; then 
    RUN() { sh -c "$1"; }
else 
    RUN() { su -c "$1"; }
fi

clear
echo -e "${CYAN}${BOLD}"
echo "   █████╗  ██████╗██╗     "
echo "  ██╔══██╗██╔════╝██║     "
echo "  ███████║██║     ██║     "
echo "  ██╔══██║██║     ██║     "
echo "  ██║  ██║╚██████╗███████╗"
echo "  ╚═╝  ╚═╝ ╚═════╝╚══════╝"
echo -e "${NC}"
echo -e "${BOLD}     ULTIMATE ACL MANAGER START     ${NC}"
echo -e "${GREY}------------------------------------${NC}"

APPS=$(pm list packages | grep -i roblox | cut -d ":" -f2 | sort -u)

if [ -z "$APPS" ]; then 
    echo -e "${RED}[!] Tidak ada aplikasi Roblox yang terdeteksi. Batal jalan.${NC}"
    exit 1
fi

# Fungsi Setup Split Screen (Swipe yang Dirapikan)
run_setup() {
    echo -e "${YELLOW}[!] Menyiapkan layar Split Screen...${NC}"
    RUN "wm density 164"
    sleep 2
    RUN "service call window 101 i32 20"
    
    IDX=0
    COUNT=$(echo "$APPS" | wc -w)
    
    for PKG in $APPS; do
        IDX=$((IDX + 1))
        echo -e "${GREY}[>] Membuka $PKG...${NC}"
        RUN "monkey -p $PKG -c android.intent.category.LAUNCHER 1" >/dev/null 2>&1
        sleep 6
        
        # Masuk ke menu Recent Apps & atur Split
        RUN "input keyevent 3" # Home
        sleep 1
        RUN "input keyevent 187" # Recent Apps
        sleep 2
        
        RUN "input tap 364 125"
        sleep 1
        RUN "input tap 357 343"
        sleep 2
        
        RUN "input swipe 300 250 680 250 600"
        sleep 1
        
        # Perhitungan layar yang lebih rapi
        TOP=$(( (IDX - 1) * (1200 / COUNT) ))
        BOT=$(( IDX * (1200 / COUNT) ))
        
        RUN "input swipe 540 50 540 $TOP 300"
        RUN "input swipe 540 275 540 $BOT 300"
        sleep 0.5
    done
    
    # Kembali ke Termux
    RUN "monkey -p com.termux -c android.intent.category.LAUNCHER 1" >/dev/null 2>&1
    sleep 2
    echo -e "${GREEN}[V] Split Screen Selesai!${NC}"
}

# Tanya Pengguna apakah mau Auto-Swipe
echo -e "${YELLOW}Jalankan Auto-Setup (Split Screen)?${NC}"
echo "1. Ya (Otomatis atur layar)"
echo "2. Tidak (Langsung masuk ke Mode Cleaner & Reopen)"
echo -n -e "${CYAN}> Pilih (1/2): ${NC}"
read OPSI

if [ "$OPSI" == "1" ]; then
    run_setup
fi

echo -e "\n${GREEN}[V] Menjalankan Auto Cleaner & Reopen... (CTRL+C untuk stop)${NC}"
sleep 2

TIMER=$(date +%s)
LAST_CLEAN="Belum dilakukan"
INTERVAL=180 # 3 Menit

while true; do
    NOW=$(date +%s)
    
    if [ $((NOW - TIMER)) -ge $INTERVAL ] || [ "$LAST_CLEAN" = "Belum dilakukan" ]; then
        clear
        echo -e "${CYAN}${BOLD}=== ACL XCODE WATCHDOG ===${NC}"
        
        echo -e "${BOLD}Status Akun:${NC}"
        for PKG in $APPS; do
            PID=$(pidof $PKG)
            if [ -z "$PID" ]; then
                echo -e " ❌ $PKG : ${RED}MATI! Membuka ulang...${NC}"
                # Fitur Auto Reopen
                RUN "monkey -p $PKG -c android.intent.category.LAUNCHER 1" >/dev/null 2>&1
                sleep 5 # Beri waktu agar app bisa loading
            else
                echo -e " ✅ $PKG : ${GREEN}ONLINE${NC}"
            fi
        done
        
        echo -e "${GREY}------------------------------------${NC}"
        echo -e "${YELLOW}[$(date +%H:%M:%S)] Membersihkan RAM & Cache...${NC}"
        
        for PKG in $APPS; do 
            RUN "rm -rf /data/data/$PKG/cache/*" >/dev/null 2>&1
        done
        RUN "echo 3 > /proc/sys/vm/drop_caches"
        
        LAST_CLEAN=$(date +%H:%M:%S)
        TIMER=$(date +%s)
        
        echo -e "${GREEN}[V] Sistem bersih! Terakhir: $LAST_CLEAN${NC}"
        echo -e "${GREY}Menunggu 3 menit... (CTRL+C untuk stop)${NC}"
    fi
    
    sleep 10
done
