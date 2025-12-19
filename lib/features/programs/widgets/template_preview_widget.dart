import 'package:flutter/material.dart';

class TemplatePreviewWidget extends StatelessWidget {
  final String templateStyle;
  final String? selectedStyle;
  final VoidCallback onTap;

  const TemplatePreviewWidget({
    super.key,
    required this.templateStyle,
    required this.selectedStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = templateStyle == selectedStyle;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              Expanded(
                child: _buildTemplatePreview(context),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.grey[100],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected)
                      const Icon(Icons.check_circle, color: Colors.white, size: 16),
                    if (isSelected) const SizedBox(width: 6),
                    Text(
                      _getTemplateName(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontSize: 13,
                      ),
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

  Widget _buildTemplatePreview(BuildContext context) {
    switch (templateStyle) {
      case 'moden':
        return _ModenPreview();
      case 'klasik':
        return _KlasikPreview();
      case 'formal':
        return _FormalPreview();
      case 'kreatif':
        return _KreatifPreview();
      default:
        return _ModenPreview();
    }
  }

  String _getTemplateName() {
    switch (templateStyle) {
      case 'moden':
        return 'Moden';
      case 'klasik':
        return 'Klasik';
      case 'formal':
        return 'Formal';
      case 'kreatif':
        return 'Kreatif';
      default:
        return templateStyle;
    }
  }
}

class _ModenPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(height: 3, color: const Color(0xFF696CFF)),
          const SizedBox(height: 8),
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF696CFF), width: 1),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF696CFF), Color(0xFF8B8EFF)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Text(
              'SIJIL',
              style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF696CFF)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Container(height: 6, width: 50, color: Colors.grey[300]),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 20,
                height: 20,
                color: Colors.grey[200],
              ),
              Container(height: 1, width: 30, color: Colors.grey[400]),
            ],
          ),
          const SizedBox(height: 4),
          Container(height: 3, color: const Color(0xFF696CFF)),
        ],
      ),
    );
  }
}

class _KlasikPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFBF0),
      padding: const EdgeInsets.all(6),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD4AF37), width: 0.5),
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 20, height: 1, color: const Color(0xFFD4AF37)),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4AF37),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(width: 20, height: 1, color: const Color(0xFFD4AF37)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'SIJIL',
                style: TextStyle(
                  color: const Color(0xFFB8860B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(height: 6, width: 45, color: Colors.grey[300]),
              Container(height: 1, width: 35, color: const Color(0xFFD4AF37)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD4AF37)),
                    ),
                  ),
                  Container(height: 1, width: 28, color: const Color(0xFF4A3728)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormalPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(height: 15, color: const Color(0xFF1A237E)),
          Expanded(
            child: Row(
              children: [
                Container(width: 3, color: const Color(0xFF1A237E)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF1A237E)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          color: const Color(0xFF1A237E),
                          child: const Text(
                            'SIJIL',
                            style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          color: const Color(0xFFE8EAF6),
                          child: Container(height: 6, width: 40, color: Colors.grey[400]),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF1A237E), width: 1.5),
                              ),
                            ),
                            Container(height: 1.5, width: 25, color: const Color(0xFF1A237E)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 3, color: const Color(0xFF1A237E)),
              ],
            ),
          ),
          Container(height: 8, color: const Color(0xFF1A237E)),
        ],
      ),
    );
  }
}

class _KreatifPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            top: -15,
            left: -15,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00897B).withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            right: -10,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF6F00).withOpacity(0.2),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF00897B), width: 1.5),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF00897B)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(height: 4, width: 30, color: const Color(0xFF00897B)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'SIJIL',
                  style: TextStyle(
                    color: const Color(0xFFFF6F00),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00897B), Color(0xFF4DB6AC)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(height: 4, width: 35, color: Colors.white),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(height: 1.5, width: 25, color: const Color(0xFF00897B)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
