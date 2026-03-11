#!/system/bin/sh

# ==========================================
#                 NAMA ACL                  
# ==========================================

clear
echo "=========================================="
echo "                NAMA ACL                  "
echo "=========================================="
echo ""
read -p "[?] Masukkan Link Private Server (PS): " LINK
read -p "[?] Masukkan Link Webhook Discord    : " WEBHOOK
echo ""

APPS=$(pm list packages | grep "com.roblox.nomercy" | cut -d ":" -f2)
TIMER=$(date +%s)

# Fungsi untuk mengirim info ke Webhook
send_webhook() {
    if [ -n "$WEBHOOK" ]; then
        MSG=$1
        # Menggunakan curl untuk mengirim data JSON ke Webhook
        curl -s -H "Content-Type: application/json" \
             -X POST \
             -d "{\"content\": \"$MSG\"}" \
             "$WEBHOOK" > /dev/null 2>&1
    fi
}

set_screen() {
    echo "[*] Mengatur density layar ke 164..."
    su -c "wm density 164"
    sleep 1
    su -c "service call window 101 i32 20"
}

run_setup() {
    set_screen
    IDX=0
    for PKG in $APPS; do
        # Logika Grid 3x3 (Tersusun ke bawah terlebih dahulu)
        ROW=$(( IDX % 3 ))
        COL=$(( IDX / 3 ))
        
        # Koordinat X (Kolom): Kiri, Tengah, Kanan
        if [ $COL -eq 0 ]; then T_X=250; elif [ $COL -eq 1 ]; then T_X=500; else T_X=750; fi
        
        # Koordinat Y (Baris ke bawah): Atas, Tengah, Bawah
        if [ $ROW -eq 0 ]; then T_Y=250; elif [ $ROW -eq 1 ]; then T_Y=610; else T_Y=950; fi
        
        echo "[>] Membuka $PKG (Menyusun di posisi: X=$T_X, Y=$T_Y)"
        su -c "monkey -p $PKG -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
        sleep 5
        
        # Membuka recent apps & mengatur posisi freeform
        su -c "input keyevent 3"; sleep 0.5
        su -c "input keyevent 187"; sleep 1.5
        su -c "input tap 364 125"; sleep 0.8
        su -c "input tap 357 343"; sleep 1
        
        # Menggeser jendela ke posisi Grid yang sudah dihitung
        su -c "input swipe 300 250 $T_X $T_Y 600"
        sleep 1
        
        IDX=$((IDX + 1))
    done
    
    su -c "monkey -p com.termux -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
    sleep 2
    
    for PKG in $APPS; do
        echo "[>] Join Private Server untuk $PKG"
        su -c "monkey -p $PKG -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
        sleep 2
        su -c "am start -a android.intent.action.VIEW -d '$LINK' -p $PKG" > /dev/null 2>&1
        sleep 12
    done
    
    # Kirim notifikasi sukses ke webhook
    send_webhook "✅ **NAMA ACL**: Setup selesai! Semua akun berhasil bergabung ke dalam Game."
}

if [ -z "$APPS" ]; then
    echo "[!] Tidak ada aplikasi Roblox (com.roblox.nomercy) yang ditemukan."
    exit
fi

run_setup

while true; do
    RESET=0
    NOW=$(date +%s)
    
    # Hapus cache setiap 5 menit (300 detik)
    if [ $((NOW - TIMER)) -ge 300 ]; then
        for PKG in $APPS; do
            su -c "rm -rf /data/data/$PKG/cache/*" > /dev/null 2>&1
        done
        TIMER=$NOW
    fi

    # Monitoring Force Close
    for PKG in $APPS; do
        CHECK=$(su -c "dumpsys activity activities | grep 'mResumedActivity' | grep $PKG")
        if [ -z "$CHECK" ]; then
            echo "[!] Terdeteksi Force Close pada: $PKG"
            send_webhook "⚠️ **NAMA ACL**: Aplikasi \`$PKG\` mengalami Force Close! Melakukan proses restart..."
            RESET=1
            break
        fi
    done

    # Proses Restart jika ada yang FC
    if [ $RESET -eq 1 ]; then
        sleep 10
        for PKG in $APPS; do su -c "am force-stop $PKG"; done
        sleep 2
        
        su -c "input keyevent 3"; sleep 1
        su -c "input keyevent 187"; sleep 2
        
        # Membersihkan recent apps
        for i in 1 2 3 4 5 6 7; do
            su -c "input swipe 540 1000 540 100 250"
            sleep 0.8
        done
        
        su -c "input keyevent 3"; sleep 1
        run_setup
        TIMER=$(date +%s)
        continue 
    fi

    echo "[$(date +%T)] Sedang memantau aktivitas aplikasi..."
    sleep 15
done
