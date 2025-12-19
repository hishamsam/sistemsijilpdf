import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/certificate_texts.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/certificate.dart';
import '../../../data/models/participant.dart';
import '../../../data/models/program.dart';

class TemplateKlasik {
  // Classic color scheme
  static const PdfColor goldColor = PdfColor.fromInt(0xFFB8860B);
  static const PdfColor darkGold = PdfColor.fromInt(0xFF8B6914);
  static const PdfColor darkBrown = PdfColor.fromInt(0xFF3D2914);
  static const PdfColor creamColor = PdfColor.fromInt(0xFFFFFDF5);
  static const PdfColor lightText = PdfColor.fromInt(0xFF6B5B4D);

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
      decoration: const pw.BoxDecoration(color: creamColor),
      child: pw.Stack(
        children: [
          // Outer decorative border
          pw.Positioned.fill(
            child: pw.Container(
              margin: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: goldColor, width: 4),
              ),
            ),
          ),
          // Inner decorative border
          pw.Positioned.fill(
            child: pw.Container(
              margin: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: darkGold, width: 1),
              ),
            ),
          ),
          // Innermost border
          pw.Positioned.fill(
            child: pw.Container(
              margin: const pw.EdgeInsets.all(28),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: goldColor, width: 0.5),
              ),
            ),
          ),
          
          // Main content
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(55, 45, 55, 40),
            child: pw.Column(
              children: [
                // Logo - fixed container with auto-fit image
                pw.Container(
                  width: 80,
                  height: 80,
                  child: logoImage != null
                      ? pw.Center(
                          child: pw.Image(
                            pw.MemoryImage(logoImage),
                            fit: pw.BoxFit.contain,
                            width: 75,
                            height: 75,
                          ),
                        )
                      : pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: goldColor, width: 1),
                          ),
                          child: pw.Center(
                            child: pw.Text('LOGO', style: pw.TextStyle(font: boldFont, fontSize: 10, color: lightText)),
                          ),
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
                      color: darkBrown, 
                      letterSpacing: 2,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                
                pw.SizedBox(height: 18),
                
                // Decorative divider
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Container(width: 60, height: 1, color: goldColor),
                    pw.SizedBox(width: 10),
                    pw.Container(
                      width: 8,
                      height: 8,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: goldColor,
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Container(width: 60, height: 1, color: goldColor),
                  ],
                ),
                
                pw.SizedBox(height: 18),
                
                // Title
                pw.Text(
                  texts.getCertificateTitle(program.certificateType),
                  style: pw.TextStyle(
                    font: boldFont, 
                    fontSize: 34, 
                    color: goldColor,
                    letterSpacing: 3,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                if (texts.getCertificateTitleSecondary(program.certificateType) != null) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(
                    texts.getCertificateTitleSecondary(program.certificateType)!,
                    style: pw.TextStyle(
                      font: italicFont, 
                      fontSize: 14, 
                      color: lightText,
                      letterSpacing: 1,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
                
                pw.SizedBox(height: 26),
                
                // Certification text
                pw.Text(
                  texts.certificationText,
                  style: pw.TextStyle(font: regularFont, fontSize: 12, color: darkBrown),
                ),
                if (texts.certificationTextSecondary != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    texts.certificationTextSecondary!,
                    style: pw.TextStyle(font: italicFont, fontSize: 10, color: lightText),
                  ),
                ],
                
                pw.SizedBox(height: 16),
                
                // Name
                pw.Text(
                  formattedName,
                  style: pw.TextStyle(
                    font: boldFont, 
                    fontSize: 28, 
                    color: darkBrown,
                    letterSpacing: 1,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                
                // IC Number (if enabled)
                if (program.showIcNumber) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(
                    '(${_formatIcNumber(participant.icNumber)})',
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 11,
                      color: lightText,
                      letterSpacing: 0.5,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
                
                pw.SizedBox(height: 20),
                
                // Participation text
                pw.Text(
                  texts.getParticipationText(program.certificateType),
                  style: pw.TextStyle(font: regularFont, fontSize: 12, color: darkBrown),
                ),
                if (texts.getParticipationTextSecondary(program.certificateType) != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    texts.getParticipationTextSecondary(program.certificateType)!,
                    style: pw.TextStyle(font: italicFont, fontSize: 10, color: lightText),
                  ),
                ],
                
                pw.SizedBox(height: 14),
                
                // Program name
                pw.Text(
                  '"${program.programName}"',
                  style: pw.TextStyle(
                    font: boldFont, 
                    fontSize: 16, 
                    color: darkGold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                
                pw.SizedBox(height: 16),
                
                // Date
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(texts.dateLabel, style: pw.TextStyle(font: regularFont, fontSize: 10, color: darkBrown)),
                    if (texts.dateLabelSecondary != null) ...[
                      pw.Text(' / ', style: pw.TextStyle(font: regularFont, fontSize: 10, color: lightText)),
                      pw.Text(texts.dateLabelSecondary!, style: pw.TextStyle(font: italicFont, fontSize: 10, color: lightText)),
                    ],
                    pw.Text(' :  ${AppDateUtils.formatDateMalay(program.issueDate)}', 
                      style: pw.TextStyle(font: boldFont, fontSize: 11, color: darkBrown)),
                  ],
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
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(4),
                    border: pw.Border.all(color: goldColor, width: 0.5),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // QR Code
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: goldColor, width: 0.5),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Image(pw.MemoryImage(qrCodeImage), width: 55, height: 55),
                            pw.SizedBox(height: 6),
                            pw.Text(texts.scanToVerify, style: pw.TextStyle(font: regularFont, fontSize: 6, color: darkBrown)),
                            if (texts.scanToVerifySecondary != null) ...[
                              pw.SizedBox(height: 1),
                              pw.Text(texts.scanToVerifySecondary!, style: pw.TextStyle(font: italicFont, fontSize: 5, color: lightText)),
                            ],
                          ],
                        ),
                      ),
                      pw.Spacer(),
                      // Certificate number
                      pw.Column(
                        children: [
                          pw.Text(texts.certificateNumberLabel, style: pw.TextStyle(font: regularFont, fontSize: 7, color: darkBrown)),
                          if (texts.certificateNumberLabelSecondary != null)
                            pw.Text(texts.certificateNumberLabelSecondary!, style: pw.TextStyle(font: italicFont, fontSize: 6, color: lightText)),
                          pw.SizedBox(height: 6),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: goldColor, width: 0.5),
                              borderRadius: pw.BorderRadius.circular(3),
                            ),
                            child: pw.Text(certificate.certificateNumber, style: pw.TextStyle(font: boldFont, fontSize: 8, color: darkBrown)),
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
                          border: pw.Border.all(color: goldColor, width: 2),
                        ),
                        child: pw.Center(
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(_formatProgramCode(program.programCode), style: pw.TextStyle(font: boldFont, fontSize: 8, color: darkGold)),
                              pw.Container(width: 25, height: 0.5, color: goldColor, margin: const pw.EdgeInsets.symmetric(vertical: 2)),
                              pw.Text('${program.programYear}', style: pw.TextStyle(font: boldFont, fontSize: 10, color: darkGold)),
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
        return _buildSingleSignatory(
          name: program.signatoryName!,
          title: program.signatoryTitle,
          roleLabel: texts.programDirector,
          roleLabelSecondary: texts.programDirectorSecondary,
          signatureImage: signatureImage,
          boldFont: boldFont,
          regularFont: regularFont,
          italicFont: italicFont,
          language: program.language,
        );
      } else if (hasSignatory2) {
        return _buildSingleSignatory(
          name: program.signatoryName2!,
          title: program.signatoryTitle2,
          signatureImage: signatureImage2,
          boldFont: boldFont,
          regularFont: regularFont,
          italicFont: italicFont,
          language: program.language,
        );
      } else {
        return _buildSingleSignatory(
          name: program.signatoryName3!,
          title: program.signatoryTitle3,
          signatureImage: signatureImage3,
          boldFont: boldFont,
          regularFont: regularFont,
          italicFont: italicFont,
          language: program.language,
        );
      }
    }
    
    final List<pw.Widget> signatureWidgets = [];
    
    if (hasSignatory1) {
      signatureWidgets.add(
        pw.Expanded(
          child: _buildSignatoryColumn(
            name: program.signatoryName!,
            title: program.signatoryTitle,
            roleLabel: texts.programDirector,
            roleLabelSecondary: texts.programDirectorSecondary,
            signatureImage: signatureImage,
            boldFont: boldFont,
            regularFont: regularFont,
            italicFont: italicFont,
            language: program.language,
          ),
        ),
      );
    }
    
    if (hasSignatory2) {
      if (signatureWidgets.isNotEmpty) signatureWidgets.add(pw.SizedBox(width: 20));
      signatureWidgets.add(
        pw.Expanded(
          child: _buildSignatoryColumn(
            name: program.signatoryName2!,
            title: program.signatoryTitle2,
            signatureImage: signatureImage2,
            boldFont: boldFont,
            regularFont: regularFont,
            italicFont: italicFont,
            language: program.language,
          ),
        ),
      );
    }
    
    if (hasSignatory3) {
      if (signatureWidgets.isNotEmpty) signatureWidgets.add(pw.SizedBox(width: 20));
      signatureWidgets.add(
        pw.Expanded(
          child: _buildSignatoryColumn(
            name: program.signatoryName3!,
            title: program.signatoryTitle3,
            signatureImage: signatureImage3,
            boldFont: boldFont,
            regularFont: regularFont,
            italicFont: italicFont,
            language: program.language,
          ),
        ),
      );
    }
    
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: signatureWidgets,
    );
  }

  static pw.Widget _buildSingleSignatory({
    required String name,
    String? title,
    String? roleLabel,
    String? roleLabelSecondary,
    Uint8List? signatureImage,
    required pw.Font boldFont,
    required pw.Font regularFont,
    required pw.Font italicFont,
    String language = 'bilingual',
  }) {
    return pw.Center(
      child: pw.Container(
        width: 200,
        child: _buildSignatoryColumn(
          name: name,
          title: title,
          roleLabel: roleLabel,
          roleLabelSecondary: roleLabelSecondary,
          signatureImage: signatureImage,
          boldFont: boldFont,
          regularFont: regularFont,
          italicFont: italicFont,
          language: language,
        ),
      ),
    );
  }

  static pw.Widget _buildSignatoryColumn({
    required String name,
    String? title,
    String? roleLabel,
    String? roleLabelSecondary,
    Uint8List? signatureImage,
    required pw.Font boldFont,
    required pw.Font regularFont,
    required pw.Font italicFont,
    String language = 'bilingual',
  }) {
    // Parse title for bilingual support (format: "BM / EN" or just single language)
    String? titlePrimary;
    String? titleSecondary;
    
    if (title != null && title.isNotEmpty) {
      if (title.contains('/')) {
        final parts = title.split('/').map((e) => e.trim()).toList();
        titlePrimary = parts[0];
        if (parts.length > 1 && parts[1].isNotEmpty) {
          titleSecondary = parts[1];
        }
      } else {
        titlePrimary = title;
      }
    }
    
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        pw.Container(
          width: 120,
          height: 50,
          alignment: pw.Alignment.bottomCenter,
          child: signatureImage != null
              ? pw.Image(
                  pw.MemoryImage(signatureImage),
                  fit: pw.BoxFit.contain,
                  width: 100,
                  height: 45,
                )
              : pw.SizedBox(height: 45),
        ),
        pw.Container(width: 150, height: 1, color: darkBrown),
        pw.SizedBox(height: 6),
        pw.Text(
          name.toUpperCase(),
          style: pw.TextStyle(font: boldFont, fontSize: 10, color: darkBrown, letterSpacing: 0.5),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 3),
        if (titlePrimary != null) ...[
          pw.Text(titlePrimary, style: pw.TextStyle(font: regularFont, fontSize: 8, color: darkBrown), textAlign: pw.TextAlign.center),
          if (titleSecondary != null && language == 'bilingual')
            pw.Text(titleSecondary, style: pw.TextStyle(font: italicFont, fontSize: 7, color: lightText), textAlign: pw.TextAlign.center),
        ],
        if (titlePrimary == null && roleLabel != null) ...[
          pw.SizedBox(height: 2),
          pw.Text(roleLabel, style: pw.TextStyle(font: regularFont, fontSize: 8, color: darkBrown), textAlign: pw.TextAlign.center),
          if (roleLabelSecondary != null && language == 'bilingual')
            pw.Text(roleLabelSecondary, style: pw.TextStyle(font: italicFont, fontSize: 7, color: lightText), textAlign: pw.TextAlign.center),
        ],
      ],
    );
  }
}
