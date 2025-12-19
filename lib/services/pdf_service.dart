import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/utils/file_utils.dart';
import '../data/models/certificate.dart';
import '../data/models/participant.dart';
import '../data/models/program.dart';
import '../features/certificates/templates/template_moden.dart';
import '../features/certificates/templates/template_klasik.dart';
import '../features/certificates/templates/template_formal.dart';
import '../features/certificates/templates/template_kreatif.dart';

class PdfService {
  pw.Font? _regularFont;
  pw.Font? _boldFont;
  pw.Font? _italicFont;

  Future<void> _loadFonts() async {
    if (_regularFont != null) return;
    
    final regularData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    final italicData = await rootBundle.load('assets/fonts/Roboto-Italic.ttf');
    
    _regularFont = pw.Font.ttf(regularData);
    _boldFont = pw.Font.ttf(boldData);
    _italicFont = pw.Font.ttf(italicData);
  }

  Future<Uint8List> generateCertificate({
    required Certificate certificate,
    required Participant participant,
    required Program program,
    required Uint8List qrCodeImage,
    Uint8List? logoImage,
    Uint8List? signatureImage,
    Uint8List? signatureImage2,
    Uint8List? signatureImage3,
  }) async {
    await _loadFonts();
    
    final pdf = pw.Document();

    pw.Widget certificateWidget;
    
    switch (program.templateStyle) {
      case 'klasik':
        certificateWidget = TemplateKlasik.build(
          participant: participant,
          program: program,
          certificate: certificate,
          qrCodeImage: qrCodeImage,
          logoImage: logoImage,
          signatureImage: signatureImage,
          signatureImage2: signatureImage2,
          signatureImage3: signatureImage3,
          regularFont: _regularFont!,
          boldFont: _boldFont!,
          italicFont: _italicFont!,
        );
        break;
      case 'formal':
        certificateWidget = TemplateFormal.build(
          participant: participant,
          program: program,
          certificate: certificate,
          qrCodeImage: qrCodeImage,
          logoImage: logoImage,
          signatureImage: signatureImage,
          signatureImage2: signatureImage2,
          signatureImage3: signatureImage3,
          regularFont: _regularFont!,
          boldFont: _boldFont!,
          italicFont: _italicFont!,
        );
        break;
      case 'kreatif':
        certificateWidget = TemplateKreatif.build(
          participant: participant,
          program: program,
          certificate: certificate,
          qrCodeImage: qrCodeImage,
          logoImage: logoImage,
          signatureImage: signatureImage,
          signatureImage2: signatureImage2,
          signatureImage3: signatureImage3,
          regularFont: _regularFont!,
          boldFont: _boldFont!,
          italicFont: _italicFont!,
        );
        break;
      case 'moden':
      default:
        certificateWidget = TemplateModen.build(
          participant: participant,
          program: program,
          certificate: certificate,
          qrCodeImage: qrCodeImage,
          logoImage: logoImage,
          signatureImage: signatureImage,
          signatureImage2: signatureImage2,
          signatureImage3: signatureImage3,
          regularFont: _regularFont!,
          boldFont: _boldFont!,
          italicFont: _italicFont!,
        );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => certificateWidget,
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> generateMergedPdf(List<Uint8List> certificates) async {
    final pdf = pw.Document();

    for (final certBytes in certificates) {
      final pages = await Printing.raster(certBytes, dpi: 150).toList();
      for (final page in pages) {
        final image = await page.toPng();
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (context) => pw.Center(
              child: pw.Image(pw.MemoryImage(image)),
            ),
          ),
        );
      }
    }

    return pdf.save();
  }

  Future<File> savePdf(Uint8List bytes, String filename) async {
    final directory = await FileUtils.getCertificatesDirectory();
    return await FileUtils.saveFile(bytes, directory, filename);
  }

  Future<void> printPdf(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  Future<void> sharePdf(Uint8List bytes, String filename) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  Future<Uint8List> generateCombinedCertificates({
    required List<Map<String, dynamic>> certificateDataList,
    required Program program,
    Uint8List? logoImage,
    Uint8List? signatureImage,
    Uint8List? signatureImage2,
    Uint8List? signatureImage3,
  }) async {
    await _loadFonts();
    
    final pdf = pw.Document();

    for (final data in certificateDataList) {
      final certificate = data['certificate'] as Certificate;
      final participant = data['participant'] as Participant;
      final qrCodeImage = data['qrImage'] as Uint8List;

      pw.Widget certificateWidget;
      
      switch (program.templateStyle) {
        case 'klasik':
          certificateWidget = TemplateKlasik.build(
            participant: participant,
            program: program,
            certificate: certificate,
            qrCodeImage: qrCodeImage,
            logoImage: logoImage,
            signatureImage: signatureImage,
            signatureImage2: signatureImage2,
            signatureImage3: signatureImage3,
            regularFont: _regularFont!,
            boldFont: _boldFont!,
            italicFont: _italicFont!,
          );
          break;
        case 'formal':
          certificateWidget = TemplateFormal.build(
            participant: participant,
            program: program,
            certificate: certificate,
            qrCodeImage: qrCodeImage,
            logoImage: logoImage,
            signatureImage: signatureImage,
            signatureImage2: signatureImage2,
            signatureImage3: signatureImage3,
            regularFont: _regularFont!,
            boldFont: _boldFont!,
            italicFont: _italicFont!,
          );
          break;
        case 'kreatif':
          certificateWidget = TemplateKreatif.build(
            participant: participant,
            program: program,
            certificate: certificate,
            qrCodeImage: qrCodeImage,
            logoImage: logoImage,
            signatureImage: signatureImage,
            signatureImage2: signatureImage2,
            signatureImage3: signatureImage3,
            regularFont: _regularFont!,
            boldFont: _boldFont!,
            italicFont: _italicFont!,
          );
          break;
        case 'moden':
        default:
          certificateWidget = TemplateModen.build(
            participant: participant,
            program: program,
            certificate: certificate,
            qrCodeImage: qrCodeImage,
            logoImage: logoImage,
            signatureImage: signatureImage,
            signatureImage2: signatureImage2,
            signatureImage3: signatureImage3,
            regularFont: _regularFont!,
            boldFont: _boldFont!,
            italicFont: _italicFont!,
          );
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (context) => certificateWidget,
        ),
      );
    }

    return pdf.save();
  }
}
