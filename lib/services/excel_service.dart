import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../data/models/participant.dart';

class ExcelService {
  Future<List<Participant>> importFromExcel(int programId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result == null || result.files.isEmpty) {
      return [];
    }

    final file = File(result.files.single.path!);
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    final participants = <Participant>[];
    final sheet = excel.tables.values.first;

    bool headerSkipped = false;
    for (final row in sheet.rows) {
      if (!headerSkipped) {
        headerSkipped = true;
        continue;
      }

      if (row.isEmpty || row[0] == null) continue;

      final fullName = _getCellValue(row, 0);
      final icNumber = _getCellValue(row, 1);
      final email = _getCellValue(row, 2);

      if (fullName.isNotEmpty && icNumber.isNotEmpty) {
        participants.add(Participant(
          programId: programId,
          fullName: fullName.toUpperCase(),
          icNumber: icNumber.replaceAll('-', '').replaceAll(' ', ''),
          email: email.isNotEmpty ? email : null,
        ));
      }
    }

    return participants;
  }

  String _getCellValue(List<Data?> row, int index) {
    if (index >= row.length || row[index] == null) return '';
    final value = row[index]!.value;
    if (value == null) return '';
    return value.toString().trim();
  }

  Future<File?> generateTemplate() async {
    final excel = Excel.createExcel();
    
    // Delete default sheet and create new one
    excel.delete('Sheet1');
    final sheet = excel['Peserta'];
    excel.setDefaultSheet('Peserta');

    // Header row
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('NAMA PENUH');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue('NO KAD PENGENALAN');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = TextCellValue('EMAIL (PILIHAN)');

    // Example row 1
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value = TextCellValue('AHMAD BIN ALI');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1)).value = TextCellValue('901234567890');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1)).value = TextCellValue('ahmad@email.com');

    // Example row 2
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value = TextCellValue('SITI BINTI AHMAD');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2)).value = TextCellValue('911234567890');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 2)).value = TextCellValue('siti@email.com');

    // Set column widths
    sheet.setColumnWidth(0, 35);
    sheet.setColumnWidth(1, 20);
    sheet.setColumnWidth(2, 30);

    final saveResult = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan Template Excel',
      fileName: 'template_peserta.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (saveResult == null) return null;

    final bytes = excel.save();
    if (bytes == null) return null;

    final file = File(saveResult);
    await file.writeAsBytes(bytes);
    return file;
  }
}
