#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#   ROBLOX ACL MANAGER - ADVANCED EDITION
#   BY Acl XCODE | Multi-Account Controller
# ==========================================

# ========== KONFIGURASI ==========
SCRIPT_BASE="loadstring(game:HttpGet('https://raw.githubusercontent.com/4LynxX/Lynx/refs/heads/main/LynxxMain.lua'))()"
APPS=($(pm list packages | grep "com.roblox" | cut -d ":" -f2))

# Variabel Global
WEBHOOK_URL="https://discord.com/api/webhooks/1351397684464849028/2IZf0bkS7ChFf16lQR0f7yLEyzqL7G0zzcCwYxy9i0BcKSCY5nADb3BidzIK7W86h35D"
LINK_PS=""
LYNX_CONFIG=""
IS_RUNNING=false
START_TIME=0
CRASH_COUNT=0

# ========== FUNGSI UTILITY ==========
send_discord() {
    if [ -n "$WEBHOOK_URL" ]; then
        curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"$1\"}" "$WEBHOOK_URL" &> /dev/null &
    fi
}

kill_all() {
    echo "[KILL] Mematikan semua aplikasi Roblox..."
    for KILL in "${APPS[@]}"; do 
        su -c "am force-stop $KILL" 2>/dev/null
        echo "  └─ ✓ $KILL"
    done
}

get_uptime() {
    if $IS_RUNNING; then
        local uptime=$(( $(date +%s) - START_TIME ))
        local hours=$((uptime / 3600))
        local minutes=$(( (uptime % 3600) / 60 ))
        local seconds=$((uptime % 60))
        printf "%02d:%02d:%02d" $hours $minutes $seconds
    else
        echo "00:00:00"
    fi
}

get_active_count() {
    local count=0
    for PKG in "${APPS[@]}"; do
        CHECK=$(su -c "dumpsys window windows | grep -E 'mCurrentFocus' | grep $PKG" 2>/dev/null)
        if [ -n "$CHECK" ]; then
            ((count++))
        fi
    done
    echo "$count/${#APPS[@]}"
}

draw_progress_bar() {
    local current=$1
    local total=$2
    local width=30
    local percentage=$((current * 100 / total))
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))
    
    printf "["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %3d%%" $percentage
}

# ========== FUNGSI UTAMA ==========
generate_lynx_script() {
    local config_json="$1"
    
    cat << EOF
-- Lynx Auto Loader dengan Config
local config = $config_json
loadstring(game:HttpGet('https://raw.githubusercontent.com/4LynxX/Lynx/refs/heads/main/LynxxMain.lua'))()
wait(2)
if Lynx and Lynx.ApplyConfig then Lynx.ApplyConfig(config) end
EOF
}

inject_autoexec() {
    local script_content="$1"
    
    echo "[INJECT] Menginjeksi script autoexec..."
    for PKG in "${APPS[@]}"; do
        su -c "mkdir -p /data/data/$PKG/files/auth/scripts/autoexec" 2>/dev/null
        echo "$script_content" | su -c "cat > /data/data/$PKG/files/auth/scripts/autoexec/main.lua" 2>/dev/null
        su -c "chmod 777 /data/data/$PKG/files/auth/scripts/autoexec/main.lua" 2>/dev/null
        echo "  └─ ✓ $PKG"
    done
}

rebuild_layout() {
    local link="$1"
    local lynx_script="$2"
    
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  [BUILD] Mengatur Layout Multi-Account"
    echo "═══════════════════════════════════════════════════════════"
    
    su -c "wm density 164" >/dev/null 2>&1
    su -c "service call window 101 i32 20" >/dev/null 2>&1
    
    inject_autoexec "$lynx_script"
    
    SCREEN_W=720; SCREEN_H=1280
    TOTAL_APPS=${#APPS[@]}
    WINDOW_H=$((SCREEN_H / TOTAL_APPS))
    
    echo ""
    echo "[LAUNCH] Membuka ${#APPS[@]} akun..."
    
    for i in "${!APPS[@]}"; do
        PKG=${APPS[$i]}
        echo "  └─ [$((i+1))/$TOTAL_APPS] $PKG"
        
        su -c "monkey -p $PKG -c android.intent.category.LAUNCHER 1" >/dev/null 2>&1
        sleep 5
        
        su -c "input keyevent KEYCODE_HOME" >/dev/null 2>&1; sleep 0.5
        su -c "input keyevent KEYCODE_APP_SWITCH" >/dev/null 2>&1; sleep 1.5
        su -c "input tap 364 125" >/dev/null 2>&1; sleep 0.8
        su -c "input tap 357 343" >/dev/null 2>&1; sleep 1.5
        
        TASK_ID=$(su -c "dumpsys activity activities | grep -B 2 'realActivity.*$PKG' | grep 'taskId=' | grep -oP '(?<=taskId=)[0-9]+' | tail -n 1" 2>/dev/null)
        
        POS_TOP=$((i * WINDOW_H))
        POS_BOTTOM=$(((i + 1) * WINDOW_H))
        
        if [ -n "$TASK_ID" ]; then
            su -c "am task resize $TASK_ID 0 $POS_TOP $SCREEN_W $POS_BOTTOM" >/dev/null 2>&1
            echo "     └─ Task $TASK_ID diresize"
        fi
        sleep 1
    done
    
    echo ""
    echo "[FOCUS] Mengembalikan Termux..."
    su -c "monkey -p com.termux -c android.intent.category.LAUNCHER 1" >/dev/null 2>&1
    sleep 2
    
    echo ""
    echo "[LINK] Membuka Private Server..."
    for PKG in "${APPS[@]}"; do
        su -c "am start -a android.intent.action.VIEW -d '$link' -p $PKG" >/dev/null 2>&1
        echo "  └─ ✓ $PKG"
        sleep 12
    done
    
    echo ""
    echo "[✓] BUILD COMPLETE - Semua akun siap!"
}

# ========== MENU TAMPILAN ==========
show_header() {
    clear
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║              ROBLOX ACL MANAGER - ADVANCED              ║"
    echo "║                   Multi-Account Controller              ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║ Status   : $(if $IS_RUNNING; then echo "🟢 RUNNING"; else echo "🔴 STOPPED"; fi)                          ║"
    echo "║ Uptime   : $(get_uptime)                                          ║"
    echo "║ Active   : $(get_active_count) Active Accounts                    ║"
    echo "║ Crashes  : $CRASH_COUNT                                            ║"
    echo "╚══════════════════════════════════════════════════════════╝"
}

show_stats() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                    LIVE STATISTICS                       ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    
    local active=$(get_active_count | cut -d'/' -f1)
    local total=${#APPS[@]}
    echo "║ Active Accounts: $active/$total"
    echo "║ $(draw_progress_bar $active $total)"
    
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║ DETECTED ACCOUNTS:                                       ║"
    local i=1
    for app in "${APPS[@]}"; do
        local status=$(su -c "dumpsys window windows | grep -E 'mCurrentFocus' | grep $app" 2>/dev/null && echo "🟢" || echo "⚫")
        printf "║  %2d. %-30s %s\n" $i "$app" "$status"
        ((i++))
    done
    echo "╚══════════════════════════════════════════════════════════╝"
}

show_config() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                   CURRENT CONFIGURATION                 ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║ LINK PS    : $(echo ${LINK_PS:-"Not Set"} | cut -c1-50)"
    echo "║ WEBHOOK    : $(echo ${WEBHOOK_URL:-"Not Set"} | cut -c1-50)"
    echo "║ LYNX CONFIG: ${LYNX_CONFIG:-"Default"}"
    echo "╚══════════════════════════════════════════════════════════╝"
}

show_menu() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                         MENU                             ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║  [1] 🚀 START  - Multi Account                          ║"
    echo "║  [2] ⏹️  STOP   - Stop All                              ║"
    echo "║  [3] 🔄 RESTART - Restart All                           ║"
    echo "║  ────────────────────────────────────────────────────── ║"
    echo "║  [4] 🔗 Set Link Private Server                         ║"
    echo "║  [5] 📢 Set Discord Webhook                             ║"
    echo "║  [6] ⚙️  Set Lynx Config                                ║"
    echo "║  ────────────────────────────────────────────────────── ║"
    echo "║  [7] 📊 View Statistics                                ║"
    echo "║  [8] 🔧 Configuration                                  ║"
    echo "║  [0] ❌ Exit                                           ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    echo -n "  Select Option [0-8] → "
}

# ========== MENU FUNCTIONS ==========
start_accounts() {
    if [ -z "$LINK_PS" ]; then
        echo ""
        echo "[!] ERROR: Link Private Server belum diatur!"
        echo "    Silakan pilih menu [4] untuk mengatur link"
        sleep 3
        return
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  [START] Initializing Multi-Account System"
    echo "═══════════════════════════════════════════════════════════"
    
    if [ -n "$LYNX_CONFIG" ]; then
        LYNX_SCRIPT=$(generate_lynx_script "$LYNX_CONFIG")
    else
        LYNX_SCRIPT="$SCRIPT_BASE"
    fi
    
    send_discord "🚀 **ACL XCODE START**: Membuka ${#APPS[@]} akun"
    
    rebuild_layout "$LINK_PS" "$LYNX_SCRIPT"
    
    IS_RUNNING=true
    START_TIME=$(date +%s)
    
    send_discord "✅ **ACL XCODE RUNNING**: ${#APPS[@]} akun aktif"
    
    echo ""
    read -p "  Press Enter to continue..."
}

stop_accounts() {
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  [STOP] Menghentikan semua akun"
    echo "═══════════════════════════════════════════════════════════"
    
    send_discord "⏹️ **ACL XCODE STOP**: Mematikan semua akun"
    kill_all
    IS_RUNNING=false
    
    echo ""
    read -p "  Press Enter to continue..."
}

restart_accounts() {
    if ! $IS_RUNNING; then
        echo ""
        echo "[!] Akun sedang tidak berjalan!"
        sleep 2
        return
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  [RESTART] Merestart semua akun"
    echo "═══════════════════════════════════════════════════════════"
    
    send_discord "🔄 **ACL XCODE RESTART**: Merestart semua akun"
    
    kill_all
    sleep 2
    
    if [ -n "$LYNX_CONFIG" ]; then
        LYNX_SCRIPT=$(generate_lynx_script "$LYNX_CONFIG")
    else
        LYNX_SCRIPT="$SCRIPT_BASE"
    fi
    
    rebuild_layout "$LINK_PS" "$LYNX_SCRIPT"
    START_TIME=$(date +%s)
    
    echo ""
    read -p "  Press Enter to continue..."
}

set_link_ps() {
    echo ""
    echo -n "  Masukkan Link Private Server: "
    read new_link
    if [ -n "$new_link" ]; then
        LINK_PS="$new_link"
        echo "  [✓] Link PS saved!"
    fi
    sleep 2
}

set_webhook() {
    echo ""
    echo -n "  Masukkan Discord Webhook URL: "
    read new_webhook
    if [ -n "$new_webhook" ]; then
        WEBHOOK_URL="$new_webhook"
        echo "  [✓] Webhook saved!"
    fi
    sleep 2
}

set_lynx_config() {
    echo ""
    echo "  Masukkan Lynx Config (JSON format):"
    echo "  Contoh: {\"autoFarm\":true,\"speed\":100}"
    echo -n "  → "
    read new_config
    if [ -n "$new_config" ]; then
        LYNX_CONFIG="$new_config"
        echo "  [✓] Config saved!"
    else
        LYNX_CONFIG=""
        echo "  [✓] Using default config"
    fi
    sleep 2
}

# ========== MONITORING ==========
monitor_accounts() {
    while true; do
        if $IS_RUNNING; then
            STUCK=false
            for PKG in "${APPS[@]}"; do
                CHECK=$(su -c "dumpsys window windows | grep -E 'mCurrentFocus' | grep $PKG" 2>/dev/null)
                if [ -z "$CHECK" ]; then 
                    STUCK=true
                    break
                fi
            done

            if [ "$STUCK" = true ]; then
                ((CRASH_COUNT++))
                
                echo ""
                echo "═══════════════════════════════════════════════════════════"
                echo "  [ALERT] Crash terdeteksi! (Total: $CRASH_COUNT)"
                echo "═══════════════════════════════════════════════════════════"
                
                send_discord "⚠️ **ALERT** Crash #$CRASH_COUNT detected! Restarting..."
                
                for KILL in "${APPS[@]}"; do 
                    su -c "am force-stop $KILL" 2>/dev/null
                done
                sleep 2
                
                if [ -n "$LYNX_CONFIG" ]; then
                    LYNX_SCRIPT=$(generate_lynx_script "$LYNX_CONFIG")
                else
                    LYNX_SCRIPT="$SCRIPT_BASE"
                fi
                
                rebuild_layout "$LINK_PS" "$LYNX_SCRIPT"
            fi
        fi
        sleep 10
    done
}

# ========== MAIN PROGRAM ==========
clear
echo "╔══════════════════════════════════════════════════════════╗"
echo "║         ROBLOX ACL MANAGER - INITIALIZING...            ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Check root
if ! su -c "echo test" >/dev/null 2>&1; then
    echo "[ERROR] Root access required!"
    exit 1
fi

echo "[✓] Root access granted"
echo "[✓] Detected ${#APPS[@]} Roblox applications"
echo ""

# Start monitor
monitor_accounts &
MONITOR_PID=$!

# Main loop
while true; do
    show_header
    show_stats
    show_config
    show_menu
    
    read choice
    
    case $choice in
        1) start_accounts ;;
        2) stop_accounts ;;
        3) restart_accounts ;;
        4) set_link_ps ;;
        5) set_webhook ;;
        6) set_lynx_config ;;
        7) 
            show_header
            show_stats
            show_config
            echo ""
            read -p "  Press Enter to continue..."
            ;;
        8) 
            show_config
            echo ""
            read -p "  Press Enter to continue..."
            ;;
        0) 
            echo ""
            echo "═══════════════════════════════════════════════════════════"
            echo "  [EXIT] Shutting down..."
            if $IS_RUNNING; then
                kill_all
            fi
            kill $MONITOR_PID 2>/dev/null
            echo "  Bye!"
            exit 0
            ;;
        *) 
            echo ""
            echo "  [!] Invalid option!"
            sleep 2
            ;;
    esac
done
