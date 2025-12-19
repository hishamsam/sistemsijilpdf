import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/localization/app_strings.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../services/backup_service.dart';
import '../../../services/auto_csv_service.dart';
import '../../../data/repositories/settings_repository.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _backupService = BackupService();
  final _settingsRepo = SettingsRepository();
  final _verificationUrlController = TextEditingController();
  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _isSavingUrl = false;

  @override
  void initState() {
    super.initState();
    _loadVerificationUrl();
  }

  @override
  void dispose() {
    _verificationUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadVerificationUrl() async {
    final url = await _settingsRepo.getVerificationUrl();
    if (url != null) {
      _verificationUrlController.text = url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDark ? Colors.white60 : AppColors.textSecondary;
    
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(tr(context, 'settings_title'), style: AppStyles.heading1.copyWith(color: textColor)),
              const SizedBox(height: 8),
              Text(
                tr(context, 'manage_app_settings'),
                style: AppStyles.bodyMedium.copyWith(
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 32),

              // Settings grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column
                  Expanded(
                    child: Column(
                      children: [
                        _buildAppearanceCard(settings),
                        const SizedBox(height: 24),
                        _buildSecurityCard(settings),
                        const SizedBox(height: 24),
                        _buildBackupCard(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Right column
                  Expanded(
                    child: Column(
                      children: [
                        _buildOnlineVerificationCard(),
                        const SizedBox(height: 24),
                        _buildFactoryResetCard(settings),
                        const SizedBox(height: 24),
                        _buildAboutCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppearanceCard(SettingsProvider settings) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.palette_rounded,
            title: tr(context, 'appearance'),
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),

          // Language
          _SettingsTile(
            icon: Icons.language_rounded,
            title: tr(context, 'language'),
            subtitle: settings.language == 'ms' ? 'Bahasa Melayu' : 'English',
            trailing: DropdownButton<String>(
              value: settings.language,
              underline: const SizedBox(),
              borderRadius: BorderRadius.circular(8),
              items: const [
                DropdownMenuItem(
                  value: 'ms',
                  child: Text('Bahasa Melayu'),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  settings.setLanguage(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(SettingsProvider settings) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.security_rounded,
            title: tr(context, 'security'),
            color: AppColors.warning,
          ),
          const SizedBox(height: 24),

          // Password lock
          _SettingsTile(
            icon: Icons.lock_rounded,
            title: tr(context, 'password_lock'),
            subtitle: settings.hasPassword ? tr(context, 'active') : tr(context, 'inactive'),
            trailing: Switch(
              value: settings.hasPassword,
              onChanged: (value) {
                if (value) {
                  _showSetPasswordDialog();
                } else {
                  settings.removePassword();
                }
              },
              activeColor: AppColors.primary,
            ),
          ),
          const Divider(height: 32),

          // Change password
          if (settings.hasPassword)
            _SettingsTile(
              icon: Icons.edit_rounded,
              title: tr(context, 'change_password'),
              subtitle: tr(context, 'update_password'),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
              onTap: () => _showChangePasswordDialog(),
            ),
        ],
      ),
    );
  }

  Widget _buildBackupCard() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.backup_rounded,
            title: tr(context, 'backup_restore'),
            color: AppColors.success,
          ),
          const SizedBox(height: 24),

          Text(
            tr(context, 'backup_desc'),
            style: AppStyles.bodySmall,
          ),
          const SizedBox(height: 20),

          AppButton(
            text: _isBackingUp ? tr(context, 'creating_backup') : tr(context, 'create_backup'),
            icon: Icons.cloud_upload_rounded,
            width: double.infinity,
            isLoading: _isBackingUp,
            onPressed: _backup,
          ),
          const SizedBox(height: 12),
          AppButton(
            text: _isRestoring ? tr(context, 'restoring') : tr(context, 'restore_data'),
            icon: Icons.cloud_download_rounded,
            width: double.infinity,
            variant: AppButtonVariant.secondary,
            isLoading: _isRestoring,
            onPressed: _restore,
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineVerificationCard() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.public_rounded,
            title: tr(context, 'online_verification'),
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),

          Text(
            tr(context, 'verification_url_desc'),
            style: AppStyles.bodySmall,
          ),
          const SizedBox(height: 16),

          // Verification URL Input
          TextField(
            controller: _verificationUrlController,
            decoration: InputDecoration(
              labelText: tr(context, 'verification_url_label'),
              hintText: 'https://script.google.com/macros/s/xxxxx/exec',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.link_rounded),
            ),
            style: AppStyles.bodyMedium,
          ),
          const SizedBox(height: 12),

          AppButton(
            text: _isSavingUrl ? tr(context, 'saving') : tr(context, 'save_url'),
            icon: Icons.save_rounded,
            width: double.infinity,
            isLoading: _isSavingUrl,
            onPressed: _saveVerificationUrl,
          ),
          const SizedBox(height: 20),

          const Divider(),
          const SizedBox(height: 16),

          Text(
            tr(context, 'csv_setup_guide'),
            style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          AppButton(
            text: tr(context, 'open_csv_folder'),
            icon: Icons.folder_open_rounded,
            width: double.infinity,
            variant: AppButtonVariant.secondary,
            onPressed: _openCsvFolder,
          ),
          const SizedBox(height: 12),
          AppButton(
            text: tr(context, 'setup_guide'),
            icon: Icons.help_outline_rounded,
            width: double.infinity,
            variant: AppButtonVariant.secondary,
            onPressed: _showSetupGuide,
          ),
        ],
      ),
    );
  }

  Future<void> _saveVerificationUrl() async {
    final url = _verificationUrlController.text.trim();
    
    if (url.isNotEmpty && !url.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL mesti bermula dengan https://'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSavingUrl = true);

    try {
      await _settingsRepo.setVerificationUrl(url);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(url.isEmpty 
              ? 'URL dipadamkan. QR akan guna format JSON.' 
              : 'URL disimpan! QR code akan mengandungi link verification.'),
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
    } finally {
      setState(() => _isSavingUrl = false);
    }
  }

  Widget _buildFactoryResetCard(SettingsProvider settings) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.restart_alt_rounded,
            title: tr(context, 'factory_reset'),
            color: AppColors.error,
          ),
          const SizedBox(height: 24),

          Text(
            tr(context, 'factory_reset_desc'),
            style: AppStyles.bodySmall,
          ),
          const SizedBox(height: 20),

          AppButton(
            text: tr(context, 'reset_now'),
            icon: Icons.warning_rounded,
            width: double.infinity,
            variant: AppButtonVariant.secondary,
            color: AppColors.error,
            onPressed: () => _showFactoryResetDialog(settings),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.info_rounded,
            title: tr(context, 'about_app'),
            color: AppColors.info,
          ),
          const SizedBox(height: 24),

          _SettingsTile(
            icon: Icons.apps_rounded,
            title: tr(context, 'app_version'),
            subtitle: '1.0.0',
          ),
          const Divider(height: 24),
          _SettingsTile(
            icon: Icons.code_rounded,
            title: tr(context, 'built_with'),
            subtitle: 'Flutter Desktop',
          ),
          const Divider(height: 24),
          _SettingsTile(
            icon: Icons.storage_rounded,
            title: tr(context, 'data_storage'),
            subtitle: 'SQLite (Offline)',
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 14),
        Text(title, style: AppStyles.heading4),
      ],
    );
  }

  Future<void> _backup() async {
    setState(() => _isBackingUp = true);

    try {
      final path = await _backupService.createBackup();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sandaran berjaya disimpan: $path'),
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
    } finally {
      setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restore() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Pulihkan Data?'),
          content: const Text(
            'Ini akan menggantikan semua data sedia ada. Pastikan anda telah membuat sandaran terlebih dahulu.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Pulihkan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        setState(() => _isRestoring = true);

        try {
          // Load backup data from file
          final file = File(result.files.single.path!);
          final jsonData = await file.readAsString();
          final backupData = jsonDecode(jsonData) as Map<String, dynamic>;
          await _backupService.restoreBackup(backupData);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data berjaya dipulihkan!'),
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
        } finally {
          setState(() => _isRestoring = false);
        }
      }
    }
  }

  void _showSetPasswordDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tetapkan Kata Laluan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan kata laluan baru'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Kata Laluan',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final password = controller.text;
              if (password.length >= 4) {
                context.read<SettingsProvider>().setPassword(password);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kata laluan berjaya ditetapkan!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldController = TextEditingController();
    final newController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tukar Kata Laluan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Kata Laluan Lama',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Kata Laluan Baru',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final settings = context.read<SettingsProvider>();
              if (await settings.verifyPassword(oldController.text)) {
                settings.setPassword(newController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kata laluan berjaya ditukar!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kata laluan lama tidak betul'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _openCsvFolder() async {
    try {
      final autoCsvService = AutoCsvService();
      
      // Ensure CSV is up to date
      await autoCsvService.updateCsvFile();
      
      final folderPath = await autoCsvService.getCsvFolderPath();

      if (folderPath != null && mounted) {
        // Open folder in file explorer
        await Process.run('explorer', [folderPath]);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Folder dibuka: $folderPath'),
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

  void _showSetupGuide() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.public_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(tr(context, 'online_verification_guide')),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStep('1', tr(context, 'export_cert_data'), 
                  tr(context, 'export_csv_hint')),
                const SizedBox(height: 16),
                _buildStep('2', tr(context, 'create_google_sheets'), 
                  tr(context, 'google_sheets_hint')),
                const SizedBox(height: 16),
                _buildStep('3', tr(context, 'setup_apps_script'), 
                  tr(context, 'apps_script_hint')),
                const SizedBox(height: 16),
                _buildStep('4', tr(context, 'deploy_web_app'), 
                  tr(context, 'deploy_hint')),
                const SizedBox(height: 16),
                _buildStep('5', tr(context, 'share_link'), 
                  tr(context, 'share_link_hint')),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tr(context, 'guide_note'),
                          style: TextStyle(color: AppColors.info, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(tr(context, 'understand'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(description, style: AppStyles.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  void _showFactoryResetDialog(SettingsProvider settings) {
    final confirmController = TextEditingController();
    final lang = settings.language;
    final confirmWord = lang == 'ms' ? 'PADAM' : 'DELETE';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error),
            const SizedBox(width: 12),
            Text(tr(context, 'factory_reset_confirm')),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(context, 'factory_reset_warning'),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 16),
              _buildResetItem(Icons.folder_rounded, tr(context, 'all_programs')),
              _buildResetItem(Icons.people_rounded, tr(context, 'all_participants')),
              _buildResetItem(Icons.verified_rounded, tr(context, 'all_certificates')),
              _buildResetItem(Icons.settings_rounded, tr(context, 'all_settings')),
              const SizedBox(height: 24),
              Text(
                tr(context, 'type_confirm'),
                style: AppStyles.bodyMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                decoration: InputDecoration(
                  hintText: confirmWord,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr(context, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (confirmController.text.toUpperCase() == confirmWord) {
                Navigator.pop(ctx);
                await _performFactoryReset(settings);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr(context, 'wrong_confirm_word')),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(tr(context, 'factory_reset'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildResetItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(text, style: AppStyles.bodyMedium),
        ],
      ),
    );
  }

  Future<void> _performFactoryReset(SettingsProvider settings) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(tr(context, 'resetting')),
          ],
        ),
      ),
    );

    try {
      await settings.factoryReset();
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr(context, 'factory_reset_success')),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${tr(context, 'error_prefix')}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyles.bodyLarge),
                Text(subtitle, style: AppStyles.caption),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
