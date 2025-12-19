import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/certificate_texts.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/certificate.dart';
import '../../../data/models/participant.dart';
import '../../../data/models/program.dart';

class TemplateModen {
  // Professional color scheme
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF1A365D);    // Deep navy blue
  static const PdfColor accentColor = PdfColor.fromInt(0xFF2B6CB0);     // Royal blue
  static const PdfColor goldColor = PdfColor.fromInt(0xFFB7791F);       // Gold accent
  static const PdfColor textColor = PdfColor.fromInt(0xFF2D3748);       // Dark gray text
  static const PdfColor lightText = PdfColor.fromInt(0xFF718096);       // Light gray text

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
    // Format participant name properly
    final formattedName = _formatName(participant.fullName);
    final texts = CertificateTexts(program.language);
    
    return pw.Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const pw.BoxDecoration(color: PdfColors.white),
      child: pw.Stack(
        children: [
          // Decorative top border
          pw.Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: pw.Container(
              height: 12,
              decoration: const pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [primaryColor, accentColor, primaryColor],
                ),
              ),
            ),
          ),
          
          // Decorative bottom border
          pw.Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: pw.Container(
              height: 12,
              decoration: const pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [primaryColor, accentColor, primaryColor],
                ),
              ),
            ),
          ),
          
          // Inner frame
          pw.Positioned.fill(
            child: pw.Container(
              margin: const pw.EdgeInsets.all(25),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: primaryColor, width: 2),
              ),
            ),
          ),
          
          // Main content
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(60, 45, 60, 40),
            child: pw.Column(
              children: [
                // === HEADER SECTION ===
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
                            border: pw.Border.all(color: primaryColor, width: 1),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Center(
                            child: pw.Text('LOGO', style: pw.TextStyle(font: boldFont, fontSize: 10, color: lightText)),
                          ),
                        ),
                ),
                
                pw.SizedBox(height: 10),
                
                // Organizer name
                if (program.organizer != null && program.organizer!.isNotEmpty)
                  pw.Text(
                    program.organizer!.toUpperCase(),
                    style: pw.TextStyle(
                      font: boldFont, 
                      fontSize: 14, 
                      color: primaryColor, 
                      letterSpacing: 1.5,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                
                pw.SizedBox(height: 20),
                
                // Decorative line
                pw.Container(
                  width: 120,
                  height: 2,
                  color: goldColor,
                ),
                
                pw.SizedBox(height: 20),
                
                // === TITLE SECTION ===
                // Certificate title
                pw.Text(
                  texts.getCertificateTitle(program.certificateType),
                  style: pw.TextStyle(
                    font: boldFont, 
                    fontSize: 32, 
                    color: primaryColor,
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
                      fontSize: 14, 
                      color: lightText,
                      letterSpacing: 1,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
                
                pw.SizedBox(height: 28),
                
                // === CERTIFICATION TEXT ===
                pw.Text(
                  texts.certificationText,
                  style: pw.TextStyle(font: regularFont, fontSize: 12, color: textColor),
                  textAlign: pw.TextAlign.center,
                ),
                if (texts.certificationTextSecondary != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    texts.certificationTextSecondary!,
                    style: pw.TextStyle(font: italicFont, fontSize: 10, color: lightText),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
                
                pw.SizedBox(height: 18),
                
                // === PARTICIPANT NAME ===
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: goldColor, width: 2),
                      top: pw.BorderSide(color: goldColor, width: 0.5),
                    ),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        formattedName,
                        style: pw.TextStyle(
                          font: boldFont, 
                          fontSize: 26, 
                          color: primaryColor,
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
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 22),
                
                // === PARTICIPATION TEXT ===
                pw.Text(
                  texts.getParticipationText(program.certificateType),
                  style: pw.TextStyle(font: regularFont, fontSize: 12, color: textColor),
                  textAlign: pw.TextAlign.center,
                ),
                if (texts.getParticipationTextSecondary(program.certificateType) != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    texts.getParticipationTextSecondary(program.certificateType)!,
                    style: pw.TextStyle(font: italicFont, fontSize: 10, color: lightText),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
                
                pw.SizedBox(height: 14),
                
                // === PROGRAM NAME ===
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF7FAFC),
                    borderRadius: pw.BorderRadius.circular(4),
                    border: pw.Border.all(color: accentColor.shade(0.3), width: 0.5),
                  ),
                  child: pw.Text(
                    '"${program.programName}"',
                    style: pw.TextStyle(
                      font: boldFont, 
                      fontSize: 16, 
                      color: accentColor,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                
                pw.SizedBox(height: 18),
                
                // === DATE ===
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      texts.dateLabel,
                      style: pw.TextStyle(font: regularFont, fontSize: 10, color: textColor),
                    ),
                    if (texts.dateLabelSecondary != null) ...[
                      pw.Text(
                        ' / ',
                        style: pw.TextStyle(font: regularFont, fontSize: 10, color: lightText),
                      ),
                      pw.Text(
                        texts.dateLabelSecondary!,
                        style: pw.TextStyle(font: italicFont, fontSize: 10, color: lightText),
                      ),
                    ],
                    pw.Text(
                      ' :  ${AppDateUtils.formatDateMalay(program.issueDate)}',
                      style: pw.TextStyle(font: boldFont, fontSize: 11, color: textColor),
                    ),
                  ],
                ),
                
                pw.Spacer(),
                
                // === SIGNATURE SECTION ===
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
                
                pw.SizedBox(height: 20),
                
                // === FOOTER SECTION ===
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFFAFAFA),
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColor.fromInt(0xFFE2E8F0), width: 0.5),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // QR Code section
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(4),
                          border: pw.Border.all(color: PdfColor.fromInt(0xFFE2E8F0), width: 0.5),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Image(pw.MemoryImage(qrCodeImage), width: 55, height: 55),
                            pw.SizedBox(height: 6),
                            pw.Text(
                              texts.scanToVerify,
                              style: pw.TextStyle(font: regularFont, fontSize: 6, color: textColor),
                            ),
                            if (texts.scanToVerifySecondary != null) ...[
                              pw.SizedBox(height: 1),
                              pw.Text(
                                texts.scanToVerifySecondary!,
                                style: pw.TextStyle(font: italicFont, fontSize: 5, color: lightText),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      pw.Spacer(),
                      
                      // Certificate number
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              texts.certificateNumberLabel,
                              style: pw.TextStyle(font: regularFont, fontSize: 7, color: textColor),
                            ),
                            if (texts.certificateNumberLabelSecondary != null)
                              pw.Text(
                                texts.certificateNumberLabelSecondary!,
                                style: pw.TextStyle(font: italicFont, fontSize: 6, color: lightText),
                              ),
                            pw.SizedBox(height: 6),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.white,
                                borderRadius: pw.BorderRadius.circular(3),
                                border: pw.Border.all(color: accentColor, width: 0.5),
                              ),
                              child: pw.Text(
                                certificate.certificateNumber,
                                style: pw.TextStyle(
                                  font: boldFont, 
                                  fontSize: 8, 
                                  color: primaryColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      pw.Spacer(),
                      
                      // Program badge
                      pw.Container(
                        width: 55,
                        height: 55,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(color: goldColor, width: 2),
                          color: PdfColors.white,
                        ),
                        child: pw.Center(
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                _formatProgramCode(program.programCode),
                                style: pw.TextStyle(
                                  font: boldFont, 
                                  fontSize: 8, 
                                  color: primaryColor,
                                ),
                              ),
                              pw.Container(
                                width: 25,
                                height: 0.5,
                                color: goldColor,
                                margin: const pw.EdgeInsets.symmetric(vertical: 2),
                              ),
                              pw.Text(
                                '${program.programYear}',
                                style: pw.TextStyle(
                                  font: boldFont, 
                                  fontSize: 10, 
                                  color: primaryColor,
                                ),
                              ),
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

  // Format IC number with dashes
  static String _formatIcNumber(String ic) {
    final cleanIc = ic.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanIc.length == 12) {
      return '${cleanIc.substring(0, 6)}-${cleanIc.substring(6, 8)}-${cleanIc.substring(8)}';
    }
    return ic;
  }

  // Format name with proper capitalization and spacing
  static String _formatName(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    return words.map((word) {
      if (word.isEmpty) return '';
      // Handle special words like 'bin', 'binti', 'a/l', 'a/p'
      final lowerWord = word.toLowerCase();
      if (lowerWord == 'bin' || lowerWord == 'binti' || 
          lowerWord == 'a/l' || lowerWord == 'a/p' ||
          lowerWord == 'anak') {
        return lowerWord;
      }
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  // Format program code - max 4 chars
  static String _formatProgramCode(String code) {
    if (code.length > 6) {
      return code.substring(0, 6);
    }
    return code;
  }

  // Build signature section with support for multiple signatories
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
    // Count active signatories
    final hasSignatory1 = program.signatoryName != null && program.signatoryName!.isNotEmpty;
    final hasSignatory2 = program.signatoryName2 != null && program.signatoryName2!.isNotEmpty;
    final hasSignatory3 = program.signatoryName3 != null && program.signatoryName3!.isNotEmpty;
    
    final signatoryCount = [hasSignatory1, hasSignatory2, hasSignatory3].where((e) => e).length;
    
    if (signatoryCount == 0) return pw.SizedBox();
    
    // Single signatory - centered
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
    
    // Multiple signatories - row layout
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

  // Build single centered signatory
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

  // Build signatory column widget
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
        // Signature image container - fixed size for alignment
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
        
        // Signature line
        pw.Container(
          width: 150,
          height: 1,
          color: textColor,
        ),
        
        pw.SizedBox(height: 6),
        
        // Signatory name
        pw.Text(
          name.toUpperCase(),
          style: pw.TextStyle(
            font: boldFont, 
            fontSize: 10, 
            color: textColor,
            letterSpacing: 0.5,
          ),
          textAlign: pw.TextAlign.center,
        ),
        
        pw.SizedBox(height: 3),
        
        // Title (user-defined position/jawatan) with bilingual support
        if (titlePrimary != null) ...[
          pw.Text(
            titlePrimary,
            style: pw.TextStyle(font: regularFont, fontSize: 8, color: textColor),
            textAlign: pw.TextAlign.center,
          ),
          if (titleSecondary != null && language == 'bilingual')
            pw.Text(
              titleSecondary,
              style: pw.TextStyle(font: italicFont, fontSize: 7, color: lightText),
              textAlign: pw.TextAlign.center,
            ),
        ],
        
        // Role label with bilingual support (fallback if no title)
        if (titlePrimary == null && roleLabel != null) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            roleLabel,
            style: pw.TextStyle(font: regularFont, fontSize: 8, color: textColor),
            textAlign: pw.TextAlign.center,
          ),
          if (roleLabelSecondary != null && language == 'bilingual')
            pw.Text(
              roleLabelSecondary,
              style: pw.TextStyle(font: italicFont, fontSize: 7, color: lightText),
              textAlign: pw.TextAlign.center,
            ),
        ],
      ],
    );
  }
}
