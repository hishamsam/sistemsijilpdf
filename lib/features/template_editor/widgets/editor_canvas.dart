import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/template_element.dart';
import '../providers/template_editor_provider.dart';
import 'canvas_element.dart';

class EditorCanvas extends StatefulWidget {
  const EditorCanvas({super.key});

  @override
  State<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends State<EditorCanvas> {
  List<_AlignGuide> _guides = [];
  static const double _snapThreshold = 5.0;

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  void _updateGuides(TemplateEditorProvider provider, String elementId, double x, double y, double w, double h) {
    final template = provider.template;
    final elements = provider.sortedElements.where((e) => e.id != elementId).toList();
    
    List<_AlignGuide> newGuides = [];
    double snapX = x;
    double snapY = y;
    
    final centerX = x + w / 2;
    final centerY = y + h / 2;
    final right = x + w;
    final bottom = y + h;
    
    // Canvas center guides
    final canvasCenterX = template.canvasWidth / 2;
    final canvasCenterY = template.canvasHeight / 2;
    
    // Check canvas center alignment
    if ((centerX - canvasCenterX).abs() < _snapThreshold) {
      newGuides.add(_AlignGuide(x: canvasCenterX, isVertical: true, isCanvasCenter: true));
      snapX = canvasCenterX - w / 2;
    }
    if ((centerY - canvasCenterY).abs() < _snapThreshold) {
      newGuides.add(_AlignGuide(y: canvasCenterY, isVertical: false, isCanvasCenter: true));
      snapY = canvasCenterY - h / 2;
    }
    
    // Check canvas edge alignment
    if (x.abs() < _snapThreshold) {
      newGuides.add(_AlignGuide(x: 0, isVertical: true));
      snapX = 0;
    }
    if ((right - template.canvasWidth).abs() < _snapThreshold) {
      newGuides.add(_AlignGuide(x: template.canvasWidth, isVertical: true));
      snapX = template.canvasWidth - w;
    }
    if (y.abs() < _snapThreshold) {
      newGuides.add(_AlignGuide(y: 0, isVertical: false));
      snapY = 0;
    }
    if ((bottom - template.canvasHeight).abs() < _snapThreshold) {
      newGuides.add(_AlignGuide(y: template.canvasHeight, isVertical: false));
      snapY = template.canvasHeight - h;
    }
    
    // Check alignment with other elements
    for (final other in elements) {
      final otherCenterX = other.x + other.width / 2;
      final otherCenterY = other.y + other.height / 2;
      final otherRight = other.x + other.width;
      final otherBottom = other.y + other.height;
      
      // Left edge alignments
      if ((x - other.x).abs() < _snapThreshold) {
        newGuides.add(_AlignGuide(x: other.x, isVertical: true));
        snapX = other.x;
      }
      if ((x - otherRight).abs() < _snapThreshold) {
        newGuides.add(_AlignGuide(x: otherRight, isVertical: true));
        snapX = otherRight;
      }
      
      // Right edge alignments
      if ((right - other.x).abs() < _snapThreshold) {
        newGuides.add(_AlignGuide(x: other.x, isVertical: true));
        snapX = other.x - w;
      }
      if ((right - otherRight).abs() < _snapThreshold) {
        newGuides.add(_AlignGuide(x: otherRight, isVertical: true));
        snapX = otherRight - w;
      }
      
      // Center X alignment
      if ((centerX - otherCenterX).abs() < _snapThreshold) {
        newGuides.add(_AlignGuide(x: otherCenterX, isVertical: true));
        snapX = otherCenterX - w / 2;
      }
      
      // Top edge alignments
      if ((y - other.y).abs() < _snapThreshold) {
        newGuides.add(_AlignGuide(y: other.y, isVertical: false));
        snapY = other.y;
      }
      if ((y - otherBottom).abs() < _snapThreshold) {
        newGuides.add(_AlignGuide(y: otherBottom, isVertical: false));
        snapY = otherBottom;
      }
      
      // Bottom edge alignments
      if ((bottom - other.y).abs() < _snapThreshold) {
        newGuides.add(_AlignGuide(y: other.y, isVertical: false));
        snapY = other.y - h;
      }
      if ((bottom - otherBottom).abs() < _snapThreshold) {
        newGuides.add(_AlignGuide(y: otherBottom, isVertical: false));
        snapY = otherBottom - h;
      }
      
      // Center Y alignment
      if ((centerY - otherCenterY).abs() < _snapThreshold) {
        newGuides.add(_AlignGuide(y: otherCenterY, isVertical: false));
        snapY = otherCenterY - h / 2;
      }
    }
    
    setState(() => _guides = newGuides);
    
    // Apply snap
    if (snapX != x || snapY != y) {
      provider.updateElementPosition(elementId, snapX, snapY);
    }
  }

  void _clearGuides() {
    if (_guides.isNotEmpty) {
      setState(() => _guides = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateEditorProvider>(
      builder: (context, provider, _) {
        final template = provider.template;

        return Container(
          color: const Color(0xFFE5E5E5),
          child: DragTarget<ElementType>(
            onAcceptWithDetails: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPos = box.globalToLocal(details.offset);
              
              final canvasX = (localPos.dx - provider.panOffset.dx) / provider.zoom;
              final canvasY = (localPos.dy - provider.panOffset.dy) / provider.zoom;
              
              provider.addElement(details.data, position: Offset(canvasX - 50, canvasY - 25));
            },
            builder: (context, candidateData, rejectedData) {
              return GestureDetector(
                onTap: () => provider.clearSelection(),
                onPanUpdate: (details) {
                  if (provider.selectedElementId == null) {
                    provider.setPanOffset(provider.panOffset + details.delta);
                  }
                },
                child: ClipRect(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final canvasLeft = provider.panOffset.dx + (constraints.maxWidth - template.canvasWidth * provider.zoom) / 2;
                      final canvasTop = provider.panOffset.dy + 40;
                      
                      return Stack(
                        children: [
                          // Grid background
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _GridPainter(
                                zoom: provider.zoom,
                                offset: provider.panOffset,
                              ),
                            ),
                          ),
                          
                          // Canvas
                          Positioned(
                            left: canvasLeft,
                            top: canvasTop,
                            child: Transform.scale(
                              scale: provider.zoom,
                              alignment: Alignment.topLeft,
                              child: Container(
                                width: template.canvasWidth,
                                height: template.canvasHeight,
                                decoration: BoxDecoration(
                                  color: _parseColor(template.backgroundColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Background image
                                    if (template.backgroundImage != null)
                                      Positioned.fill(
                                        child: _buildBackgroundImage(template),
                                      ),
                                    
                                    // Alignment guides
                                    ..._guides.map((guide) => _buildGuide(guide, template)),
                                    
                                    // Elements
                                    ...provider.sortedElements.map((element) {
                                      final isSelected = provider.selectedElementIds.contains(element.id);
                                      final isMultiSelected = isSelected && provider.selectedElementIds.length > 1;
                                      
                                      return CanvasElement(
                                        key: ValueKey(element.id),
                                        element: element,
                                        isSelected: isSelected,
                                        isMultiSelected: isMultiSelected,
                                        onSelect: (addToSelection) => provider.selectElement(element.id, addToSelection: addToSelection),
                                        onDragStart: () {
                                          provider.startElementDrag(element.id);
                                        },
                                        onDragUpdate: (dx, dy) {
                                          final newX = element.x + dx / provider.zoom;
                                          final newY = element.y + dy / provider.zoom;
                                          _updateGuides(provider, element.id, newX, newY, element.width, element.height);
                                          provider.updateElementPosition(element.id, newX, newY);
                                        },
                                        onMultiDragUpdate: (dx, dy) {
                                          provider.moveSelectedElements(
                                            dx / provider.zoom,
                                            dy / provider.zoom,
                                          );
                                          _clearGuides();
                                        },
                                        onResizeUpdate: (x, y, w, h) {
                                          provider.updateElementBounds(element.id, x, y, w, h);
                                          _clearGuides();
                                        },
                                        onDragEnd: _clearGuides,
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Drop indicator
                          if (candidateData.isNotEmpty)
                            Positioned.fill(
                              child: Container(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Lepaskan di sini',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGuide(_AlignGuide guide, dynamic template) {
    final color = guide.isCanvasCenter ? Colors.blue : Colors.red;
    
    if (guide.isVertical) {
      return Positioned(
        left: guide.x,
        top: 0,
        bottom: 0,
        child: Container(
          width: 1,
          color: color.withValues(alpha: 0.8),
        ),
      );
    } else {
      return Positioned(
        left: 0,
        right: 0,
        top: guide.y,
        child: Container(
          height: 1,
          color: color.withValues(alpha: 0.8),
        ),
      );
    }
  }

  Widget _buildBackgroundImage(dynamic template) {
    final file = File(template.backgroundImage!);
    if (!file.existsSync()) return const SizedBox.shrink();

    BoxFit fit;
    switch (template.backgroundFit) {
      case 'contain':
        fit = BoxFit.contain;
        break;
      case 'fill':
        fit = BoxFit.fill;
        break;
      case 'stretch':
        fit = BoxFit.fill;
        break;
      case 'cover':
      default:
        fit = BoxFit.cover;
    }

    return Image.file(
      file,
      fit: fit,
      width: template.canvasWidth,
      height: template.canvasHeight,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey),
          ),
        );
      },
    );
  }
}

class _AlignGuide {
  final double? x;
  final double? y;
  final bool isVertical;
  final bool isCanvasCenter;

  _AlignGuide({
    this.x,
    this.y,
    required this.isVertical,
    this.isCanvasCenter = false,
  });
}

class _GridPainter extends CustomPainter {
  final double zoom;
  final Offset offset;

  _GridPainter({required this.zoom, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    const gridSize = 20.0;
    final scaledGridSize = gridSize * zoom;

    double x = offset.dx % scaledGridSize;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      x += scaledGridSize;
    }

    double y = offset.dy % scaledGridSize;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += scaledGridSize;
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) =>
      oldDelegate.zoom != zoom || oldDelegate.offset != offset;
}
