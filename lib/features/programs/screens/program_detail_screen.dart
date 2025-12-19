import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/localization/app_strings.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_input.dart';
import '../../../widgets/app_card.dart';
import '../../../data/models/participant.dart';
import '../../../services/excel_service.dart';
import '../providers/program_provider.dart';
import '../../certificates/screens/certificate_preview_screen.dart';
import '../../certificates/screens/combined_pdf_preview_screen.dart';
import 'program_create_screen.dart';

class ProgramDetailScreen extends StatefulWidget {
  final int programId;

  const ProgramDetailScreen({super.key, required this.programId});

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Set<int> _selectedParticipants = {};
  bool _isSelectMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgramProvider>().loadParticipants(widget.programId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1C2A) : AppColors.background;
    final surfaceColor = isDark ? const Color(0xFF252836) : AppColors.surface;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDark ? Colors.white60 : AppColors.textSecondary;
    
    return Scaffold(
      backgroundColor: bgColor,
      body: Consumer<ProgramProvider>(
        builder: (context, provider, _) {
          final program = provider.selectedProgram;
          if (program == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final allParticipants = provider.participants;
          final participants = _searchQuery.isEmpty
              ? allParticipants
              : allParticipants
                  .where((p) => p.fullName.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();

          return Row(
            children: [
              // Left sidebar
              Container(
                width: 80,
                color: surfaceColor,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_rounded, color: textColor),
                      tooltip: tr(context, 'back'),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      color: surfaceColor,
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.folder_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(program.programName, style: AppStyles.heading2.copyWith(color: textColor)),
                                const SizedBox(height: 4),
                                Text(
                                  program.organizer ?? tr(context, 'no_organizer'),
                                  style: AppStyles.bodyMedium.copyWith(
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildQuickStats(program),
                          const SizedBox(width: 24),
                          PopupMenuButton<String>(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.more_horiz_rounded),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            itemBuilder: (context) => [
                              _buildMenuItem('edit', Icons.edit_rounded, tr(context, 'edit_program')),
                              _buildMenuItem('template', Icons.description_rounded, tr(context, 'download_template')),
                              _buildMenuItem('delete', Icons.delete_rounded, tr(context, 'delete_program'), isDestructive: true),
                            ],
                            onSelected: (value) => _handleMenuAction(value, program, provider),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Participants list
                            Expanded(
                              flex: 3,
                              child: AppCard(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  children: [
                                    // Toolbar
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(color: AppColors.divider),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            tr(context, 'participant_list'),
                                            style: AppStyles.heading4,
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${participants.length}',
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          SizedBox(
                                            width: 200,
                                            child: AppSearchInput(
                                              controller: _searchController,
                                              hint: tr(context, 'search_participant'),
                                              onChanged: (v) => setState(() => _searchQuery = v),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Actions bar
                                    if (_isSelectMode && _selectedParticipants.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        color: AppColors.primary.withValues(alpha: 0.05),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${_selectedParticipants.length} ${tr(context, 'selected')}',
                                              style: AppStyles.bodyMedium.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const Spacer(),
                                            AppButton(
                                              text: tr(context, 'generate_certificate'),
                                              height: 36,
                                              icon: Icons.verified_rounded,
                                              onPressed: () => _generateCertificates(provider),
                                            ),
                                            const SizedBox(width: 8),
                                            AppIconButton(
                                              icon: Icons.close_rounded,
                                              size: 36,
                                              onPressed: () {
                                                setState(() {
                                                  _isSelectMode = false;
                                                  _selectedParticipants.clear();
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                    // List
                                    Expanded(
                                      child: participants.isEmpty
                                          ? _buildEmptyParticipants()
                                          : ListView.separated(
                                              padding: const EdgeInsets.all(8),
                                              itemCount: participants.length,
                                              separatorBuilder: (_, __) => const Divider(height: 1),
                                              itemBuilder: (context, index) {
                                                final participant = participants[index];
                                                return _ParticipantTile(
                                                  participant: participant,
                                                  isSelected: _selectedParticipants.contains(participant.id),
                                                  isSelectMode: _isSelectMode,
                                                  onTap: () => _onParticipantTap(participant),
                                                  onLongPress: () => _onParticipantLongPress(participant),
                                                  onView: () => _viewCertificate(participant, provider),
                                                  onGenerate: () => _generateSingleCertificate(participant, provider),
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),

                            // Side panel
                            SizedBox(
                              width: 300,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    // Import card
                                  AppCard(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: AppColors.success.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.upload_file_rounded,
                                                color: AppColors.success,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(tr(context, 'import_data'), style: AppStyles.heading4),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          tr(context, 'import_excel_hint'),
                                          style: AppStyles.bodySmall,
                                        ),
                                        const SizedBox(height: 16),
                                        AppButton(
                                          text: tr(context, 'import_excel'),
                                          icon: Icons.file_upload_rounded,
                                          width: double.infinity,
                                          variant: AppButtonVariant.secondary,
                                          color: AppColors.success,
                                          onPressed: () => _importExcel(provider),
                                        ),
                                        const SizedBox(height: 8),
                                        AppButton(
                                          text: tr(context, 'download_template'),
                                          icon: Icons.download_rounded,
                                          width: double.infinity,
                                          variant: AppButtonVariant.text,
                                          onPressed: () => _downloadTemplate(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Quick actions
                                  AppCard(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.bolt_rounded,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(tr(context, 'quick_actions'), style: AppStyles.heading4),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        AppButton(
                                          text: tr(context, 'select_all'),
                                          icon: Icons.select_all_rounded,
                                          width: double.infinity,
                                          variant: AppButtonVariant.secondary,
                                          onPressed: participants.isEmpty
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _isSelectMode = true;
                                                    _selectedParticipants = participants
                                                        .map((p) => p.id!)
                                                        .toSet();
                                                  });
                                                },
                                        ),
                                        const SizedBox(height: 8),
                                        AppButton(
                                          text: tr(context, 'generate_all_certificates'),
                                          icon: Icons.verified_rounded,
                                          width: double.infinity,
                                          onPressed: participants.isEmpty
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _selectedParticipants = participants
                                                        .map((p) => p.id!)
                                                        .toSet();
                                                  });
                                                  _generateCertificates(provider);
                                                },
                                        ),
                                        const SizedBox(height: 8),
                                        AppButton(
                                          text: tr(context, 'regenerate_all_certificates'),
                                          icon: Icons.refresh_rounded,
                                          width: double.infinity,
                                          variant: AppButtonVariant.secondary,
                                          color: AppColors.warning,
                                          onPressed: participants.isEmpty
                                              ? null
                                              : () => _showRegenerateDialog(provider, participants),
                                        ),
                                        const SizedBox(height: 8),
                                        AppButton(
                                          text: tr(context, 'combine_all_pdf'),
                                          icon: Icons.picture_as_pdf_rounded,
                                          width: double.infinity,
                                          variant: AppButtonVariant.secondary,
                                          color: AppColors.error,
                                          onPressed: participants.isEmpty
                                              ? null
                                              : () => _combinePdf(provider, participants),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ],
                                ),
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
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(dynamic program) {
    return Row(
      children: [
        _StatBadge(
          label: tr(context, 'participant_word'),
          value: '${program.participantCount}',
          color: AppColors.primary,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String label, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDestructive ? AppColors.error : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isDestructive ? AppColors.error : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyParticipants() {
    return EmptyStateCard(
      icon: Icons.people_outline_rounded,
      title: tr(context, 'no_participants'),
      subtitle: tr(context, 'import_participants_hint'),
    );
  }

  void _handleMenuAction(String action, dynamic program, ProgramProvider provider) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProgramCreateScreen(program: program),
          ),
        ).then((_) {
          // Refresh program data after editing
          context.read<ProgramProvider>().selectProgram(widget.programId);
        });
        break;
      case 'template':
        _downloadTemplate();
        break;
      case 'delete':
        _showDeleteDialog(program, provider);
        break;
    }
  }

  void _showDeleteDialog(dynamic program, ProgramProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(tr(context, 'delete_program_question')),
        content: Text(tr(context, 'all_data_deleted')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr(context, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteProgram(program.id);
              if (mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(tr(context, 'delete'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _onParticipantTap(Participant participant) {
    setState(() {
      if (_selectedParticipants.contains(participant.id)) {
        _selectedParticipants.remove(participant.id);
        if (_selectedParticipants.isEmpty) _isSelectMode = false;
      } else {
        _selectedParticipants.add(participant.id!);
        _isSelectMode = true;
      }
    });
  }

  void _onParticipantLongPress(Participant participant) {
    setState(() {
      _isSelectMode = true;
      _selectedParticipants.add(participant.id!);
    });
  }

  Future<void> _importExcel(ProgramProvider provider) async {
    try {
      final count = await provider.importParticipants(widget.programId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$count peserta berjaya diimport!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ralat: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _downloadTemplate() async {
    try {
      final excelService = ExcelService();
      final file = await excelService.generateTemplate();

      if (mounted && file != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Template disimpan: ${file.path}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ralat: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _generateCertificates(ProgramProvider provider) async {
    if (_selectedParticipants.isEmpty) return;

    final participants = provider.participants
        .where((p) => _selectedParticipants.contains(p.id))
        .toList();

    int count = 0;
    for (final p in participants) {
      await provider.generateCertificate(p);
      count++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count sijil berjaya dijana!'),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() {
        _isSelectMode = false;
        _selectedParticipants.clear();
      });
    }
  }

  Future<void> _generateSingleCertificate(Participant participant, ProgramProvider provider) async {
    final pdfBytes = await provider.generateCertificate(participant);
    if (pdfBytes != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sijil untuk ${participant.fullName} berjaya dijana!'),
          backgroundColor: AppColors.success,
        ),
      );
      // Navigate to preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CertificatePreviewScreen(
            pdfBytes: pdfBytes,
            participant: participant,
            program: provider.selectedProgram!,
          ),
        ),
      );
    }
  }

  Future<void> _viewCertificate(Participant participant, ProgramProvider provider) async {
    final pdfBytes = await provider.generateCertificate(participant);
    if (pdfBytes != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CertificatePreviewScreen(
            pdfBytes: pdfBytes,
            participant: participant,
            program: provider.selectedProgram!,
          ),
        ),
      );
    }
  }

  Future<void> _showRegenerateDialog(ProgramProvider provider, List<Participant> participants) async {
    final participantsWithCerts = participants.where((p) => p.hasCertificate).toList();
    
    if (participantsWithCerts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr(context, 'no_certificates_to_regenerate')),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.refresh_rounded, color: AppColors.warning),
            const SizedBox(width: 12),
            Text(tr(context, 'regenerate_confirm_title')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr(context, 'regenerate_confirm_message')),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${participantsWithCerts.length} sijil akan dijana semula',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr(context, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: Text(tr(context, 'regenerate_certificates'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _regenerateCertificates(provider, participantsWithCerts);
    }
  }

  Future<void> _regenerateCertificates(ProgramProvider provider, List<Participant> participants) async {
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.warning),
                const SizedBox(height: 16),
                Text(tr(context, 'regenerating')),
                const SizedBox(height: 8),
                Text(
                  '${participants.length} sijil',
                  style: AppStyles.caption,
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      final count = await provider.regenerateAllCertificates(
        selectedParticipants: participants,
      );

      if (mounted) {
        Navigator.pop(context); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$count ${tr(context, 'regenerate_success')}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ralat: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _combinePdf(ProgramProvider provider, List<Participant> participants) async {
    if (participants.isEmpty) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Menggabungkan ${participants.length} sijil...'),
          ],
        ),
      ),
    );

    try {
      final combinedPdf = await provider.generateCombinedPdf(participants);
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      if (combinedPdf != null && mounted) {
        // Navigate to combined preview
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CombinedPdfPreviewScreen(
              pdfBytes: combinedPdf,
              program: provider.selectedProgram!,
              participantCount: participants.length,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ralat: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _ParticipantTile extends StatefulWidget {
  final Participant participant;
  final bool isSelected;
  final bool isSelectMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onView;
  final VoidCallback onGenerate;

  const _ParticipantTile({
    required this.participant,
    required this.isSelected,
    required this.isSelectMode,
    required this.onTap,
    required this.onLongPress,
    required this.onView,
    required this.onGenerate,
  });

  @override
  State<_ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<_ParticipantTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.participant;
    final hasCertificate = p.hasCertificate;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : _isHovered
                    ? AppColors.background
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Radio<bool>(
                  value: true,
                  groupValue: widget.isSelected ? true : null,
                  onChanged: (_) => widget.onTap(),
                  activeColor: AppColors.primary,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    p.fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.fullName, style: AppStyles.bodyLarge),
                    if (p.email != null || p.icNumber.isNotEmpty)
                      Text(
                        p.email ?? p.icNumber,
                        style: AppStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (hasCertificate) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        'Sijil',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  color: AppColors.primary,
                  onPressed: widget.onView,
                  tooltip: 'Lihat Sijil',
                ),
              ] else if (_isHovered) ...[
                Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: widget.onGenerate,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_circle_outline, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Jana Sijil',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
