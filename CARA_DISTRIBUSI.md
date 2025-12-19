# Panduan Distribusi Sistem Sijil untuk Orang Awam

## Pengenalan

Dokumen ini menjelaskan cara untuk mengedarkan aplikasi Sistem Sijil kepada pengguna awam. Ikuti langkah-langkah di bawah dengan teliti.

---

# BAHAGIAN A: UNTUK PEMBANGUN (Developer)

## Langkah 1: Build Aplikasi

1. **Buka Command Prompt atau PowerShell**
   - Tekan `Win + R`
   - Taip `cmd` atau `powershell`
   - Tekan Enter

2. **Pergi ke folder projek**
   ```
   cd "C:\Users\Administrator\Desktop\dektop app"
   ```

3. **Jalankan arahan build**
   ```
   flutter build windows --release
   ```

4. **Tunggu sehingga siap** (2-5 minit)
   - Mesej "Built build\windows\x64\runner\Release\sistem_sijil.exe" akan muncul

---

## Langkah 2: Sediakan Fail untuk Distribusi

### Lokasi Fail Release:
```
C:\Users\Administrator\Desktop\dektop app\build\windows\x64\runner\Release\
```

### Fail yang Ada dalam Folder Release:
| Fail | Saiz | Fungsi |
|------|------|--------|
| sistem_sijil.exe | ~124 KB | Aplikasi utama |
| flutter_windows.dll | ~18 MB | Flutter runtime |
| pdfium.dll | ~4.7 MB | Enjin PDF |
| printing_plugin.dll | ~139 KB | Plugin cetak |
| share_plus_plugin.dll | ~134 KB | Plugin kongsi |
| sqlite3.x64.windows.dll | ~1.6 MB | Database |
| url_launcher_windows_plugin.dll | ~98 KB | Plugin buka URL |
| data/ (folder) | - | Assets aplikasi |

**PENTING:** Semua fail dan folder di atas WAJIB disertakan bersama!

---

## Langkah 3: Buat Fail ZIP

### Cara Manual:

1. **Buka File Explorer**
   - Tekan `Win + E`

2. **Pergi ke folder Release**
   ```
   C:\Users\Administrator\Desktop\dektop app\build\windows\x64\runner\Release
   ```

3. **Pilih semua fail**
   - Tekan `Ctrl + A`

4. **Buat ZIP**
   - Klik kanan → Send to → Compressed (zipped) folder
   - Atau klik kanan → 7-Zip → Add to archive

5. **Namakan fail ZIP**
   - `SistemSijil_v1.0.0.zip`

6. **Saiz fail ZIP lebih kurang 25-30 MB**

---

## Langkah 4: Muat Naik dan Kongsi

### Pilihan 1: Google Drive
1. Buka https://drive.google.com
2. Klik "+ New" → "File upload"
3. Pilih fail `SistemSijil_v1.0.0.zip`
4. Tunggu muat naik siap
5. Klik kanan fail → "Get link"
6. Tukar kepada "Anyone with the link"
7. Salin link dan kongsi

### Pilihan 2: OneDrive
1. Buka https://onedrive.live.com
2. Klik "Upload" → "Files"
3. Pilih fail ZIP
4. Klik kanan → "Share"
5. Pilih "Anyone with the link"
6. Salin link

### Pilihan 3: USB Drive
1. Masukkan USB drive
2. Salin fail ZIP ke USB
3. Serahkan USB kepada pengguna

### Pilihan 4: Email
1. Lampirkan fail ZIP (jika saiz < 25MB)
2. Atau hantar link Google Drive/OneDrive

---

# BAHAGIAN B: UNTUK PENGGUNA AWAM

## Panduan Pemasangan Sistem Sijil

### Keperluan Sistem

| Keperluan | Minimum |
|-----------|---------|
| Sistem Operasi | Windows 10 atau Windows 11 (64-bit) |
| RAM | 4 GB |
| Ruang Cakera | 200 MB |
| Skrin | 1280 x 720 atau lebih tinggi |

---

### Langkah 1: Muat Turun Aplikasi

1. **Klik link yang diberikan** oleh pembangun
2. **Klik butang "Download"**
3. **Tunggu muat turun selesai**
   - Fail: `SistemSijil_v1.0.0.zip`
   - Lokasi: Folder "Downloads" anda

---

### Langkah 2: Extract Fail ZIP

#### Cara 1: Menggunakan Windows (Disyorkan)

1. **Buka folder Downloads**
   - Tekan `Win + E`
   - Klik "Downloads" di sebelah kiri

2. **Cari fail `SistemSijil_v1.0.0.zip`**

3. **Klik kanan pada fail ZIP**

4. **Pilih "Extract All..."**

5. **Pilih lokasi untuk extract**
   - Disyorkan: `C:\Program Files\SistemSijil`
   - Atau: Desktop anda

6. **Klik "Extract"**

7. **Tunggu proses selesai**

#### Cara 2: Menggunakan 7-Zip (Jika ada)

1. Klik kanan fail ZIP
2. Pilih "7-Zip" → "Extract to SistemSijil_v1.0.0\"
3. Tunggu selesai

---

### Langkah 3: Jalankan Aplikasi

1. **Buka folder yang di-extract**
   - Contoh: `C:\Program Files\SistemSijil` atau Desktop

2. **Cari fail `sistem_sijil.exe`**
   - Ikon: Logo aplikasi
   - Jenis: Application

3. **Double-click untuk jalankan**

4. **Jika muncul amaran Windows SmartScreen:**
   
   ![SmartScreen](https://i.imgur.com/example.png)
   
   - Klik **"More info"**
   - Kemudian klik **"Run anyway"**
   - Ini normal untuk aplikasi baru

5. **Aplikasi akan dibuka**

---

### Langkah 4: Buat Shortcut (Pilihan)

Untuk akses mudah pada masa hadapan:

1. **Klik kanan pada `sistem_sijil.exe`**

2. **Pilih "Create shortcut"**

3. **Pindahkan shortcut ke Desktop**
   - Atau ke Start Menu

4. **Kini anda boleh buka aplikasi dari Desktop**

---

### Langkah 5: Tetapan Awal

Apabila aplikasi dibuka buat kali pertama:

1. **Pilih Bahasa**
   - Pergi ke Settings/Tetapan
   - Pilih Bahasa Melayu atau English

2. **Set Kata Laluan (Disyorkan)**
   - Pergi ke Settings/Tetapan
   - Aktifkan "Kunci Kata Laluan"
   - Masukkan kata laluan pilihan anda

3. **Mulakan menggunakan aplikasi!**

---

## Penyelesaian Masalah (Troubleshooting)

### Masalah 1: "Windows protected your PC"

**Penyelesaian:**
1. Klik "More info"
2. Klik "Run anyway"

**Kenapa ini berlaku?**
- Windows tidak mengenali aplikasi baru
- Aplikasi ini selamat untuk digunakan

---

### Masalah 2: Antivirus Menyekat Aplikasi

**Penyelesaian:**
1. Buka tetapan antivirus anda
2. Tambah folder SistemSijil ke "Exclusion" atau "Whitelist"
3. Cuba jalankan semula aplikasi

**Contoh untuk Windows Defender:**
1. Buka Windows Security
2. Virus & threat protection → Manage settings
3. Scroll ke "Exclusions" → Add an exclusion
4. Pilih folder SistemSijil

---

### Masalah 3: "Missing DLL" atau "File not found"

**Punca:**
- Tidak semua fail di-extract

**Penyelesaian:**
1. Padam folder yang telah di-extract
2. Extract semula fail ZIP
3. Pastikan SEMUA fail ada dalam folder

---

### Masalah 4: Aplikasi Tidak Boleh Dibuka

**Penyelesaian:**
1. Pastikan Windows anda 64-bit
   - Klik kanan "This PC" → Properties
   - Lihat "System type: 64-bit"

2. Cuba restart komputer

3. Jalankan sebagai Administrator
   - Klik kanan `sistem_sijil.exe`
   - Pilih "Run as administrator"

---

### Masalah 5: Skrin Kosong atau Putih

**Penyelesaian:**
1. Tunggu beberapa saat (loading)
2. Jika masih kosong, restart aplikasi
3. Cuba resize tetingkap aplikasi

---

## Lokasi Data Aplikasi

Data aplikasi disimpan di:
```
C:\Users\[Nama Anda]\Documents\SistemSijil\
```

**Apa yang disimpan:**
- Database (semua program, peserta, sijil)
- Fail export (CSV, PDF)
- Sandaran (backup)

**PENTING:** Jangan padam folder ini jika anda mahu simpan data!

---

## Cara Kemas Kini (Update)

Apabila versi baru dikeluarkan:

1. **Buat sandaran data dahulu**
   - Buka aplikasi → Tetapan → Buat Sandaran

2. **Muat turun versi baru**

3. **Extract ke folder yang sama**
   - Atau folder baru

4. **Jalankan aplikasi baru**
   - Data akan dikekalkan

---

## Cara Nyahpasang (Uninstall)

Untuk membuang aplikasi:

1. **Padam folder SistemSijil**
   - Contoh: `C:\Program Files\SistemSijil`

2. **Padam shortcut** di Desktop (jika ada)

3. **(Pilihan) Padam data aplikasi**
   - `C:\Users\[Nama Anda]\Documents\SistemSijil`
   - AMARAN: Ini akan memadam semua data!

---

## Sokongan Teknikal

Jika anda menghadapi masalah:

1. **Ambil screenshot** masalah yang berlaku

2. **Catat mesej error** (jika ada)

3. **Hubungi pembangun** dengan maklumat di atas

---

## Versi Aplikasi

| Versi | Tarikh | Nota |
|-------|--------|------|
| 1.0.0 | Disember 2024 | Keluaran pertama |

---

*Dokumen ini dikemas kini pada Disember 2024*
