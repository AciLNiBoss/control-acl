#!/bin/bash
# ACL XCODE - Ultimate Optimizer & Cache Cleaner (Super Ringan)

# Warna
GREY='\033[90m'
BOLD='\033[1m'
GREEN='\033[92m'
CYAN='\033[96m'
YELLOW='\033[93m'
RED='\033[91m'
NC='\033[0m'

# Cek akses Root (Wajib untuk ubah resolusi & hapus RAM)
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
echo -e "${BOLD}     LIGHTWEIGHT ACL MANAGER START     ${NC}"
echo -e "${GREY}---------------------------------------${NC}"

# Menu Optimasi Layar
echo -e "${YELLOW}Pilih Mode Layar Sebelum Start:${NC}"
echo "1. Mode Kentang (720p & 120 DPI) + Start Cleaner"
echo "2. Normal Display (Langsung Start Cleaner)"
echo "3. Reset Layar ke Normal & Keluar"
echo -n -e "${CYAN}> Pilih (1/2/3): ${NC}"
read OPSI

if [ "$OPSI" == "1" ]; then
    echo -e "${GREY}[!] Mengubah resolusi ke 720p dan DPI 120...${NC}"
    RUN "wm size 720x1280"
    RUN "wm density 120"
    sleep 2
    echo -e "${GREEN}[V] Layar dioptimasi! Jangan kaget kalau buram/kecil.${NC}"
elif [ "$OPSI" == "3" ]; then
    echo -e "${GREY}[!] Mengembalikan resolusi ke pengaturan awal...${NC}"
    RUN "wm size reset"
    RUN "wm density reset"
    echo -e "${GREEN}[V] Layar kembali normal. Script dihentikan.${NC}"
    exit 0
fi

# Deteksi Aplikasi Roblox
APPS=$(pm list packages | grep -i roblox | cut -d ":" -f2 | sort -u)

if [ -z "$APPS" ]; then 
    echo -e "${RED}[!] Tidak ada aplikasi Roblox yang terdeteksi. Batal jalan.${NC}"
    exit 1
fi

echo -e "\n${GREEN}[V] Menyiapkan Auto Cleaner... (CTRL+C untuk berhenti)${NC}"
sleep 2

TIMER=$(date +%s)
LAST_CLEAN="Belum dilakukan"
INTERVAL=180 # 3 Menit

# Main Loop Pembersihan
while true; do
    NOW=$(date +%s)
    
    if [ $((NOW - TIMER)) -ge $INTERVAL ] || [ "$LAST_CLEAN" = "Belum dilakukan" ]; then
        # 1. Bersihkan layar Terminal biar ga numpuk dan bikin lag
        clear
        echo -e "${CYAN}${BOLD}=== ACL XCODE AUTO CLEANER ===${NC}"
        
        # 2. Pengecekan Status Ringan (Hanya cek PID tanpa buka layar)
        echo -e "${BOLD}Status Akun di Latar Belakang:${NC}"
        for PKG in $APPS; do
            PID=$(pidof $PKG)
            if [ -z "$PID" ]; then
                echo -e " ❌ $PKG : ${RED}OFFLINE / MATI${NC}"
            else
                echo -e " ✅ $PKG : ${GREEN}ONLINE${NC}"
            fi
        done
        echo -e "${GREY}---------------------------------------${NC}"
        echo -e "${YELLOW}[$(date +%H:%M:%S)] Sedang membersihkan sistem...${NC}"
        
        # 3. Hapus Cache Storage (Sampah File)
        for PKG in $APPS; do 
            RUN "rm -rf /data/data/$PKG/cache/*" >/dev/null 2>&1
        done
        
        # 4. Hapus Cache RAM Sistem Android (Sangat Penting untuk Redfinger)
        RUN "echo 3 > /proc/sys/vm/drop_caches"
        
        LAST_CLEAN=$(date +%H:%M:%S)
        TIMER=$(date +%s)
        
        echo -e "${GREEN}[V] File Cache & RAM Sistem berhasil di-refresh!${NC}"
        echo -e "${BOLD}Terakhir bersih-bersih: $LAST_CLEAN${NC}"
        echo -e "${GREY}Menunggu 3 menit untuk pembersihan berikutnya... (CTRL+C untuk stop)${NC}"
    fi
    
    # Istirahat 10 detik agar tidak membebani CPU
    sleep 10
done
