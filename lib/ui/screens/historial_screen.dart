import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
        length: 2,
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
            ],
          ),
        ),
      ),
    );
  }
}
