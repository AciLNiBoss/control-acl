#!/bin/bash
# ACL XCODE - Multi-Account Manager (All-in-One Version)

# 1. Auto Kill proses pas exit (termasuk mematikan Roblox)
trap "pkill -f com.roblox.client; exit" SIGINT SIGTERM

CONFIG_FILE="$HOME/.acl_config"

# Warna
GREY='\033[90m'
BOLD='\033[1m'
GREEN='\033[92m'
BLUE='\033[94m'
CYAN='\033[96m'
NC='\033[0m'

clear
# 2. ASCII Art ACL XCODE
echo -e "${CYAN}${BOLD}"
echo "   █████╗  ██████╗██╗     "
echo "  ██╔══██╗██╔════╝██║     "
echo "  ███████║██║     ██║     "
echo "  ██╔══██║██║     ██║     "
echo "  ██║  ██║╚██████╗███████╗"
echo "  ╚═╝  ╚═╝ ╚═════╝╚══════╝"
echo "  ██╗  ██╗ ██████╗ ██████╗ ██████╗ ███████╗"
echo "  ╚██╗██╔╝██╔════╝██╔═══██╗██╔══██╗██╔════╝"
echo "   ╚███╔╝ ██║     ██║   ██║██║  ██║█████╗  "
echo "   ██╔██╗ ██║     ██║   ██║██║  ██║██╔══╝  "
echo "  ██╔╝ ██╗╚██████╗╚██████╔╝██████╔╝███████╗"
echo "  ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝"
echo -e "${NC}"
echo -e "${BOLD}         PRIVATE MANAGER START          ${NC}"
echo -e "${GREY}------------------------------------------${NC}"

# 3. Sistem Load & Save Config (Tanpa Key)
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    echo -e "${CYAN}[!] Data lama ditemukan.${NC}"
    echo ""
    echo -n "📁 Pakai data yang sebelumnya? (y/n): "
    read REUSE
    if [[ "$REUSE" != "y" ]]; then
        rm "$CONFIG_FILE"
    fi
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${BOLD}Masukan Link PS Mu:${NC}"
    echo -n " > "
    read PS
    
    echo -e "${BOLD}Masukan URL Webhook Discord (Opsional) :${NC}"
    echo -n " > "
    read WH
    
    echo "PS='$PS'" > "$CONFIG_FILE"
    echo "WH='$WH'" >> "$CONFIG_FILE"
fi

echo ""
echo -e "${GREEN}[V] Menjalankan ACL XCODE... (CTRL+C untuk berhenti)${NC}"
sleep 2

# ==========================================
# 4. CORE ENGINE MULTI-ACCOUNT ACL XCODE
# ==========================================

LINK="$PS"
WEBHOOK="$WH"

# Opsional: Ganti link gambar ini dengan link logo ACL kamu sendiri
LOGO_URL="https://raw.githubusercontent.com/Fizxyyyy/fizxy-toolss/main/launcher_icon.png"

MSG_ID=""
APPS=$(pm list packages | grep -i roblox | cut -d ":" -f2 | sort -u)
TIMER=$(date +%s)
HEAVY_TIMER=$(date +%s)
LAST_CLEAN="Belum dilakukan"

# Cek akses Root
if [ "$(id -u)" = "0" ]; then RUN() { sh -c "$1"; }; else RUN() { su -c "$1"; }; fi

get_cpu() {
    CPU_USAGE=$(top -n 1 -b | grep "CPU:" | head -n 1 | awk '{print $2 + $4}')
    [ -z "$CPU_USAGE" ] && CPU_USAGE="0"
    CPU_INFO="${CPU_USAGE}%"
}

get_ram() {
    MEM=$(free -m | grep "Mem:")
    TOTAL=$(echo $MEM | awk '{print $2}')
    FREE=$(echo $MEM | awk '{print $4}')
    RAM_USE="${FREE}MB"
    RAM_TOTAL="${TOTAL}MB"
}

get_status() {
    STATUS_LIST=""
    ONLINE=0; OFFLINE=0
    for PKG in $APPS; do
        PID=$(pidof $PKG)
        if [ -z "$PID" ]; then STATE="🔴"; OFFLINE=$((OFFLINE+1)); else STATE="🟢"; ONLINE=$((ONLINE+1)); fi
        STATUS_LIST="${STATUS_LIST}${PKG} : ${STATE}\n"
    done
    [ $OFFLINE -gt 0 ] && MAIN_STATUS="⚠️ STATUS: ADA YANG OFF JIRR 😩" || MAIN_STATUS="STATUS: SEMUA ROBLOX ON"
}

send_monitor() {
    [ -z "$WEBHOOK" ] && return
    get_cpu && get_ram && get_status
    DATA='{"embeds": [{"title": "ACL XCODE MONITORING","description": "━━━━━━━━━━━━━━━━━━━━\n'"$MAIN_STATUS"'\n\nCPU USAGE: '"$CPU_INFO"'\n\nRAM: '"$RAM_USE"' / '"$RAM_TOTAL"'\n\nLAST CLEAN: '"$LAST_CLEAN"'\n\nROBLOX STATUS\n├ Online  : '"$ONLINE"'\n└ Offline : '"$OFFLINE"'\n\nDETAIL\n'"$STATUS_LIST"'━━━━━━━━━━━━━━━━━━━━","color": 3066993,"thumbnail": {"url": "'"$LOGO_URL"'"},"footer": {"text": "ACL XCODE • '$(date +%H:%M:%S)'","icon_url": "'"$LOGO_URL"'"}}]}'
    if [ -z "$MSG_ID" ]; then
        RESP=$(curl -s -H "Content-Type: application/json" -X POST -d "$DATA" "${WEBHOOK}?wait=true")
        MSG_ID=$(echo "$RESP" | grep -o '"id": *"[^"]*"' | head -n 1 | cut -d'"' -f4)
    else
        curl -s -o /dev/null -X PATCH -H "Content-Type: application/json" -d "$DATA" "${WEBHOOK}/messages/${MSG_ID}"
    fi
}

# Jalankan monitor Discord di latar belakang (Background Process)
( while true; do send_monitor; sleep 5; done ) &
MONITOR_PID=$!

# Update trap untuk ikut mematikan proses monitor saat keluar
trap "pkill -f com.roblox.client; kill $MONITOR_PID 2>/dev/null; exit" SIGINT SIGTERM

set_screen() { RUN "wm density 164"; sleep 1; RUN "service call window 101 i32 20"; }

run_setup() {
    set_screen
    IDX=0; COUNT=$(echo "$APPS" | wc -w)
    for PKG in $APPS; do
        IDX=$((IDX + 1))
        RUN "monkey -p $PKG -c android.intent.category.LAUNCHER 1" >/dev/null 2>&1
        sleep 6; RUN "input keyevent 3"; sleep 1; RUN "input keyevent 187"; sleep 2
        RUN "input tap 364 125"; sleep 1; RUN "input tap 357 343"; sleep 2
        RUN "input swipe 300 250 680 250 600"; sleep 1
        TOP=$(( (IDX - 1) * (1200 / COUNT) )); BOT=$(( IDX * (1200 / COUNT) ))
        RUN "input swipe 540 50 540 $TOP 300"; RUN "input swipe 540 275 540 $BOT 300"; sleep 0.5
    done
    RUN "monkey -p com.termux -c android.intent.category.LAUNCHER 1" >/dev/null 2>&1; sleep 2
    for PKG in $APPS; do
        RUN "monkey -p $PKG -c android.intent.category.LAUNCHER 1" >/dev/null 2>&1; sleep 2
        RUN "am start -a android.intent.action.VIEW -d '$LINK' -p $PKG" >/dev/null 2>&1; sleep 12
    done
}

# Mulai Eksekusi
if [ -z "$APPS" ]; then echo -e "${CYAN}[!] Tidak ada aplikasi Roblox yang terdeteksi.${NC}"; exit; fi
run_setup

# Main Watchdog Loop
while true; do
    RESET=0; NOW=$(date +%s)
    
    # Cache Cleaner
    if [ $((NOW - TIMER)) -ge 300 ]; then
        for PKG in $APPS; do RUN "rm -rf /data/data/$PKG/cache/*" >/dev/null 2>&1; done
        LAST_CLEAN=$(date +%H:%M:%S); TIMER=$NOW
    fi
    
    # Crash Checker
    if [ $((NOW - HEAVY_TIMER)) -ge 45 ]; then
        for PKG in $APPS; do
            PROC=$(pidof $PKG)
            [ -z "$PROC" ] && { RESET=1; break; }
            WIN=$(RUN "dumpsys window windows | grep $PKG")
            [ -z "$WIN" ] && { RESET=1; break; }
        done
        HEAVY_TIMER=$NOW
    fi
    
    # Auto Recovery
    if [ $RESET -eq 1 ]; then
        for PKG in $APPS; do RUN "am force-stop $PKG"; done
        sleep 2; RUN "input keyevent 3"; sleep 1; RUN "input keyevent 187"; sleep 1
        for i in 1 2 3; do RUN "input swipe 540 800 540 100 200"; sleep 0.5; done
        run_setup; TIMER=$(date +%s); continue
    fi
    sleep 15
done
