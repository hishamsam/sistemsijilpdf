import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/template_element.dart';
import '../models/custom_template.dart';
import '../repositories/custom_template_repository.dart';

class TemplateEditorProvider extends ChangeNotifier {
  final CustomTemplateRepository _repository = CustomTemplateRepository();
  final Uuid _uuid = const Uuid();

  CustomTemplate _template = CustomTemplate.starter();
  String? _selectedElementId;
  List<String> _selectedElementIds = [];
  double _zoom = 1.0;
  Offset _panOffset = Offset.zero;
  bool _isLoading = false;
  bool _isDirty = false;
  
  // Undo/Redo stacks
  final List<List<TemplateElement>> _undoStack = [];
  final List<List<TemplateElement>> _redoStack = [];
  static const int _maxUndoSteps = 50;

  // Getters
  CustomTemplate get template => _template;
  List<TemplateElement> get elements => _template.elements;
  String? get selectedElementId => _selectedElementId;
  List<String> get selectedElementIds => _selectedElementIds;
  TemplateElement? get selectedElement => _selectedElementId != null
      ? elements.firstWhere((e) => e.id == _selectedElementId, orElse: () => elements.first)
      : null;
  double get zoom => _zoom;
  Offset get panOffset => _panOffset;
  bool get isLoading => _isLoading;
  bool get isDirty => _isDirty;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  // Initialize with existing template or create new
  void initTemplate({CustomTemplate? existingTemplate}) {
    if (existingTemplate != null) {
      _template = existingTemplate;
    } else {
      _template = CustomTemplate.starter();
    }
    _selectedElementId = null;
    _selectedElementIds = [];
    _undoStack.clear();
    _redoStack.clear();
    _isDirty = false;
    notifyListeners();
  }

  // Save state for undo
  void _saveState() {
    _undoStack.add(List<TemplateElement>.from(
      elements.map((e) => e.copyWith()),
    ));
    if (_undoStack.length > _maxUndoSteps) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    _isDirty = true;
  }

  // Undo
  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(List<TemplateElement>.from(
      elements.map((e) => e.copyWith()),
    ));
    final previousState = _undoStack.removeLast();
    _template = _template.copyWith(elements: previousState);
    notifyListeners();
  }

  // Redo
  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(List<TemplateElement>.from(
      elements.map((e) => e.copyWith()),
    ));
    final nextState = _redoStack.removeLast();
    _template = _template.copyWith(elements: nextState);
    notifyListeners();
  }

  // Add element
  void addElement(ElementType type, {Offset? position}) {
    _saveState();
    final element = TemplateElement(
      id: _uuid.v4(),
      type: type,
      x: position?.dx ?? (_template.canvasWidth / 2 - 50),
      y: position?.dy ?? (_template.canvasHeight / 2 - 25),
      zIndex: elements.length,
    );
    _template.elements.add(element);
    _selectedElementId = element.id;
    _selectedElementIds = [element.id];
    notifyListeners();
  }

  // Select element
  void selectElement(String? id, {bool addToSelection = false}) {
    if (addToSelection && id != null) {
      if (_selectedElementIds.contains(id)) {
        _selectedElementIds.remove(id);
        if (_selectedElementIds.isEmpty) {
          _selectedElementId = null;
        } else {
          _selectedElementId = _selectedElementIds.last;
        }
      } else {
        _selectedElementIds.add(id);
        _selectedElementId = id;
      }
    } else {
      _selectedElementId = id;
      _selectedElementIds = id != null ? [id] : [];
    }
    notifyListeners();
  }

  // Clear selection
  void clearSelection() {
    _selectedElementId = null;
    _selectedElementIds = [];
    notifyListeners();
  }

  // Select all elements
  void selectAll() {
    _selectedElementIds = elements.map((e) => e.id).toList();
    if (_selectedElementIds.isNotEmpty) {
      _selectedElementId = _selectedElementIds.last;
    }
    notifyListeners();
  }

  // Update element position
  void updateElementPosition(String id, double x, double y) {
    final index = elements.indexWhere((e) => e.id == id);
    if (index == -1) return;
    elements[index].x = x;
    elements[index].y = y;
    notifyListeners();
  }

  // Move all selected elements by delta
  void moveSelectedElements(double dx, double dy) {
    if (_selectedElementIds.isEmpty) return;
    
    for (final id in _selectedElementIds) {
      final index = elements.indexWhere((e) => e.id == id);
      if (index != -1 && !elements[index].isLocked) {
        elements[index].x += dx;
        elements[index].y += dy;
      }
    }
    notifyListeners();
  }

  // Move selected elements with arrow keys (with step)
  void moveSelectedElementsBy(double dx, double dy, {bool saveState = true}) {
    if (_selectedElementIds.isEmpty) return;
    if (saveState) _saveState();
    
    for (final id in _selectedElementIds) {
      final index = elements.indexWhere((e) => e.id == id);
      if (index != -1 && !elements[index].isLocked) {
        elements[index].x = (elements[index].x + dx).clamp(0, _template.canvasWidth - elements[index].width);
        elements[index].y = (elements[index].y + dy).clamp(0, _template.canvasHeight - elements[index].height);
      }
    }
    notifyListeners();
  }

  // Update element size
  void updateElementSize(String id, double width, double height) {
    final index = elements.indexWhere((e) => e.id == id);
    if (index == -1) return;
    elements[index].width = width.clamp(20, _template.canvasWidth);
    elements[index].height = height.clamp(20, _template.canvasHeight);
    notifyListeners();
  }

  // Update element position and size (for resize handles)
  void updateElementBounds(String id, double x, double y, double width, double height) {
    final index = elements.indexWhere((e) => e.id == id);
    if (index == -1) return;
    elements[index].x = x;
    elements[index].y = y;
    elements[index].width = width.clamp(20, _template.canvasWidth);
    elements[index].height = height.clamp(20, _template.canvasHeight);
    notifyListeners();
  }

  // Start drag (save state)
  void startElementDrag(String id) {
    _saveState();
  }

  // Update element rotation
  void updateElementRotation(String id, double rotation) {
    _saveState();
    final index = elements.indexWhere((e) => e.id == id);
    if (index == -1) return;
    elements[index].rotation = rotation;
    notifyListeners();
  }

  // Update element property
  void updateElementProperty(String id, String key, dynamic value) {
    _saveState();
    final index = elements.indexWhere((e) => e.id == id);
    if (index == -1) return;
    elements[index].properties[key] = value;
    notifyListeners();
  }

  // Delete element
  void deleteElement(String id) {
    _saveState();
    _template.elements.removeWhere((e) => e.id == id);
    if (_selectedElementId == id) {
      _selectedElementId = null;
    }
    _selectedElementIds.remove(id);
    notifyListeners();
  }

  // Delete selected elements
  void deleteSelectedElements() {
    if (_selectedElementIds.isEmpty) return;
    _saveState();
    _template.elements.removeWhere((e) => _selectedElementIds.contains(e.id));
    _selectedElementId = null;
    _selectedElementIds = [];
    notifyListeners();
  }

  // Duplicate element
  void duplicateElement(String id) {
    final element = elements.firstWhere((e) => e.id == id, orElse: () => elements.first);
    _saveState();
    final newElement = element.copyWith(
      id: _uuid.v4(),
      x: element.x + 20,
      y: element.y + 20,
      zIndex: elements.length,
    );
    _template.elements.add(newElement);
    _selectedElementId = newElement.id;
    _selectedElementIds = [newElement.id];
    notifyListeners();
  }

  // Bring element to front
  void bringToFront(String id) {
    _saveState();
    final maxZ = elements.map((e) => e.zIndex).reduce((a, b) => a > b ? a : b);
    final index = elements.indexWhere((e) => e.id == id);
    if (index == -1) return;
    elements[index].zIndex = maxZ + 1;
    notifyListeners();
  }

  // Send element to back
  void sendToBack(String id) {
    _saveState();
    final minZ = elements.map((e) => e.zIndex).reduce((a, b) => a < b ? a : b);
    final index = elements.indexWhere((e) => e.id == id);
    if (index == -1) return;
    elements[index].zIndex = minZ - 1;
    notifyListeners();
  }

  // Zoom
  void setZoom(double value) {
    _zoom = value.clamp(0.25, 3.0);
    notifyListeners();
  }

  void zoomIn() => setZoom(_zoom + 0.1);
  void zoomOut() => setZoom(_zoom - 0.1);
  void resetZoom() {
    _zoom = 1.0;
    _panOffset = Offset.zero;
    notifyListeners();
  }

  // Pan
  void setPanOffset(Offset offset) {
    _panOffset = offset;
    notifyListeners();
  }

  // Update template name
  void updateTemplateName(String name) {
    _template = _template.copyWith(name: name);
    _isDirty = true;
    notifyListeners();
  }

  // Update background color
  void updateBackgroundColor(String color) {
    _saveState();
    _template = _template.copyWith(backgroundColor: color);
    notifyListeners();
  }

  // Update background image
  void updateBackgroundImage(String? imagePath) {
    _saveState();
    _template = _template.copyWith(backgroundImage: imagePath);
    _isDirty = true;
    notifyListeners();
  }

  // Update background fit
  void updateBackgroundFit(String fit) {
    _saveState();
    _template = _template.copyWith(backgroundFit: fit);
    _isDirty = true;
    notifyListeners();
  }

  // Update language
  void updateLanguage(String language) {
    _template = _template.copyWith(language: language);
    _isDirty = true;
    notifyListeners();
  }

  // Remove background image
  void removeBackgroundImage() {
    _saveState();
    _template = CustomTemplate(
      id: _template.id,
      name: _template.name,
      thumbnail: _template.thumbnail,
      elements: _template.elements,
      canvasWidth: _template.canvasWidth,
      canvasHeight: _template.canvasHeight,
      backgroundColor: _template.backgroundColor,
      backgroundImage: null,
      backgroundFit: _template.backgroundFit,
      language: _template.language,
      createdAt: _template.createdAt,
      updatedAt: _template.updatedAt,
    );
    _isDirty = true;
    notifyListeners();
  }

  // Save template
  Future<int> saveTemplate() async {
    _isLoading = true;
    notifyListeners();

    try {
      int id;
      if (_template.id != null) {
        await _repository.update(_template);
        id = _template.id!;
      } else {
        id = await _repository.insert(_template);
        _template = _template.copyWith(id: id);
      }
      _isDirty = false;
      return id;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load template
  Future<void> loadTemplate(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final template = await _repository.getById(id);
      if (template != null) {
        _template = template;
        _selectedElementId = null;
        _selectedElementIds = [];
        _undoStack.clear();
        _redoStack.clear();
        _isDirty = false;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get all templates
  Future<List<CustomTemplate>> getAllTemplates() async {
    return await _repository.getAll();
  }

  // Delete template
  Future<void> deleteTemplate(int id) async {
    await _repository.delete(id);
    notifyListeners();
  }

  // Lock/unlock element
  void toggleElementLock(String id) {
    final index = elements.indexWhere((e) => e.id == id);
    if (index == -1) return;
    elements[index].isLocked = !elements[index].isLocked;
    notifyListeners();
  }

  // Get sorted elements by z-index
  List<TemplateElement> get sortedElements {
    final sorted = List<TemplateElement>.from(elements);
    sorted.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return sorted;
  }
}
