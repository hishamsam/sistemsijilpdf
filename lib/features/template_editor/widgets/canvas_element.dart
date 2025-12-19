import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../models/template_element.dart';

class CanvasElement extends StatefulWidget {
  final TemplateElement element;
  final bool isSelected;
  final bool isMultiSelected;
  final Function(bool addToSelection) onSelect;
  final VoidCallback onDragStart;
  final Function(double dx, double dy) onDragUpdate;
  final Function(double dx, double dy) onMultiDragUpdate;
  final Function(double x, double y, double w, double h) onResizeUpdate;
  final VoidCallback? onDragEnd;

  const CanvasElement({
    super.key,
    required this.element,
    required this.isSelected,
    this.isMultiSelected = false,
    required this.onSelect,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onMultiDragUpdate,
    required this.onResizeUpdate,
    this.onDragEnd,
  });

  @override
  State<CanvasElement> createState() => _CanvasElementState();
}

class _CanvasElementState extends State<CanvasElement> {
  String? _activeHandle;

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final element = widget.element;

    return Positioned(
      left: element.x,
      top: element.y,
      child: GestureDetector(
        onTap: () {
          final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
          widget.onSelect(isShiftPressed);
        },
        onPanStart: (_) {
          final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
          widget.onSelect(isShiftPressed);
          widget.onDragStart();
        },
        onPanUpdate: (details) {
          if (!element.isLocked) {
            if (widget.isMultiSelected) {
              widget.onMultiDragUpdate(details.delta.dx, details.delta.dy);
            } else {
              widget.onDragUpdate(details.delta.dx, details.delta.dy);
            }
          }
        },
        onPanEnd: (_) {
          widget.onDragEnd?.call();
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Element content
            Transform.rotate(
              angle: element.rotation * 3.14159 / 180,
              child: Container(
                width: element.width,
                height: element.height,
                decoration: widget.isSelected
                    ? BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      )
                    : null,
                child: _buildElementContent(),
              ),
            ),

            // Resize handles (only when selected)
            if (widget.isSelected && !element.isLocked) ...[
              // Corner handles
              _buildHandle('tl', -5, -5, () => _startResize('tl')),
              _buildHandle('tr', element.width - 5, -5, () => _startResize('tr')),
              _buildHandle('bl', -5, element.height - 5, () => _startResize('bl')),
              _buildHandle('br', element.width - 5, element.height - 5, () => _startResize('br')),
              // Edge handles (top, bottom, left, right)
              _buildHandle('tc', element.width / 2 - 5, -5, () => _startResize('tc')),
              _buildHandle('bc', element.width / 2 - 5, element.height - 5, () => _startResize('bc')),
              _buildHandle('lc', -5, element.height / 2 - 5, () => _startResize('lc')),
              _buildHandle('rc', element.width - 5, element.height / 2 - 5, () => _startResize('rc')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(String id, double left, double top, VoidCallback onStart) {
    return Positioned(
      left: left,
      top: top,
      child: MouseRegion(
        cursor: _getCursorForHandle(id),
        child: GestureDetector(
          onPanStart: (_) {
            _activeHandle = id;
            widget.onDragStart();
          },
          onPanUpdate: (details) {
            _handleResize(details.delta.dx, details.delta.dy);
          },
          onPanEnd: (_) {
            _activeHandle = null;
            widget.onDragEnd?.call();
          },
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  MouseCursor _getCursorForHandle(String id) {
    switch (id) {
      case 'tl':
      case 'br':
        return SystemMouseCursors.resizeUpLeftDownRight;
      case 'tr':
      case 'bl':
        return SystemMouseCursors.resizeUpRightDownLeft;
      case 'tc':
      case 'bc':
        return SystemMouseCursors.resizeUpDown;
      case 'lc':
      case 'rc':
        return SystemMouseCursors.resizeLeftRight;
      default:
        return SystemMouseCursors.basic;
    }
  }

  void _startResize(String handle) {
    _activeHandle = handle;
  }

  void _handleResize(double dx, double dy) {
    if (_activeHandle == null) return;

    final element = widget.element;
    double newX = element.x;
    double newY = element.y;
    double newW = element.width;
    double newH = element.height;

    switch (_activeHandle) {
      case 'tl':
        newX += dx;
        newY += dy;
        newW -= dx;
        newH -= dy;
        break;
      case 'tr':
        newY += dy;
        newW += dx;
        newH -= dy;
        break;
      case 'bl':
        newX += dx;
        newW -= dx;
        newH += dy;
        break;
      case 'br':
        newW += dx;
        newH += dy;
        break;
      case 'tc':
        newY += dy;
        newH -= dy;
        break;
      case 'bc':
        newH += dy;
        break;
      case 'lc':
        newX += dx;
        newW -= dx;
        break;
      case 'rc':
        newW += dx;
        break;
    }

    // Minimum size
    if (newW >= 20 && newH >= 20) {
      widget.onResizeUpdate(newX, newY, newW, newH);
    }
  }

  Widget _buildElementContent() {
    final element = widget.element;
    final props = element.properties;

    switch (element.type) {
      case ElementType.text:
        return Container(
          alignment: _getTextAlignment(props['textAlign'] as String? ?? 'center'),
          child: Text(
            props['text'] as String? ?? 'Teks',
            style: TextStyle(
              fontSize: (props['fontSize'] as num?)?.toDouble() ?? 16,
              fontWeight: props['fontWeight'] == 'bold' ? FontWeight.bold : FontWeight.normal,
              fontStyle: props['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
              color: _parseColor(props['color'] as String? ?? '#000000'),
              letterSpacing: (props['letterSpacing'] as num?)?.toDouble() ?? 0,
            ),
            textAlign: _getTextAlignValue(props['textAlign'] as String? ?? 'center'),
          ),
        );

      case ElementType.logo:
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: const Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.image_rounded, size: 32, color: Colors.grey),
              ),
            ),
          ),
        );

      case ElementType.image:
        final imagePath = props['imagePath'] as String?;
        if (imagePath != null) {
          return Image.asset(imagePath, fit: BoxFit.contain);
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: const Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.photo_rounded, size: 32, color: Colors.grey),
              ),
            ),
          ),
        );

      case ElementType.signature:
        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: _parseColor(props['lineColor'] as String? ?? '#000000'))),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.draw_rounded, size: 24, color: Colors.grey),
                  Text(
                    'Tandatangan ${props['signatoryIndex'] ?? 1}',
                    style: TextStyle(
                      fontSize: 9,
                      color: _parseColor(props['nameColor'] as String? ?? '#000000'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case ElementType.qrCode:
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.qr_code_rounded, size: 40),
              ),
            ),
          ),
        );

      case ElementType.shape:
        final shapeType = props['shapeType'] as String? ?? 'rectangle';
        final fillColor = _parseColor(props['fillColor'] as String? ?? '#FFFFFF');
        final strokeColor = _parseColor(props['strokeColor'] as String? ?? '#000000');
        final strokeWidth = (props['strokeWidth'] as num?)?.toDouble() ?? 1;
        final cornerRadius = (props['cornerRadius'] as num?)?.toDouble() ?? 0;

        if (shapeType == 'circle') {
          return Container(
            decoration: BoxDecoration(
              color: fillColor,
              shape: BoxShape.circle,
              border: Border.all(color: strokeColor, width: strokeWidth),
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(cornerRadius),
            border: Border.all(color: strokeColor, width: strokeWidth),
          ),
        );

      case ElementType.line:
        final color = _parseColor(props['color'] as String? ?? '#000000');
        final strokeWidth = (props['strokeWidth'] as num?)?.toDouble() ?? 2;
        return Center(
          child: Container(
            height: strokeWidth,
            color: color,
          ),
        );
    }
  }

  Alignment _getTextAlignment(String align) {
    switch (align) {
      case 'left':
        return Alignment.centerLeft;
      case 'right':
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }

  TextAlign _getTextAlignValue(String align) {
    switch (align) {
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.center;
    }
  }
}
