import 'dart:convert';

enum ElementType {
  text,
  image,
  logo,
  signature,
  qrCode,
  shape,
  line,
}

enum ShapeType {
  rectangle,
  circle,
  roundedRect,
}

class TemplateElement {
  final String id;
  final ElementType type;
  double x;
  double y;
  double width;
  double height;
  double rotation;
  int zIndex;
  bool isLocked;
  Map<String, dynamic> properties;

  TemplateElement({
    required this.id,
    required this.type,
    this.x = 0,
    this.y = 0,
    this.width = 100,
    this.height = 50,
    this.rotation = 0,
    this.zIndex = 0,
    this.isLocked = false,
    Map<String, dynamic>? properties,
  }) : properties = properties ?? _defaultProperties(type);

  static Map<String, dynamic> _defaultProperties(ElementType type) {
    switch (type) {
      case ElementType.text:
        return {
          'text': 'Teks Baru',
          'variable': null, // {nama}, {tarikh}, {program}, etc
          'fontSize': 16.0,
          'fontFamily': 'Roboto',
          'fontWeight': 'normal', // normal, bold
          'fontStyle': 'normal', // normal, italic
          'color': '#000000',
          'textAlign': 'center',
          'letterSpacing': 0.0,
        };
      case ElementType.image:
        return {
          'imagePath': null,
          'fit': 'contain', // contain, cover, fill
          'opacity': 1.0,
        };
      case ElementType.logo:
        return {
          'useProgram': true, // Use logo from program
          'imagePath': null,
          'fit': 'contain',
          'opacity': 1.0,
        };
      case ElementType.signature:
        return {
          'signatoryIndex': 1, // 1, 2, or 3
          'showName': true,
          'showTitle': true,
          'showLine': true,
          'nameColor': '#000000',
          'lineColor': '#000000',
        };
      case ElementType.qrCode:
        return {
          'size': 80.0,
          'showLabel': true,
          'labelText': 'Imbas untuk pengesahan',
        };
      case ElementType.shape:
        return {
          'shapeType': 'rectangle',
          'fillColor': '#FFFFFF',
          'strokeColor': '#000000',
          'strokeWidth': 1.0,
          'cornerRadius': 0.0,
          'opacity': 1.0,
        };
      case ElementType.line:
        return {
          'color': '#000000',
          'strokeWidth': 2.0,
          'style': 'solid', // solid, dashed
        };
    }
  }

  TemplateElement copyWith({
    String? id,
    ElementType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    int? zIndex,
    bool? isLocked,
    Map<String, dynamic>? properties,
  }) {
    return TemplateElement(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
      isLocked: isLocked ?? this.isLocked,
      properties: properties ?? Map<String, dynamic>.from(this.properties),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotation': rotation,
      'zIndex': zIndex,
      'isLocked': isLocked,
      'properties': properties,
    };
  }

  factory TemplateElement.fromMap(Map<String, dynamic> map) {
    return TemplateElement(
      id: map['id'] as String,
      type: ElementType.values.firstWhere((e) => e.name == map['type']),
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      rotation: (map['rotation'] as num?)?.toDouble() ?? 0,
      zIndex: map['zIndex'] as int? ?? 0,
      isLocked: map['isLocked'] as bool? ?? false,
      properties: Map<String, dynamic>.from(map['properties'] as Map),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory TemplateElement.fromJson(String json) =>
      TemplateElement.fromMap(jsonDecode(json) as Map<String, dynamic>);

  // Variable placeholders for text
  static const Map<String, String> textVariables = {
    '{nama}': 'Nama Peserta',
    '{no_kp}': 'No. Kad Pengenalan',
    '{program}': 'Nama Program',
    '{tarikh}': 'Tarikh',
    '{tarikh_luput}': 'Tarikh Luput',
    '{penganjur}': 'Nama Penganjur',
    '{no_sijil}': 'Nombor Sijil',
    '{tahun}': 'Tahun Program',
  };
}
