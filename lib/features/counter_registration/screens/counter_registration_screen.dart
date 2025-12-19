import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/localization/app_strings.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_input.dart';
import '../../../widgets/app_button.dart';
import '../providers/counter_registration_provider.dart';

class CounterRegistrationScreen extends StatefulWidget {
  const CounterRegistrationScreen({super.key});

  @override
  State<CounterRegistrationScreen> createState() => _CounterRegistrationScreenState();
}

class _CounterRegistrationScreenState extends State<CounterRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _icController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _icFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CounterRegistrationProvider>().loadPrograms();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _icController.dispose();
    _emailController.dispose();
    _nameFocusNode.dispose();
    _icFocusNode.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _icController.clear();
    _emailController.clear();
    _nameFocusNode.requestFocus();
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CounterRegistrationProvider>();
    
    final result = await provider.registerParticipant(
      fullName: _nameController.text.trim(),
      icNumber: _icController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
    );

    if (!mounted) return;

    if (result['success'] == true) {
      _showMessage('${tr(context, 'registration_success')} ${result['name']}', isError: false);
      _clearForm();
    } else {
      final errorKey = result['errorKey'] as String;
      String errorMsg = tr(context, errorKey);
      if (result['details'] != null) {
        errorMsg += ': ${result['details']}';
      }
      _showMessage(errorMsg, isError: true);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDark ? Colors.white60 : AppColors.textSecondary;

    return Consumer<CounterRegistrationProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.how_to_reg_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr(context, 'counter_registration'),
                          style: AppStyles.heading2.copyWith(color: textColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr(context, 'counter_registration_desc'),
                          style: AppStyles.bodySmall.copyWith(color: secondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Stats Cards
              if (provider.selectedProgram != null)
                _buildStatsRow(provider),

              const SizedBox(height: 24),

              // Main Content
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildRegistrationForm(provider),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 1,
                          child: _buildRecentRegistrations(provider),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildRegistrationForm(provider),
                      const SizedBox(height: 24),
                      _buildRecentRegistrations(provider),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(CounterRegistrationProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.event_available_rounded,
            title: tr(context, 'selected_program'),
            value: provider.selectedProgram?.programName ?? '-',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.today_rounded,
            title: tr(context, 'today_registrations'),
            value: '${provider.todayRegistrationCount}',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(CounterRegistrationProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(context, 'registration_form'),
                style: AppStyles.heading3,
              ),
              const SizedBox(height: 24),

              // Program Selector
              Text(
                tr(context, 'select_program'),
                style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1C2A) : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: provider.selectedProgram != null 
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : Colors.transparent,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    hint: Text(tr(context, 'choose_program')),
                    value: provider.selectedProgram?.id,
                    items: provider.programs.map((program) {
                      return DropdownMenuItem<int>(
                        value: program.id,
                        child: Text(
                          '${program.programName} (${program.programCode})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (programId) {
                      if (programId != null) {
                        final program = provider.programs.firstWhere(
                          (p) => p.id == programId,
                        );
                        provider.selectProgram(program);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (provider.selectedProgram != null) ...[
                // Full Name
                AppInput(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  label: tr(context, 'full_name'),
                  hint: tr(context, 'full_name_hint'),
                  prefixIconData: Icons.person_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return tr(context, 'please_enter_name');
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    _icFocusNode.requestFocus();
                  },
                ),
                const SizedBox(height: 16),

                // IC Number
                AppInput(
                  controller: _icController,
                  focusNode: _icFocusNode,
                  label: tr(context, 'ic_number'),
                  hint: tr(context, 'ic_number_hint'),
                  prefixIconData: Icons.credit_card_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return tr(context, 'please_enter_ic');
                    }
                    if (value.length < 12) {
                      return tr(context, 'ic_must_12_digits');
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submitRegistration(),
                ),
                const SizedBox(height: 16),

                // Email (Optional)
                AppInput(
                  controller: _emailController,
                  label: '${tr(context, 'email')} (${tr(context, 'optional')})',
                  hint: tr(context, 'email_hint'),
                  prefixIconData: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),

                // Submit Button
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: tr(context, 'register'),
                        icon: Icons.how_to_reg_rounded,
                        isLoading: provider.isLoading,
                        onPressed: _submitRegistration,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppButton(
                      label: tr(context, 'clear'),
                      icon: Icons.clear_rounded,
                      buttonVariant: ButtonVariant.secondary,
                      onPressed: _clearForm,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentRegistrations(CounterRegistrationProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  tr(context, 'recent_registrations'),
                  style: AppStyles.heading4,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (provider.selectedProgram == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 48,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tr(context, 'select_program_first'),
                        style: AppStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else if (provider.registeredParticipants.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add_disabled_rounded,
                        size: 48,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tr(context, 'no_registrations_today'),
                        style: AppStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.registeredParticipants.length > 10 
                    ? 10 
                    : provider.registeredParticipants.length,
                separatorBuilder: (_, idx) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final participant = provider.registeredParticipants[
                    provider.registeredParticipants.length - 1 - index
                  ];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        participant.fullName.isNotEmpty 
                            ? participant.fullName[0] 
                            : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(
                      participant.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _formatIc(participant.icNumber),
                      style: AppStyles.caption,
                    ),
                    trailing: Text(
                      _formatTime(participant.createdAt),
                      style: AppStyles.caption,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatIc(String ic) {
    if (ic.length == 12) {
      return '${ic.substring(0, 6)}-${ic.substring(6, 8)}-${ic.substring(8)}';
    }
    return ic;
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252836) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.caption,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppStyles.heading4.copyWith(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
