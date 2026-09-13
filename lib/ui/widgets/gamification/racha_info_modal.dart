import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../models/perfil_model.dart';

/// Modal interactivo que detalla la racha diaria del niño,
/// su récord histórico y el progreso hacia la siguiente medalla.
class RachaInfoModal extends StatelessWidget {
  final Perfil perfil;

  const RachaInfoModal({super.key, required this.perfil});

  static Future<void> mostrar(BuildContext context, Perfil perfil) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: RachaInfoModal(perfil: perfil),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final racha = perfil.rachaActual;
    final record = perfil.mejorRacha;

    // Calcular siguiente meta
    int proximaMeta = 3;
    String proximaMedalla = 'Bronce (3 días)';
    if (racha >= 3 && racha < 7) {
      proximaMeta = 7;
      proximaMedalla = 'Plata (7 días)';
    } else if (racha >= 7 && racha < 14) {
      proximaMeta = 14;
      proximaMedalla = 'Oro (14 días)';
    } else if (racha >= 14 && racha < 30) {
      proximaMeta = 30;
      proximaMedalla = 'Diamante (30 días)';
    } else if (racha >= 30) {
      proximaMeta = racha + 10;
      proximaMedalla = '¡Leyenda Imparable!';
    }

    final double progreso = (racha / proximaMeta).clamp(0.0, 1.0);

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón cerrar superior
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 22),
                    SizedBox(width: 8),
                    Text(
                      "Racha de Hábitos",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fueguito animado grande
            Pulse(
              duration: const Duration(seconds: 2),
              infinite: true,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5722), Color(0xFFFF9800), Color(0xFFFFD54F)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.5),
                      blurRadius: 25,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  size: 54,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contador de días
            Text(
              racha == 1 ? "1 DÍA DE RACHA" : "$racha DÍAS DE RACHA",
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              racha == 0
                  ? "¡Completa tus misiones hoy para encender tu fuego!"
                  : "¡Estás imparable, ${perfil.nombre}! Cada día de constancia te hace más fuerte.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.35),
            ),
            const SizedBox(height: 20),

            // Métricas: Récord y Siguiente Medalla
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Mejor Racha:",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        "$record días 🏆",
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Próxima Medalla:",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        proximaMedalla,
                        style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progreso,
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botón de cierre motivador
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: const Color(0xFF1A1A2E),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "¡A mantener el fuego encendido!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
