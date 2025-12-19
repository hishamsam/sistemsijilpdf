import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/utils/date_utils.dart';
import '../../../data/models/certificate.dart';
import '../../../data/models/participant.dart';
import '../../../data/models/program.dart';
import '../models/custom_template.dart';
import '../models/template_element.dart';

class TemplatePdfService {
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

  PdfColor _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    final intValue = int.parse(hex, radix: 16);
    return PdfColor(
      ((intValue >> 16) & 0xFF) / 255,
      ((intValue >> 8) & 0xFF) / 255,
      (intValue & 0xFF) / 255,
    );
  }

  String _formatIcNumber(String ic) {
    final cleanIc = ic.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanIc.length == 12) {
      return '${cleanIc.substring(0, 6)}-${cleanIc.substring(6, 8)}-${cleanIc.substring(8)}';
    }
    return ic;
  }

  // Calculate optimal font size for long text
  double _calculateFontSize(String text, double maxWidth, double baseFontSize, pw.Font font) {
    // Estimate character width (average ~0.6 of font size for most fonts)
    final avgCharWidth = baseFontSize * 0.55;
    final textWidth = text.length * avgCharWidth;
    
    if (textWidth <= maxWidth) {
      return baseFontSize;
    }
    
    // Scale down font size proportionally, with minimum of 8
    final scaleFactor = maxWidth / textWidth;
    final newSize = baseFontSize * scaleFactor;
    return newSize < 8 ? 8 : newSize;
  }

  String _replaceVariables(String text, Participant participant, Program program, Certificate certificate, String language) {
    String formattedDate;
    String formattedExpiryDate;
    
    if (language == 'english') {
      formattedDate = AppDateUtils.formatDateEnglish(program.issueDate);
      formattedExpiryDate = program.expiryDate != null ? AppDateUtils.formatDateEnglish(program.expiryDate!) : '-';
    } else {
      formattedDate = AppDateUtils.formatDateMalay(program.issueDate);
      formattedExpiryDate = program.expiryDate != null ? AppDateUtils.formatDateMalay(program.expiryDate!) : '-';
    }
    
    return text
        .replaceAll('{nama}', participant.fullName)
        .replaceAll('{no_kp}', _formatIcNumber(participant.icNumber))
        .replaceAll('{program}', program.programName)
        .replaceAll('{tarikh}', formattedDate)
        .replaceAll('{tarikh_luput}', formattedExpiryDate)
        .replaceAll('{penganjur}', program.organizer ?? '')
        .replaceAll('{no_sijil}', certificate.certificateNumber)
        .replaceAll('{tahun}', program.programYear.toString());
  }

  Future<Uint8List> generateFromTemplate({
    required CustomTemplate template,
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

    // Sort elements by z-index
    final sortedElements = List<TemplateElement>.from(template.elements);
    sortedElements.sort((a, b) => a.zIndex.compareTo(b.zIndex));

    // Load background image if exists
    Uint8List? backgroundImageBytes;
    if (template.backgroundImage != null) {
      final bgFile = File(template.backgroundImage!);
      if (await bgFile.exists()) {
        backgroundImageBytes = await bgFile.readAsBytes();
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Container(
            width: template.canvasWidth,
            height: template.canvasHeight,
            color: _parseColor(template.backgroundColor),
            child: pw.Stack(
              children: [
                // Background image
                if (backgroundImageBytes != null)
                  pw.Positioned.fill(
                    child: pw.Image(
                      pw.MemoryImage(backgroundImageBytes),
                      fit: _getBoxFit(template.backgroundFit),
                    ),
                  ),
                // Elements
                ...sortedElements.map((element) {
                  return pw.Positioned(
                    left: element.x,
                    top: element.y,
                    child: pw.Transform.rotate(
                      angle: element.rotation * 3.14159 / 180,
                      child: pw.SizedBox(
                        width: element.width,
                        height: element.height,
                        child: _buildElement(
                          element,
                          participant: participant,
                          program: program,
                          certificate: certificate,
                          qrCodeImage: qrCodeImage,
                          language: program.language,
                          logoImage: logoImage,
                          signatureImage: signatureImage,
                          signatureImage2: signatureImage2,
                          signatureImage3: signatureImage3,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildElement(
    TemplateElement element, {
    required Participant participant,
    required Program program,
    required Certificate certificate,
    required Uint8List qrCodeImage,
    required String language,
    Uint8List? logoImage,
    Uint8List? signatureImage,
    Uint8List? signatureImage2,
    Uint8List? signatureImage3,
  }) {
    final props = element.properties;

    switch (element.type) {
      case ElementType.text:
        String text = props['text'] as String? ?? '';
        text = _replaceVariables(text, participant, program, certificate, language);
        
        final baseFontSize = (props['fontSize'] as num?)?.toDouble() ?? 16;
        final textAlign = props['textAlign'] as String? ?? 'center';
        final fontWeight = props['fontWeight'] as String?;
        final fontStyle = props['fontStyle'] as String?;
        final color = _parseColor(props['color'] as String? ?? '#000000');
        final letterSpacing = (props['letterSpacing'] as num?)?.toDouble() ?? 0;
        
        final font = _getFont(fontWeight, fontStyle);
        
        // Check if text is too long for the width and needs scaling
        final estimatedWidth = text.length * baseFontSize * 0.5;
        double fontSize = baseFontSize;
        
        // Auto-scale font if text is too wide (single line text like names)
        if (estimatedWidth > element.width && !text.contains('\n')) {
          // Scale down proportionally
          final scale = element.width / estimatedWidth;
          fontSize = (baseFontSize * scale).clamp(8.0, baseFontSize);
        }
        
        final textStyle = pw.TextStyle(
          font: font,
          fontSize: fontSize,
          color: color,
          letterSpacing: letterSpacing,
        );
        
        // Use FittedBox for single-line text to ensure it fits
        if (!text.contains('\n')) {
          return pw.Container(
            width: element.width,
            height: element.height,
            alignment: _getAlignment(textAlign),
            child: pw.FittedBox(
              fit: pw.BoxFit.scaleDown,
              child: pw.Text(
                text,
                style: textStyle,
                textAlign: _getTextAlign(textAlign),
              ),
            ),
          );
        }
        
        // Multi-line text
        return pw.Container(
          width: element.width,
          height: element.height,
          alignment: _getAlignment(textAlign),
          child: pw.Text(
            text,
            style: textStyle,
            textAlign: _getTextAlign(textAlign),
            softWrap: true,
          ),
        );

      case ElementType.logo:
        if (logoImage != null) {
          return pw.Center(
            child: pw.Image(
              pw.MemoryImage(logoImage),
              fit: pw.BoxFit.contain,
            ),
          );
        }
        return pw.Container();

      case ElementType.image:
        final imagePath = props['imagePath'] as String?;
        if (imagePath != null) {
          try {
            final file = File(imagePath);
            if (file.existsSync()) {
              final bytes = file.readAsBytesSync();
              return pw.Center(
                child: pw.Image(
                  pw.MemoryImage(bytes),
                  fit: pw.BoxFit.contain,
                ),
              );
            }
          } catch (_) {}
        }
        return pw.Container();

      case ElementType.signature:
        final index = props['signatoryIndex'] as int? ?? 1;
        Uint8List? sigImage;
        String? name;
        String? title;

        switch (index) {
          case 1:
            sigImage = signatureImage;
            name = program.signatoryName;
            title = program.signatoryTitle;
            break;
          case 2:
            sigImage = signatureImage2;
            name = program.signatoryName2;
            title = program.signatoryTitle2;
            break;
          case 3:
            sigImage = signatureImage3;
            name = program.signatoryName3;
            title = program.signatoryTitle3;
            break;
        }

        // Parse bilingual title (format: "BM / EN")
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

        final nameFontSize = (props['nameFontSize'] as num?)?.toDouble() ?? 10;
        final titleFontSize = (props['titleFontSize'] as num?)?.toDouble() ?? 8;
        final nameColor = _parseColor(props['nameColor'] as String? ?? '#000000');
        
        // Calculate signature image height (about 45% of element height)
        final sigHeight = element.height * 0.45;
        
        return pw.Column(
          mainAxisSize: pw.MainAxisSize.max,
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Signature image
            pw.Container(
              height: sigHeight,
              width: element.width,
              alignment: pw.Alignment.bottomCenter,
              child: sigImage != null
                  ? pw.Image(
                      pw.MemoryImage(sigImage),
                      fit: pw.BoxFit.contain,
                      height: sigHeight - 5,
                    )
                  : pw.SizedBox(),
            ),
            
            // Line
            if (props['showLine'] == true)
              pw.Container(
                width: element.width * 0.85,
                height: 1,
                color: _parseColor(props['lineColor'] as String? ?? '#000000'),
              ),
            
            pw.SizedBox(height: 4),
            
            // Name
            if (props['showName'] == true && name != null && name.isNotEmpty)
              pw.Text(
                name.toUpperCase(),
                style: pw.TextStyle(
                  font: _boldFont,
                  fontSize: nameFontSize,
                  color: nameColor,
                ),
                textAlign: pw.TextAlign.center,
                maxLines: 2,
              ),
            
            // Title
            if (props['showTitle'] == true && titlePrimary != null && titlePrimary.isNotEmpty) ...[
              pw.SizedBox(height: 2),
              pw.Text(
                titlePrimary,
                style: pw.TextStyle(
                  font: _regularFont,
                  fontSize: titleFontSize,
                  color: nameColor,
                ),
                textAlign: pw.TextAlign.center,
                maxLines: 2,
              ),
              if (titleSecondary != null && titleSecondary.isNotEmpty && language == 'bilingual')
                pw.Text(
                  titleSecondary,
                  style: pw.TextStyle(
                    font: _italicFont,
                    fontSize: titleFontSize - 1,
                    color: PdfColors.grey700,
                  ),
                  textAlign: pw.TextAlign.center,
                  maxLines: 2,
                ),
            ],
          ],
        );

      case ElementType.qrCode:
        return pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Image(
              pw.MemoryImage(qrCodeImage),
              width: element.width * 0.8,
              height: element.width * 0.8,
            ),
            if (props['showLabel'] == true) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                props['labelText'] as String? ?? 'Imbas untuk pengesahan',
                style: pw.TextStyle(font: _regularFont, fontSize: 6),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ],
        );

      case ElementType.shape:
        final shapeType = props['shapeType'] as String? ?? 'rectangle';
        final fillColor = _parseColor(props['fillColor'] as String? ?? '#FFFFFF');
        final strokeColor = _parseColor(props['strokeColor'] as String? ?? '#000000');
        final strokeWidth = (props['strokeWidth'] as num?)?.toDouble() ?? 1;
        final cornerRadius = (props['cornerRadius'] as num?)?.toDouble() ?? 0;

        if (shapeType == 'circle') {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: fillColor,
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: strokeColor, width: strokeWidth),
            ),
          );
        }
        return pw.Container(
          decoration: pw.BoxDecoration(
            color: fillColor,
            borderRadius: pw.BorderRadius.circular(cornerRadius),
            border: pw.Border.all(color: strokeColor, width: strokeWidth),
          ),
        );

      case ElementType.line:
        final color = _parseColor(props['color'] as String? ?? '#000000');
        final strokeWidth = (props['strokeWidth'] as num?)?.toDouble() ?? 2;
        return pw.Center(
          child: pw.Container(
            width: element.width,
            height: strokeWidth,
            color: color,
          ),
        );
    }
  }

  pw.Font _getFont(String? weight, String? style) {
    if (weight == 'bold') return _boldFont!;
    if (style == 'italic') return _italicFont!;
    return _regularFont!;
  }

  pw.Alignment _getAlignment(String align) {
    switch (align) {
      case 'left':
        return pw.Alignment.centerLeft;
      case 'right':
        return pw.Alignment.centerRight;
      default:
        return pw.Alignment.center;
    }
  }

  pw.TextAlign _getTextAlign(String align) {
    switch (align) {
      case 'left':
        return pw.TextAlign.left;
      case 'right':
        return pw.TextAlign.right;
      default:
        return pw.TextAlign.center;
    }
  }

  pw.CrossAxisAlignment _getCrossAxisAlignment(String align) {
    switch (align) {
      case 'left':
        return pw.CrossAxisAlignment.start;
      case 'right':
        return pw.CrossAxisAlignment.end;
      default:
        return pw.CrossAxisAlignment.center;
    }
  }

  pw.BoxFit _getBoxFit(String fit) {
    switch (fit) {
      case 'contain':
        return pw.BoxFit.contain;
      case 'fill':
        return pw.BoxFit.fill;
      case 'cover':
      default:
        return pw.BoxFit.cover;
    }
  }
}
