# Sistem Sijil - Dokumentasi Lengkap

## Pengenalan

Sistem Sijil adalah aplikasi desktop yang dibangunkan menggunakan Flutter untuk pengurusan dan penjanaan sijil digital. Aplikasi ini menyokong dwibahasa (Bahasa Melayu & English) dan boleh beroperasi secara offline.

---

## Keperluan Sistem

### Minimum
- Windows 10 atau lebih tinggi
- RAM: 4GB
- Ruang storan: 500MB
- Resolusi skrin: 1280 x 720

### Perisian Diperlukan untuk Development
- Flutter SDK 3.0+
- Dart SDK
- Visual Studio 2022 dengan C++ Desktop Development
- Git

---

## Pemasangan & Setup

### 1. Clone/Download Projek

```bash
cd "C:\Users\Administrator\Desktop"
git clone <repository-url> "dektop app"
```

### 2. Install Dependencies

```bash
cd "C:\Users\Administrator\Desktop\dektop app"
flutter pub get
```

### 3. Build Aplikasi

#### Development Mode
```bash
flutter run -d windows
```

#### Release Mode
```bash
flutter build windows --release
```

Fail executable akan dijana di:
```
build\windows\x64\runner\Release\sistem_sijil.exe
```

### 4. Mengatasi Masalah Build

Jika terdapat error CMake:
```bash
# Padam folder build dan cuba semula
Remove-Item -Recurse -Force "build\windows"
flutter clean
flutter pub get
flutter run -d windows
```

---

## Struktur Projek

```
lib/
├── app.dart                      # Main app widget
├── main.dart                     # Entry point
├── core/
│   ├── constants/               # Konstant aplikasi
│   ├── localization/
│   │   └── app_strings.dart     # Terjemahan BM & EN
│   ├── theme/
│   │   ├── app_colors.dart      # Warna tema
│   │   ├── app_styles.dart      # Text styles
│   │   └── app_theme.dart       # Theme configuration
│   └── utils/
│       ├── crypto_utils.dart    # Enkripsi & hash
│       ├── date_utils.dart      # Format tarikh
│       └── file_utils.dart      # Operasi fail
├── data/
│   ├── database/
│   │   └── database_helper.dart # SQLite database
│   ├── models/
│   │   ├── certificate.dart     # Model sijil
│   │   ├── participant.dart     # Model peserta
│   │   └── program.dart         # Model program
│   └── repositories/
│       ├── certificate_repository.dart
│       ├── participant_repository.dart
│       ├── program_repository.dart
│       └── settings_repository.dart
├── features/
│   ├── certificates/
│   │   ├── screens/             # Preview sijil
│   │   └── templates/           # Template sijil (4 jenis)
│   ├── dashboard/
│   │   └── screens/
│   │       └── dashboard_screen.dart
│   ├── programs/
│   │   ├── providers/
│   │   │   └── program_provider.dart
│   │   ├── screens/
│   │   │   ├── program_create_screen.dart
│   │   │   ├── program_detail_screen.dart
│   │   │   └── programs_list_screen.dart
│   │   └── widgets/
│   ├── settings/
│   │   ├── providers/
│   │   │   └── settings_provider.dart
│   │   └── screens/
│   │       └── settings_screen.dart
│   └── verification/
│       └── screens/
│           └── verify_screen.dart
├── services/
│   ├── auto_csv_service.dart    # Export CSV automatik
│   ├── backup_service.dart      # Sandaran & pemulihan
│   ├── excel_service.dart       # Import/export Excel
│   ├── pdf_service.dart         # Jana PDF sijil
│   └── qr_service.dart          # Jana QR code
└── widgets/
    ├── app_button.dart          # Custom button
    ├── app_card.dart            # Custom card
    ├── app_input.dart           # Custom input
    ├── responsive_layout.dart   # Layout responsif
    └── sidebar.dart             # Navigation sidebar
```

---

## Ciri-ciri Utama

### 1. Pengurusan Program
- Cipta, edit, padam program
- Tetapkan maklumat penganjur
- Pilih jenis sijil (Penyertaan, Penghargaan, Pencapaian, Kehadiran)
- Pilih template (Moden, Klasik, Formal, Kreatif)
- Muat naik logo dan tandatangan

### 2. Pengurusan Peserta
- Import senarai dari Excel
- Tambah/padam peserta manual
- Carian peserta
- Pilihan berbilang untuk jana sijil

### 3. Penjanaan Sijil
- Jana sijil PDF individu
- Jana sijil secara pukal
- Gabung semua sijil dalam satu PDF
- QR code untuk pengesahan
- 4 template sijil tersedia

### 4. Pengesahan Sijil
- Sahkan sijil menggunakan nombor sijil
- Sahkan melalui QR code
- Papar maklumat sijil yang sah

### 5. Tetapan
- Tukar bahasa (BM/EN)
- Kunci kata laluan
- Sandaran & pemulihan data
- Setup pengesahan online

---

## Sistem Localization (Dwibahasa)

### Cara Kerja

Sistem menggunakan `Map` untuk menyimpan terjemahan:

```dart
// lib/core/localization/app_strings.dart

static const Map<String, Map<String, String>> _strings = {
  'welcome': {'ms': 'Selamat Datang!', 'en': 'Welcome!'},
  'settings': {'ms': 'Tetapan', 'en': 'Settings'},
  // ...
};
```

### Penggunaan dalam Widget

```dart
import '../../../core/localization/app_strings.dart';

// Dalam widget build method:
Text(tr(context, 'welcome'))  // Output: "Selamat Datang!" atau "Welcome!"
```

### Menambah Terjemahan Baru

1. Buka `lib/core/localization/app_strings.dart`
2. Tambah key baru dalam `_strings` map:

```dart
'new_key': {'ms': 'Teks Melayu', 'en': 'English Text'},
```

3. Gunakan dalam widget:

```dart
Text(tr(context, 'new_key'))
```

### Tukar Bahasa

Bahasa ditukar melalui `SettingsProvider`:

```dart
// Dalam settings_screen.dart
settings.setLanguage('en');  // Tukar ke English
settings.setLanguage('ms');  // Tukar ke Bahasa Melayu
```

---

## Database

### SQLite Tables

#### programs
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| program_name | TEXT | Nama program |
| program_code | TEXT | Kod program |
| program_year | INTEGER | Tahun program |
| organizer | TEXT | Nama penganjur |
| organizer_tagline | TEXT | Tagline |
| signatory_name | TEXT | Nama penandatangan |
| signatory_title | TEXT | Jawatan |
| certificate_type | TEXT | Jenis sijil |
| template_style | TEXT | Gaya template |
| language | TEXT | Bahasa sijil |
| issue_date | TEXT | Tarikh keluaran |
| logo_path | TEXT | Path logo |
| signature_path | TEXT | Path tandatangan |

#### participants
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| program_id | INTEGER | Foreign key |
| full_name | TEXT | Nama penuh |
| ic_number | TEXT | No. KP |
| email | TEXT | Email |
| has_certificate | INTEGER | Status sijil |

#### certificates
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| participant_id | INTEGER | Foreign key |
| certificate_number | TEXT | Nombor sijil |
| qr_data | TEXT | Data QR |
| generated_at | TEXT | Tarikh jana |
| verification_count | INTEGER | Kali disahkan |

#### settings
| Column | Type | Description |
|--------|------|-------------|
| key | TEXT | Primary key |
| value | TEXT | Nilai setting |

---

## Pengesahan Online (Pilihan)

### Setup Google Apps Script

1. **Export Data Sijil**
   - Klik "Buka Folder CSV" di Tetapan
   - Fail CSV akan dijana automatik

2. **Buat Google Sheets**
   - Buka [sheets.google.com](https://sheets.google.com)
   - Import fail CSV

3. **Setup Apps Script**
   - Pergi ke Extensions > Apps Script
   - Paste kod dari fail `apps_script.js`

4. **Deploy Web App**
   - Klik Deploy > New deployment
   - Pilih "Web app"
   - Set "Who has access" kepada "Anyone"
   - Copy URL deployment

5. **Simpan URL**
   - Paste URL di Tetapan > Pengesahan Online
   - QR code pada sijil akan mengandungi link pengesahan

---

## Sandaran & Pemulihan

### Buat Sandaran
1. Buka Tetapan
2. Klik "Buat Sandaran"
3. Pilih lokasi untuk simpan fail `.json`

### Pulihkan Data
1. Buka Tetapan
2. Klik "Pulihkan Data"
3. Pilih fail sandaran `.json`
4. Sahkan untuk menggantikan data sedia ada

---

## Factory Reset (Set Semula Kilang)

### Apa yang Dipadam
Factory reset akan memadam **SEMUA** data dalam aplikasi:
- Semua program
- Semua peserta
- Semua sijil yang dijana
- Semua tetapan (kata laluan, URL pengesahan, dll.)

### Cara Melakukan Factory Reset

1. Buka **Tetapan**
2. Scroll ke bahagian **Set Semula Kilang**
3. Klik butang **"Set Semula Sekarang"**
4. Dialog pengesahan akan muncul
5. Taip perkataan pengesahan:
   - Bahasa Melayu: `PADAM`
   - English: `DELETE`
6. Klik butang **"Set Semula Kilang"**
7. Tunggu proses selesai

### Amaran
- **Tindakan ini TIDAK BOLEH dibatalkan**
- Pastikan anda telah membuat sandaran sebelum melakukan factory reset
- Selepas reset, aplikasi akan kembali ke tetapan asal

### Tetapan Asal Selepas Reset
| Setting | Nilai |
|---------|-------|
| Tema | Light |
| Bahasa | Bahasa Melayu (ms) |
| Kata Laluan | Tiada |
| URL Pengesahan | Tiada |

---

## Troubleshooting

### Build Error: CMake Platform Mismatch
```bash
Remove-Item -Recurse -Force "build\windows"
flutter clean
flutter pub get
flutter run -d windows
```

### Build Terlalu Lama
- Build pertama mengambil masa 5-15 minit
- Pastikan antivirus tidak scan folder build
- Gunakan `flutter build windows --release` untuk production

### Database Error
- Padam fail database dan restart aplikasi
- Lokasi: `%APPDATA%\sistem_sijil\`

### Import Excel Gagal
- Pastikan format Excel betul (nama, no_kp, email)
- Muat turun template dari aplikasi

---

## Pembangunan Lanjutan

### Menambah Template Sijil Baru

1. Cipta fail baru di `lib/features/certificates/templates/`
2. Extend `StatelessWidget`
3. Implement layout menggunakan `pw.Document()`
4. Daftar template dalam `pdf_service.dart`

### Menambah Bahasa Baru

1. Tambah kod bahasa dalam `app_strings.dart`:
```dart
'welcome': {'ms': '...', 'en': '...', 'zh': '欢迎'},
```

2. Kemaskini dropdown di `settings_screen.dart`

3. Kemaskini `SettingsRepository` jika perlu

---

## Unit Testing

### Struktur Test
```
test/
├── models/
│   ├── program_test.dart      (7 tests)
│   ├── participant_test.dart  (8 tests)
│   └── certificate_test.dart  (9 tests)
├── utils/
│   ├── crypto_utils_test.dart (18 tests)
│   └── date_utils_test.dart   (17 tests)
├── localization/
│   └── app_strings_test.dart  (10 tests)
└── widget_test.dart           (3 tests)
```

### Menjalankan Tests
```bash
# Jalankan semua tests
flutter test

# Jalankan dengan coverage
flutter test --coverage

# Jalankan test tertentu
flutter test test/models/program_test.dart
```

### Jumlah Tests: 72 tests (100% LULUS)

---

## Lesen & Kredit

- Dibangunkan dengan Flutter
- Database: SQLite (sqflite)
- PDF: pdf package
- QR Code: qr_flutter
- Excel: excel package

---

## Sokongan

Untuk sebarang pertanyaan atau masalah:
- Semak dokumentasi ini
- Rujuk kod sumber
- Buat issue di repository

---

*Dokumentasi ini dikemaskini pada Disember 2024*
