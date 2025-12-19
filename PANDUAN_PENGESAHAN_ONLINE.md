# Panduan Setup Pengesahan Sijil Online

Panduan lengkap untuk setup sistem pengesahan sijil online menggunakan Google Sheets + Apps Script (100% PERCUMA).

> **PENTING:** Fail CSV akan auto-update setiap kali sijil dijana. Anda hanya perlu upload semula ke Google Sheets.

---

## Gambaran Keseluruhan

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Sistem Sijil   │────▶│  Google Sheets   │◀────│  Halaman Web    │
│  (Desktop App)  │     │  (Database)      │     │  (Pengesahan)   │
└─────────────────┘     └──────────────────┘     └─────────────────┘
      Export CSV              API                    Public Access
```

**Cara Ia Berfungsi:**
1. App desktop export data sijil ke format CSV
2. CSV di-import ke Google Sheets (jadi database online)
3. Google Apps Script jadi API untuk semak sijil
4. Halaman web untuk orang awam sahkan sijil

---

## Langkah 1: Export Data Sijil dari App

1. Buka aplikasi **Sistem Sijil**
2. Pergi ke **Tetapan** (Settings)
3. Cari bahagian **"Pengesahan Online"**
4. Klik butang **"Export Data Sijil"**
5. Pilih folder untuk simpan (contoh: Desktop)
6. Tunggu sehingga selesai

**Hasil:** 4 fail akan dicipta dalam folder tersebut:
- `sijil_data.csv` - Data sijil
- `apps_script.js` - Kod untuk Google
- `verify.html` - Halaman web pengesahan
- `README.txt` - Panduan ringkas

---

## Langkah 2: Buat Google Sheets

### 2.1 Buka Google Sheets
1. Buka browser (Chrome/Edge)
2. Pergi ke: **https://sheets.google.com**
3. Log masuk dengan akaun Google anda

### 2.2 Buat Spreadsheet Baru
1. Klik butang **"+ Blank"** atau **"Kosong"**
2. Spreadsheet baru akan dibuka

### 2.3 Namakan Spreadsheet
1. Klik pada "Untitled spreadsheet" di atas
2. Tukar nama kepada: **"Database Sijil"**

### 2.4 Import Data CSV
1. Klik **File** → **Import**
2. Pilih tab **Upload**
3. Klik **"Browse"** atau seret fail `sijil_data.csv`
4. Tunggu upload selesai
5. Dalam dialog import:
   - Import location: **Replace current sheet**
   - Separator type: **Comma**
6. Klik **"Import data"**

**Hasil:** Data sijil akan dipaparkan dalam spreadsheet.

![Contoh Data](https://i.imgur.com/example.png)

| certificate_number | unique_code | participant_name | ic_number | program_name | ... |
|-------------------|-------------|------------------|-----------|--------------|-----|
| CERT-PROG-2024-0001 | abc-123-... | Ali bin Abu | 901234-... | Kursus A | ... |

---

## Langkah 3: Setup Google Apps Script

### 3.1 Buka Apps Script
1. Dalam Google Sheets, klik menu **Extensions**
2. Pilih **Apps Script**
3. Tab baru akan dibuka dengan editor kod

### 3.2 Padam Kod Sedia Ada
1. Dalam editor, pilih semua kod (Ctrl+A)
2. Padam (Delete)

### 3.3 Copy Kod Apps Script

Copy kod di bawah ini **SEPENUHNYA**:

```javascript
function doGet(e) {
  try {
    if (!e || !e.parameter || !e.parameter.cert) {
      return ContentService
        .createTextOutput(JSON.stringify({
          valid: false,
          message: 'Sila masukkan nombor sijil'
        }))
        .setMimeType(ContentService.MimeType.JSON);
    }
    
    var cert = e.parameter.cert;
    var result = verifyCertificate(cert);
    
    return ContentService
      .createTextOutput(JSON.stringify(result))
      .setMimeType(ContentService.MimeType.JSON);
      
  } catch (error) {
    return ContentService
      .createTextOutput(JSON.stringify({
        valid: false,
        message: 'Ralat: ' + error.toString()
      }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

function verifyCertificate(certNumber) {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  var data = sheet.getDataRange().getValues();
  var headers = data[0];
  
  var certNumCol = headers.indexOf('certificate_number');
  var nameCol = headers.indexOf('participant_name');
  var icCol = headers.indexOf('ic_number');
  var programCol = headers.indexOf('program_name');
  var dateCol = headers.indexOf('issue_date');
  
  if (certNumCol === -1) {
    return {
      valid: false,
      message: 'Column certificate_number tidak dijumpai'
    };
  }
  
  for (var i = 1; i < data.length; i++) {
    var cellValue = String(data[i][certNumCol]).trim();
    var searchValue = String(certNumber).trim();
    
    if (cellValue === searchValue) {
      return {
        valid: true,
        certificate_number: data[i][certNumCol],
        participant_name: data[i][nameCol] || '-',
        ic_number: maskIC(String(data[i][icCol] || '')),
        program_name: data[i][programCol] || '-',
        issue_date: formatDate(data[i][dateCol])
      };
    }
  }
  
  return {
    valid: false,
    message: 'Sijil tidak dijumpai dalam rekod'
  };
}

function maskIC(ic) {
  if (!ic || ic.length < 6) return ic;
  return ic.substring(0, 6) + '****' + ic.substring(ic.length - 2);
}

function formatDate(date) {
  if (!date) return '-';
  if (date instanceof Date) {
    return Utilities.formatDate(date, 'Asia/Kuala_Lumpur', 'dd/MM/yyyy');
  }
  return String(date);
}
```

### 3.4 Paste Kod
1. Kembali ke tab Apps Script
2. Paste kod (Ctrl+V)
3. Klik butang **Save** (ikon 💾) atau Ctrl+S
4. Namakan projek: **"Pengesahan Sijil API"**

> ⚠️ **JANGAN** tekan butang "Run" dalam editor. Kod ini hanya berfungsi bila dipanggil melalui URL web.

---

## Langkah 4: Deploy Web App

### 4.1 Mulakan Deployment
1. Klik butang **"Deploy"** (kanan atas)
2. Pilih **"New deployment"**

### 4.2 Pilih Jenis Deployment
1. Klik ikon **gear ⚙️** di sebelah "Select type"
2. Pilih **"Web app"**

### 4.3 Konfigurasi Deployment
Isi maklumat berikut:

| Field | Nilai |
|-------|-------|
| Description | Pengesahan Sijil API |
| Execute as | **Me (email anda)** |
| Who has access | **Anyone** |

> ⚠️ **PENTING:** Pastikan "Who has access" adalah **"Anyone"** supaya orang awam boleh guna.

### 4.4 Deploy
1. Klik butang **"Deploy"**
2. Klik **"Authorize access"**
3. Pilih akaun Google anda
4. Jika ada amaran "Google hasn't verified this app":
   - Klik **"Advanced"**
   - Klik **"Go to Pengesahan Sijil API (unsafe)"**
5. Klik **"Allow"**

### 4.5 Salin URL
1. Selepas deploy berjaya, **SALIN URL** yang dipaparkan
2. URL kelihatan seperti:
   ```
   https://script.google.com/macros/s/AKfycbx.../exec
   ```
3. **SIMPAN URL INI** - anda perlukan untuk langkah seterusnya

---

## Langkah 5: Setup Halaman Web Pengesahan

### 5.1 Edit Fail HTML
1. Buka fail `verify.html` dengan **Notepad**
2. Cari baris ini (sekitar baris 70):
   ```javascript
   const APPS_SCRIPT_URL = 'YOUR_APPS_SCRIPT_URL_HERE';
   ```

### 5.2 Gantikan URL
1. Padam `YOUR_APPS_SCRIPT_URL_HERE`
2. Paste URL yang anda salin dari Langkah 4.5
3. Pastikan URL dalam tanda petikan `' '`

**Sebelum:**
```javascript
const APPS_SCRIPT_URL = 'YOUR_APPS_SCRIPT_URL_HERE';
```

**Selepas:**
```javascript
const APPS_SCRIPT_URL = 'https://script.google.com/macros/s/AKfycbx.../exec';
```

### 5.3 Simpan Fail
1. Klik **File** → **Save** atau Ctrl+S

---

## Langkah 6: Test Pengesahan

### 6.1 Buka Halaman Web
1. Double-klik fail `verify.html`
2. Halaman akan dibuka dalam browser

### 6.2 Test dengan Nombor Sijil
1. Masukkan nombor sijil (contoh: `CERT-PROG-2024-0001`)
2. Klik butang **"Sahkan Sijil"**
3. Tunggu beberapa saat

### 6.3 Hasil
**Jika sijil sah:**
```
✅ Sijil Sah
No. Sijil: CERT-PROG-2024-0001
Nama: Ali bin Abu
No. IC: 901234****56
Program: Kursus Kepimpinan
Tarikh: 2024-12-03
```

**Jika sijil tidak sah:**
```
❌ Sijil Tidak Sah
Nombor sijil tidak dijumpai dalam sistem.
```

---

## Langkah 7: Kongsi Halaman Web (Pilihan)

### Pilihan A: Kongsi Fail HTML Secara Terus
- Hantar fail `verify.html` melalui email/WhatsApp
- Penerima boleh buka fail tersebut dalam browser

### Pilihan B: Upload ke GitHub Pages (Percuma)

1. Buat akaun GitHub di https://github.com
2. Buat repository baru (contoh: `verify-sijil`)
3. Upload fail `verify.html`
4. Pergi ke Settings → Pages
5. Source: Deploy from branch → Main → Save
6. URL anda: `https://username.github.io/verify-sijil/verify.html`

### Pilihan C: Google Sites (Percuma)

1. Buka https://sites.google.com
2. Buat site baru
3. Tambah "Embed" → "Embed code"
4. Paste kandungan HTML

---

## Cara Update Data Sijil

Bila ada sijil baru, ikut langkah ini:

### Kaedah 1: Export Semula (Disyorkan)
1. Export data sijil dari app
2. Buka Google Sheets
3. Padam semua baris data (kecuali header baris 1)
4. File → Import → Upload CSV baru
5. Pilih "Append to current sheet"

### Kaedah 2: Tambah Manual
1. Buka Google Sheets
2. Tambah baris baru di bawah
3. Isi data sijil secara manual

---

## Troubleshooting (Masalah & Penyelesaian)

### Masalah: "Authorization required"
**Penyelesaian:** 
- Klik Authorize dan benarkan akses
- Pastikan anda log masuk dengan akaun Google yang sama

### Masalah: "Script function not found"
**Penyelesaian:**
- Pastikan kod Apps Script di-copy dengan lengkap
- Pastikan ada function `doGet(e)`

### Masalah: Halaman web tidak berfungsi
**Penyelesaian:**
- Pastikan URL Apps Script betul
- Pastikan deployment adalah "Anyone"
- Cuba deploy semula dengan version baru

### Masalah: CORS Error
**Penyelesaian:**
- Pastikan "Who has access" = "Anyone"
- Deploy sebagai "Web app" bukan "API executable"

---

## Soalan Lazim (FAQ)

**S: Adakah ini percuma?**
J: Ya, 100% percuma. Google Sheets dan Apps Script tiada caj.

**S: Berapa banyak sijil boleh disimpan?**
J: Google Sheets boleh simpan sehingga 10 juta sel. Untuk sijil, boleh simpan puluhan ribu rekod.

**S: Adakah data selamat?**
J: Data disimpan dalam Google Drive anda. Hanya anda boleh edit. Orang lain hanya boleh semak/verify.

**S: Boleh guna di telefon?**
J: Ya, halaman web verify.html boleh dibuka di mana-mana browser termasuk telefon.

---

## Ringkasan Langkah

| # | Langkah | Masa |
|---|---------|------|
| 1 | Export data dari app | 1 min |
| 2 | Buat Google Sheets & import CSV | 3 min |
| 3 | Setup Apps Script | 5 min |
| 4 | Deploy Web App | 2 min |
| 5 | Edit verify.html dengan URL | 2 min |
| 6 | Test pengesahan | 1 min |
| **Total** | | **~15 min** |

---

## Bantuan

Jika ada masalah, rujuk:
- Dokumentasi Google Apps Script: https://developers.google.com/apps-script
- Google Sheets Help: https://support.google.com/docs/answer/6000292

---

*Dokumen ini dijana oleh Sistem Sijil v1.0*
