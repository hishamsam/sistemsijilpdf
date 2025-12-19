import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/localization/app_strings.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_input.dart';
import '../../../widgets/app_card.dart';
import '../providers/program_provider.dart';
import 'program_create_screen.dart';
import 'program_detail_screen.dart';

class ProgramsListScreen extends StatefulWidget {
  const ProgramsListScreen({super.key});

  @override
  State<ProgramsListScreen> createState() => _ProgramsListScreenState();
}

class _ProgramsListScreenState extends State<ProgramsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDark ? Colors.white60 : AppColors.textSecondary;
    
    return Consumer<ProgramProvider>(
      builder: (context, provider, _) {
        final allPrograms = provider.programs;
        final programs = _searchQuery.isEmpty
            ? allPrograms
            : allPrograms
                .where((p) =>
                    p.programName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    (p.organizer?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
                .toList();

        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr(context, 'program_list'), style: AppStyles.heading1.copyWith(color: textColor)),
                      const SizedBox(height: 4),
                      Text(
                        '${programs.length} ${tr(context, 'programs_found')}',
                        style: AppStyles.bodyMedium.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  AppButton(
                    text: tr(context, 'add_program'),
                    icon: Icons.add_rounded,
                    width: 180,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProgramCreateScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search and filters
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppSearchInput(
                      controller: _searchController,
                      hint: tr(context, 'search_program'),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      onClear: () {
                        setState(() => _searchQuery = '');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  AppIconButton(
                    icon: Icons.filter_list_rounded,
                    tooltip: tr(context, 'filter'),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  AppIconButton(
                    icon: Icons.sort_rounded,
                    tooltip: tr(context, 'sort'),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Programs list
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : programs.isEmpty
                        ? _buildEmptyState()
                        : _buildProgramsList(programs),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: EmptyStateCard(
        icon: Icons.folder_open_rounded,
        title: _searchQuery.isEmpty ? tr(context, 'no_programs') : tr(context, 'no_results'),
        subtitle: _searchQuery.isEmpty
            ? tr(context, 'create_first_program')
            : tr(context, 'try_other_keywords'),
        action: _searchQuery.isEmpty
            ? AppButton(
                text: tr(context, 'create_program'),
                icon: Icons.add_rounded,
                width: 160,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProgramCreateScreen(),
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }

  Widget _buildProgramsList(List programs) {
    return ListView.separated(
      itemCount: programs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final program = programs[index];
        return _ProgramListItem(program: program);
      },
    );
  }
}

class _ProgramListItem extends StatefulWidget {
  final dynamic program;

  const _ProgramListItem({required this.program});

  @override
  State<_ProgramListItem> createState() => _ProgramListItemState();
}

class _ProgramListItemState extends State<_ProgramListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final program = widget.program;
    final progress = program.participantCount > 0 
        ? program.certificateCount / program.participantCount 
        : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _navigateToDetail(context, program),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: _isHovered ? 16 : 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: _isHovered
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.folder_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.programName,
                      style: AppStyles.heading4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.business_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          program.organizer ?? tr(context, 'no_organizer'),
                          style: AppStyles.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(program.issueDate),
                          style: AppStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stats
              Container(
                width: 100,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '${program.participantCount}',
                      style: AppStyles.heading4.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(tr(context, 'participant_word'), style: AppStyles.caption),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              Container(
                width: 100,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '${program.certificateCount}',
                      style: AppStyles.heading4.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    Text(tr(context, 'certificate_word'), style: AppStyles.caption),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Progress
              SizedBox(
                width: 60,
                child: Column(
                  children: [
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: AppStyles.labelMedium.copyWith(
                        color: _getProgressColor(progress),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.background,
                        valueColor: AlwaysStoppedAnimation(_getProgressColor(progress)),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => [
                  _buildMenuItem('view', Icons.visibility_rounded, tr(context, 'view')),
                  _buildMenuItem('edit', Icons.edit_rounded, tr(context, 'edit')),
                  _buildMenuItem('delete', Icons.delete_rounded, tr(context, 'delete'), isDestructive: true),
                ],
                onSelected: (value) => _handleMenuAction(context, value, program),
              ),
            ],
          ),
        ),
      ),
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

  void _navigateToDetail(BuildContext context, dynamic program) {
    context.read<ProgramProvider>().selectProgram(program.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProgramDetailScreen(programId: program.id),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action, dynamic program) {
    switch (action) {
      case 'view':
        _navigateToDetail(context, program);
        break;
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProgramCreateScreen(program: program),
          ),
        );
        break;
      case 'delete':
        _showDeleteDialog(context, program);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context, dynamic program) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(tr(context, 'delete_program_question')),
        content: Text(
          '${tr(context, 'delete_confirm_message')} "${program.programName}"? ${tr(context, 'action_cannot_undone')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr(context, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProgramProvider>().deleteProgram(program.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(tr(context, 'delete'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1) return AppColors.success;
    if (progress > 0) return AppColors.warning;
    return AppColors.textLight;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mac', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ogo', 'Sep', 'Okt', 'Nov', 'Dis'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
