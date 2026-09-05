import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../models/perfil_model.dart';
import 'racha_info_modal.dart';

/// Chip interactivo con fueguito animado para el encabezado del niño.
class RachaBadge extends StatelessWidget {
  final Perfil perfil;

  const RachaBadge({super.key, required this.perfil});

  @override
  Widget build(BuildContext context) {
    final racha = perfil.rachaActual;
    final tieneRacha = racha > 0;

    return Semantics(
      label: "Racha de hábitos: $racha días seguidos. Toca para ver tus medallas y récord.",
      button: true,
      child: GestureDetector(
        onTap: () => RachaInfoModal.mostrar(context, perfil),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: tieneRacha
                  ? [const Color(0xFFFF5722), const Color(0xFFF57C00)]
                  : [Colors.grey.shade700, Colors.grey.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: tieneRacha ? Colors.amber.withValues(alpha: 0.6) : Colors.white24,
              width: 1.2,
            ),
            boxShadow: [
              if (tieneRacha)
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Pulse(
                duration: const Duration(seconds: 2),
                infinite: tieneRacha,
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: tieneRacha ? Colors.amberAccent : Colors.grey.shade400,
                  size: 20,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                "$racha",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
