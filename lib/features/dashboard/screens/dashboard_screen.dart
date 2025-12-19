import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/localization/app_strings.dart';
import '../../../widgets/sidebar.dart';
import '../../../widgets/app_card.dart';
import '../../programs/providers/program_provider.dart';
import '../../programs/screens/programs_list_screen.dart';
import '../../programs/screens/program_create_screen.dart';
import '../../programs/screens/program_detail_screen.dart';
import '../../participants/screens/participants_list_screen.dart';
import '../../counter_registration/screens/counter_registration_screen.dart';
import '../../verification/screens/verify_screen.dart';
import '../../settings/screens/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgramProvider>().loadPrograms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1C2A) : AppColors.background;
    
    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() => _selectedIndex = index);
            },
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const _DashboardContent();
      case 1:
        return const ProgramsListScreen();
      case 2:
        return const ParticipantsListScreen();
      case 3:
        return const CounterRegistrationScreen();
      case 4:
        return const VerifyScreen();
      case 5:
        return const SettingsScreen();
      default:
        return const _DashboardContent();
    }
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDark ? Colors.white60 : AppColors.textSecondary;
    
    return Consumer<ProgramProvider>(
      builder: (context, provider, _) {
        final programs = provider.programs;
        final totalParticipants = programs.fold<int>(
          0,
          (sum, p) => sum + p.participantCount,
        );
        final totalCertificates = provider.totalCertificates;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              LayoutBuilder(
                builder: (context, constraints) {
                  final isSmall = constraints.maxWidth < 500;
                  if (isSmall) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr(context, 'welcome'),
                          style: AppStyles.heading2.copyWith(color: textColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr(context, 'manage_certificates_easily'),
                          style: AppStyles.bodySmall.copyWith(color: secondaryTextColor),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.add_rounded,
                                label: tr(context, 'new_program'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ProgramCreateScreen()),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            _RefreshButton(
                              onTap: () => context.read<ProgramProvider>().loadPrograms(),
                              isLoading: provider.isLoading,
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr(context, 'welcome'),
                              style: AppStyles.heading1.copyWith(color: textColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tr(context, 'manage_certificates_easily'),
                              style: AppStyles.bodyMedium.copyWith(color: secondaryTextColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          _RefreshButton(
                            onTap: () => context.read<ProgramProvider>().loadPrograms(),
                            isLoading: provider.isLoading,
                          ),
                          const SizedBox(width: 12),
                          _QuickActionButton(
                            icon: Icons.add_rounded,
                            label: tr(context, 'new_program'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ProgramCreateScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Stats cards
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        StatsCard(
                          title: tr(context, 'total_programs'),
                          value: '${programs.length}',
                          icon: Icons.folder_rounded,
                          iconColor: AppColors.primary,
                          iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        const SizedBox(height: 12),
                        StatsCard(
                          title: tr(context, 'total_participants'),
                          value: '$totalParticipants',
                          icon: Icons.people_rounded,
                          iconColor: AppColors.accent,
                          iconBgColor: AppColors.accent.withValues(alpha: 0.1),
                        ),
                        const SizedBox(height: 12),
                        StatsCard(
                          title: tr(context, 'certificates_generated'),
                          value: '$totalCertificates',
                          icon: Icons.verified_rounded,
                          iconColor: AppColors.success,
                          iconBgColor: AppColors.success.withValues(alpha: 0.1),
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: tr(context, 'total_programs'),
                          value: '${programs.length}',
                          icon: Icons.folder_rounded,
                          iconColor: AppColors.primary,
                          iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatsCard(
                          title: tr(context, 'total_participants'),
                          value: '$totalParticipants',
                          icon: Icons.people_rounded,
                          iconColor: AppColors.accent,
                          iconBgColor: AppColors.accent.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatsCard(
                          title: tr(context, 'certificates_generated'),
                          value: '$totalCertificates',
                          icon: Icons.verified_rounded,
                          iconColor: AppColors.success,
                          iconBgColor: AppColors.success.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Recent programs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr(context, 'recent_programs'), style: AppStyles.heading3),
                  if (programs.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // Navigate to programs
                      },
                      child: Text(
                        tr(context, 'view_all'),
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              if (provider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (programs.isEmpty)
                _EmptyState()
              else
                _ProgramsGrid(programs: programs.take(6).toList()),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(48),
      child: EmptyStateCard(
        icon: Icons.folder_open_rounded,
        title: tr(context, 'no_programs'),
        subtitle: tr(context, 'start_first_program'),
        action: _QuickActionButton(
          icon: Icons.add_rounded,
          label: tr(context, 'create_program'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProgramCreateScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProgramsGrid extends StatelessWidget {
  final List programs;

  const _ProgramsGrid({required this.programs});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 3;
    double childAspectRatio = 1.4;
    
    if (screenWidth < 900) {
      crossAxisCount = 2;
      childAspectRatio = 1.3;
    }
    if (screenWidth < 600) {
      crossAxisCount = 1;
      childAspectRatio = 1.8;
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final program = programs[index];
        return _ProgramCard(program: program);
      },
    );
  }
}

class _ProgramCard extends StatefulWidget {
  final dynamic program;

  const _ProgramCard({required this.program});

  @override
  State<_ProgramCard> createState() => _ProgramCardState();
}

class _ProgramCardState extends State<_ProgramCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final program = widget.program;
    final progress = program.participantCount > 0
        ? 0.0 // Placeholder - would need certificate count
        : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.read<ProgramProvider>().selectProgram(program.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProgramDetailScreen(programId: program.id),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: _isHovered
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.folder_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(progress).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(progress),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(progress),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                program.programName,
                style: AppStyles.heading4,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                program.organizer ?? tr(context, 'no_organizer'),
                style: AppStyles.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${program.participantCount} ${tr(context, 'participants')}',
                    style: AppStyles.caption,
                  ),
                  const Spacer(),
                  Text(
                    '${program.participantCount}',
                    style: AppStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation(_getStatusColor(progress)),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(double progress) {
    if (progress >= 1) return AppColors.success;
    if (progress > 0) return AppColors.warning;
    return AppColors.textLight;
  }

  String _getStatusText(double progress) {
    if (progress >= 1) return tr(context, 'completed');
    if (progress > 0) return tr(context, 'in_progress');
    return tr(context, 'not_started');
  }
}

class _RefreshButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const _RefreshButton({
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
        ),
      ),
    );
  }
}
