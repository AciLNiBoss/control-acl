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

# ==========================================
#               REM DARURAT (TRAP)
# ==========================================
cleanup() {
    clear
    echo -e "${R}╔══════════════════════════════════════════╗${NC}"
    echo -e "${R}║         [!] REM DARURAT AKTIF [!]        ║${NC}"
    echo -e "${R}╠══════════════════════════════════════════╣${NC}"
    echo -e "${R}║${W} Menghentikan semua proses ACL Manager... ${R}║${NC}"
    echo -e "${R}╚══════════════════════════════════════════╝${NC}"
    echo -e ""
    
    if [ -n "$WEBHOOK_URL" ]; then
        su -c "curl -s -H \"Content-Type: application/json\" -X POST -d \"{\\\"content\\\": \\\"🛑 **[ACL Manager]** Skrip dihentikan paksa oleh pengguna (Rem Darurat)!\\\"}\" \"$WEBHOOK_URL\"" > /dev/null 2>&1
    fi
    exit 0
}

trap cleanup INT TERM HUP

# ==========================================
#               FUNGSI UI PANEL
# ==========================================
draw_header() {
    clear
    echo -e "${C}╔══════════════════════════════════════════╗${NC}"
    echo -e "${C}║${G}       ROBLOX MANAGER BY ACL (CLEAN)      ${C}║${NC}"
    echo -e "${C}╚══════════════════════════════════════════╝${NC}"
}

countdown() {
    local seconds=$1
    local msg=$2
    while [ $seconds -gt 0 ]; do
        draw_header
        echo -e "${Y} ▶ STATUS  : ${W}$msg${NC}"
        echo -e "${Y} ▶ MENUNGGU: ${C}$seconds detik...${NC}"
        echo -e "${C}──────────────────────────────────────────${NC}"
        echo -e "${R}   [!] Tekan CTRL+C untuk Berhenti [!]    ${NC}"
        sleep 1
        seconds=$((seconds - 1))
    done
}

# ==========================================
#               SETUP AWAL
# ==========================================
draw_header
read -p "$(echo -e ${Y}"[?] Tempelkan Link Private Server:\n> "${NC})" LINK
echo -e "${C}──────────────────────────────────────────${NC}"
read -p "$(echo -e ${Y}"[?] Tempelkan Link Webhook Discord (Kosongkan jika tidak pakai):\n> "${NC})" WEBHOOK_URL

APPS=$(pm list packages | grep "com.roblox.nomercy" | cut -d ":" -f2)
TIMER=$(date +%s)

if [ -z "$APPS" ]; then
    draw_header
    echo -e "${R}[!] Tidak ada aplikasi com.roblox.acl yang ditemukan!${NC}\n"
    exit
fi

TOTAL_APPS=$(echo "$APPS" | wc -w)

send_webhook() {
    local MSG=$1
    if [ -n "$WEBHOOK_URL" ]; then
        su -c "curl -s -H \"Content-Type: application/json\" -X POST -d \"{\\\"content\\\": \\\"$MSG\\\"}\" \"$WEBHOOK_URL\"" > /dev/null 2>&1
    fi
}

set_screen() {
    countdown 2 "Mengatur resolusi layar (wm density 164)..."
    su -c "wm density 164"
    su -c "service call window 101 i32 20"
}

run_setup() {
    set_screen
    send_webhook "🚀 **[ACL Manager]** Memulai eksekusi untuk $TOTAL_APPS akun..."
    
    # -------------------------------------------------------------
    # TITIK AWAL JENDELA MUNCUL (Titik Cubit)
    # Jika saat dicoba jendelanya tidak mau tergeser, ubah angka ini 
    # agar pas mengenai bagian atas (title bar) jendela Roblox yang baru muncul.
    # -------------------------------------------------------------
    SPAWN_X=450  # Posisi Kiri-Kanan (Biasanya di tengah layar)
    SPAWN_Y=150  # Posisi Atas-Bawah (Biasanya di atas)
    
    IDX=0
    for PKG in $APPS; do
        # PENGATURAN POSISI ATAS, TENGAH, BAWAH
        case $IDX in
            0) POS="Kiri Atas";    T_X=100; T_Y=150 ;; # Akun 1
            1) POS="Kanan Atas";   T_X=600; T_Y=150 ;; # Akun 2
            2) POS="Kiri Tengah";  T_X=100; T_Y=550 ;; # Akun 3
            3) POS="Kanan Tengah"; T_X=600; T_Y=550 ;; # Akun 4
            4) POS="Kiri Bawah";   T_X=100; T_Y=950 ;; # Akun 5
            5) POS="Kanan Bawah";  T_X=600; T_Y=950 ;; # Akun 6
            *) POS="Luar Layar";   T_X=350; T_Y=550 ;; # Akun 7 dst
        esac
        
        draw_header
        echo -e "${Y} ▶ Membuka Akun $((IDX + 1)) / $TOTAL_APPS (${POS})${NC}"
        echo -e "${W}   Target: $PKG${NC}"
        su -c "monkey -p $PKG -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
        
        countdown 8 "Menunggu $PKG terbuka penuh..."
        
        su -c "input keyevent 3"; sleep 1
        su -c "input keyevent 187"; sleep 2
        su -c "input tap 364 125"; sleep 1
        su -c "input tap 357 343"; sleep 1.5
        
        draw_header
        echo -e "${C} ▶ Menarik $PKG dari atas layar ke $POS...${NC}"
        
        # Eksekusi geser: Tarik dari titik SPAWN (Atas) menuju titik Target (T_X, T_Y)
        su -c "input swipe $SPAWN_X $SPAWN_Y $T_X $T_Y 600"
        sleep 1.5
        
        countdown 60 "Jeda antar akun agar tidak crash..."
        
        IDX=$((IDX + 1))
    done
    
    countdown 3 "Mengembalikan fokus ke Termux..."
    su -c "monkey -p com.termux -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
    
    for PKG in $APPS; do
        draw_header
        echo -e "${G} ▶ Proses Rejoin Private Server...${NC}"
        echo -e "${W}   Target: $PKG${NC}"
        
        su -c "monkey -p $PKG -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
        sleep 2
        su -c "am start -a android.intent.action.VIEW -d '$LINK' -p $PKG" > /dev/null 2>&1
        
        countdown 12 "Menunggu akun masuk ke dalam server..."
    done
    send_webhook "✅ **[ACL Manager]** Semua akun berhasil diarahkan ke Private Server!"
}

# Menjalankan fungsi setup
run_setup

# ==========================================
#             SISTEM MONITORING
# ==========================================
while true; do
    NOW=$(date +%s)
    
    if [ $((NOW - TIMER)) -ge 300 ]; then
        draw_header
        echo -e "${Y} ▶ MEMBERSIHKAN CACHE APLIKASI...${NC}"
        for PKG in $APPS; do
            su -c "rm -rf /data/data/$PKG/cache/*" > /dev/null 2>&1
        done
        TIMER=$NOW
        sleep 2
    fi

    for PKG in $APPS; do
        CHECK=$(su -c "dumpsys activity activities | grep 'mResumedActivity' | grep $PKG")
        if [ -z "$CHECK" ]; then
            send_webhook "⚠️ **[ACL Manager]** Terdeteksi Force Close pada $PKG! Melakukan pemulihan..."
            
            draw_header
            echo -e "${R} ⚠️ TERDETEKSI FORCE CLOSE PADA:${NC}"
            echo -e "${W}    $PKG${NC}"
            
            su -c "am force-stop $PKG"
            countdown 5 "Menutup paksa sisa data $PKG..."
            
            draw_header
            echo -e "${Y} ▶ Membuka ulang $PKG...${NC}"
            su -c "monkey -p $PKG -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
            countdown 10 "Menunggu aplikasi siap..."
            
            draw_header
            echo -e "${G} ▶ Rejoin Private Server untuk: $PKG...${NC}"
            su -c "am start -a android.intent.action.VIEW -d '$LINK' -p $PKG" > /dev/null 2>&1
            countdown 12 "Menunggu proses join selesai..."
            
            su -c "monkey -p com.termux -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
        fi
    done

    for i in $(seq 15 -1 1); do
        draw_header
        echo -e "${W} ▶ Total Akun : ${Y}$TOTAL_APPS${NC}"
        echo -e "${W} ▶ Status     : ${G}Monitoring Aktif...${NC}"
        echo -e "${W} ▶ Jam Sistem : ${Y}$(date +%T)${NC}"
        echo -e "${W} ▶ Cek Ulang  : ${C}$i detik lagi${NC}"
        echo -e "${C}──────────────────────────────────────────${NC}"
        echo -e "${R}   [!] Tekan CTRL+C untuk Berhenti [!]    ${NC}"
        sleep 1
    done
done
