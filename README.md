# 🚀 ACL XCODE ULTIMATE MANAGER
### *High-Performance Multi-Account Automation for Roblox Cloud Farming*

![Version](https://img.shields.io/badge/Version-2.1.0-blueviolet?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android_Rooted-green?style=for-the-badge)
![Environment](https://img.shields.io/badge/Environment-Termux-black?style=for-the-badge)
![Automation](https://img.shields.io/badge/Automation-Multi_Instance-orange?style=for-the-badge)
![Script](https://img.shields.io/badge/Script-Lynx_Hub-cyan?style=for-the-badge)

---

# 📖 Deskripsi

**ACL XCODE Ultimate Manager** adalah framework otomasi berbasis **Bash Script** yang dirancang untuk menjalankan banyak akun Roblox secara simultan di perangkat **Android Rooted**.

Framework ini sangat cocok untuk:

- Cloud farming
- Multi account automation
- Redfinger / Cloud phone
- Farming private server

Sistem ini menggabungkan:

- **multi instance management**
- **auto script injection**
- **smart window layout**
- **crash monitoring**
- **discord notification**

sehingga seluruh proses dapat berjalan **full otomatis tanpa interaksi manual**.

---

# 💎 Fitur Unggulan

| Fitur | Deskripsi |
|------|-----------|
| 🛰️ Universal Radar | Otomatis mendeteksi semua aplikasi dengan package `com.roblox*` |
| 💉 Auto Script Injection | Inject Lynx Hub ke folder `autoexec` secara massal |
| 🖥️ Smart Layouting | Mengatur posisi window agar banyak instance tetap rapi |
| 🔗 Deep-Link Join | Join private server menggunakan Android Intent |
| 📢 Discord Monitoring | Mengirim log farming dan crash alert |
| 🩹 Smart Config | Config webhook dan private server disimpan otomatis |
| 🔁 Crash Detection | Monitoring aplikasi setiap 30 detik |
| ⚡ Auto Restart | Jika crash semua instance akan restart otomatis |

---

# 📱 Device Requirements

Agar script berjalan optimal perangkat harus memenuhi syarat berikut:

✔ Android **Rooted**  
✔ Support **Freeform Window Mode**  
✔ Install **Termux**  
✔ Sudah install **Roblox / Executor APK**  
✔ Internet stabil  

Script memerlukan akses ke:

```
/data/data/
```

yang hanya bisa diakses dengan **ROOT**.

---

# 🛠️ Persiapan Lingkungan (Setup)

Salin dan jalankan perintah berikut di **Termux**:

```bash
# Update system
pkg update && pkg upgrade -y

# Install dependency
pkg install git curl tsu nano -y

# Beri akses storage
termux-setup-storage
```

---

# 📦 Instalasi Script

Clone repository dari GitHub:

```bash
git clone https://github.com/AciLNiBoss/control-acl.git
```

Masuk ke folder project:

```bash
cd control-acl
```

Berikan izin executable:

```bash
chmod +x run.sh
```

Jalankan script:

```bash
bash run.sh
```

atau

```bash
./run.sh
```

---

# ⚙️ Setup Awal

Saat pertama menjalankan script kamu akan diminta memasukkan:

### Discord Webhook

Digunakan untuk monitoring farming.

Contoh:

```
https://discord.com/api/webhooks/xxxxxxxx
```

---

### Roblox Private Server Link

Contoh:

```
https://www.roblox.com/games/start?placeId=xxxx&privateServerLinkCode=xxxx
```

---

Setelah itu konfigurasi akan disimpan di file lokal:

```
~/.acl_local_config
```

Isi file:

```
WEBHOOK_URL='discord_webhook'
LINK_PS='private_server_link'
```

---

# ⚡ Cara Kerja Sistem

Framework ACL bekerja dalam beberapa tahap otomatis.

---

## 1️⃣ Package Detection

Script akan memindai semua aplikasi Roblox menggunakan:

```
pm list packages | grep roblox
```

Contoh hasil:

```
com.roblox.client
com.roblox.acl
com.roblox.acm
```

Semua package ini akan dimasukkan ke dalam sistem automation.

---

## 2️⃣ Auto Script Injection

Script akan membuat folder:

```
/data/data/<package>/files/auth/scripts/autoexec
```

lalu menambahkan file:

```
main.lua
```

yang berisi loader:

```
loadstring(game:HttpGet('https://raw.githubusercontent.com/...'))()
```

Saat Roblox dijalankan script akan otomatis aktif.

---

## 3️⃣ Multi Instance Launch

Script menggunakan command Android:

```
monkey
```

untuk membuka semua aplikasi Roblox secara otomatis.

---

## 4️⃣ Smart Window Layout

Sistem akan mengatur posisi jendela menggunakan:

```
wm density
input tap
input swipe
```

sehingga beberapa instance dapat berjalan dalam satu layar.

---

## 5️⃣ Private Server Auto Join

Script akan membuka private server menggunakan Android intent:

```
am start -a android.intent.action.VIEW
```

untuk setiap instance Roblox.

---

## 6️⃣ Crash Monitoring System

Setiap **30 detik** script akan mengecek apakah aplikasi masih berjalan.

Jika crash terdeteksi:

```
am force-stop
```

maka semua instance akan **restart otomatis**.

---

# 📢 Discord Monitoring

Script dapat mengirim notifikasi ke Discord seperti:

```
🚀 ACL XCODE START
Menjalankan 5 akun Roblox
```

atau jika crash:

```
⚠️ Crash detected
Restarting instances
```

---

# 📂 Struktur Project

```
control-acl
│
├── run.sh
└── README.md
```

---

# 🔧 Troubleshooting

### Roblox tidak terdeteksi

Cek package dengan:

```bash
pm list packages | grep roblox
```

---

### Permission denied

Pastikan sudah menjalankan:

```bash
chmod +x run.sh
```

---

### Root tidak aktif

Cek dengan:

```bash
su
```

Jika tidak muncul akses root berarti perangkat belum root.

---

### Script tidak join server

Pastikan link private server valid.

---

# ⚠️ Disclaimer

Project ini membutuhkan akses:

```
ROOT
/data/data
```

Gunakan script ini dengan tanggung jawab sendiri.

Penggunaan yang melanggar kebijakan layanan platform menjadi tanggung jawab pengguna.

---

# 👨‍💻 Author

**ACL XCODE**

---

# ⭐ Support

Jika project ini membantu kamu:

⭐ Star repository  
⭐ Fork project ini  
⭐ Share ke komunitas  

Agar project ini bisa terus dikembangkan.
