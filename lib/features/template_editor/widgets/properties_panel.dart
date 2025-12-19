import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../models/template_element.dart';
import '../providers/template_editor_provider.dart';

class PropertiesPanel extends StatefulWidget {
  const PropertiesPanel({super.key});

  @override
  State<PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends State<PropertiesPanel> {
  final _textController = TextEditingController();
  final _xController = TextEditingController();
  final _yController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _fontSizeController = TextEditingController();
  final _colorController = TextEditingController();
  final _fillColorController = TextEditingController();
  final _strokeColorController = TextEditingController();
  final _strokeWidthController = TextEditingController();
  final _labelTextController = TextEditingController();
  
  String? _lastElementId;
  
  @override
  void dispose() {
    _textController.dispose();
    _xController.dispose();
    _yController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _fontSizeController.dispose();
    _colorController.dispose();
    _fillColorController.dispose();
    _strokeColorController.dispose();
    _strokeWidthController.dispose();
    _labelTextController.dispose();
    super.dispose();
  }
  
  void _updateControllers(TemplateElement element) {
    if (_lastElementId != element.id) {
      _lastElementId = element.id;
      final props = element.properties;
      
      _textController.text = props['text'] as String? ?? '';
      _xController.text = element.x.toStringAsFixed(0);
      _yController.text = element.y.toStringAsFixed(0);
      _widthController.text = element.width.toStringAsFixed(0);
      _heightController.text = element.height.toStringAsFixed(0);
      _fontSizeController.text = ((props['fontSize'] as num?)?.toDouble() ?? 16).toStringAsFixed(0);
      _colorController.text = props['color'] as String? ?? '#000000';
      _fillColorController.text = props['fillColor'] as String? ?? '#FFFFFF';
      _strokeColorController.text = props['strokeColor'] as String? ?? '#000000';
      _strokeWidthController.text = ((props['strokeWidth'] as num?)?.toDouble() ?? 1).toStringAsFixed(0);
      _labelTextController.text = props['labelText'] as String? ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateEditorProvider>(
      builder: (context, provider, _) {
        final element = provider.selectedElement;
        
        if (element != null) {
          _updateControllers(element);
        } else {
          _lastElementId = null;
        }

        return Container(
          width: 280,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(left: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('Properties', style: AppStyles.labelLarge),
                  ],
                ),
              ),
              Expanded(
                child: element == null
                    ? _buildNoSelection()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildElementInfo(element, provider),
                            const SizedBox(height: 16),
                            _buildPositionSection(element, provider),
                            const SizedBox(height: 16),
                            _buildSizeSection(element, provider),
                            const SizedBox(height: 16),
                            ..._buildTypeSpecificProperties(element, provider),
                            const SizedBox(height: 16),
                            _buildActionsSection(element, provider),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app_rounded, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Pilih elemen untuk\nedit properties',
            textAlign: TextAlign.center,
            style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildElementInfo(TemplateElement element, TemplateEditorProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(_getElementIcon(element.type), color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getElementTypeName(element.type), style: AppStyles.labelMedium),
                Text('ID: ${element.id.length > 8 ? element.id.substring(0, 8) : element.id}...', style: AppStyles.caption),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              element.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
              size: 20,
            ),
            onPressed: () => provider.toggleElementLock(element.id),
            tooltip: element.isLocked ? 'Buka kunci' : 'Kunci',
          ),
        ],
      ),
    );
  }

  Widget _buildPositionSection(TemplateElement element, TemplateEditorProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Posisi'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _xController,
                decoration: _inputDecoration('X'),
                keyboardType: TextInputType.number,
                onSubmitted: (v) {
                  final parsed = double.tryParse(v);
                  if (parsed != null) {
                    provider.updateElementPosition(element.id, parsed, element.y);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _yController,
                decoration: _inputDecoration('Y'),
                keyboardType: TextInputType.number,
                onSubmitted: (v) {
                  final parsed = double.tryParse(v);
                  if (parsed != null) {
                    provider.updateElementPosition(element.id, element.x, parsed);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeSection(TemplateElement element, TemplateEditorProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Saiz'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _widthController,
                decoration: _inputDecoration('Lebar'),
                keyboardType: TextInputType.number,
                onSubmitted: (v) {
                  final parsed = double.tryParse(v);
                  if (parsed != null) {
                    provider.updateElementSize(element.id, parsed, element.height);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _heightController,
                decoration: _inputDecoration('Tinggi'),
                keyboardType: TextInputType.number,
                onSubmitted: (v) {
                  final parsed = double.tryParse(v);
                  if (parsed != null) {
                    provider.updateElementSize(element.id, element.width, parsed);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildTypeSpecificProperties(TemplateElement element, TemplateEditorProvider provider) {
    switch (element.type) {
      case ElementType.text:
        return _buildTextProperties(element, provider);
      case ElementType.shape:
        return _buildShapeProperties(element, provider);
      case ElementType.line:
        return _buildLineProperties(element, provider);
      case ElementType.signature:
        return _buildSignatureProperties(element, provider);
      case ElementType.qrCode:
        return _buildQrProperties(element, provider);
      default:
        return [];
    }
  }

  List<Widget> _buildTextProperties(TemplateElement element, TemplateEditorProvider provider) {
    final props = element.properties;
    return [
      _buildSectionHeader('Teks'),
      const SizedBox(height: 8),
      TextField(
        controller: _textController,
        decoration: _inputDecoration('Teks'),
        maxLines: 2,
        onChanged: (v) => provider.updateElementProperty(element.id, 'text', v),
      ),
      const SizedBox(height: 12),
      
      DropdownButtonFormField<String?>(
        value: props['variable'] as String?,
        decoration: _inputDecoration('Variable'),
        isExpanded: true,
        items: [
          const DropdownMenuItem(value: null, child: Text('Tiada')),
          ...TemplateElement.textVariables.entries.map((e) => 
            DropdownMenuItem(value: e.key, child: Text('${e.key}', overflow: TextOverflow.ellipsis)),
          ),
        ],
        onChanged: (v) {
          provider.updateElementProperty(element.id, 'variable', v);
          if (v != null) {
            provider.updateElementProperty(element.id, 'text', v);
            _textController.text = v;
          }
        },
      ),
      const SizedBox(height: 12),

      TextField(
        controller: _fontSizeController,
        decoration: _inputDecoration('Saiz Font'),
        keyboardType: TextInputType.number,
        onSubmitted: (v) {
          final parsed = double.tryParse(v);
          if (parsed != null) {
            provider.updateElementProperty(element.id, 'fontSize', parsed);
          }
        },
      ),
      const SizedBox(height: 12),

      Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              icon: Icons.format_bold_rounded,
              isActive: props['fontWeight'] == 'bold',
              onPressed: () => provider.updateElementProperty(
                element.id, 'fontWeight', props['fontWeight'] == 'bold' ? 'normal' : 'bold',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildToggleButton(
              icon: Icons.format_italic_rounded,
              isActive: props['fontStyle'] == 'italic',
              onPressed: () => provider.updateElementProperty(
                element.id, 'fontStyle', props['fontStyle'] == 'italic' ? 'normal' : 'italic',
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),

      Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              icon: Icons.format_align_left_rounded,
              isActive: props['textAlign'] == 'left',
              onPressed: () => provider.updateElementProperty(element.id, 'textAlign', 'left'),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildToggleButton(
              icon: Icons.format_align_center_rounded,
              isActive: props['textAlign'] == 'center' || props['textAlign'] == null,
              onPressed: () => provider.updateElementProperty(element.id, 'textAlign', 'center'),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildToggleButton(
              icon: Icons.format_align_right_rounded,
              isActive: props['textAlign'] == 'right',
              onPressed: () => provider.updateElementProperty(element.id, 'textAlign', 'right'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),

      Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _parseColor(_colorController.text),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _colorController,
              decoration: _inputDecoration('Warna'),
              onChanged: (v) {
                provider.updateElementProperty(element.id, 'color', v);
                setState(() {});
              },
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildShapeProperties(TemplateElement element, TemplateEditorProvider provider) {
    final props = element.properties;
    return [
      _buildSectionHeader('Bentuk'),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: props['shapeType'] as String? ?? 'rectangle',
        decoration: _inputDecoration('Jenis'),
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: 'rectangle', child: Text('Segi Empat')),
          DropdownMenuItem(value: 'roundedRect', child: Text('Bulat')),
          DropdownMenuItem(value: 'circle', child: Text('Bulatan')),
        ],
        onChanged: (v) => provider.updateElementProperty(element.id, 'shapeType', v),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _parseColor(_fillColorController.text),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _fillColorController,
              decoration: _inputDecoration('Warna Isi'),
              onChanged: (v) {
                provider.updateElementProperty(element.id, 'fillColor', v);
                setState(() {});
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _parseColor(_strokeColorController.text),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _strokeColorController,
              decoration: _inputDecoration('Warna Garisan'),
              onChanged: (v) {
                provider.updateElementProperty(element.id, 'strokeColor', v);
                setState(() {});
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _strokeWidthController,
        decoration: _inputDecoration('Tebal Garisan'),
        keyboardType: TextInputType.number,
        onSubmitted: (v) {
          final parsed = double.tryParse(v);
          if (parsed != null) {
            provider.updateElementProperty(element.id, 'strokeWidth', parsed);
          }
        },
      ),
    ];
  }

  List<Widget> _buildLineProperties(TemplateElement element, TemplateEditorProvider provider) {
    return [
      _buildSectionHeader('Garisan'),
      const SizedBox(height: 8),
      Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _parseColor(_colorController.text),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _colorController,
              decoration: _inputDecoration('Warna'),
              onChanged: (v) {
                provider.updateElementProperty(element.id, 'color', v);
                setState(() {});
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _strokeWidthController,
        decoration: _inputDecoration('Tebal'),
        keyboardType: TextInputType.number,
        onSubmitted: (v) {
          final parsed = double.tryParse(v);
          if (parsed != null) {
            provider.updateElementProperty(element.id, 'strokeWidth', parsed);
          }
        },
      ),
    ];
  }

  List<Widget> _buildSignatureProperties(TemplateElement element, TemplateEditorProvider provider) {
    final props = element.properties;
    return [
      _buildSectionHeader('Tandatangan'),
      const SizedBox(height: 8),
      DropdownButtonFormField<int>(
        value: props['signatoryIndex'] as int? ?? 1,
        decoration: _inputDecoration('Penandatangan'),
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: 1, child: Text('Penandatangan 1')),
          DropdownMenuItem(value: 2, child: Text('Penandatangan 2')),
          DropdownMenuItem(value: 3, child: Text('Penandatangan 3')),
        ],
        onChanged: (v) => provider.updateElementProperty(element.id, 'signatoryIndex', v),
      ),
      const SizedBox(height: 12),
      _buildCheckbox(
        label: 'Papar Nama',
        value: props['showName'] as bool? ?? true,
        onChanged: (v) => provider.updateElementProperty(element.id, 'showName', v),
      ),
      _buildCheckbox(
        label: 'Papar Jawatan',
        value: props['showTitle'] as bool? ?? true,
        onChanged: (v) => provider.updateElementProperty(element.id, 'showTitle', v),
      ),
      _buildCheckbox(
        label: 'Papar Garisan',
        value: props['showLine'] as bool? ?? true,
        onChanged: (v) => provider.updateElementProperty(element.id, 'showLine', v),
      ),
    ];
  }

  List<Widget> _buildQrProperties(TemplateElement element, TemplateEditorProvider provider) {
    final props = element.properties;
    return [
      _buildSectionHeader('Kod QR'),
      const SizedBox(height: 8),
      _buildCheckbox(
        label: 'Papar Label',
        value: props['showLabel'] as bool? ?? true,
        onChanged: (v) => provider.updateElementProperty(element.id, 'showLabel', v),
      ),
      if (props['showLabel'] == true) ...[
        const SizedBox(height: 8),
        TextField(
          controller: _labelTextController,
          decoration: _inputDecoration('Teks Label'),
          onChanged: (v) => provider.updateElementProperty(element.id, 'labelText', v),
        ),
      ],
    ];
  }

  Widget _buildActionsSection(TemplateElement element, TemplateEditorProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Tindakan'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Duplikat'),
                onPressed: () => provider.duplicateElement(element.id),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_rounded, size: 16),
                label: const Text('Padam'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                onPressed: () => provider.deleteElement(element.id),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.flip_to_front_rounded, size: 16),
                label: const Text('Ke Depan'),
                onPressed: () => provider.bringToFront(element.id),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.flip_to_back_rounded, size: 16),
                label: const Text('Ke Belakang'),
                onPressed: () => provider.sendToBack(element.id),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: AppStyles.caption.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: AppStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: AppColors.border),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.black;
    }
  }

  IconData _getElementIcon(ElementType type) {
    switch (type) {
      case ElementType.text:
        return Icons.text_fields_rounded;
      case ElementType.image:
        return Icons.photo_rounded;
      case ElementType.logo:
        return Icons.image_rounded;
      case ElementType.signature:
        return Icons.draw_rounded;
      case ElementType.qrCode:
        return Icons.qr_code_rounded;
      case ElementType.shape:
        return Icons.rectangle_outlined;
      case ElementType.line:
        return Icons.horizontal_rule_rounded;
    }
  }

  String _getElementTypeName(ElementType type) {
    switch (type) {
      case ElementType.text:
        return 'Teks';
      case ElementType.image:
        return 'Gambar';
      case ElementType.logo:
        return 'Logo';
      case ElementType.signature:
        return 'Tandatangan';
      case ElementType.qrCode:
        return 'Kod QR';
      case ElementType.shape:
        return 'Bentuk';
      case ElementType.line:
        return 'Garisan';
    }
  }
}
