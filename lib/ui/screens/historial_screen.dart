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
            bottom: const TabBar(
              labelColor: Colors.amber,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.amber,
              tabs: [
                Tab(icon: Icon(Icons.today), text: "Hoy"),
                Tab(icon: Icon(Icons.emoji_events), text: "Trofeos"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // TAB 1: LOGROS DE HOY
              historialDia.isEmpty
                  ? const Center(child: Text("Aún no hay actividad hoy", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: historialDia.length,
                itemBuilder: (ctx, i) {
                  final tarea = historialDia[i];
                  final esSancion = tarea.puntos < 0;
                  return Card(
                      color: esSancion ? Colors.red[50] : Colors.green[50],
                      child: ListTile(
                        leading: Icon(esSancion ? Icons.warning : Icons.check_circle, color: esSancion ? Colors.red : Colors.green),
                        title: Text(tarea.nombre, style: TextStyle(fontWeight: FontWeight.bold, color: esSancion ? Colors.red : Colors.green)),
                        subtitle: Text(esSancion ? "Sanción: ${tarea.puntos}" : "Ganaste \$${tarea.puntos}"),
                      )
                  );
                },
              ),

              // TAB 2: VICTORIAS PASADAS
              historialVictorias.isEmpty
                  ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.emoji_events_outlined, size: 60, color: Colors.grey), SizedBox(height: 10), Text("¡Completa tu primera meta!", style: TextStyle(color: Colors.grey))]))
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: historialVictorias.length,
                itemBuilder: (ctx, i) {
                  final victoria = historialVictorias[historialVictorias.length - 1 - i];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.star, color: Colors.white)),
                      title: Text(victoria['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text("Completado: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(victoria['fecha']))}"),
                      trailing: Text("\$${victoria['costo']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
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
