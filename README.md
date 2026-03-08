# 🚀 ACL XCODE ULTIMATE MANAGER
### *High-Performance Multi-Account Automation for Roblox Cloud Farming*

![Version](https://img.shields.io/badge/Version-2.1.0-blueviolet?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android_Rooted-green?style=for-the-badge)
![Tool](https://img.shields.io/badge/Tool-Termux-orange?style=for-the-badge)
![Script](https://img.shields.io/badge/Script-Lynx_Hub-cyan?style=for-the-badge)

**ACL XCODE** adalah framework otomasi berbasis Bash yang dirancang khusus untuk menjalankan banyak akun Roblox secara simultan di perangkat Android Rooted (Sangat optimal untuk **Redfinger** & **Cloud Phones**). Sistem ini menggabungkan manajemen jendela cerdas dengan injeksi script otomatis.

---

## 💎 Fitur Unggulan

| Fitur | Deskripsi Teknis |
| :--- | :--- |
| **🛰️ Universal Radar** | Otomatis mendeteksi berbagai Package Name (com.roblox.acl, .acm, .acn, dll). |
| **💉 Auto-Injection** | Menanamkan Lynx Hub ke folder `autoexec` secara massal tanpa interaksi manual. |
| **🖥️ Smart Layouting** | Mengatur posisi jendela (Freeform Mode) secara presisi agar layar tetap efisien. |
| **🔗 Deep-Link Join** | Akses langsung ke Private Server (PS) menggunakan protokol Android Intent. |
| **📢 Discord Monitoring** | Laporan status farming, notifikasi startup, dan alert crash langsung ke Discord. |
| **🩹 Self-Healing System** | Mendeteksi akun yang DC/Stuck dan melakukan sinkronisasi ulang secara otomatis. |

---

## 🛠️ Persiapan Lingkungan (Setup)

Pastikan Termux kamu sudah terkonfigurasi dengan alat-alat berikut sebelum menjalankan script:

```bash
# 1. Update system & Install dependency
pkg update && pkg upgrade -y
pkg install tsu curl nano -y

# 2. Berikan izin akses penyimpanan (Untuk proses injeksi)
termux-setup-storage
