import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/localization/app_strings.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_input.dart';
import '../../../widgets/app_card.dart';
import '../../../data/models/program.dart';
import '../providers/program_provider.dart';
import '../../template_editor/models/custom_template.dart';
import '../../template_editor/repositories/custom_template_repository.dart';
import '../../template_editor/screens/template_editor_screen.dart';

class ProgramCreateScreen extends StatefulWidget {
  final Program? program;

  const ProgramCreateScreen({super.key, this.program});

  @override
  State<ProgramCreateScreen> createState() => _ProgramCreateScreenState();
}

class _ProgramCreateScreenState extends State<ProgramCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _organizerController;
  late TextEditingController _taglineController;
  late TextEditingController _signatoryNameController;
  late TextEditingController _signatoryTitleController;
  late TextEditingController _signatoryName2Controller;
  late TextEditingController _signatoryTitle2Controller;
  late TextEditingController _signatoryName3Controller;
  late TextEditingController _signatoryTitle3Controller;
  late TextEditingController _watermarkController;

  String _certificateType = 'penyertaan';
  String _templateStyle = 'moden';
  String _language = 'bilingual';
  String _qrPosition = 'bottom-right';
  bool _showIcNumber = false;
  DateTime _issueDate = DateTime.now();
  DateTime? _expiryDate;
  double _watermarkOpacity = 0.1;
  bool _isLoading = false;
  bool _showSignatory2 = false;
  bool _showSignatory3 = false;
  
  String? _logoPath;
  String? _signaturePath;
  String? _signaturePath2;
  String? _signaturePath3;
  
  int? _customTemplateId;
  List<CustomTemplate> _customTemplates = [];
  final CustomTemplateRepository _templateRepo = CustomTemplateRepository();

  bool get _isEditing => widget.program != null;

  @override
  void initState() {
    super.initState();
    final p = widget.program;
    _nameController = TextEditingController(text: p?.programName ?? '');
    _organizerController = TextEditingController(text: p?.organizer ?? '');
    _taglineController = TextEditingController(text: p?.organizerTagline ?? '');
    _signatoryNameController = TextEditingController(text: p?.signatoryName ?? '');
    _signatoryTitleController = TextEditingController(text: p?.signatoryTitle ?? '');
    _signatoryName2Controller = TextEditingController(text: p?.signatoryName2 ?? '');
    _signatoryTitle2Controller = TextEditingController(text: p?.signatoryTitle2 ?? '');
    _signatoryName3Controller = TextEditingController(text: p?.signatoryName3 ?? '');
    _signatoryTitle3Controller = TextEditingController(text: p?.signatoryTitle3 ?? '');
    _watermarkController = TextEditingController(text: p?.watermarkText ?? '');

    if (p != null) {
      _certificateType = p.certificateType;
      _templateStyle = p.templateStyle;
      _language = p.language;
      _qrPosition = p.qrPosition;
      _showIcNumber = p.showIcNumber;
      _issueDate = p.issueDate;
      _expiryDate = p.expiryDate;
      _watermarkOpacity = p.watermarkOpacity;
      _logoPath = p.logoPath;
      _signaturePath = p.signaturePath;
      _signaturePath2 = p.signaturePath2;
      _signaturePath3 = p.signaturePath3;
      _showSignatory2 = p.signatoryName2?.isNotEmpty == true;
      _showSignatory3 = p.signatoryName3?.isNotEmpty == true;
      _customTemplateId = p.customTemplateId;
    }
    _loadCustomTemplates();
  }

  Future<void> _loadCustomTemplates() async {
    final templates = await _templateRepo.getAll();
    setState(() => _customTemplates = templates);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _organizerController.dispose();
    _taglineController.dispose();
    _signatoryNameController.dispose();
    _signatoryTitleController.dispose();
    _signatoryName2Controller.dispose();
    _signatoryTitle2Controller.dispose();
    _signatoryName3Controller.dispose();
    _signatoryTitle3Controller.dispose();
    _watermarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Container(
            width: 80,
            color: AppColors.surface,
            child: Column(
              children: [
                const SizedBox(height: 24),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: tr(context, 'back'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditing ? tr(context, 'edit_program_title') : tr(context, 'new_program_title'),
                    style: AppStyles.heading1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isEditing
                        ? tr(context, 'update_program_info')
                        : tr(context, 'fill_program_info'),
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              _buildMainInfoCard(),
                              const SizedBox(height: 24),
                              _buildSignatoryCard(),
                              const SizedBox(height: 24),
                              _buildMediaCard(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildCertificateTypeCard(),
                              const SizedBox(height: 24),
                              _buildTemplateCard(),
                              const SizedBox(height: 24),
                              _buildActionButtons(),
                            ],
                          ),
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
    );
  }

  Widget _buildMainInfoCard() {
    return AppCard(
      padding: const EdgeInsets.all(24),
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
                child: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(tr(context, 'program_info'), style: AppStyles.heading4),
            ],
          ),
          const SizedBox(height: 24),
          AppInput(
            label: tr(context, 'program_name_label'),
            hint: tr(context, 'program_name_hint'),
            controller: _nameController,
            validator: (v) => v?.isEmpty == true ? tr(context, 'please_enter_program_name') : null,
          ),
          const SizedBox(height: 20),
          AppInput(
            label: tr(context, 'organizer_name'),
            hint: tr(context, 'organizer_hint'),
            controller: _organizerController,
          ),
          const SizedBox(height: 20),
          AppInput(
            label: tr(context, 'organizer_tagline'),
            hint: tr(context, 'organizer_tagline_hint'),
            controller: _taglineController,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr(context, 'issue_date_label'), style: AppStyles.labelLarge),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text(_formatDate(_issueDate), style: AppStyles.bodyLarge)),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tarikh Luput (Pilihan)', style: AppStyles.labelLarge),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectExpiryDate,
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.event_busy_rounded, color: _expiryDate != null ? AppColors.warning : AppColors.textSecondary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text(_expiryDate != null ? _formatDate(_expiryDate!) : 'Tiada', style: AppStyles.bodyLarge)),
                            if (_expiryDate != null)
                              InkWell(
                                onTap: () => setState(() => _expiryDate = null),
                                child: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 18),
                              )
                            else
                              const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignatoryCard() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.draw_rounded, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(tr(context, 'signatory_info'), style: AppStyles.heading4)),
              Text('${_showSignatory2 ? (_showSignatory3 ? 3 : 2) : 1} Penandatangan', style: AppStyles.caption),
            ],
          ),
          const SizedBox(height: 24),
          
          // Signatory 1
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Penandatangan 1 (Utama)', style: AppStyles.labelLarge.copyWith(color: AppColors.primary)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Signature upload
                    _buildSignatureUpload(
                      imagePath: _signaturePath,
                      onUpload: () => _pickImage('signature1'),
                      onRemove: () => setState(() => _signaturePath = null),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          AppInput(
                            label: tr(context, 'signatory_name'),
                            hint: tr(context, 'signatory_name_hint'),
                            controller: _signatoryNameController,
                          ),
                          const SizedBox(height: 12),
                          AppInput(
                            label: tr(context, 'signatory_title'),
                            hint: tr(context, 'signatory_title_hint'),
                            controller: _signatoryTitleController,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Signatory 2
          if (_showSignatory2) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Penandatangan 2', style: AppStyles.labelLarge.copyWith(color: AppColors.secondary)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => setState(() {
                          _showSignatory2 = false;
                          _showSignatory3 = false;
                          _signatoryName2Controller.clear();
                          _signatoryTitle2Controller.clear();
                          _signaturePath2 = null;
                        }),
                        tooltip: 'Buang',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Signature upload
                      _buildSignatureUpload(
                        imagePath: _signaturePath2,
                        onUpload: () => _pickImage('signature2'),
                        onRemove: () => setState(() => _signaturePath2 = null),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            AppInput(
                              label: 'Nama',
                              hint: 'Nama penandatangan kedua',
                              controller: _signatoryName2Controller,
                            ),
                            const SizedBox(height: 12),
                            AppInput(
                              label: 'Jawatan',
                              hint: 'Jawatan penandatangan kedua',
                              controller: _signatoryTitle2Controller,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          
          // Signatory 3
          if (_showSignatory3) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Penandatangan 3', style: AppStyles.labelLarge.copyWith(color: AppColors.warning)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => setState(() {
                          _showSignatory3 = false;
                          _signatoryName3Controller.clear();
                          _signatoryTitle3Controller.clear();
                          _signaturePath3 = null;
                        }),
                        tooltip: 'Buang',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Signature upload
                      _buildSignatureUpload(
                        imagePath: _signaturePath3,
                        onUpload: () => _pickImage('signature3'),
                        onRemove: () => setState(() => _signaturePath3 = null),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            AppInput(
                              label: 'Nama',
                              hint: 'Nama penandatangan ketiga',
                              controller: _signatoryName3Controller,
                            ),
                            const SizedBox(height: 12),
                            AppInput(
                              label: 'Jawatan',
                              hint: 'Jawatan penandatangan ketiga',
                              controller: _signatoryTitle3Controller,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          
          // Add signatory buttons
          if (!_showSignatory2 || !_showSignatory3) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (!_showSignatory2)
                  TextButton.icon(
                    onPressed: () => setState(() => _showSignatory2 = true),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Tambah Penandatangan 2'),
                  ),
                if (_showSignatory2 && !_showSignatory3)
                  TextButton.icon(
                    onPressed: () => setState(() => _showSignatory3 = true),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Tambah Penandatangan 3'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaCard() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.image_rounded, color: AppColors.info),
              ),
              const SizedBox(width: 12),
              Text(tr(context, 'organizer_logo'), style: AppStyles.heading4),
            ],
          ),
          const SizedBox(height: 24),
          // Logo upload only
          _buildImageUpload(
            label: tr(context, 'organizer_logo'),
            imagePath: _logoPath,
            onUpload: () => _pickImage('logo'),
            onRemove: () => setState(() => _logoPath = null),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUpload({
    required String label,
    required String? imagePath,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyles.labelLarge),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            border: Border.all(
              color: AppColors.border,
              style: BorderStyle.solid,
            ),
          ),
          child: imagePath != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                      child: Image.file(
                        File(imagePath),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: onUpload,
                  borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 32,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr(context, 'click_to_upload'),
                          style: AppStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSignatureUpload({
    required String? imagePath,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: imagePath != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePath),
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: onUpload,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.draw_rounded, size: 28, color: AppColors.textSecondary),
                  const SizedBox(height: 4),
                  Text('Tandatangan', style: AppStyles.caption.copyWith(fontSize: 9)),
                ],
              ),
            ),
    );
  }

  Future<void> _pickImage(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        switch (type) {
          case 'logo':
            _logoPath = result.files.single.path;
            break;
          case 'signature1':
            _signaturePath = result.files.single.path;
            break;
          case 'signature2':
            _signaturePath2 = result.files.single.path;
            break;
          case 'signature3':
            _signaturePath3 = result.files.single.path;
            break;
        }
      });
    }
  }

  Widget _buildCertificateTypeCard() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.category_rounded, color: AppColors.warning),
              ),
              const SizedBox(width: 12),
              Text(tr(context, 'certificate_type'), style: AppStyles.heading4),
            ],
          ),
          const SizedBox(height: 20),
          _buildTypeOption('penyertaan', tr(context, 'cert_participation'), Icons.people_rounded),
          _buildTypeOption('penghargaan', tr(context, 'cert_appreciation'), Icons.star_rounded),
          _buildTypeOption('pencapaian', tr(context, 'cert_achievement'), Icons.emoji_events_rounded),
          _buildTypeOption('kehadiran', tr(context, 'cert_attendance'), Icons.check_circle_rounded),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String value, String label, IconData icon) {
    final isSelected = _certificateType == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _certificateType = value),
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCard() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.palette_rounded, color: AppColors.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(tr(context, 'certificate_template'), style: AppStyles.heading4)),
              TextButton.icon(
                onPressed: _openTemplateEditor,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Buat Custom'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Built-in templates
          Text('Template Sedia Ada', style: AppStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildTemplateOption('moden', tr(context, 'template_modern'), AppColors.primary),
              _buildTemplateOption('klasik', tr(context, 'template_classic'), const Color(0xFFD4AF37)),
              _buildTemplateOption('formal', tr(context, 'template_formal'), const Color(0xFF1A237E)),
              _buildTemplateOption('kreatif', tr(context, 'template_creative'), AppColors.accent),
            ],
          ),
          
          // Custom templates
          if (_customTemplates.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Template Custom', style: AppStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: _customTemplates.length,
              itemBuilder: (context, index) {
                final template = _customTemplates[index];
                return _buildCustomTemplateOption(template);
              },
            ),
          ],
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.language_rounded, color: AppColors.info),
              ),
              const SizedBox(width: 12),
              Text(tr(context, 'certificate_language'), style: AppStyles.heading4),
            ],
          ),
          const SizedBox(height: 16),
          _buildLanguageOption('bilingual', tr(context, 'bilingual'), Icons.translate_rounded),
          const SizedBox(height: 8),
          _buildLanguageOption('malay', tr(context, 'malay_only'), Icons.flag_rounded),
          const SizedBox(height: 8),
          _buildLanguageOption('english', tr(context, 'english_only'), Icons.language_rounded),
          
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          
          // Show IC Number toggle
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.badge_rounded, color: AppColors.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr(context, 'show_ic_number'), style: AppStyles.heading4),
                    Text(
                      tr(context, 'show_ic_number_desc'),
                      style: AppStyles.caption,
                    ),
                  ],
                ),
              ),
              Switch(
                value: _showIcNumber,
                onChanged: (value) => setState(() => _showIcNumber = value),
                activeColor: AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String value, String label, IconData icon) {
    final isSelected = _language == value;
    return InkWell(
      onTap: () => setState(() => _language = value),
      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.info.withValues(alpha: 0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.info : Colors.transparent, 
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              color: isSelected ? AppColors.info : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.info : AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.info, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateOption(String value, String label, Color color) {
    final isSelected = _templateStyle == value && _customTemplateId == null;
    return InkWell(
      onTap: () => setState(() {
        _templateStyle = value;
        _customTemplateId = null;
      }),
      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTemplateOption(CustomTemplate template) {
    final isSelected = _customTemplateId == template.id;
    return InkWell(
      onTap: () => setState(() {
        _templateStyle = 'custom';
        _customTemplateId = template.id;
      }),
      borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          border: Border.all(color: isSelected ? AppColors.accent : Colors.transparent, width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : const Icon(Icons.description_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    template.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.accent : AppColors.textPrimary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 16, color: AppColors.textSecondary),
                padding: EdgeInsets.zero,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Padam')),
                ],
                onSelected: (value) async {
                  if (value == 'edit') {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TemplateEditorScreen(template: template),
                      ),
                    );
                    if (result == true) _loadCustomTemplates();
                  } else if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Padam Template'),
                        content: Text('Adakah anda pasti mahu padam template "${template.name}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            child: const Text('Padam'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _templateRepo.delete(template.id!);
                      _loadCustomTemplates();
                      if (_customTemplateId == template.id) {
                        setState(() {
                          _templateStyle = 'moden';
                          _customTemplateId = null;
                        });
                      }
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTemplateEditor() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const TemplateEditorScreen(),
      ),
    );
    if (result == true) {
      _loadCustomTemplates();
    }
  }

  Widget _buildActionButtons() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          AppButton(
            text: _isLoading ? tr(context, 'saving') : _isEditing ? tr(context, 'update') : tr(context, 'save_btn'),
            width: double.infinity,
            isLoading: _isLoading,
            onPressed: _saveProgram,
          ),
          const SizedBox(height: 12),
          AppButton(
            text: tr(context, 'cancel'),
            width: double.infinity,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _issueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => _issueDate = date);
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? _issueDate.add(const Duration(days: 365)),
      firstDate: _issueDate,
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.warning),
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => _expiryDate = date);
  }

  String _formatDate(DateTime date) {
    final months = ['Januari', 'Februari', 'Mac', 'April', 'Mei', 'Jun', 'Julai', 'Ogos', 'September', 'Oktober', 'November', 'Disember'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _saveProgram() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final provider = context.read<ProgramProvider>();

      if (_isEditing) {
        final updated = widget.program!.copyWith(
          programName: _nameController.text.trim(),
          organizer: _organizerController.text.trim(),
          organizerTagline: _taglineController.text.trim(),
          signatoryName: _signatoryNameController.text.trim(),
          signatoryTitle: _signatoryTitleController.text.trim(),
          signatoryName2: _signatoryName2Controller.text.trim(),
          signatoryTitle2: _signatoryTitle2Controller.text.trim(),
          signatoryName3: _signatoryName3Controller.text.trim(),
          signatoryTitle3: _signatoryTitle3Controller.text.trim(),
          certificateType: _certificateType,
          templateStyle: _templateStyle,
          language: _language,
          qrPosition: _qrPosition,
          showIcNumber: _showIcNumber,
          issueDate: _issueDate,
          expiryDate: _expiryDate,
          watermarkText: _watermarkController.text.trim(),
          watermarkOpacity: _watermarkOpacity,
          logoPath: _logoPath,
          signaturePath: _signaturePath,
          signaturePath2: _signaturePath2,
          signaturePath3: _signaturePath3,
          customTemplateId: _customTemplateId,
        );
        await provider.updateProgram(updated);
      } else {
        final baseName = _nameController.text.trim()
            .toUpperCase()
            .replaceAll(RegExp(r'[^A-Z0-9]'), '');
        final baseCode = baseName.length > 6 ? baseName.substring(0, 6) : baseName;
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final uniqueSuffix = timestamp.substring(timestamp.length - 4);
        final programCode = '$baseCode$uniqueSuffix';
        
        final program = Program(
          programName: _nameController.text.trim(),
          programCode: programCode,
          programYear: _issueDate.year,
          organizer: _organizerController.text.trim(),
          organizerTagline: _taglineController.text.trim(),
          signatoryName: _signatoryNameController.text.trim(),
          signatoryTitle: _signatoryTitleController.text.trim(),
          signatoryName2: _signatoryName2Controller.text.trim(),
          signatoryTitle2: _signatoryTitle2Controller.text.trim(),
          signatoryName3: _signatoryName3Controller.text.trim(),
          signatoryTitle3: _signatoryTitle3Controller.text.trim(),
          certificateType: _certificateType,
          templateStyle: _templateStyle,
          language: _language,
          qrPosition: _qrPosition,
          showIcNumber: _showIcNumber,
          issueDate: _issueDate,
          expiryDate: _expiryDate,
          watermarkText: _watermarkController.text.trim(),
          watermarkOpacity: _watermarkOpacity,
          logoPath: _logoPath,
          signaturePath: _signaturePath,
          signaturePath2: _signaturePath2,
          signaturePath3: _signaturePath3,
          customTemplateId: _customTemplateId,
        );
        await provider.createProgram(program);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? tr(context, 'program_updated') : tr(context, 'program_created')),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tr(context, 'error_prefix')}: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
