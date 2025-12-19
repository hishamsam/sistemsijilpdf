import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../widgets/app_button.dart';
import '../models/custom_template.dart';
import '../models/template_element.dart';
import '../providers/template_editor_provider.dart';
import '../widgets/editor_canvas.dart';
import '../widgets/element_toolbox.dart';
import '../widgets/properties_panel.dart';

class TemplateEditorScreen extends StatelessWidget {
  final CustomTemplate? template;

  const TemplateEditorScreen({super.key, this.template});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = TemplateEditorProvider();
        provider.initTemplate(existingTemplate: template);
        return provider;
      },
      child: const _TemplateEditorContent(),
    );
  }
}

class _TemplateEditorContent extends StatefulWidget {
  const _TemplateEditorContent();

  @override
  State<_TemplateEditorContent> createState() => _TemplateEditorContentState();
}

class _TemplateEditorContentState extends State<_TemplateEditorContent> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _canvasFocus = FocusNode();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final provider = context.read<TemplateEditorProvider>();
      _nameController.text = provider.template.name;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _canvasFocus.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final provider = context.read<TemplateEditorProvider>();

    // Delete selected elements
    if (event.logicalKey == LogicalKeyboardKey.delete ||
        event.logicalKey == LogicalKeyboardKey.backspace) {
      provider.deleteSelectedElements();
    }

    // Ctrl+Z - Undo, Ctrl+Shift+Z - Redo
    if (HardwareKeyboard.instance.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyZ) {
      if (HardwareKeyboard.instance.isShiftPressed) {
        provider.redo();
      } else {
        provider.undo();
      }
    }

    // Ctrl+Y - Redo
    if (HardwareKeyboard.instance.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyY) {
      provider.redo();
    }

    // Ctrl+A - Select All
    if (HardwareKeyboard.instance.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyA) {
      provider.selectAll();
    }

    // Ctrl+D - Duplicate
    if (HardwareKeyboard.instance.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyD) {
      if (provider.selectedElementId != null) {
        provider.duplicateElement(provider.selectedElementId!);
      }
    }

    // Ctrl+S - Save
    if (HardwareKeyboard.instance.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.keyS) {
      _saveTemplate();
    }

    // Escape - Clear selection
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      provider.clearSelection();
    }

    // Arrow keys - Move selected elements
    final step = HardwareKeyboard.instance.isShiftPressed ? 10.0 : 1.0;
    
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      provider.moveSelectedElementsBy(0, -step);
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      provider.moveSelectedElementsBy(0, step);
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      provider.moveSelectedElementsBy(-step, 0);
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      provider.moveSelectedElementsBy(step, 0);
    }
  }

  Future<void> _saveTemplate() async {
    final provider = context.read<TemplateEditorProvider>();
    provider.updateTemplateName(_nameController.text.trim());
    
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sila masukkan nama template'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      await provider.saveTemplate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template berjaya disimpan'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    final provider = context.read<TemplateEditorProvider>();
    if (!provider.isDirty) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Perubahan Belum Disimpan'),
        content: const Text('Adakah anda ingin simpan perubahan sebelum keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Buang'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveTemplate();
              if (mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          Navigator.pop(context, true);
        }
      },
      child: Consumer<TemplateEditorProvider>(
        builder: (context, provider, _) {
          return KeyboardListener(
            focusNode: _canvasFocus,
            autofocus: true,
            onKeyEvent: _handleKeyEvent,
            child: Scaffold(
              backgroundColor: AppColors.background,
              body: GestureDetector(
                onTap: () => _canvasFocus.requestFocus(),
                behavior: HitTestBehavior.translucent,
                child: Column(
                  children: [
                    _buildToolbar(provider),
                    Expanded(
                      child: Row(
                        children: [
                          const ElementToolbox(),
                          Expanded(
                            child: GestureDetector(
                              onTapDown: (_) => _canvasFocus.requestFocus(),
                              child: EditorCanvas(),
                            ),
                          ),
                          const PropertiesPanel(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolbar(TemplateEditorProvider provider) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) {
                Navigator.pop(context, true);
              }
            },
            tooltip: 'Kembali',
          ),
          const SizedBox(width: 16),
          
          SizedBox(
            width: 200,
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Nama Template',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
              onChanged: (value) => provider.updateTemplateName(value),
            ),
          ),
          
          const Spacer(),
          
          // Undo/Redo
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            onPressed: provider.canUndo ? () => provider.undo() : null,
            tooltip: 'Undo (Ctrl+Z)',
          ),
          IconButton(
            icon: const Icon(Icons.redo_rounded),
            onPressed: provider.canRedo ? () => provider.redo() : null,
            tooltip: 'Redo (Ctrl+Y)',
          ),
          
          const SizedBox(width: 8),
          const VerticalDivider(width: 24),
          const SizedBox(width: 8),
          
          // Background image button
          _buildBackgroundButton(provider),
          
          const SizedBox(width: 8),
          const VerticalDivider(width: 24),
          const SizedBox(width: 8),
          
          // Zoom controls
          IconButton(
            icon: const Icon(Icons.zoom_out_rounded),
            onPressed: () => provider.setZoom(provider.zoom - 0.1),
            tooltip: 'Zoom Out',
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${(provider.zoom * 100).toInt()}%',
              style: AppStyles.labelMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in_rounded),
            onPressed: () => provider.setZoom(provider.zoom + 0.1),
            tooltip: 'Zoom In',
          ),
          
          const SizedBox(width: 8),
          const VerticalDivider(width: 24),
          const SizedBox(width: 8),
          
          AppButton(
            text: 'Simpan',
            onPressed: _saveTemplate,
            icon: Icons.save_rounded,
            width: 120,
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundButton(TemplateEditorProvider provider) {
    final hasBackground = provider.template.backgroundImage != null;
    
    return PopupMenuButton<String>(
      tooltip: 'Latar Belakang',
      offset: const Offset(0, 40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: hasBackground ? AppColors.primary.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: hasBackground ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wallpaper_rounded,
              size: 18,
              color: hasBackground ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              'Latar Belakang',
              style: TextStyle(
                fontSize: 13,
                color: hasBackground ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: hasBackground ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'upload',
          child: Row(
            children: [
              const Icon(Icons.upload_rounded, size: 18),
              const SizedBox(width: 8),
              Text(hasBackground ? 'Tukar Gambar' : 'Muat Naik Gambar'),
            ],
          ),
        ),
        if (hasBackground) ...[
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'fit_cover',
            child: Row(
              children: [
                Icon(
                  Icons.fit_screen_rounded,
                  size: 18,
                  color: provider.template.backgroundFit == 'cover' ? AppColors.primary : null,
                ),
                const SizedBox(width: 8),
                const Text('Cover (Auto-fit)'),
                if (provider.template.backgroundFit == 'cover')
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.check, size: 16, color: AppColors.primary),
                  ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'fit_contain',
            child: Row(
              children: [
                Icon(
                  Icons.aspect_ratio_rounded,
                  size: 18,
                  color: provider.template.backgroundFit == 'contain' ? AppColors.primary : null,
                ),
                const SizedBox(width: 8),
                const Text('Contain'),
                if (provider.template.backgroundFit == 'contain')
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.check, size: 16, color: AppColors.primary),
                  ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'fit_fill',
            child: Row(
              children: [
                Icon(
                  Icons.fullscreen_rounded,
                  size: 18,
                  color: provider.template.backgroundFit == 'fill' ? AppColors.primary : null,
                ),
                const SizedBox(width: 8),
                const Text('Stretch'),
                if (provider.template.backgroundFit == 'fill')
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.check, size: 16, color: AppColors.primary),
                  ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                SizedBox(width: 8),
                Text('Buang Latar Belakang', style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
        ],
      ],
      onSelected: (value) async {
        switch (value) {
          case 'upload':
            await _uploadBackgroundImage(provider);
            break;
          case 'fit_cover':
            provider.updateBackgroundFit('cover');
            break;
          case 'fit_contain':
            provider.updateBackgroundFit('contain');
            break;
          case 'fit_fill':
            provider.updateBackgroundFit('fill');
            break;
          case 'remove':
            provider.removeBackgroundImage();
            break;
        }
      },
    );
  }

  Future<void> _uploadBackgroundImage(TemplateEditorProvider provider) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        provider.updateBackgroundImage(filePath);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gambar latar belakang berjaya dimuat naik'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }
}
