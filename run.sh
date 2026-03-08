#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#   ROBLOX ACL MANAGER - UNIVERSAL RADAR
#   BY Acl XCODE
# ==========================================

C='\033[1;36m'; G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; W='\033[1;37m'; N='\033[0m'

clear
echo -e "${C}╔════════════════════════════════════════════╗${N}"
echo -e "${C}║${Y}      🚀 ACL XCODE ULTIMATE MANAGER 🚀      ${C}║${N}"
echo -e "${C}║${W}      Auto-Detect Multi-Package Mode        ${C}║${N}"
echo -e "${C}╚════════════════════════════════════════════╝${N}"

# --- INPUT DISCORD & PS ---
WEBHOOK_URL=""
while [[ ! $WEBHOOK_URL =~ ^https://discord.com/api/webhooks/ ]]; do
    echo -e "${G}[?] Masukkan URL Webhook Discord:${N}"
    read -r -p " ➔  " WEBHOOK_URL
done

LINK_PS=""
while [ -z "$LINK_PS" ]; do
    echo -e "${G}[?] Masukkan Link Private Server (PS):${N}"
    read -r -p " ➔  " LINK_PS
done

SCRIPT_LYNX="loadstring(game:HttpGet('https://raw.githubusercontent.com/4LynxX/Lynx/refs/heads/main/LynxxMain.lua'))()"

# RADAR OTOMATIS: Mencari semua package yang mengandung kata "roblox"
# Ini akan mendeteksi com.roblox.acl, com.roblox.acm, com.roblox.acl1, dll secara otomatis
APPS=($(pm list packages | grep "com.roblox" | cut -d ":" -f2))

send_discord() {
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$1\"}" "$WEBHOOK_URL" &> /dev/null
}

inject_autoexec() {
    for PKG in "${APPS[@]}"; do
        echo -e "${Y}[*] Injecting Lynx Hub to $PKG...${N}"
        su -c "mkdir -p /data/data/$PKG/files/auth/scripts/autoexec"
        su -c "echo \"$SCRIPT_LYNX\" > /data/data/$PKG/files/auth/scripts/autoexec/main.lua"
        su -c "chmod 777 /data/data/$PKG/files/auth/scripts/autoexec/main.lua"
    done
}

rebuild_layout() {
    su -c "wm density 164"
    su -c "service call window 101 i32 20"
    inject_autoexec
    
    for i in "${!APPS[@]}"; do
        PKG=${APPS[$i]}
        targets=(250 610 950 1290 1630); T_Y=${targets[$((i % 5))]}
        
        echo -e "${W}[*] Launching: ${G}$PKG${N}"
        su -c "monkey -p $PKG -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
        sleep 5 
        su -c "input keyevent KEYCODE_HOME"; sleep 0.5
        su -c "input keyevent KEYCODE_APP_SWITCH"; sleep 1.5
        su -c "input tap 364 125"; sleep 0.8
        su -c "input tap 357 343"; sleep 1
        su -c "input swipe 300 250 680 $T_Y 600"
        sleep 1
    done
    
    su -c "monkey -p com.termux -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
    sleep 2
    
    for PKG in "${APPS[@]}"; do
        echo -e "${G}[>] Joining PS: $PKG${N}"
        su -c "monkey -p $PKG -c android.intent.category.LAUNCHER 1" > /dev/null 2>&1
        sleep 1.5 
        su -c "am start -a android.intent.action.VIEW -d '$LINK_PS' -p $PKG" > /dev/null 2>&1
        sleep 12 
    done
}

if [ ${#APPS[@]} -eq 0 ]; then
    echo -e "${R}[!] ERROR: Tidak ada APK Roblox/ACL yang terdeteksi!${N}"
    exit 1
fi

echo -e "${G}[✓] Terdeteksi ${#APPS[@]} aplikasi siap running.${N}"
send_discord "🚀 **ACL XCODE START**: Menjalankan ${#APPS[@]} akun."
rebuild_layout

while true; do
    STUCK=false
    for PKG in "${APPS[@]}"; do
        CHECK=$(su -c "dumpsys window windows | grep -E 'mCurrentFocus' | grep $PKG")
        if [ -z "$CHECK" ]; then STUCK=true; break; fi
    done

    if [ "$STUCK" = true ]; then
        send_discord "⚠️ **ACL XCODE ALERT**: Akun DC. Restarting..."
        for KILL in "${APPS[@]}"; do su -c "am force-stop $KILL"; done
        rebuild_layout
    fi
    sleep 30
done
