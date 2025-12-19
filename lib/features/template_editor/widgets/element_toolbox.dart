import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../models/template_element.dart';
import '../providers/template_editor_provider.dart';

class ElementToolbox extends StatelessWidget {
  const ElementToolbox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Icon(Icons.widgets_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Elemen', style: AppStyles.labelLarge),
              ],
            ),
          ),
          
          // Elements list
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Teks'),
                  const SizedBox(height: 8),
                  _buildElementItem(
                    context,
                    ElementType.text,
                    Icons.text_fields_rounded,
                    'Teks',
                    'Tambah teks biasa atau variable',
                  ),
                  
                  const SizedBox(height: 16),
                  _buildSectionHeader('Media'),
                  const SizedBox(height: 8),
                  _buildElementItem(
                    context,
                    ElementType.logo,
                    Icons.image_rounded,
                    'Logo',
                    'Logo penganjur',
                  ),
                  const SizedBox(height: 8),
                  _buildElementItem(
                    context,
                    ElementType.image,
                    Icons.photo_rounded,
                    'Gambar',
                    'Upload gambar custom',
                  ),
                  const SizedBox(height: 8),
                  _buildElementItem(
                    context,
                    ElementType.signature,
                    Icons.draw_rounded,
                    'Tandatangan',
                    'Ruangan tandatangan',
                  ),
                  const SizedBox(height: 8),
                  _buildElementItem(
                    context,
                    ElementType.qrCode,
                    Icons.qr_code_rounded,
                    'Kod QR',
                    'Kod pengesahan',
                  ),
                  
                  const SizedBox(height: 16),
                  _buildSectionHeader('Bentuk'),
                  const SizedBox(height: 8),
                  _buildElementItem(
                    context,
                    ElementType.shape,
                    Icons.rectangle_outlined,
                    'Bentuk',
                    'Segi empat, bulat, dll',
                  ),
                  const SizedBox(height: 8),
                  _buildElementItem(
                    context,
                    ElementType.line,
                    Icons.horizontal_rule_rounded,
                    'Garisan',
                    'Garisan hiasan',
                  ),
                  
                  const SizedBox(height: 16),
                  _buildSectionHeader('Variable Teks'),
                  const SizedBox(height: 8),
                  ...TemplateElement.textVariables.entries.map((e) => 
                    _buildVariableItem(context, e.key, e.value),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildElementItem(
    BuildContext context,
    ElementType type,
    IconData icon,
    String label,
    String description,
  ) {
    return Draggable<ElementType>(
      data: type,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildElementCard(icon, label, description),
      ),
      child: GestureDetector(
        onTap: () {
          context.read<TemplateEditorProvider>().addElement(type);
        },
        child: _buildElementCard(icon, label, description),
      ),
    );
  }

  Widget _buildElementCard(IconData icon, String label, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppStyles.labelMedium),
                Text(
                  description,
                  style: AppStyles.caption.copyWith(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariableItem(BuildContext context, String variable, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () {
          final provider = context.read<TemplateEditorProvider>();
          provider.addElement(ElementType.text);
          // Update the newly added element with variable
          if (provider.selectedElementId != null) {
            provider.updateElementProperty(provider.selectedElementId!, 'text', variable);
            provider.updateElementProperty(provider.selectedElementId!, 'variable', variable);
          }
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Text(
                variable,
                style: AppStyles.caption.copyWith(
                  fontFamily: 'monospace',
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  description,
                  style: AppStyles.caption.copyWith(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
