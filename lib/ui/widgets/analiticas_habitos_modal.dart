import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/perfil_model.dart';
import '../../providers/tarea_provider.dart';

class AnaliticasHabitosModal extends StatelessWidget {
  final Perfil perfil;

  const AnaliticasHabitosModal({
    super.key,
    required this.perfil,
  });

  @override
  Widget build(BuildContext context) {
    final tareaProv = Provider.of<TareaProvider>(context);

    final porcentajeCumplimiento = tareaProv.porcentajeCumplimientoHoy(perfil.id);
    final programadasHoy = tareaProv.tareasProgramadasHoy(perfil.id);
    final completadasHoy = programadasHoy
        .where((t) => t.estado == 'aprobada' && t.ultimoDiaCompletado == tareaProv.fechaIdHoy)
        .toList();

    final conteoBloques = tareaProv.conteoPorBloque(perfil.id);
    final completadasBloques = tareaProv.conteoCompletadasPorBloque(perfil.id);

    final porcentajeAhorro = perfil.metaAhorro > 0
        ? (perfil.saldo / perfil.metaAhorro).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Tirador superior
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Cabecera
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.analytics_rounded, color: Colors.teal.shade700, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hábitos & Analíticas",
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Resumen de rendimiento de ${perfil.nombre}",
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Contenido de analíticas
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // TARJETA PRINCIPAL: Cumplimiento de Hoy
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade700, Colors.teal.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: CircularProgressIndicator(
                              value: programadasHoy.isEmpty ? 0.0 : porcentajeCumplimiento,
                              strokeWidth: 8,
                              backgroundColor: Colors.white.withValues(alpha: 0.25),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          Text(
                            programadasHoy.isEmpty
                                ? "0%"
                                : "${(porcentajeCumplimiento * 100).toInt()}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Cumplimiento de Hoy",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              programadasHoy.isEmpty
                                  ? "No hay misiones programadas para hoy."
                                  : "${completadasHoy.length} de ${programadasHoy.length} misiones completadas",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                porcentajeCumplimiento == 1.0 && programadasHoy.isNotEmpty
                                    ? "🎉 ¡Día 100% perfecto!"
                                    : "💪 En progreso continuo",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // SECCIÓN: Desglose por Bloques del Día
                const Text(
                  "Distribución y Avance por Horario",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _itemBloque(
                  titulo: "Mañana ☀️",
                  color: Colors.amber.shade700,
                  total: conteoBloques['manana'] ?? 0,
                  completadas: completadasBloques['manana'] ?? 0,
                ),
                const SizedBox(height: 10),
                _itemBloque(
                  titulo: "Tarde 🌤️",
                  color: Colors.orange.shade700,
                  total: conteoBloques['tarde'] ?? 0,
                  completadas: completadasBloques['tarde'] ?? 0,
                ),
                const SizedBox(height: 10),
                _itemBloque(
                  titulo: "Noche 🌙",
                  color: Colors.indigo.shade600,
                  total: conteoBloques['noche'] ?? 0,
                  completadas: completadasBloques['noche'] ?? 0,
                ),

                const SizedBox(height: 24),

                // SECCIÓN: Racha y Rendimiento de Hábitos
                const Text(
                  "Constancia y Hábitos (Gamificación)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          children: [
                            const Text("🔥 Racha Actual", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange)),
                            const SizedBox(height: 4),
                            Text(
                              "${perfil.rachaActual} días",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.orange.shade900),
                            ),
                            Text("Días seguidos", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          children: [
                            const Text("🏅 Récord Histórico", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber)),
                            const SizedBox(height: 4),
                            Text(
                              "${perfil.mejorRacha} días",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber.shade900),
                            ),
                            Text("Mejor marca", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // SECCIÓN: Progreso hacia la Meta Familiar
                if (perfil.metaAhorro > 0) ...[
                  const Text(
                    "Meta Familiar de Recompensa",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              perfil.nombreMeta.isNotEmpty ? perfil.nombreMeta : "Meta Principal",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.purple),
                            ),
                            Text(
                              "\$${perfil.saldo} / \$${perfil.metaAhorro.toInt()} pts",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: porcentajeAhorro,
                            minHeight: 10,
                            backgroundColor: Colors.purple.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade600),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          porcentajeAhorro >= 1.0
                              ? "🎯 ¡Meta completada! Lista para celebrar el canje."
                              : "Faltan \$${(perfil.metaAhorro - perfil.saldo).toInt()} puntos para alcanzarla.",
                          style: TextStyle(fontSize: 12, color: Colors.purple.shade800),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemBloque({
    required String titulo,
    required Color color,
    required int total,
    required int completadas,
  }) {
    final progreso = total > 0 ? (completadas / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
              ),
              Text(
                total == 0 ? "Sin misiones" : "$completadas de $total cumplidas",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progreso,
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
