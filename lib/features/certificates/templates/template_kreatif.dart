import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/certificate_texts.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/certificate.dart';
import '../../../data/models/participant.dart';
import '../../../data/models/program.dart';

class TemplateKreatif {
  // Creative color scheme
  static const PdfColor tealColor = PdfColor.fromInt(0xFF0D9488);
  static const PdfColor tealDark = PdfColor.fromInt(0xFF0F766E);
  static const PdfColor orangeColor = PdfColor.fromInt(0xFFEA580C);
  static const PdfColor textDark = PdfColor.fromInt(0xFF1E293B);
  static const PdfColor textLight = PdfColor.fromInt(0xFF64748B);

  static pw.Widget build({
    required Participant participant,
    required Program program,
    required Certificate certificate,
    required Uint8List qrCodeImage,
    required pw.Font regularFont,
    required pw.Font boldFont,
    required pw.Font italicFont,
    Uint8List? logoImage,
    Uint8List? signatureImage,
    Uint8List? signatureImage2,
    Uint8List? signatureImage3,
  }) {
    final formattedName = _formatName(participant.fullName);
    final texts = CertificateTexts(program.language);
    
    return pw.Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const pw.BoxDecoration(color: PdfColors.white),
      child: pw.Stack(
        children: [
          // Decorative circles
          pw.Positioned(top: -60, left: -60, child: pw.Container(
            width: 150, height: 150,
            decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: tealColor.shade(0.1)),
          )),
          pw.Positioned(top: -30, left: -30, child: pw.Container(
            width: 80, height: 80,
            decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: tealColor.shade(0.15)),
          )),
          pw.Positioned(bottom: -50, right: -50, child: pw.Container(
            width: 130, height: 130,
            decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: orangeColor.shade(0.1)),
          )),
          pw.Positioned(bottom: -25, right: -25, child: pw.Container(
            width: 70, height: 70,
            decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: orangeColor.shade(0.15)),
          )),
          
          // Main border
          pw.Positioned.fill(
            child: pw.Container(
              margin: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(16),
                border: pw.Border.all(color: tealColor, width: 3),
              ),
            ),
          ),
          
          // Main content
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(55, 50, 55, 40),
            child: pw.Column(
              children: [
                // Logo - fixed container with auto-fit image
                pw.Container(
                  width: 85,
                  height: 85,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(12),
                    border: pw.Border.all(color: tealColor, width: 2),
                  ),
                  child: logoImage != null
                      ? pw.Image(
                          pw.MemoryImage(logoImage),
                          fit: pw.BoxFit.contain,
                          width: 65,
                          height: 65,
                        )
                      : pw.Center(
                          child: pw.Text('LOGO', style: pw.TextStyle(font: boldFont, fontSize: 10, color: textLight)),
                        ),
                ),
                
                pw.SizedBox(height: 10),
                
                // Organizer
                if (program.organizer != null)
                  pw.Text(
                    program.organizer!.toUpperCase(),
                    style: pw.TextStyle(
                      font: boldFont, 
                      fontSize: 14, 
                      color: tealDark,
                      letterSpacing: 1,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                
                pw.SizedBox(height: 18),
                
                // Title
                pw.Text(
                  texts.getCertificateTitle(program.certificateType),
                  style: pw.TextStyle(
                    font: boldFont, 
                    fontSize: 32, 
                    color: orangeColor,
                    letterSpacing: 2,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                if (texts.getCertificateTitleSecondary(program.certificateType) != null) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(
                    texts.getCertificateTitleSecondary(program.certificateType)!,
                    style: pw.TextStyle(
                      font: italicFont, 
                      fontSize: 13, 
                      color: textLight,
                      letterSpacing: 1,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
                
                pw.SizedBox(height: 26),
                
                // Certification text
                pw.Text(
                  texts.certificationText,
                  style: pw.TextStyle(font: regularFont, fontSize: 12, color: textDark),
                ),
                if (texts.certificationTextSecondary != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    texts.certificationTextSecondary!,
                    style: pw.TextStyle(font: italicFont, fontSize: 10, color: textLight),
                  ),
                ],
                
                pw.SizedBox(height: 16),
                
                // Name with gradient background
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 35, vertical: 14),
                  decoration: pw.BoxDecoration(
                    gradient: const pw.LinearGradient(
                      colors: [tealColor, tealDark],
                    ),
                    borderRadius: pw.BorderRadius.circular(30),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        formattedName,
                        style: pw.TextStyle(
                          font: boldFont, 
                          fontSize: 24, 
                          color: PdfColors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      // IC Number (if enabled)
                      if (program.showIcNumber) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '(${_formatIcNumber(participant.icNumber)})',
                          style: pw.TextStyle(
                            font: regularFont,
                            fontSize: 10,
                            color: PdfColors.white,
                            letterSpacing: 0.5,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Participation text
                pw.Text(
                  texts.getParticipationText(program.certificateType),
                  style: pw.TextStyle(font: regularFont, fontSize: 12, color: textDark),
                ),
                if (texts.getParticipationTextSecondary(program.certificateType) != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    texts.getParticipationTextSecondary(program.certificateType)!,
                    style: pw.TextStyle(font: italicFont, fontSize: 10, color: textLight),
                  ),
                ],
                
                pw.SizedBox(height: 14),
                
                // Program name
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFFFF7ED),
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: orangeColor.shade(0.3), width: 1),
                  ),
                  child: pw.Text(
                    '"${program.programName}"',
                    style: pw.TextStyle(
                      font: boldFont, 
                      fontSize: 15, 
                      color: orangeColor,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                
                pw.SizedBox(height: 16),
                
                // Date
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF0FDFA),
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(texts.dateLabel, style: pw.TextStyle(font: regularFont, fontSize: 10, color: textDark)),
                      if (texts.dateLabelSecondary != null) ...[
                        pw.Text(' / ', style: pw.TextStyle(font: regularFont, fontSize: 10, color: textLight)),
                        pw.Text(texts.dateLabelSecondary!, style: pw.TextStyle(font: italicFont, fontSize: 10, color: textLight)),
                      ],
                      pw.Text(' :  ${AppDateUtils.formatDateMalay(program.issueDate)}', 
                        style: pw.TextStyle(font: boldFont, fontSize: 11, color: tealDark)),
                    ],
                  ),
                ),
                
                pw.Spacer(),
                
                // Signature section - supports multiple signatories
                _buildSignatureSection(
                  program: program,
                  texts: texts,
                  boldFont: boldFont,
                  regularFont: regularFont,
                  italicFont: italicFont,
                  signatureImage: signatureImage,
                  signatureImage2: signatureImage2,
                  signatureImage3: signatureImage3,
                ),
                
                pw.SizedBox(height: 18),
                
                // Footer
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF8FAFC),
                    borderRadius: pw.BorderRadius.circular(10),
                    border: pw.Border.all(color: PdfColor.fromInt(0xFFE2E8F0), width: 1),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // QR Code
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(color: tealColor, width: 1),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Image(pw.MemoryImage(qrCodeImage), width: 55, height: 55),
                            pw.SizedBox(height: 6),
                            pw.Text(texts.scanToVerify, style: pw.TextStyle(font: regularFont, fontSize: 6, color: textDark)),
                            if (texts.scanToVerifySecondary != null) ...[
                              pw.SizedBox(height: 1),
                              pw.Text(texts.scanToVerifySecondary!, style: pw.TextStyle(font: italicFont, fontSize: 5, color: textLight)),
                            ],
                          ],
                        ),
                      ),
                      pw.Spacer(),
                      // Certificate number
                      pw.Column(
                        children: [
                          pw.Text(texts.certificateNumberLabel, style: pw.TextStyle(font: regularFont, fontSize: 7, color: textDark)),
                          if (texts.certificateNumberLabelSecondary != null)
                            pw.Text(texts.certificateNumberLabelSecondary!, style: pw.TextStyle(font: italicFont, fontSize: 6, color: textLight)),
                          pw.SizedBox(height: 6),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              borderRadius: pw.BorderRadius.circular(6),
                              border: pw.Border.all(color: tealColor, width: 1),
                            ),
                            child: pw.Text(certificate.certificateNumber, style: pw.TextStyle(font: boldFont, fontSize: 8, color: tealDark)),
                          ),
                        ],
                      ),
                      pw.Spacer(),
                      // Badge
                      pw.Container(
                        width: 55,
                        height: 55,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(color: orangeColor, width: 2),
                          color: PdfColors.white,
                        ),
                        child: pw.Center(
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(_formatProgramCode(program.programCode), style: pw.TextStyle(font: boldFont, fontSize: 8, color: orangeColor)),
                              pw.Container(width: 25, height: 0.5, color: orangeColor, margin: const pw.EdgeInsets.symmetric(vertical: 2)),
                              pw.Text('${program.programYear}', style: pw.TextStyle(font: boldFont, fontSize: 10, color: orangeColor)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatIcNumber(String ic) {
    final cleanIc = ic.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanIc.length == 12) {
      return '${cleanIc.substring(0, 6)}-${cleanIc.substring(6, 8)}-${cleanIc.substring(8)}';
    }
    return ic;
  }

  static String _formatName(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    return words.map((word) {
      if (word.isEmpty) return '';
      final lowerWord = word.toLowerCase();
      if (lowerWord == 'bin' || lowerWord == 'binti' || lowerWord == 'a/l' || lowerWord == 'a/p' || lowerWord == 'anak') {
        return lowerWord;
      }
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  static String _formatProgramCode(String code) => code.length > 6 ? code.substring(0, 6) : code;

  static pw.Widget _buildSignatureSection({
    required Program program,
    required CertificateTexts texts,
    required pw.Font boldFont,
    required pw.Font regularFont,
    required pw.Font italicFont,
    Uint8List? signatureImage,
    Uint8List? signatureImage2,
    Uint8List? signatureImage3,
  }) {
    final hasSignatory1 = program.signatoryName != null && program.signatoryName!.isNotEmpty;
    final hasSignatory2 = program.signatoryName2 != null && program.signatoryName2!.isNotEmpty;
    final hasSignatory3 = program.signatoryName3 != null && program.signatoryName3!.isNotEmpty;
    
    final signatoryCount = [hasSignatory1, hasSignatory2, hasSignatory3].where((e) => e).length;
    
    if (signatoryCount == 0) return pw.SizedBox();
    
    if (signatoryCount == 1) {
      if (hasSignatory1) {
        return _buildSingleSignatory(name: program.signatoryName!, title: program.signatoryTitle, roleLabel: texts.programDirector, roleLabelSecondary: texts.programDirectorSecondary, signatureImage: signatureImage, boldFont: boldFont, regularFont: regularFont, italicFont: italicFont, language: program.language);
      } else if (hasSignatory2) {
        return _buildSingleSignatory(name: program.signatoryName2!, title: program.signatoryTitle2, signatureImage: signatureImage2, boldFont: boldFont, regularFont: regularFont, italicFont: italicFont, language: program.language);
      } else {
        return _buildSingleSignatory(name: program.signatoryName3!, title: program.signatoryTitle3, signatureImage: signatureImage3, boldFont: boldFont, regularFont: regularFont, italicFont: italicFont, language: program.language);
      }
    }
    
    final List<pw.Widget> signatureWidgets = [];
    
    if (hasSignatory1) {
      signatureWidgets.add(pw.Expanded(child: _buildSignatoryColumn(name: program.signatoryName!, title: program.signatoryTitle, roleLabel: texts.programDirector, roleLabelSecondary: texts.programDirectorSecondary, signatureImage: signatureImage, boldFont: boldFont, regularFont: regularFont, italicFont: italicFont, language: program.language)));
    }
    if (hasSignatory2) {
      if (signatureWidgets.isNotEmpty) signatureWidgets.add(pw.SizedBox(width: 20));
      signatureWidgets.add(pw.Expanded(child: _buildSignatoryColumn(name: program.signatoryName2!, title: program.signatoryTitle2, signatureImage: signatureImage2, boldFont: boldFont, regularFont: regularFont, italicFont: italicFont, language: program.language)));
    }
    if (hasSignatory3) {
      if (signatureWidgets.isNotEmpty) signatureWidgets.add(pw.SizedBox(width: 20));
      signatureWidgets.add(pw.Expanded(child: _buildSignatoryColumn(name: program.signatoryName3!, title: program.signatoryTitle3, signatureImage: signatureImage3, boldFont: boldFont, regularFont: regularFont, italicFont: italicFont, language: program.language)));
    }
    
    return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly, crossAxisAlignment: pw.CrossAxisAlignment.start, children: signatureWidgets);
  }

  static pw.Widget _buildSingleSignatory({required String name, String? title, String? roleLabel, String? roleLabelSecondary, Uint8List? signatureImage, required pw.Font boldFont, required pw.Font regularFont, required pw.Font italicFont, String language = 'bilingual'}) {
    return pw.Center(child: pw.Container(width: 200, child: _buildSignatoryColumn(name: name, title: title, roleLabel: roleLabel, roleLabelSecondary: roleLabelSecondary, signatureImage: signatureImage, boldFont: boldFont, regularFont: regularFont, italicFont: italicFont, language: language)));
  }

  static pw.Widget _buildSignatoryColumn({required String name, String? title, String? roleLabel, String? roleLabelSecondary, Uint8List? signatureImage, required pw.Font boldFont, required pw.Font regularFont, required pw.Font italicFont, String language = 'bilingual'}) {
    String? titlePrimary;
    String? titleSecondary;
    if (title != null && title.isNotEmpty) {
      if (title.contains('/')) {
        final parts = title.split('/').map((e) => e.trim()).toList();
        titlePrimary = parts[0];
        if (parts.length > 1 && parts[1].isNotEmpty) titleSecondary = parts[1];
      } else {
        titlePrimary = title;
      }
    }
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        pw.Container(width: 120, height: 50, alignment: pw.Alignment.bottomCenter, child: signatureImage != null ? pw.Image(pw.MemoryImage(signatureImage), fit: pw.BoxFit.contain, width: 100, height: 45) : pw.SizedBox(height: 45)),
        pw.Container(width: 150, height: 2, color: tealColor),
        pw.SizedBox(height: 6),
        pw.Text(name.toUpperCase(), style: pw.TextStyle(font: boldFont, fontSize: 10, color: tealDark, letterSpacing: 0.5), textAlign: pw.TextAlign.center),
        pw.SizedBox(height: 3),
        if (titlePrimary != null) ...[
          pw.Text(titlePrimary, style: pw.TextStyle(font: regularFont, fontSize: 8, color: textDark), textAlign: pw.TextAlign.center),
          if (titleSecondary != null && language == 'bilingual')
            pw.Text(titleSecondary, style: pw.TextStyle(font: italicFont, fontSize: 7, color: textLight), textAlign: pw.TextAlign.center),
        ],
        if (titlePrimary == null && roleLabel != null) ...[
          pw.SizedBox(height: 2),
          pw.Text(roleLabel, style: pw.TextStyle(font: regularFont, fontSize: 8, color: textDark), textAlign: pw.TextAlign.center),
          if (roleLabelSecondary != null && language == 'bilingual')
            pw.Text(roleLabelSecondary, style: pw.TextStyle(font: italicFont, fontSize: 7, color: textLight), textAlign: pw.TextAlign.center),
        ],
      ],
    );
  }
}
