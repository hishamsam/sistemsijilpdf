import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/localization/app_strings.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_input.dart';
import '../../../widgets/app_card.dart';
import '../../../data/repositories/certificate_repository.dart';
import '../../../data/repositories/participant_repository.dart';
import '../../../data/repositories/program_repository.dart';
import '../../../data/models/certificate.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _codeController = TextEditingController();
  bool _isVerifying = false;
  VerificationResult? _result;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDark ? Colors.white60 : AppColors.textSecondary;
    
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(tr(context, 'certificate_verification'), style: AppStyles.heading1.copyWith(color: textColor)),
          const SizedBox(height: 8),
          Text(
            tr(context, 'verify_authenticity'),
            style: AppStyles.bodyMedium.copyWith(
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 32),

          // Content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verification form
              Expanded(
                flex: 2,
                child: AppCard(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.verified_user_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tr(context, 'verify_certificate'), style: AppStyles.heading3),
                                Text(
                                  tr(context, 'enter_qr_or_number'),
                                  style: AppStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      AppInput(
                        label: tr(context, 'verification_code'),
                        hint: tr(context, 'verification_code_hint'),
                        controller: _codeController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        text: _isVerifying ? tr(context, 'verifying') : tr(context, 'verify_certificate'),
                        icon: Icons.search_rounded,
                        width: double.infinity,
                        isLoading: _isVerifying,
                        onPressed: _verify,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Result panel
              Expanded(
                flex: 3,
                child: _result != null
                    ? _buildResultCard()
                    : _buildPlaceholder(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return AppCard(
      padding: const EdgeInsets.all(48),
      child: EmptyStateCard(
        icon: Icons.qr_code_scanner_rounded,
        title: tr(context, 'no_verification'),
        subtitle: tr(context, 'enter_code_to_verify'),
      ),
    );
  }

  Widget _buildResultCard() {
    final result = _result!;
    final isValid = result.isValid;

    return AppCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isValid
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isValid ? Icons.verified_rounded : Icons.cancel_rounded,
                  color: isValid ? AppColors.success : AppColors.error,
                  size: 36,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isValid ? tr(context, 'valid_certificate') : tr(context, 'invalid_certificate'),
                      style: AppStyles.heading2.copyWith(
                        color: isValid ? AppColors.success : AppColors.error,
                      ),
                    ),
                    Text(
                      isValid
                          ? tr(context, 'certificate_authentic')
                          : result.message ?? tr(context, 'certificate_not_verified'),
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (isValid && result.certificate != null) ...[
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // Certificate details
            Text(tr(context, 'certificate_info'), style: AppStyles.heading4),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.numbers_rounded,
              label: tr(context, 'certificate_number'),
              value: result.certificate!.certificateNumber,
            ),
            _DetailRow(
              icon: Icons.person_rounded,
              label: tr(context, 'participant_name'),
              value: result.participantName ?? '-',
            ),
            _DetailRow(
              icon: Icons.folder_rounded,
              label: tr(context, 'program'),
              value: result.programName ?? '-',
            ),
            if (result.certificate!.generatedAt != null)
              _DetailRow(
                icon: Icons.calendar_today_rounded,
                label: tr(context, 'issue_date'),
                value: _formatDate(result.certificate!.generatedAt!),
              ),
            _DetailRow(
              icon: Icons.access_time_rounded,
              label: tr(context, 'times_verified'),
              value: '${result.certificate!.verificationCount} ${tr(context, 'times')}',
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr(context, 'please_enter_code')),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _result = null;
    });

    try {
      final certRepo = CertificateRepository();
      final participantRepo = ParticipantRepository();
      final programRepo = ProgramRepository();

      Certificate? certificate;

      // Try to find by certificate number first
      certificate = await certRepo.getByCertificateNumber(code);

      // If not found, try to parse QR data
      if (certificate == null && code.contains('|')) {
        final parts = code.split('|');
        if (parts.length >= 3) {
          final certNumber = parts[0];
          final signature = parts.last;

          certificate = await certRepo.getByCertificateNumber(certNumber);

          // Certificate found via QR code parsing
        }
      }

      if (certificate != null) {
        // Get participant and program info
        final participant = await participantRepo.getById(certificate.participantId);
        final program = participant != null
            ? await programRepo.getById(participant.programId)
            : null;

        setState(() {
          _result = VerificationResult(
            isValid: true,
            certificate: certificate,
            participantName: participant?.fullName,
            programName: program?.programName,
          );
        });
      } else {
        setState(() {
          _result = VerificationResult(
            isValid: false,
            message: tr(context, 'certificate_not_found'),
          );
        });
      }
    } catch (e) {
      setState(() {
        _result = VerificationResult(
          isValid: false,
          message: 'Ralat: $e',
        );
      });
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Mac', 'April', 'Mei', 'Jun',
      'Julai', 'Ogos', 'September', 'Oktober', 'November', 'Disember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppStyles.caption),
                Text(value, style: AppStyles.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VerificationResult {
  final bool isValid;
  final String? message;
  final Certificate? certificate;
  final String? participantName;
  final String? programName;

  VerificationResult({
    required this.isValid,
    this.message,
    this.certificate,
    this.participantName,
    this.programName,
  });
}
