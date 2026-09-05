import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../../providers/auth_provider.dart';
import '../../providers/perfiles_provider.dart';
import '../../services/feedback_service.dart';

class FeedbackBottomSheet extends StatefulWidget {
  const FeedbackBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FeedbackBottomSheet(),
    );
  }

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final FeedbackService _feedbackService = FeedbackService();

  String _selectedCategory = 'Sugerencia';
  int _rating = 5;
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _categories = [
    {
      'label': 'Sugerencia',
      'icon': Icons.lightbulb_outline_rounded,
      'color': Colors.amber.shade700,
    },
    {
      'label': 'Problema',
      'icon': Icons.bug_report_outlined,
      'color': Colors.red.shade600,
    },
    {
      'label': 'Califícanos',
      'icon': Icons.star_rounded,
      'color': Colors.orange.shade700,
    },
    {
      'label': 'Otro',
      'icon': Icons.chat_bubble_outline_rounded,
      'color': Colors.indigo.shade600,
    },
  ];

  static const Map<int, String> _ratingLabels = {
    1: 'Muy insatisfecho 😞',
    2: 'Poco satisfecho 😐',
    3: 'Aceptable 🙂',
    4: '¡Muy bueno! 😊',
    5: '¡Excelente experiencia! 🌟',
  };

  String get _hintText {
    if (_selectedCategory == 'Califícanos') {
      switch (_rating) {
        case 1:
        case 2:
          return '¿Qué podemos mejorar para que tu experiencia sea de 5 estrellas? (Opcional)';
        case 3:
          return '¿Qué te gustaría ver en las próximas versiones de Misión Kids? (Opcional)';
        case 4:
        case 5:
        default:
          return '¡Nos alegra mucho! Cuéntanos qué es lo que más te gusta de la app... (Opcional)';
      }
    }
    return 'Cuéntanos qué podemos mejorar, qué te gusta o si encontraste algún problema...';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _enviarFeedback() async {
    final text = _controller.text.trim();
    final bool esCalificacion = _selectedCategory == 'Califícanos';

    if (!esCalificacion) {
      if (text.isEmpty) {
        setState(() => _errorMessage = 'Por favor escribe tu comentario.');
        return;
      }

      if (text.length < 5) {
        setState(() => _errorMessage = 'El mensaje es demasiado corto (mín. 5 caracteres).');
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      final perfilesProv = Provider.of<PerfilesProvider>(context, listen: false);
      final perfil = perfilesProv.perfilActivo;

      final mensajeFinal = text.isNotEmpty
          ? text
          : (esCalificacion ? 'Calificación: $_rating estrellas' : '');

      await _feedbackService.submitFeedback(
        message: mensajeFinal,
        category: _selectedCategory,
        rating: esCalificacion ? _rating : null,
        userEmail: authProv.usuario?.email,
        perfilNombre: perfil?.nombre,
        familiaId: authProv.familiaId,
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¡Muchas gracias! Tu opinión nos ayuda a mejorar Misión Kids.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.teal.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Ocurrió un error al enviar el feedback: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final bool esCalificacion = _selectedCategory == 'Califícanos';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: FadeInUp(
        duration: const Duration(milliseconds: 250),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicador superior de arrastre
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Encabezado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      esCalificacion ? Icons.star_rounded : Icons.rate_review_rounded,
                      color: esCalificacion ? Colors.amber.shade700 : primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          esCalificacion ? '¿Cómo calificarías Misión Kids?' : '¿Tienes sugerencias o dudas?',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          esCalificacion
                              ? 'Toca las estrellas para calificar tu experiencia'
                              : 'Tu retroalimentación construye Misión Kids',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Categorías
              Text(
                'Categoría:',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat['label'];
                    final Color catColor = cat['color'];

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        avatar: Icon(
                          cat['icon'],
                          size: 18,
                          color: isSelected ? Colors.white : catColor,
                        ),
                        label: Text(
                          cat['label'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selectedColor: catColor,
                        backgroundColor: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                        checkmarkColor: Colors.white,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? catColor : Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        onSelected: _isSubmitting
                            ? null
                            : (val) {
                                if (val) {
                                  setState(() {
                                    _selectedCategory = cat['label'];
                                    _errorMessage = null;
                                  });
                                }
                              },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Selector interactivo de estrellas cuando la categoría es Califícanos
              if (esCalificacion) ...[
                FadeIn(
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.amber.withValues(alpha: 0.08)
                          : Colors.amber.shade50.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final starNumber = index + 1;
                            final isFilled = starNumber <= _rating;

                            return IconButton(
                              iconSize: 38,
                              splashRadius: 26,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              onPressed: _isSubmitting
                                  ? null
                                  : () => setState(() => _rating = starNumber),
                              icon: Icon(
                                isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: isFilled ? Colors.amber.shade600 : Colors.grey.shade400,
                              ),
                              tooltip: '$starNumber estrellas',
                            );
                          }),
                        ),
                        const SizedBox(height: 4),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _ratingLabels[_rating] ?? '',
                            key: ValueKey<int>(_rating),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Campo de texto
              TextField(
                controller: _controller,
                enabled: !_isSubmitting,
                maxLines: esCalificacion ? 3 : 4,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: _hintText,
                  hintStyle: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: esCalificacion ? Colors.amber.shade700 : primaryColor,
                      width: 2,
                    ),
                  ),
                  errorText: _errorMessage,
                ),
              ),
              const SizedBox(height: 14),

              // Botón de Enviar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _enviarFeedback,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          esCalificacion ? Icons.send_rounded : Icons.send_rounded,
                          size: 20,
                        ),
                  label: Text(
                    _isSubmitting
                        ? 'Enviando...'
                        : (esCalificacion ? 'Enviar calificación' : 'Enviar comentarios'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: esCalificacion ? Colors.amber.shade700 : primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
