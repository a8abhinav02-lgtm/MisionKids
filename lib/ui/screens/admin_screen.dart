import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../../providers/perfiles_provider.dart';
import '../../providers/tarea_provider.dart';
import '../../models/perfil_model.dart';
import '../../models/tarea_model.dart';
import '../widgets/formulario_tarea.dart';
import '../themes/app_theme.dart';
import 'formulario_perfil_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    final perfilesProv = Provider.of<PerfilesProvider>(context);
    final perfiles = perfilesProv.todosLosPerfiles;
    final tareaProv = Provider.of<TareaProvider>(context);

    if (perfilesProv.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    if (perfiles.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Admin"), backgroundColor: Colors.grey[800]),
        body: const Center(child: Text("Debes crear al menos un perfil de niño")),
      );
    }

    return DefaultTabController(
      length: perfiles.length,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          "Panel de Padres",
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // BOTÓN AGREGAR HIJO — Ahora prominente y visible
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormularioPerfilScreen())),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF00B4D8), Color(0xFF0077B6)]),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF00B4D8).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_add, color: Colors.white, size: 20),
                                SizedBox(width: 6),
                                Text("Hijo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tabs con diseño visual premium
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      isScrollable: true,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white54,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(colors: [Colors.amber, Color(0xFFF77F00)]),
                        boxShadow: [
                          BoxShadow(color: Colors.amber.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      padding: const EdgeInsets.all(4),
                      tabs: perfiles.map((p) {
                        final color = AppTheme.colors[p.colorPrimario] ?? Colors.grey;
                        return Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(AppTheme.getAvatarIcon(p.tematica), size: 18, color: color.shade200),
                              const SizedBox(width: 8),
                              Text(p.nombre),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Tab Content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                      child: TabBarView(
                        children: perfiles.map((perfil) => _TabAdminPerfil(perfil: perfil, tareaProv: tareaProv, perfilesProv: perfilesProv)).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============ TAB CONTENT PER CHILD ============

class _TabAdminPerfil extends StatelessWidget {
  final Perfil perfil;
  final TareaProvider tareaProv;
  final PerfilesProvider perfilesProv;

  const _TabAdminPerfil({required this.perfil, required this.tareaProv, required this.perfilesProv});

  @override
  Widget build(BuildContext context) {
    final double dineroActual = perfil.saldo.toDouble();
    final double meta = perfil.metaAhorro;
    final String nombreMeta = perfil.nombreMeta;
    final bool hayMeta = meta > 0;

    double porcentaje = 0.0;
    if (hayMeta && dineroActual > 0) porcentaje = (dineroActual / meta).clamp(0.0, 1.0);

    final tareasPorRevisar = tareaProv.tareasPorRevisar(perfil.id);
    final todasLasTareas = tareaProv.listaTodasLasTareas(perfil.id);
    final color = AppTheme.colors[perfil.colorPrimario] ?? Colors.indigo;

    return ListView(
      padding: const EdgeInsets.only(bottom: 80, top: 16),
      children: [
        // RESUMEN DEL PERFIL — card con gradiente
        FadeInDown(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.shade600, color.shade400]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(AppTheme.getAvatarIcon(perfil.tematica), color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(perfil.nombre, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("Saldo: \$${dineroActual.toInt()}", style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (hayMeta) Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text("${(porcentaje * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
                if (hayMeta) ...[
                  const SizedBox(height: 16),
                  Text("🎯 $nombreMeta", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(value: porcentaje, minHeight: 10, backgroundColor: Colors.white24, color: Colors.amber),
                  ),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("\$${dineroActual.toInt()} acumulados", style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                    Text("Meta: \$${meta.toInt()}", style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                  ]),
                ],
                if (!hayMeta) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: color, elevation: 0),
                      icon: const Icon(Icons.add_task),
                      label: const Text("DEFINIR NUEVO RETO"),
                      onPressed: () => _dialogoDefinirMeta(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ACCIONES RÁPIDAS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _AccionRapida(
                  icono: Icons.edit_note,
                  label: "Editar Reto",
                  color: Colors.blue,
                  onTap: () => _dialogoDefinirMeta(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AccionRapida(
                  icono: Icons.warning_amber_rounded,
                  label: "Multa",
                  color: Colors.red,
                  onTap: () => _mostrarDialogoSancion(context),
                ),
              ),
            ],
          ),
        ),

        // APROBACIONES PENDIENTES
        if (tareasPorRevisar.isNotEmpty) ...[
          const SizedBox(height: 20),
          FadeInDown(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade200, width: 1.5),
                boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.notifications_active, color: Colors.orange, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Text("Esperando Aprobación (${tareasPorRevisar.length})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                  ]),
                  const SizedBox(height: 12),
                  ...tareasPorRevisar.map((tarea) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.orange.shade100, child: Icon(tarea.icono, color: Colors.orange.shade700, size: 22)),
                      title: Text(tarea.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text("💰 \$${tarea.puntos}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: Colors.red.shade300, size: 28),
                            onPressed: () => tareaProv.rechazarTarea(tarea),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green, size: 32),
                            onPressed: () async {
                              final success = await tareaProv.aprobarTarea(tarea);
                              if (success) {
                                perfilesProv.agregarDinero(perfil.id, tarea.puntos);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],

        // MISIONES EXISTENTES
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Misiones de ${perfil.nombre}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.grey.shade700)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 20),
                label: const Text("Nueva"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => _mostrarDialogoTarea(context, null),
              ),
            ],
          ),
        ),

        if (todasLasTareas.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_rounded, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text("Sin misiones creadas aún", style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
                ],
              ),
            ),
          ),

        ...todasLasTareas.map((tarea) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(tarea.icono, color: color, size: 22),
            ),
            title: Text(tarea.nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            subtitle: Text(
              "${_bloqueLabel(tarea.bloque)} • ${tarea.esObligatoria ? '🔑 Obligatoria' : '💰 ${tarea.puntos} pts'}",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 22), 
                  onPressed: () async {
                    final success = await tareaProv.aprobarTareaManual(tarea);
                    if (success) {
                      perfilesProv.agregarDinero(perfil.id, tarea.puntos);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("\$${tarea.puntos} agregados.")));
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ya estaba aprobada hoy.")));
                      }
                    }
                  }
                ),
                IconButton(icon: Icon(Icons.edit_rounded, color: color, size: 22), onPressed: () => _mostrarDialogoTarea(context, tarea)),
                IconButton(icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 22), onPressed: () => tareaProv.eliminarTarea(tarea)),
              ],
            ),
          ),
        )),
      ],
    );
  }

  String _bloqueLabel(String bloque) {
    switch (bloque) {
      case 'manana': return '🌞 Mañana';
      case 'tarde': return '⛅ Tarde';
      case 'noche': return '🌙 Noche';
      default: return bloque;
    }
  }

  void _dialogoDefinirMeta(BuildContext context) {
    final nombreCtrl = TextEditingController(text: perfil.nombreMeta);
    final montoCtrl = TextEditingController(text: perfil.metaAhorro > 0 ? perfil.metaAhorro.toInt().toString() : '');

    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Definir Nuevo Reto 🎯"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre del Premio", prefixIcon: Icon(Icons.emoji_events))),
          const SizedBox(height: 12),
          TextField(controller: montoCtrl, decoration: const InputDecoration(labelText: "Costo (Puntos)", prefixText: "\$ ", prefixIcon: Icon(Icons.monetization_on)), keyboardType: TextInputType.number),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
        ElevatedButton(onPressed: () {
          if (nombreCtrl.text.isNotEmpty && montoCtrl.text.isNotEmpty) {
            perfilesProv.definirNuevaMeta(perfil.id, nombreCtrl.text, double.tryParse(montoCtrl.text) ?? 0);
            Navigator.pop(ctx);
          }
        }, child: const Text("Guardar")),
      ],
    ));
  }

  void _mostrarDialogoSancion(BuildContext context) {
    final motivoCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("⚠️ Aplicar Multa"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("Se restará del saldo acumulado."),
        const SizedBox(height: 12),
        TextField(controller: motivoCtrl, decoration: const InputDecoration(labelText: "Motivo", prefixIcon: Icon(Icons.note))),
        const SizedBox(height: 12),
        TextField(controller: montoCtrl, decoration: const InputDecoration(labelText: "Monto", prefixText: "\$ ", prefixIcon: Icon(Icons.money_off)), keyboardType: TextInputType.number),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: () async {
            if (motivoCtrl.text.isNotEmpty && montoCtrl.text.isNotEmpty) {
              final sancion = await tareaProv.aplicarSancion(motivoCtrl.text, int.tryParse(montoCtrl.text) ?? 0, perfil.id);
              await perfilesProv.agregarDinero(perfil.id, sancion.puntos);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sanción aplicada.")));
              }
            }
          },
          child: const Text("Aplicar"),
        ),
      ],
    ));
  }

  void _mostrarDialogoTarea(BuildContext context, Tarea? tareaExistente) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => FormularioTarea(tarea: tareaExistente, perfilId: perfil.id),
    );
  }
}

// ============ QUICK ACTION BUTTON ============

class _AccionRapida extends StatelessWidget {
  final IconData icono;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AccionRapida({required this.icono, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icono, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
