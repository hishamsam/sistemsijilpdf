import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../models/custom_template.dart';
import '../repositories/custom_template_repository.dart';
import 'template_editor_screen.dart';

class TemplateSelectorScreen extends StatefulWidget {
  final String? currentTemplateStyle;
  final int? currentCustomTemplateId;
  final Function(String?, int?) onSelect;

  const TemplateSelectorScreen({
    super.key,
    this.currentTemplateStyle,
    this.currentCustomTemplateId,
    required this.onSelect,
  });

  @override
  State<TemplateSelectorScreen> createState() => _TemplateSelectorScreenState();
}

class _TemplateSelectorScreenState extends State<TemplateSelectorScreen> {
  final CustomTemplateRepository _repository = CustomTemplateRepository();
  List<CustomTemplate> _customTemplates = [];
  bool _isLoading = true;
  String? _selectedStyle;
  int? _selectedCustomId;

  final List<Map<String, dynamic>> _builtInTemplates = [
    {
      'style': 'moden',
      'name': 'Moden',
      'description': 'Reka bentuk moden dan bersih',
      'color': AppColors.primary,
      'icon': Icons.auto_awesome_rounded,
    },
    {
      'style': 'klasik',
      'name': 'Klasik',
      'description': 'Gaya tradisional dengan hiasan emas',
      'color': const Color(0xFFD4AF37),
      'icon': Icons.star_rounded,
    },
    {
      'style': 'formal',
      'name': 'Formal',
      'description': 'Profesional dan rasmi',
      'color': const Color(0xFF1A237E),
      'icon': Icons.business_rounded,
    },
    {
      'style': 'kreatif',
      'name': 'Kreatif',
      'description': 'Warna-warni dan dinamik',
      'color': AppColors.accent,
      'icon': Icons.palette_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedStyle = widget.currentTemplateStyle;
    _selectedCustomId = widget.currentCustomTemplateId;
    _loadCustomTemplates();
  }

  Future<void> _loadCustomTemplates() async {
    setState(() => _isLoading = true);
    try {
      _customTemplates = await _repository.getAll();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectBuiltIn(String style) {
    setState(() {
      _selectedStyle = style;
      _selectedCustomId = null;
    });
    widget.onSelect(style, null);
  }

  void _selectCustom(int id) {
    setState(() {
      _selectedStyle = 'custom';
      _selectedCustomId = id;
    });
    widget.onSelect('custom', id);
  }

  Future<void> _createNewTemplate() async {
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

  Future<void> _editTemplate(CustomTemplate template) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateEditorScreen(template: template),
      ),
    );
    if (result == true) {
      _loadCustomTemplates();
    }
  }

  Future<void> _deleteTemplate(CustomTemplate template) async {
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
      await _repository.delete(template.id!);
      _loadCustomTemplates();
      if (_selectedCustomId == template.id) {
        setState(() {
          _selectedStyle = 'moden';
          _selectedCustomId = null;
        });
        widget.onSelect('moden', null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Template'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Built-in templates
            Text('Template Sedia Ada', style: AppStyles.heading4),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _builtInTemplates.length,
              itemBuilder: (context, index) {
                final template = _builtInTemplates[index];
                final isSelected = _selectedStyle == template['style'] && _selectedCustomId == null;
                return _buildBuiltInCard(template, isSelected);
              },
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // Custom templates
            Row(
              children: [
                Text('Template Custom', style: AppStyles.heading4),
                const Spacer(),
                TextButton.icon(
                  onPressed: _createNewTemplate,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Buat Baru'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_customTemplates.isEmpty)
              _buildEmptyCustom()
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: _customTemplates.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildCreateNewCard();
                  }
                  final template = _customTemplates[index - 1];
                  final isSelected = _selectedCustomId == template.id;
                  return _buildCustomCard(template, isSelected);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuiltInCard(Map<String, dynamic> template, bool isSelected) {
    return InkWell(
      onTap: () => _selectBuiltIn(template['style']),
      borderRadius: BorderRadius.circular(12),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 3)
                : null,
          ),
          child: Column(
            children: [
              // Preview area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: (template['color'] as Color).withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    template['icon'] as IconData,
                    size: 48,
                    color: template['color'] as Color,
                  ),
                ),
              ),
              // Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            template['name'] as String,
                            style: AppStyles.labelLarge.copyWith(
                              color: isSelected ? AppColors.primary : null,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template['description'] as String,
                      style: AppStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomCard(CustomTemplate template, bool isSelected) {
    return InkWell(
      onTap: () => _selectCustom(template.id!),
      borderRadius: BorderRadius.circular(12),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 3)
                : null,
          ),
          child: Column(
            children: [
              // Preview area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.description_rounded,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      // Actions
                      Positioned(
                        top: 4,
                        right: 4,
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded, size: 18),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Padam')),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editTemplate(template);
                            } else if (value == 'delete') {
                              _deleteTemplate(template);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: AppStyles.labelLarge.copyWith(
                              color: isSelected ? AppColors.primary : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${template.elements.length} elemen',
                            style: AppStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateNewCard() {
    return InkWell(
      onTap: _createNewTemplate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text('Buat Template', style: AppStyles.labelLarge),
            const SizedBox(height: 4),
            Text('Design sendiri', style: AppStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCustom() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.design_services_rounded, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text('Tiada Template Custom', style: AppStyles.bodyLarge),
          const SizedBox(height: 8),
          Text(
            'Klik butang "Buat Baru" untuk mencipta template anda sendiri',
            style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _createNewTemplate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Buat Template Baru'),
          ),
        ],
      ),
    );
  }
}
