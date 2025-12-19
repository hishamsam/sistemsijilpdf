import 'dart:convert';
import 'template_element.dart';

class CustomTemplate {
  final int? id;
  final String name;
  final String? thumbnail;
  final List<TemplateElement> elements;
  final double canvasWidth;
  final double canvasHeight;
  final String backgroundColor;
  final String? backgroundImage; // Path to background image
  final String backgroundFit; // contain, cover, fill, stretch
  final String language; // 'malay', 'english', 'bilingual'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomTemplate({
    this.id,
    required this.name,
    this.thumbnail,
    List<TemplateElement>? elements,
    this.canvasWidth = 595, // A4 width in points (72 dpi)
    this.canvasHeight = 842, // A4 height in points
    this.backgroundColor = '#FFFFFF',
    this.backgroundImage,
    this.backgroundFit = 'cover',
    this.language = 'malay',
    this.createdAt,
    this.updatedAt,
  }) : elements = elements ?? [];

  CustomTemplate copyWith({
    int? id,
    String? name,
    String? thumbnail,
    List<TemplateElement>? elements,
    double? canvasWidth,
    double? canvasHeight,
    String? backgroundColor,
    String? backgroundImage,
    String? backgroundFit,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnail: thumbnail ?? this.thumbnail,
      elements: elements ?? List<TemplateElement>.from(this.elements),
      canvasWidth: canvasWidth ?? this.canvasWidth,
      canvasHeight: canvasHeight ?? this.canvasHeight,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      backgroundFit: backgroundFit ?? this.backgroundFit,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'thumbnail': thumbnail,
      'elements': jsonEncode(elements.map((e) => e.toMap()).toList()),
      'canvas_width': canvasWidth,
      'canvas_height': canvasHeight,
      'background_color': backgroundColor,
      'background_image': backgroundImage,
      'background_fit': backgroundFit,
      'language': language,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory CustomTemplate.fromMap(Map<String, dynamic> map) {
    List<TemplateElement> elementsList = [];
    if (map['elements'] != null) {
      final elementsJson = map['elements'] is String 
          ? jsonDecode(map['elements']) 
          : map['elements'];
      elementsList = (elementsJson as List)
          .map((e) => TemplateElement.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    return CustomTemplate(
      id: map['id'] as int?,
      name: map['name'] as String,
      thumbnail: map['thumbnail'] as String?,
      elements: elementsList,
      canvasWidth: (map['canvas_width'] as num?)?.toDouble() ?? 595,
      canvasHeight: (map['canvas_height'] as num?)?.toDouble() ?? 842,
      backgroundColor: map['background_color'] as String? ?? '#FFFFFF',
      backgroundImage: map['background_image'] as String?,
      backgroundFit: map['background_fit'] as String? ?? 'cover',
      language: map['language'] as String? ?? 'malay',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String) 
          : null,
    );
  }

  // Create a default starter template
  factory CustomTemplate.starter() {
    return CustomTemplate(
      name: 'Template Baru',
      elements: [
        // Logo placeholder
        TemplateElement(
          id: 'logo_1',
          type: ElementType.logo,
          x: 247.5,
          y: 40,
          width: 100,
          height: 100,
        ),
        // Title
        TemplateElement(
          id: 'title_1',
          type: ElementType.text,
          x: 97.5,
          y: 160,
          width: 400,
          height: 50,
          properties: {
            'text': 'SIJIL PENGHARGAAN',
            'variable': null,
            'fontSize': 32.0,
            'fontFamily': 'Roboto',
            'fontWeight': 'bold',
            'fontStyle': 'normal',
            'color': '#1A365D',
            'textAlign': 'center',
            'letterSpacing': 2.0,
          },
        ),
        // Certification text
        TemplateElement(
          id: 'cert_text_1',
          type: ElementType.text,
          x: 97.5,
          y: 230,
          width: 400,
          height: 30,
          properties: {
            'text': 'Dengan ini mengesahkan bahawa',
            'variable': null,
            'fontSize': 14.0,
            'fontFamily': 'Roboto',
            'fontWeight': 'normal',
            'fontStyle': 'normal',
            'color': '#333333',
            'textAlign': 'center',
            'letterSpacing': 0.0,
          },
        ),
        // Participant name
        TemplateElement(
          id: 'name_1',
          type: ElementType.text,
          x: 97.5,
          y: 280,
          width: 400,
          height: 45,
          properties: {
            'text': '{nama}',
            'variable': '{nama}',
            'fontSize': 28.0,
            'fontFamily': 'Roboto',
            'fontWeight': 'bold',
            'fontStyle': 'normal',
            'color': '#1A365D',
            'textAlign': 'center',
            'letterSpacing': 1.0,
          },
        ),
        // Program text
        TemplateElement(
          id: 'program_text_1',
          type: ElementType.text,
          x: 97.5,
          y: 350,
          width: 400,
          height: 30,
          properties: {
            'text': 'Telah berjaya menyertai program',
            'variable': null,
            'fontSize': 14.0,
            'fontFamily': 'Roboto',
            'fontWeight': 'normal',
            'fontStyle': 'normal',
            'color': '#333333',
            'textAlign': 'center',
            'letterSpacing': 0.0,
          },
        ),
        // Program name
        TemplateElement(
          id: 'program_name_1',
          type: ElementType.text,
          x: 97.5,
          y: 390,
          width: 400,
          height: 35,
          properties: {
            'text': '{program}',
            'variable': '{program}',
            'fontSize': 18.0,
            'fontFamily': 'Roboto',
            'fontWeight': 'bold',
            'fontStyle': 'normal',
            'color': '#2B6CB0',
            'textAlign': 'center',
            'letterSpacing': 0.0,
          },
        ),
        // Date
        TemplateElement(
          id: 'date_1',
          type: ElementType.text,
          x: 97.5,
          y: 450,
          width: 400,
          height: 25,
          properties: {
            'text': 'Tarikh: {tarikh}',
            'variable': '{tarikh}',
            'fontSize': 12.0,
            'fontFamily': 'Roboto',
            'fontWeight': 'normal',
            'fontStyle': 'normal',
            'color': '#333333',
            'textAlign': 'center',
            'letterSpacing': 0.0,
          },
        ),
        // Signature
        TemplateElement(
          id: 'signature_1',
          type: ElementType.signature,
          x: 197.5,
          y: 520,
          width: 200,
          height: 120,
          properties: {
            'signatoryIndex': 1,
            'showName': true,
            'showTitle': true,
            'showLine': true,
            'nameColor': '#000000',
            'lineColor': '#000000',
          },
        ),
        // QR Code
        TemplateElement(
          id: 'qr_1',
          type: ElementType.qrCode,
          x: 40,
          y: 700,
          width: 80,
          height: 80,
          properties: {
            'size': 80.0,
            'showLabel': true,
            'labelText': 'Imbas untuk pengesahan',
          },
        ),
        // Certificate number
        TemplateElement(
          id: 'cert_no_1',
          type: ElementType.text,
          x: 350,
          y: 750,
          width: 200,
          height: 20,
          properties: {
            'text': 'No. Sijil: {no_sijil}',
            'variable': '{no_sijil}',
            'fontSize': 10.0,
            'fontFamily': 'Roboto',
            'fontWeight': 'normal',
            'fontStyle': 'normal',
            'color': '#666666',
            'textAlign': 'right',
            'letterSpacing': 0.0,
          },
        ),
      ],
    );
  }
}
