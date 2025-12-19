import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../data/repositories/certificate_repository.dart';
import '../data/repositories/participant_repository.dart';
import '../data/repositories/program_repository.dart';

class AutoCsvService {
  static final AutoCsvService _instance = AutoCsvService._internal();
  factory AutoCsvService() => _instance;
  AutoCsvService._internal();

  final CertificateRepository _certRepo = CertificateRepository();
  final ParticipantRepository _participantRepo = ParticipantRepository();
  final ProgramRepository _programRepo = ProgramRepository();

  Future<String> get _csvFolderPath async {
    final appDir = await getApplicationDocumentsDirectory();
    final csvDir = Directory('${appDir.path}/SistemSijil/OnlineVerification');
    if (!await csvDir.exists()) {
      await csvDir.create(recursive: true);
    }
    return csvDir.path;
  }

  Future<void> updateCsvFile() async {
    try {
      final folderPath = await _csvFolderPath;
      final certificates = await _certRepo.getAll();

      if (certificates.isEmpty) return;

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

      final csvFile = File('$folderPath/sijil_data.csv');
      await csvFile.writeAsString(buffer.toString());

      await _ensureHelperFilesExist(folderPath);
    } catch (e) {
      print('Error updating CSV: $e');
    }
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Future<String?> getCsvFolderPath() async {
    try {
      return await _csvFolderPath;
    } catch (e) {
      return null;
    }
  }

  Future<void> _ensureHelperFilesExist(String folderPath) async {
    final appsScriptFile = File('$folderPath/apps_script.js');
    if (!await appsScriptFile.exists()) {
      await _createAppsScriptFile(folderPath);
    }

    final verifyHtmlFile = File('$folderPath/verify.html');
    if (!await verifyHtmlFile.exists()) {
      await _createVerificationHtmlFile(folderPath);
    }

    final readmeFile = File('$folderPath/README.txt');
    if (!await readmeFile.exists()) {
      await _createReadmeFile(folderPath);
    }
  }

  Future<void> _createAppsScriptFile(String folderPath) async {
    const appsScript = '''
// Google Apps Script untuk Pengesahan Sijil Online
// Copy dan paste kod ini ke Apps Script (Extensions > Apps Script)
// JANGAN tekan Run - kod ini hanya berfungsi melalui URL web

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
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheets = ss.getSheets();
  
  // Cuba cari data dalam semua sheets
  for (var s = 0; s < sheets.length; s++) {
    var sheet = sheets[s];
    var lastRow = sheet.getLastRow();
    var lastCol = sheet.getLastColumn();
    
    // Skip jika sheet kosong
    if (lastRow < 2 || lastCol < 1) continue;
    
    var data = sheet.getRange(1, 1, lastRow, lastCol).getValues();
    var headers = data[0];
    
    // Cari column index (case-insensitive)
    var certNumCol = -1, nameCol = -1, icCol = -1, programCol = -1, dateCol = -1;
    
    for (var h = 0; h < headers.length; h++) {
      var header = String(headers[h]).toLowerCase().trim();
      if (header === 'certificate_number' || header === 'no_sijil' || header === 'cert_number') {
        certNumCol = h;
      } else if (header === 'participant_name' || header === 'nama' || header === 'name') {
        nameCol = h;
      } else if (header === 'ic_number' || header === 'ic' || header === 'no_ic' || header === 'no_kp') {
        icCol = h;
      } else if (header === 'program_name' || header === 'program' || header === 'kursus') {
        programCol = h;
      } else if (header === 'issue_date' || header === 'tarikh' || header === 'date') {
        dateCol = h;
      }
    }
    
    // Skip jika tiada column certificate_number
    if (certNumCol === -1) continue;
    
    // Cari sijil
    for (var i = 1; i < data.length; i++) {
      var cellValue = String(data[i][certNumCol]).trim().toUpperCase();
      var searchValue = String(certNumber).trim().toUpperCase();
      
      if (cellValue === searchValue) {
        return {
          valid: true,
          certificate_number: data[i][certNumCol],
          participant_name: nameCol >= 0 ? (data[i][nameCol] || '-') : '-',
          ic_number: icCol >= 0 ? maskIC(String(data[i][icCol] || '')) : '-',
          program_name: programCol >= 0 ? (data[i][programCol] || '-') : '-',
          issue_date: dateCol >= 0 ? formatDate(data[i][dateCol]) : '-'
        };
      }
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

// Function untuk test dalam Apps Script editor
function testConnection() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getActiveSheet();
  var lastRow = sheet.getLastRow();
  var lastCol = sheet.getLastColumn();
  
  Logger.log('Sheet name: ' + sheet.getName());
  Logger.log('Last row: ' + lastRow);
  Logger.log('Last column: ' + lastCol);
  
  if (lastRow > 0 && lastCol > 0) {
    var headers = sheet.getRange(1, 1, 1, lastCol).getValues()[0];
    Logger.log('Headers: ' + headers.join(', '));
    
    if (lastRow > 1) {
      var firstData = sheet.getRange(2, 1, 1, lastCol).getValues()[0];
      Logger.log('First data row: ' + firstData.join(', '));
    }
  }
  
  return 'Check Logs (View > Logs)';
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
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">
            <h1>Pengesahan Sijil</h1>
            <p>Sistem Pengesahan Sijil Rasmi</p>
        </div>
        
        <div class="form-group">
            <label for="certNumber">Nombor Sijil</label>
            <input type="text" id="certNumber" placeholder="Contoh: CERT-PROG-2024-0001">
        </div>
        
        <button onclick="verifyCertificate()" id="verifyBtn">Sahkan Sijil</button>
        
        <div class="result" id="result"></div>
    </div>

    <script>
        // GANTIKAN URL INI dengan URL Apps Script anda
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
            resultDiv.innerHTML = '<div style="text-align:center;color:#666;">Mencari rekod sijil...</div>';
            
            try {
                const response = await fetch(APPS_SCRIPT_URL + '?cert=' + encodeURIComponent(certNumber));
                const data = await response.json();
                
                if (data.valid) {
                    resultDiv.className = 'result valid';
                    resultDiv.innerHTML = 
                        '<h3>Sijil Sah</h3>' +
                        '<div class="info-row"><span class="info-label">No. Sijil:</span><span class="info-value">' + data.certificate_number + '</span></div>' +
                        '<div class="info-row"><span class="info-label">Nama:</span><span class="info-value">' + data.participant_name + '</span></div>' +
                        '<div class="info-row"><span class="info-label">No. IC:</span><span class="info-value">' + data.ic_number + '</span></div>' +
                        '<div class="info-row"><span class="info-label">Program:</span><span class="info-value">' + data.program_name + '</span></div>' +
                        '<div class="info-row"><span class="info-label">Tarikh:</span><span class="info-value">' + data.issue_date + '</span></div>';
                } else {
                    resultDiv.className = 'result invalid';
                    resultDiv.innerHTML = '<h3>Sijil Tidak Sah</h3><p>' + (data.message || 'Nombor sijil tidak dijumpai.') + '</p>';
                }
            } catch (error) {
                resultDiv.className = 'result invalid';
                resultDiv.innerHTML = '<h3>Ralat</h3><p>Tidak dapat menghubungi pelayan.</p>';
            }
            
            btn.disabled = false;
            btn.textContent = 'Sahkan Sijil';
        }
        
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
PANDUAN PENGESAHAN SIJIL ONLINE
===============================

FAIL DALAM FOLDER INI:
1. sijil_data.csv  - Data sijil (AUTO-UPDATE setiap kali sijil dijana)
2. apps_script.js  - Kod untuk Google Apps Script
3. verify.html     - Halaman web pengesahan
4. README.txt      - Panduan ini

LANGKAH SETUP:
1. Buka Google Sheets (sheets.google.com)
2. Import fail sijil_data.csv
3. Extensions > Apps Script > Paste kod dari apps_script.js
4. Deploy > New deployment > Web app > Anyone
5. Salin URL dan edit verify.html
6. Siap! Buka verify.html untuk test

NOTA: Fail sijil_data.csv akan dikemaskini secara automatik
setiap kali sijil baru dijana. Anda hanya perlu upload semula
ke Google Sheets untuk kemaskini data online.
''';

    final file = File('$folderPath/README.txt');
    await file.writeAsString(readme);
  }
}
