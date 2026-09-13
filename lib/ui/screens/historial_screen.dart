import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/perfil_model.dart';
import '../../providers/perfiles_provider.dart';
import '../../providers/tarea_provider.dart';
import '../themes/app_theme.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final perfilesProv = Provider.of<PerfilesProvider>(context);
    final tareaProv = Provider.of<TareaProvider>(context);

    final perfilActual = perfilesProv.perfilActivo;
    if (perfilActual == null) return const Scaffold(body: Center(child: Text("Sin Perfil")));

    final historialDia = tareaProv.listaHistorialHoy(perfilActual.id);
    final historialVictorias = perfilActual.historialVictorias;

    final temaDelNino = AppTheme.getThemeByColor(perfilActual.colorPrimario);

    return Theme(
      data: temaDelNino,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Salón de la Fama 🏆"),
            backgroundColor: temaDelNino.primaryColor,
            foregroundColor: Colors.white,
            bottom: TabBar(
              labelColor: Colors.amber,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.amber,
              indicatorWeight: 4, // Más visible para accesibilidad
              tabs: [
                Tab(
                  icon: Semantics(label: "Logros del día de hoy", child: const Icon(Icons.today)), 
                  text: "Hoy"
                ),
                Tab(
                  icon: Semantics(label: "Tus grandes trofeos y premios ganados", child: const Icon(Icons.emoji_events)), 
                  text: "Trofeos"
                ),
                Tab(
                  icon: Semantics(label: "Tus medallas de racha y constancia", child: const Icon(Icons.military_tech_rounded)), 
                  text: "Medallas"
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // TAB 1: LOGROS DE HOY
              historialDia.isEmpty
                  ? Center(
                      child: Semantics(
                        label: "Aún no has completado misiones hoy. ¡Ánimo, tú puedes!",
                        child: const Text("Aún no hay actividad hoy", style: TextStyle(color: AppTheme.highContrastGrey, fontSize: 16)),
                      )
                    )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: historialDia.length,
                itemBuilder: (ctx, i) {
                  final tarea = historialDia[i];
                  final esSancion = tarea.puntos < 0;
                  return Semantics(
                    label: esSancion 
                        ? "Atención: Sanción de ${tarea.puntos.abs()} puntos por ${tarea.nombre}" 
                        : "¡Logro! Ganaste ${tarea.puntos} puntos con ${tarea.nombre}",
                    child: Card(
                        elevation: 0,
                        color: esSancion ? Colors.red.shade50 : Colors.green.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: esSancion ? Colors.red.shade200 : Colors.green.shade200),
                        ),
                        child: ListTile(
                          minVerticalPadding: 16,
                          leading: Icon(
                            esSancion ? Icons.warning_amber_rounded : Icons.check_circle_rounded, 
                            color: esSancion ? Colors.red.shade700 : Colors.green.shade700,
                            size: 28,
                          ),
                          title: Text(
                            tarea.nombre, 
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16,
                              color: esSancion ? Colors.red.shade900 : Colors.green.shade900
                            )
                          ),
                          subtitle: Text(
                            esSancion ? "Descuento de \$${tarea.puntos.abs()}" : "¡Recibiste \$${tarea.puntos}!",
                            style: TextStyle(
                              color: esSancion ? Colors.red.shade800 : Colors.green.shade800,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        )
                    ),
                  );
                },
              ),

              // TAB 2: VICTORIAS PASADAS
              historialVictorias.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, 
                        children: [
                          Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey), 
                          SizedBox(height: 16), 
                          Text("¡Tu estante de trofeos está esperando!", style: TextStyle(color: AppTheme.highContrastGrey, fontSize: 16, fontWeight: FontWeight.bold))
                        ]
                      )
                    )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: historialVictorias.length,
                itemBuilder: (ctx, i) {
                  final victoria = historialVictorias[historialVictorias.length - 1 - i];
                  final String nombrePremio = victoria['nombre'];
                  return Semantics(
                    label: "Trofeo ganado: $nombrePremio. Toca para recordar tu victoria.",
                    child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: ListTile(
                        minVerticalPadding: 20,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                          child: const Icon(Icons.star, color: Colors.white, size: 30),
                        ),
                        title: Text(nombrePremio, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text("¡Lo lograste el ${DateFormat('dd/MM/yyyy').format(DateTime.parse(victoria['fecha']))}!"),
                        trailing: Text(
                          "\$${victoria['costo']}", 
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.indigo, fontSize: 18)
                        ),
                      ),
                    ),
                  );
                },
              ),

              // TAB 3: VITRINA DE MEDALLAS Y RACHAS
              _buildTabMedallas(context, perfilActual),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabMedallas(BuildContext context, Perfil perfil) {
    final medallasGanadas = perfil.medallas;
    final racha = perfil.rachaActual;
    final record = perfil.mejorRacha;

    final listaMedallas = [
      {
        'id': 'bronce_3',
        'titulo': 'El Constante',
        'subtitulo': '3 días seguidos cumpliendo misiones',
        'dias': 3,
        'icono': Icons.military_tech_rounded,
        'color': const Color(0xFFCD7F32), // Bronce
        'desbloqueada': medallasGanadas.contains('bronce_3') || racha >= 3 || record >= 3,
      },
      {
        'id': 'plata_7',
        'titulo': 'Guerrero Semanal',
        'subtitulo': '7 días seguidos de hábitos imparables',
        'dias': 7,
        'icono': Icons.shield_rounded,
        'color': const Color(0xFFC0C0C0), // Plata
        'desbloqueada': medallasGanadas.contains('plata_7') || racha >= 7 || record >= 7,
      },
      {
        'id': 'oro_14',
        'titulo': 'Héroe de Oro',
        'subtitulo': '14 días de constancia legendaria',
        'dias': 14,
        'icono': Icons.workspace_premium_rounded,
        'color': const Color(0xFFFFD700), // Oro
        'desbloqueada': medallasGanadas.contains('oro_14') || racha >= 14 || record >= 14,
      },
      {
        'id': 'diamante_30',
        'titulo': 'Maestro Diamante',
        'subtitulo': '¡30 días de disciplina absoluta!',
        'dias': 30,
        'icono': Icons.diamond_rounded,
        'color': const Color(0xFF00E5FF), // Diamante
        'desbloqueada': medallasGanadas.contains('diamante_30') || racha >= 30 || record >= 30,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Banner de Racha
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      racha == 1 ? "1 DÍA DE RACHA 🔥" : "$racha DÍAS DE RACHA 🔥",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Récord histórico: $record días",
                      style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          "Vitrina de Medallas",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF16213E)),
        ),
        const SizedBox(height: 12),

        ...listaMedallas.map((m) {
          final desbloqueada = m['desbloqueada'] as bool;
          final colorMedalla = m['color'] as Color;

          return Card(
            elevation: desbloqueada ? 2 : 0,
            color: desbloqueada ? Colors.white : Colors.grey.shade100,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: desbloqueada ? colorMedalla.withValues(alpha: 0.5) : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: ListTile(
              minVerticalPadding: 16,
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: desbloqueada ? colorMedalla.withValues(alpha: 0.2) : Colors.grey.shade300,
                ),
                child: Icon(
                  m['icono'] as IconData,
                  color: desbloqueada ? colorMedalla : Colors.grey.shade500,
                  size: 28,
                ),
              ),
              title: Text(
                m['titulo'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: desbloqueada ? const Color(0xFF16213E) : Colors.grey.shade600,
                ),
              ),
              subtitle: Text(
                m['subtitulo'] as String,
                style: TextStyle(
                  color: desbloqueada ? Colors.grey.shade700 : Colors.grey.shade500,
                  fontSize: 12.5,
                ),
              ),
              trailing: desbloqueada
                  ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 26)
                  : const Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 24),
            ),
          );
        }),
      ],
    );
  }
}
