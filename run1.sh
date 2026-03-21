#!/system/bin/sh
# Lana Debloat Tool by lanavienrose

BASE_URL="https://github.com/lucivaantarez/redfinger-setup/releases/latest/download"
C="\033[36m"; G="\033[32m"; Y="\033[33m"; R="\033[31m"; D="\033[90m"; N="\033[0m"

cls() { printf "\033[2J\033[H"; }

hdr() {
  cls
  printf "${C}================================================================${N}\n"
  printf "${C}  Lana Debloat Tool  v1.0.0  (2026-03-04)${N}\n"
  printf "${C}================================================================${N}\n\n"
}

progress() {
  label=$1
  total=$2
  shift 2
  i=0
  for pkg in "$@"; do
    i=$((i+1))
    pct=$((i * 100 / total))
    printf "\r  ${C}%-20s${N} [${Y}%3d%%${N}] Progressing..." "$label" "$pct"
    su -c "pm uninstall -k --user 0 $pkg" >/dev/null 2>&1
  done
  printf "\r  ${C}%-20s${N} [${G}100%%${N}] ${G}Completed!  ${N}\n"
}

install_pkg() {
  name=$1; url=$2
  printf "  ${C}%-20s${N} [${Y}  0%%${N}] Progressing..."
  curl -sSL "$url" -o /sdcard/Download/"$name".apk 2>/dev/null
  printf "\r  ${C}%-20s${N} [${Y} 50%%${N}] Progressing..."
  r=$(su -c "pm install /sdcard/Download/$name.apk" 2>&1)
  if echo "$r" | grep -q "Success"; then
    printf "\r  ${C}%-20s${N} [${G}100%%${N}] ${G}Completed!  ${N}\n"
  else
    printf "\r  ${C}%-20s${N} [${R}ERR${N}]  ${R}Failed!     ${N}\n"
  fi
}

do_bloat() {
  hdr
  printf "${C}+----------------------+--------+--------------+${N}\n"
  printf "${C}| Task                 | Status | Progress     |${N}\n"
  printf "${C}+----------------------+--------+--------------+${N}\n\n"
  progress "Bloatware" 41 \
    com.android.calendar com.android.email com.android.messaging \
    com.android.music com.android.musicfx com.android.soundrecorder \
    com.android.deskclock com.android.dreams.basic com.android.dreams.phototable \
    com.android.quicksearchbox com.android.wallpaper.livepicker \
    com.android.printspooler com.android.printservice.recommendation \
    com.android.bookmarkprovider com.android.egg com.android.nfc \
    com.android.bluetooth com.android.bluetoothmidiservice com.android.bips \
    com.android.gallery3d com.android.contacts com.android.dialer \
    com.android.emergency com.wsh.appstore com.wsh.toolkit \
    com.android.protips com.android.hotspot2 com.baidu.cloud.service \
    com.android.wallpapercropper com.android.wallpaperbackup com.android.traceur \
    com.android.smspush com.android.simappdialog com.android.htmlviewer \
    com.android.carrierconfig com.android.carrierdefaultapp \
    com.android.cellbroadcastreceiver com.android.ons com.android.mtp \
    android.ext.services com.google.android.apps.nbu.files
}

do_google() {
  hdr
  printf "${C}+----------------------+--------+--------------+${N}\n"
  printf "${C}| Task                 | Status | Progress     |${N}\n"
  printf "${C}+----------------------+--------+--------------+${N}\n\n"
  progress "Google Apps" 5 \
    com.android.vending com.google.android.play.games \
    com.google.android.gsf com.google.android.gsf.login \
    android.ext.shared
}

do_themes() {
  hdr
  printf "${C}+----------------------+--------+--------------+${N}\n"
  printf "${C}| Task                 | Status | Progress     |${N}\n"
  printf "${C}+----------------------+--------+--------------+${N}\n\n"
  progress "Themes" 23 \
    com.android.theme.color.black com.android.theme.color.cinnamon \
    com.android.theme.color.green com.android.theme.color.ocean \
    com.android.theme.color.orchid com.android.theme.color.purple \
    com.android.theme.color.space com.android.theme.font.notoserifsource \
    com.android.theme.icon.roundedrect com.android.theme.icon.squircle \
    com.android.theme.icon.teardrop \
    com.android.theme.icon_pack.circular.android \
    com.android.theme.icon_pack.circular.launcher \
    com.android.theme.icon_pack.circular.settings \
    com.android.theme.icon_pack.circular.systemui \
    com.android.theme.icon_pack.filled.android \
    com.android.theme.icon_pack.filled.launcher \
    com.android.theme.icon_pack.filled.settings \
    com.android.theme.icon_pack.filled.systemui \
    com.android.theme.icon_pack.rounded.android \
    com.android.theme.icon_pack.rounded.launcher \
    com.android.theme.icon_pack.rounded.settings \
    com.android.theme.icon_pack.rounded.systemui
}

do_install() {
  hdr
  printf "${C}+----------------------+--------+--------------+${N}\n"
  printf "${C}| App                  | Status | Progress     |${N}\n"
  printf "${C}+----------------------+--------+--------------+${N}\n\n"
  printf "  ${C}[1]${N} - MT Manager\n"
  printf "  ${C}[2]${N} - Smart Launcher 6\n"
  printf "  ${C}[3]${N} - Kernel Adiutor\n"
  printf "  ${C}[4]${N} - 1.1.1.1 VPN\n"
  printf "  ${C}[5]${N} - Install ALL\n"
  printf "  ${D}[6] - Back${N}\n\n"
  printf "${D}----------------------------------------------------------------${N}\n"
  printf "${C}? Select an option : ${N}"; read ic
  hdr
  printf "${C}+----------------------+--------+--------------+${N}\n"
  printf "${C}| App                  | Status | Progress     |${N}\n"
  printf "${C}+----------------------+--------+--------------+${N}\n\n"
  case "$ic" in
    1) install_pkg "MT Manager"       "$BASE_URL/manager.apk" ;;
    2) install_pkg "Smart Launcher 6" "$BASE_URL/launcher.apk" ;;
    3) install_pkg "Kernel Adiutor"   "$BASE_URL/kernel.apk" ;;
    4) install_pkg "1.1.1.1 VPN"      "$BASE_URL/vpn.apk" ;;
    5) install_pkg "MT Manager"       "$BASE_URL/manager.apk"
       install_pkg "Smart Launcher 6" "$BASE_URL/launcher.apk"
       install_pkg "Kernel Adiutor"   "$BASE_URL/kernel.apk"
       install_pkg "1.1.1.1 VPN"      "$BASE_URL/vpn.apk" ;;
  esac
}

done_msg() {
  printf "\n${D}----------------------------------------------------------------${N}\n"
  printf "  ${G}All tasks completed.${N} Reboot recommended.\n\n"
  sleep 2; cls
}

# MAIN
hdr
printf "${C}+----------------------+----------------------------------+${N}\n"
printf "${C}| Option               | Action                           |${N}\n"
printf "${C}+----------------------+----------------------------------+${N}\n"
printf "  ${C}[1]${N} - Safe Bloatware\n"
printf "  ${C}[2]${N} - Google Apps\n"
printf "  ${C}[3]${N} - Theme & Icon Packs\n"
printf "  ${Y}[4]${N} - Uninstall ALL\n"
printf "  ${C}[5]${N} - Install Apps\n"
printf "  ${Y}[6]${N} - Uninstall ALL + Install ALL\n"
printf "  ${D}[0] - Exit${N}\n\n"
printf "${D}----------------------------------------------------------------${N}\n"
printf "${C}? Select an option : ${N}"; read ch

case "$ch" in
  1) do_bloat; done_msg ;;
  2) do_google; done_msg ;;
  3) do_themes; done_msg ;;
  4) do_bloat; do_google; do_themes; done_msg ;;
  5) do_install; done_msg ;;
  6) do_bloat; do_google; do_themes; do_install; done_msg ;;
  0) cls; exit 0 ;;
  *) hdr; printf "  ${R}Invalid option.${N}\n\n" ;;
esac
