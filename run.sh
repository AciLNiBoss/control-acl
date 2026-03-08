#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#   ROBLOX ACL MANAGER - FULL C2
#   BY Acl XCODE (Full Control)
# ==========================================

FIREBASE_URL="https://panel-acl-default-rtdb.asia-southeast1.firebasedatabase.app/server1.json"
SCRIPT_BASE="loadstring(game:HttpGet('https://raw.githubusercontent.com/4LynxX/Lynx/refs/heads/main/LynxxMain.lua'))()"
APPS=($(pm list packages | grep "com.roblox" | cut -d ":" -f2))

# Variabel Global
WEBHOOK_URL=""
LINK_PS=""
LYNX_CONFIG=""

# --- FUNGSI-FUNGSI ---
send_discord() {
    if [ -n "$WEBHOOK_URL" ]; then
        curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"$1\"}" "$WEBHOOK_URL" &> /dev/null &
    fi
}

kill_all() {
    for KILL in "${APPS[@]}"; do su -c "am force-stop $KILL"; done
}

# Fungsi untuk membuat script Lynx dengan konfigurasi
generate_lynx_script() {
    local config_json="$1"
    
    # Escape JSON untuk dimasukkan ke dalam script
    local escaped_json=$(echo "$config_json" | sed 's/"/\\"/g')
    
    # Generate script dengan konfigurasi
    cat << EOF
-- Lynx Auto Loader dengan Config
local config = $config_json

-- Load Lynx dengan config
loadstring(game:HttpGet('https://raw.githubusercontent.com/4LynxX/Lynx/refs/heads/main/LynxxMain.lua'))()

-- Terapkan config setelah Lynx terload
wait(2)
if Lynx and Lynx.ApplyConfig then
    Lynx.ApplyConfig(config)
else
    warn("Gagal menerapkan config")
end
EOF
}

inject_autoexec() {
    local script_content="$1"
    
    for PKG in "${APPS[@]}"; do
        su -c "mkdir -p /data/data/$PKG/files/auth/scripts/autoexec"
        echo "$script_content" | su -c "cat > /data/data/$PKG/files/auth/scripts/autoexec/main.lua"
        su -c "chmod 777 /data/data/$PKG/files/auth/scripts/autoexec/main.lua"
    done
}

rebuild_layout() {
    local link="$1"
    local lynx_script="$2"
    
    su -c "wm density 164"
    su -c "service call window 101 i32 20"
    
    # Inject script dengan config
    inject_autoexec "$lynx_script"
    
    SCREEN_W=720; SCREEN_H=1280
    TOTAL_APPS=${#APPS[@]}
    WINDOW_H=$((SCREEN_H / TOTAL_APPS))
    
    for i in "${!APPS[@]}"; do
        PKG=${APPS[$i]}
        su -c "monkey -p $PKG -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
        sleep 5 
        su -c "input keyevent KEYCODE_HOME"; sleep 0.5
        su -c "input keyevent KEYCODE_APP_SWITCH"; sleep 1.5
        su -c "input tap 364 125"; sleep 0.8
        su -c "input tap 357 343"; sleep 1.5
        
        TASK_ID=$(su -c "dumpsys activity activities | grep -B 2 'realActivity.*$PKG' | grep 'taskId=' | grep -oP '(?<=taskId=)[0-9]+' | tail -n 1")
        
        POS_TOP=$((i * WINDOW_H))
        POS_BOTTOM=$(((i + 1) * WINDOW_H))
        
        if [ -n "$TASK_ID" ]; then
            su -c "am task resize $TASK_ID 0 $POS_TOP $SCREEN_W $POS_BOTTOM"
        fi
        sleep 1
    done
    
    su -c "monkey -p com.termux -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
    sleep 2
    
    for PKG in "${APPS[@]}"; do
        su -c "am start -a android.intent.action.VIEW -d '$link' -p $PKG" > /dev/null 2>&1
        sleep 12 
    done
}

# Parse JSON menggunakan grep/sed sederhana
parse_json() {
    local json="$1"
    local key="$2"
    
    # Coba ambil nilai dengan berbagai format
    local value=$(echo "$json" | grep -oP "\"$key\"\s*:\s*\"\K[^\"]+" | head -1)
    
    if [ -z "$value" ]; then
        # Coba untuk boolean/number tanpa quote
        value=$(echo "$json" | grep -oP "\"$key\"\s*:\s*\K[^,}]+" | head -1 | tr -d ' ')
    fi
    
    echo "$value"
}

# --- MAIN LOOP (C2 POLLING) ---
echo "Menghubungkan ke Web Panel ACL XCODE..."
LAST_STATE="STOP"

while true; do
    # Ambil data JSON dari Firebase
    DATA=$(curl -s "$FIREBASE_URL")
    
    # Ekstrak data dasar
    COMMAND=$(parse_json "$DATA" "command")
    LINK_PS=$(parse_json "$DATA" "link_ps")
    WEBHOOK_URL=$(parse_json "$DATA" "webhook_url")
    
    # Ekstrak Lynx config (ambil seluruh object)
    LYNX_CONFIG=$(echo "$DATA" | grep -oP '"lynx_config":\{[^}]*\}')
    
    # Jika ada command START
    if [ "$COMMAND" == "START" ] && [ "$LAST_STATE" == "STOP" ]; then
        echo "[+] Web Command: START"
        LAST_STATE="START"
        
        send_discord "🟢 **ACL XCODE START**: Membuka ${#APPS[@]} akun dengan konfigurasi..."
        
        # Generate script dengan config
        if [ -n "$LYNX_CONFIG" ]; then
            LYNX_SCRIPT=$(generate_lynx_script "{${LYNX_CONFIG#*\{}")
        else
            # Default config jika tidak ada
            LYNX_SCRIPT="$SCRIPT_BASE"
        fi
        
        rebuild_layout "$LINK_PS" "$LYNX_SCRIPT"
        send_discord "✅ **ACL XCODE RUNNING**: ${#APPS[@]} akun aktif dengan config"
        
    # Jika website menekan STOP
    elif [ "$COMMAND" == "STOP" ] && [ "$LAST_STATE" == "START" ]; then
        echo "[-] Web Command: STOP"
        LAST_STATE="STOP"
        send_discord "🔴 **ACL XCODE STOP**: Mematikan semua akun..."
        kill_all
    fi

    # Monitoring Crash
    if [ "$LAST_STATE" == "START" ]; then
        STUCK=false
        for PKG in "${APPS[@]}"; do
            CHECK=$(su -c "dumpsys window windows | grep -E 'mCurrentFocus' | grep $PKG")
            if [ -z "$CHECK" ]; then STUCK=true; break; fi
        done

        if [ "$STUCK" = true ]; then
            echo "[!] Crash terdeteksi. Restarting..."
            send_discord "⚠️ **ACL XCODE ALERT**: Terdeteksi DC/Crash! Melakukan restart..."
            kill_all
            sleep 2
            
            # Regenerate script untuk restart
            if [ -n "$LYNX_CONFIG" ]; then
                LYNX_SCRIPT=$(generate_lynx_script "{${LYNX_CONFIG#*\{}")
            else
                LYNX_SCRIPT="$SCRIPT_BASE"
            fi
            
            rebuild_layout "$LINK_PS" "$LYNX_SCRIPT"
        fi
    fi

    sleep 5
done
