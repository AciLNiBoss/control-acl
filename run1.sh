#!/system/bin/sh

# ==========================================
#             WARNA UNTUK UI TERMUX
# ==========================================
R='\033[1;31m'  # Merah
G='\033[1;32m'  # Hijau
Y='\033[1;33m'  # Kuning
C='\033[1;36m'  # Cyan
W='\033[1;37m'  # Putih
NC='\033[0m'    # Reset Warna

clear
echo -e "${C}==========================================${NC}"
echo -e "${G}       ROBLOX MANAGER BY ACL (CLEAN)      ${NC}"
echo -e "${C}==========================================${NC}"
echo -e ""

# 1. Meminta input Link Private Server
read -p "$(echo -e ${Y}"[?] Tempelkan Link Private Server: "${NC})" LINK

# 2. Meminta input Link Webhook Discord (Bisa dikosongkan)
read -p "$(echo -e ${Y}"[?] Tempelkan Link Webhook Discord (Tekan Enter jika tidak pakai): "${NC})" WEBHOOK_URL
echo -e ""

# Mencari package dengan nama com.roblox.acl
APPS=$(pm list packages | grep "com.roblox.acl" | cut -d ":" -f2)
TIMER=$(date +%s)

if [ -z "$APPS" ]; then
    echo -e "${R}[!] Tidak ada aplikasi com.roblox.acl yang ditemukan. Pemasangan dibatalkan.${NC}"
    exit
fi

TOTAL_APPS=$(echo "$APPS" | wc -w)

# Fungsi untuk mengirim pesan ke Discord via Webhook
send_webhook() {
    local MSG=$1
    if [ -n "$WEBHOOK_URL" ]; then
        su -c "curl -s -H \"Content-Type: application/json\" -X POST -d \"{\\\"content\\\": \\\"$MSG\\\"}\" \"$WEBHOOK_URL\"" > /dev/null 2>&1
    fi
}

set_screen() {
    echo -e "${C}[*] Mengatur resolusi layar (wm density 164)...${NC}"
    su -c "wm density 164"
    sleep 1
    su -c "service call window 101 i32 20"
}

run_setup() {
    set_screen
    send_webhook "🚀 **[ACL Manager]** Memulai eksekusi untuk $TOTAL_APPS akun..."
    
    IDX=0
    for PKG in $APPS; do
        T_Y=$(echo "250 610 950" | cut -d " " -f$(( (IDX % 3) + 1 )))
        echo -e "${Y}[>] Membuka $PKG...${NC}"
        su -c "monkey -p $PKG -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
        sleep 8  # Jeda nunggu Roblox terbuka penuh
        
        su -c "input keyevent 3"; sleep 1    # Jeda tombol Home
        su -c "input keyevent 187"; sleep 2  # Jeda nunggu menu Recent Apps muncul
        su -c "input tap 364 125"; sleep 1   # Jeda nunggu pop-up ikon muncul
        su -c "input tap 357 343"; sleep 1.5 # Jeda nunggu Roblox jadi mode Freeform
        
        su -c "input swipe 300 250 680 $T_Y 600"
        sleep 1.5 # Jeda nunggu jendela selesai digeser
        
        # --- PERUBAHAN: Delay 60 detik setiap selesai setting 1 akun ---
        echo -e "${C}[*] Menunggu 60 detik sebelum lanjut ke akun berikutnya...${NC}"
        sleep 30
        
        IDX=$((IDX + 1))
    done
    
    echo -e "${C}[*] Mengembalikan fokus ke Termux...${NC}"
    su -c "monkey -p com.termux -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
    sleep 2
    
    for PKG in $APPS; do
        echo -e "${G}[>] Join Private Server: $PKG...${NC}"
        su -c "monkey -p $PKG -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
        sleep 2
        su -c "am start -a android.intent.action.VIEW -d '$LINK' -p $PKG" > /dev/null 2>&1
        sleep 12
    done
    send_webhook "✅ **[ACL Manager]** Semua akun berhasil diarahkan ke Private Server!"
}

run_setup

echo -e "\n${G}[*] Sistem Monitoring Aktif. Tekan CTRL+C di Termux untuk berhenti.${NC}\n"

while true; do
    NOW=$(date +%s)
    
    # Hapus Cache tiap 5 menit (300 detik)
    if [ $((NOW - TIMER)) -ge 300 ]; then
        echo -e "${C}[*] $(date +%T) - Membersihkan cache aplikasi...${NC}"
        for PKG in $APPS; do
            su -c "rm -rf /data/data/$PKG/cache/*" > /dev/null 2>&1
        done
        TIMER=$NOW
    fi

    # Cek apakah ada akun yang keluar/Force Close
    for PKG in $APPS; do
        CHECK=$(su -c "dumpsys activity activities | grep 'mResumedActivity' | grep $PKG")
        if [ -z "$CHECK" ]; then
            echo -e "${R}[!] Terdeteksi Force Close pada: $PKG${NC}"
            send_webhook "⚠️ **[ACL Manager]** Terdeteksi Force Close pada $PKG! Menutup dan membuka ulang hanya akun tersebut..."
            
            # --- PERUBAHAN: Hanya menutup (force-stop) aplikasi yang crash ---
            su -c "am force-stop $PKG"
            sleep 2
            
            # Membuka kembali aplikasi yang crash agar tidak tertinggal
            echo -e "${Y}[>] Membuka ulang $PKG...${NC}"
            su -c "monkey -p $PKG -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
            sleep 10
            
            echo -e "${G}[>] Rejoin Private Server untuk: $PKG...${NC}"
            su -c "am start -a android.intent.action.VIEW -d '$LINK' -p $PKG" > /dev/null 2>&1
            sleep 12
            
            # Kembalikan fokus ke Termux
            su -c "monkey -p com.termux -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
        fi
    done

    echo -e "${W}[$(date +%T)] Memantau kestabilan $TOTAL_APPS akun...${NC}"
    sleep 15
done
