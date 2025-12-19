import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileUtils {
  static Future<String> getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final appDir = Directory(p.join(directory.path, 'SistemSijil'));
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir.path;
  }

  static Future<String> getCertificatesDirectory() async {
    final appDir = await getAppDirectory();
    final certDir = Directory(p.join(appDir, 'certificates'));
    if (!await certDir.exists()) {
      await certDir.create(recursive: true);
    }
    return certDir.path;
  }

  static Future<String> getLogosDirectory() async {
    final appDir = await getAppDirectory();
    final logoDir = Directory(p.join(appDir, 'logos'));
    if (!await logoDir.exists()) {
      await logoDir.create(recursive: true);
    }
    return logoDir.path;
  }

  static Future<String> getSignaturesDirectory() async {
    final appDir = await getAppDirectory();
    final sigDir = Directory(p.join(appDir, 'signatures'));
    if (!await sigDir.exists()) {
      await sigDir.create(recursive: true);
    }
    return sigDir.path;
  }

  static Future<String> getBackupsDirectory() async {
    final appDir = await getAppDirectory();
    final backupDir = Directory(p.join(appDir, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir.path;
  }

  static Future<File> saveFile(List<int> bytes, String directory, String filename) async {
    final file = File(p.join(directory, filename));
    return await file.writeAsBytes(bytes);
  }

  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static String getFileName(String path) {
    return p.basename(path);
  }

  static String sanitizeFileName(String fileName) {
    // Remove invalid characters for Windows filenames
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }
}
