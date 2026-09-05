import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'onboarding_slide_model.dart';
import '../../../models/perfil_model.dart';

/// Modal interactivo de Onboarding con diseño multimedia moderno, microanimaciones
/// y soporte para deslizamiento fluido con botón de escape rápido (Saltar).
class OnboardingModal extends StatefulWidget {
  final List<OnboardingSlideModel> slides;
  final VoidCallback onCompletado;
  final String textoBotonFinal;

  const OnboardingModal({
    super.key,
    required this.slides,
    required this.onCompletado,
    this.textoBotonFinal = '¡Comenzar!',
  });

  /// Despliega el modal de Onboarding como un diálogo flotante moderno
  static Future<void> mostrar({
    required BuildContext context,
    required List<OnboardingSlideModel> slides,
    required VoidCallback onCompletado,
    String textoBotonFinal = '¡Comenzar!',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: OnboardingModal(
          slides: slides,
          onCompletado: onCompletado,
          textoBotonFinal: textoBotonFinal,
        ),
      ),
    );
  }

  /// Genera las diapositivas de bienvenida y logística para el rol Administrador / Padre
  static List<OnboardingSlideModel> crearSlidesAdmin() {
    return const [
      OnboardingSlideModel(
        badgeText: 'PASO 1: CONEXIÓN FAMILIAR',
        title: 'Administren juntos en equipo',
        subtitle:
            'Comparte tu Código Familiar con tu pareja o tutores. Ambos podrán asignar misiones, revisar avances y sincronizar datos en tiempo real.',
        icon: Icons.people_alt_rounded,
        iconColor: Colors.amber,
        gradientColors: [Color(0xFFF77F00), Colors.amber],
        highlightTip: '💡 Puedes copiar o compartir tu código con un solo toque desde el encabezado.',
      ),
      OnboardingSlideModel(
        badgeText: 'PASO 2: MISIONES Y HÁBITOS',
        title: 'Crea misiones por bloques y puntos',
        subtitle:
            'Organiza el día de tus hijos dividiendo tareas en Mañana, Tarde y Noche. Define puntos, recurrencias diarias o días específicos de la semana.',
        icon: Icons.checklist_rtl_rounded,
        iconColor: Colors.cyanAccent,
        gradientColors: [Colors.indigo, Colors.cyan],
        highlightTip: '💡 El botón flotante "+" te permite crear nuevas misiones en cualquier momento.',
      ),
      OnboardingSlideModel(
        badgeText: 'PASO 3: METAS Y PREMIOS',
        title: 'Aprueba logros y entrega recompensas',
        subtitle:
            'Cuando tus hijos marcan una misión, pasa a tu lista de revisión. Al aprobarla, sus estrellas se suman para canjear los premios que tú definas.',
        icon: Icons.workspace_premium_rounded,
        iconColor: Colors.purpleAccent,
        gradientColors: [Colors.deepPurple, Colors.pinkAccent],
        highlightTip: '💡 Tú tienes siempre el control absoluto de validar cada canje en la tienda.',
      ),
    ];
  }

  /// Genera las diapositivas lúdicas y gamificadas para el perfil del Niño
  static List<OnboardingSlideModel> crearSlidesNino(Perfil perfil) {
    final nombre = perfil.nombre.isNotEmpty ? perfil.nombre : 'Campeón';
    return [
      OnboardingSlideModel(
        badgeText: '¡BIENVENIDO!',
        title: '¡Hola, $nombre!\nTu aventura comienza aquí',
        subtitle:
            'Este es tu cuartel especial de misiones. Cada día tendrás retos divertidos para aprender, ayudar y convertirte en el héroe de la casa.',
        icon: Icons.rocket_launch_rounded,
        iconColor: Colors.orangeAccent,
        gradientColors: const [Colors.deepOrange, Colors.orangeAccent],
        highlightTip: '🚀 Revisa tus misiones de la Mañana, Tarde y Noche.',
      ),
      const OnboardingSlideModel(
        badgeText: 'GANA ESTRELLAS',
        title: 'Cumple misiones y acumula puntos',
        subtitle:
            'Al terminar una misión, pulsa "Misión Cumplida". Tus papás la aprobarán y tus estrellas se guardarán en tu alcancía mágica.',
        icon: Icons.stars_rounded,
        iconColor: Colors.amber,
        gradientColors: [Colors.amber, Colors.orange],
        highlightTip: '⭐ ¡Entre más constante seas, más rápido subirás de nivel!',
      ),
      const OnboardingSlideModel(
        badgeText: 'RECOMPENSAS',
        title: '¡Alcanza tu gran premio!',
        subtitle:
            'Mira tu barra de meta de ahorro y visita la tienda. Cuando juntes suficientes estrellas, podrás pedirle a tus papás tu premio favorito.',
        icon: Icons.card_giftcard_rounded,
        iconColor: Colors.greenAccent,
        gradientColors: [Colors.teal, Colors.greenAccent],
        highlightTip: '🎁 ¡Todo gran esfuerzo merece una recompensa increíble!',
      ),
    ];
  }

  @override
  State<OnboardingModal> createState() => _OnboardingModalState();
}

class _OnboardingModalState extends State<OnboardingModal> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finalizar() {
    widget.onCompletado();
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _siguiente() {
    if (_paginaActual < widget.slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finalizar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = widget.slides[_paginaActual];
    final esUltima = _paginaActual == widget.slides.length - 1;

    return Container(
      constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            // Barra superior con botón Saltar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 14, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicador de paso textual
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_paginaActual + 1} de ${widget.slides.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _finalizar,
                    icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white54),
                    label: const Text(
                      'Saltar',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),

            // Carrusel de contenido
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.slides.length,
                onPageChanged: (index) {
                  setState(() => _paginaActual = index);
                },
                itemBuilder: (context, index) {
                  final item = widget.slides[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ilustración vectorial con gradiente y microanimación
                        ZoomIn(
                          key: ValueKey('icon_$index'),
                          duration: const Duration(milliseconds: 400),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: item.gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: item.iconColor.withValues(alpha: 0.4),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              item.icon,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Badge superior
                        FadeInDown(
                          key: ValueKey('badge_$index'),
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.iconColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: item.iconColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              item.badgeText,
                              style: TextStyle(
                                color: item.iconColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Título
                        FadeIn(
                          key: ValueKey('title_$index'),
                          duration: const Duration(milliseconds: 350),
                          child: Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Subtítulo
                        FadeIn(
                          key: ValueKey('sub_$index'),
                          duration: const Duration(milliseconds: 400),
                          child: Text(
                            item.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13.5,
                              height: 1.45,
                            ),
                          ),
                        ),

                        // Tip opcional
                        if (item.highlightTip != null) ...[
                          const SizedBox(height: 14),
                          FadeInUp(
                            key: ValueKey('tip_$index'),
                            duration: const Duration(milliseconds: 400),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Text(
                                item.highlightTip!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.amberAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Barra inferior con indicadores y botón siguiente
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicadores de puntos dinámicos (pills)
                  Row(
                    children: List.generate(
                      widget.slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(right: 6),
                        height: 7,
                        width: _paginaActual == i ? 24 : 7,
                        decoration: BoxDecoration(
                          color: _paginaActual == i ? slide.iconColor : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Botón Siguiente / Comenzar
                  ElevatedButton(
                    onPressed: _siguiente,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: slide.iconColor,
                      foregroundColor: const Color(0xFF16213E),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: slide.iconColor.withValues(alpha: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          esUltima ? widget.textoBotonFinal : 'Siguiente',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          esUltima ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
