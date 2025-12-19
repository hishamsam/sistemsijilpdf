import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';
import '../../../data/models/participant.dart';
import '../../../data/models/program.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/utils/file_utils.dart';

class CertificatePreviewScreen extends StatefulWidget {
  final Uint8List pdfBytes;
  final Participant participant;
  final Program program;

  const CertificatePreviewScreen({
    super.key,
    required this.pdfBytes,
    required this.participant,
    required this.program,
  });

  @override
  State<CertificatePreviewScreen> createState() => _CertificatePreviewScreenState();
}

class _CertificatePreviewScreenState extends State<CertificatePreviewScreen> {
  final TransformationController _transformationController = TransformationController();
  double _currentScale = 1.0;
  static const double _minScale = 0.5;
  static const double _maxScale = 4.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final newScale = (_currentScale * 1.25).clamp(_minScale, _maxScale);
    _setScale(newScale);
  }

  void _zoomOut() {
    final newScale = (_currentScale / 1.25).clamp(_minScale, _maxScale);
    _setScale(newScale);
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    setState(() => _currentScale = 1.0);
  }

  void _setScale(double scale) {
    final matrix = Matrix4.identity()..scale(scale);
    _transformationController.value = matrix;
    setState(() => _currentScale = scale);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1C2A) : AppColors.background;
    final surfaceColor = isDark ? const Color(0xFF252836) : AppColors.surface;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Sijil - ${widget.participant.fullName}',
          style: TextStyle(color: textColor),
        ),
        elevation: 0,
        backgroundColor: surfaceColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          // Action buttons bar with zoom controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Zoom controls
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1C2A) : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ZoomButton(
                        icon: Icons.remove,
                        onPressed: _currentScale > _minScale ? _zoomOut : null,
                        isDark: isDark,
                        tooltip: 'Kecilkan',
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${(_currentScale * 100).toInt()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                      ),
                      _ZoomButton(
                        icon: Icons.add,
                        onPressed: _currentScale < _maxScale ? _zoomIn : null,
                        isDark: isDark,
                        tooltip: 'Besarkan',
                      ),
                      const SizedBox(width: 8),
                      _ZoomButton(
                        icon: Icons.fit_screen,
                        onPressed: _resetZoom,
                        isDark: isDark,
                        tooltip: 'Reset Zoom',
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Action buttons
                _ActionButton(
                  icon: Icons.download,
                  label: 'Muat Turun',
                  color: AppColors.primary,
                  onPressed: () => _download(context),
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.print,
                  label: 'Cetak',
                  color: AppColors.success,
                  onPressed: () => _print(),
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.share,
                  label: 'Kongsi',
                  color: AppColors.warning,
                  onPressed: () => _share(),
                ),
              ],
            ),
          ),
          // PDF Preview with zoom
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D3748) : Colors.grey[300],
                borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 1.0,
                  maxScale: 1.0,
                  scaleEnabled: false,
                  panEnabled: false,
                  boundaryMargin: const EdgeInsets.all(100),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: PdfPreview(
                          build: (format) async => widget.pdfBytes,
                          canChangeOrientation: false,
                          canChangePageFormat: false,
                          canDebug: false,
                          allowSharing: false,
                          allowPrinting: false,
                          useActions: false,
                          pdfFileName: 'sijil_${widget.participant.fullName}.pdf',
                          padding: EdgeInsets.zero,
                          scrollViewDecoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _download(BuildContext context) async {
    final safeName = FileUtils.sanitizeFileName(widget.participant.fullName);
    final saveResult = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan Sijil PDF',
      fileName: 'sijil_$safeName.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (saveResult == null) return;

    final file = File(saveResult);
    await file.writeAsBytes(widget.pdfBytes);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Sijil disimpan: $saveResult')),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _print() async {
    await Printing.layoutPdf(onLayout: (format) async => widget.pdfBytes);
  }

  Future<void> _share() async {
    await Printing.sharePdf(
      bytes: widget.pdfBytes,
      filename: 'sijil_${widget.participant.fullName}.pdf',
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDark;
  final String? tooltip;

  const _ZoomButton({
    required this.icon,
    this.onPressed,
    required this.isDark,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 18,
              color: onPressed != null
                  ? (isDark ? Colors.white70 : AppColors.textSecondary)
                  : (isDark ? Colors.white24 : Colors.grey[400]),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
