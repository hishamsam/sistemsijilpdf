import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../data/repositories/certificate_repository.dart';
import '../data/repositories/participant_repository.dart';
import '../data/repositories/program_repository.dart';

class OnlineVerificationExportService {
  final CertificateRepository _certRepo = CertificateRepository();
  final ParticipantRepository _participantRepo = ParticipantRepository();
  final ProgramRepository _programRepo = ProgramRepository();

  Future<String?> exportCertificatesForGoogleSheets() async {
    final folderPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Pilih folder untuk simpan export',
    );

    if (folderPath == null) return null;

    final certificates = await _certRepo.getAll();
    
    if (certificates.isEmpty) {
      throw Exception('Tiada sijil untuk diexport');
    }

    // Create CSV content
    final buffer = StringBuffer();
    buffer.writeln('certificate_number,unique_code,participant_name,ic_number,program_name,program_code,issue_date,generated_at');

    for (final cert in certificates) {
      final participant = await _participantRepo.getById(cert.participantId);
      if (participant == null) continue;

      final program = await _programRepo.getById(participant.programId);
      if (program == null) continue;

      final issueDate = DateFormat('yyyy-MM-dd').format(program.issueDate);
      final generatedAt = cert.generatedAt != null 
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(cert.generatedAt!)
          : '';

      buffer.writeln(
        '${_escapeCsv(cert.certificateNumber)},'
        '${_escapeCsv(cert.uniqueCode)},'
        '${_escapeCsv(participant.fullName)},'
        '${_escapeCsv(participant.icNumber)},'
        '${_escapeCsv(program.programName)},'
        '${_escapeCsv(program.programCode)},'
        '$issueDate,'
        '$generatedAt'
      );
    }

    // Save CSV file
    final csvFile = File('$folderPath/sijil_data.csv');
    await csvFile.writeAsString(buffer.toString());

    // Create Apps Script file
    await _createAppsScriptFile(folderPath);

    // Create HTML verification page
    await _createVerificationHtmlFile(folderPath);

    // Create README
    await _createReadmeFile(folderPath);

    return folderPath;
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Future<void> _createAppsScriptFile(String folderPath) async {
    const appsScript = '''
// Google Apps Script untuk Pengesahan Sijil Online
// Copy dan paste kod ini ke Apps Script (Extensions > Apps Script)

function doGet(e) {
  var cert = e.parameter.cert;
  var result = verifyCertificate(cert);
  
  return ContentService
    .createTextOutput(JSON.stringify(result))
    .setMimeType(ContentService.MimeType.JSON);
}

function verifyCertificate(certNumber) {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  var data = sheet.getDataRange().getValues();
  var headers = data[0];
  
  // Find column indexes
  var certNumCol = headers.indexOf('certificate_number');
  var nameCol = headers.indexOf('participant_name');
  var icCol = headers.indexOf('ic_number');
  var programCol = headers.indexOf('program_name');
  var dateCol = headers.indexOf('issue_date');
  
  for (var i = 1; i < data.length; i++) {
    if (data[i][certNumCol] === certNumber) {
      return {
        valid: true,
        certificate_number: data[i][certNumCol],
        participant_name: data[i][nameCol],
        ic_number: maskIC(data[i][icCol]),
        program_name: data[i][programCol],
        issue_date: data[i][dateCol]
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

// Test function
function testVerify() {
  var result = verifyCertificate('TEST-2024-0001');
  Logger.log(result);
}
''';

    final file = File('$folderPath/apps_script.js');
    await file.writeAsString(appsScript);
  }

  Future<void> _createVerificationHtmlFile(String folderPath) async {
    const htmlContent = '''
<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pengesahan Sijil</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 40px;
            width: 100%;
            max-width: 500px;
        }
        .logo { text-align: center; margin-bottom: 30px; }
        .logo h1 { color: #667eea; font-size: 24px; }
        .logo p { color: #666; margin-top: 5px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; color: #333; font-weight: 500; }
        input {
            width: 100%;
            padding: 15px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 16px;
            transition: border-color 0.3s;
        }
        input:focus { outline: none; border-color: #667eea; }
        button {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        button:hover { transform: translateY(-2px); box-shadow: 0 5px 20px rgba(102,126,234,0.4); }
        button:disabled { opacity: 0.7; cursor: not-allowed; transform: none; }
        .result { margin-top: 30px; padding: 20px; border-radius: 10px; display: none; }
        .result.valid { background: #d4edda; border: 1px solid #c3e6cb; }
        .result.invalid { background: #f8d7da; border: 1px solid #f5c6cb; }
        .result h3 { margin-bottom: 15px; }
        .result.valid h3 { color: #155724; }
        .result.invalid h3 { color: #721c24; }
        .info-row { display: flex; padding: 8px 0; border-bottom: 1px solid rgba(0,0,0,0.1); }
        .info-row:last-child { border-bottom: none; }
        .info-label { color: #666; width: 140px; }
        .info-value { color: #333; font-weight: 500; }
        .loading { text-align: center; color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">
            <h1>🏆 Pengesahan Sijil</h1>
            <p>Sistem Pengesahan Sijil Rasmi</p>
        </div>
        
        <div class="form-group">
            <label for="certNumber">Nombor Sijil</label>
            <input type="text" id="certNumber" placeholder="Contoh: PROG-2024-0001">
        </div>
        
        <button onclick="verifyCertificate()" id="verifyBtn">Sahkan Sijil</button>
        
        <div class="result" id="result"></div>
    </div>

    <script>
        // PENTING: Gantikan URL ini dengan URL deployment Apps Script anda
        const APPS_SCRIPT_URL = 'YOUR_APPS_SCRIPT_URL_HERE';
        
        async function verifyCertificate() {
            const certNumber = document.getElementById('certNumber').value.trim();
            const resultDiv = document.getElementById('result');
            const btn = document.getElementById('verifyBtn');
            
            if (!certNumber) {
                alert('Sila masukkan nombor sijil');
                return;
            }
            
            btn.disabled = true;
            btn.textContent = 'Mengesahkan...';
            resultDiv.style.display = 'block';
            resultDiv.className = 'result';
            resultDiv.innerHTML = '<div class="loading">Mencari rekod sijil...</div>';
            
            try {
                const response = await fetch(APPS_SCRIPT_URL + '?cert=' + encodeURIComponent(certNumber));
                const data = await response.json();
                
                if (data.valid) {
                    resultDiv.className = 'result valid';
                    resultDiv.innerHTML = `
                        <h3>✅ Sijil Sah</h3>
                        <div class="info-row">
                            <span class="info-label">No. Sijil:</span>
                            <span class="info-value">\${data.certificate_number}</span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Nama:</span>
                            <span class="info-value">\${data.participant_name}</span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">No. IC:</span>
                            <span class="info-value">\${data.ic_number}</span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Program:</span>
                            <span class="info-value">\${data.program_name}</span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Tarikh:</span>
                            <span class="info-value">\${data.issue_date}</span>
                        </div>
                    `;
                } else {
                    resultDiv.className = 'result invalid';
                    resultDiv.innerHTML = `
                        <h3>❌ Sijil Tidak Sah</h3>
                        <p>\${data.message || 'Nombor sijil tidak dijumpai dalam sistem.'}</p>
                    `;
                }
            } catch (error) {
                resultDiv.className = 'result invalid';
                resultDiv.innerHTML = `
                    <h3>⚠️ Ralat</h3>
                    <p>Tidak dapat menghubungi pelayan. Sila cuba lagi.</p>
                `;
            }
            
            btn.disabled = false;
            btn.textContent = 'Sahkan Sijil';
        }
        
        // Allow Enter key to verify
        document.getElementById('certNumber').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') verifyCertificate();
        });
    </script>
</body>
</html>
''';

    final file = File('$folderPath/verify.html');
    await file.writeAsString(htmlContent);
  }

  Future<void> _createReadmeFile(String folderPath) async {
    const readme = '''
================================================================================
                    PANDUAN SETUP PENGESAHAN SIJIL ONLINE
                         Menggunakan Google Sheets
================================================================================

FAIL YANG DISERTAKAN:
---------------------
1. sijil_data.csv     - Data sijil untuk import ke Google Sheets
2. apps_script.js     - Kod Google Apps Script untuk API
3. verify.html        - Halaman web untuk pengesahan
4. README.txt         - Panduan ini

================================================================================
LANGKAH-LANGKAH SETUP:
================================================================================

LANGKAH 1: Buat Google Sheets
-----------------------------
1. Buka https://sheets.google.com
2. Klik "+ Blank" untuk buat spreadsheet baru
3. Namakan spreadsheet: "Sijil Database"
4. Pergi ke File > Import > Upload
5. Upload fail "sijil_data.csv"
6. Pilih "Replace current sheet" dan klik "Import data"

LANGKAH 2: Setup Apps Script
----------------------------
1. Dalam Google Sheets, pergi ke Extensions > Apps Script
2. Padam semua kod sedia ada
3. Buka fail "apps_script.js" dengan Notepad
4. Copy semua kod dan paste ke Apps Script
5. Klik butang Save (💾)
6. Namakan projek: "Pengesahan Sijil API"

LANGKAH 3: Deploy sebagai Web App
---------------------------------
1. Klik "Deploy" > "New deployment"
2. Klik ikon gear ⚙️ dan pilih "Web app"
3. Isi maklumat:
   - Description: "Pengesahan Sijil API"
   - Execute as: "Me"
   - Who has access: "Anyone"
4. Klik "Deploy"
5. Klik "Authorize access" dan ikut arahan
6. SALIN URL yang diberi (simpan URL ini!)

LANGKAH 4: Setup Halaman Web Pengesahan
---------------------------------------
1. Buka fail "verify.html" dengan Notepad
2. Cari baris: const APPS_SCRIPT_URL = 'YOUR_APPS_SCRIPT_URL_HERE';
3. Gantikan 'YOUR_APPS_SCRIPT_URL_HERE' dengan URL dari Langkah 3
4. Simpan fail

LANGKAH 5: Host Halaman Web (Pilihan)
-------------------------------------
Pilihan A: Google Sites (Percuma)
- Buka https://sites.google.com
- Buat site baru
- Embed kod HTML atau upload fail

Pilihan B: GitHub Pages (Percuma)
- Buat repository baru di GitHub
- Upload verify.html
- Enable GitHub Pages di Settings

Pilihan C: Buka secara lokal
- Double-klik verify.html untuk buka dalam browser

================================================================================
CARA UPDATE DATA SIJIL:
================================================================================
1. Export data baru dari aplikasi Sistem Sijil
2. Buka Google Sheets
3. Padam data lama (Row 2 hingga akhir)
4. Import fail CSV baru
5. Data akan dikemaskini secara automatik

================================================================================
TROUBLESHOOTING:
================================================================================
- "Authorization required": Klik Authorize dan benarkan akses
- "Script function not found": Pastikan kod Apps Script betul
- "CORS error": Pastikan deploy sebagai Web App dengan "Anyone" access

================================================================================
SOKONGAN:
================================================================================
Jika ada masalah, sila rujuk dokumentasi Google Apps Script:
https://developers.google.com/apps-script

================================================================================
''';

    final file = File('$folderPath/README.txt');
    await file.writeAsString(readme);
  }
}
