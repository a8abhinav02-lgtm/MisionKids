import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../../providers/auth_provider.dart';
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
  void _mostrarInfoFamilia(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final famId = authProv.familiaId;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.people_alt_rounded, color: Colors.amber, size: 28),
            SizedBox(width: 10),
            Text(
              "Familia Compartida",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¡Administren juntos las misiones de sus hijos!",
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "CÓDIGO DE FAMILIA",
                          style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          famId,
                          style: const TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: Colors.white70),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: famId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
                              const SizedBox(width: 8),
                              Text("¡Código $famId copiado al portapapeles!"),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF16213E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Instrucciones para invitar:",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildInstructionStep("1", "Instala Mission Kids en el otro dispositivo."),
            _buildInstructionStep("2", "Regístrate y selecciona la opción 'Unirse a Familia Existente'."),
            _buildInstructionStep("3", "Ingresa este código para sincronizar los datos en tiempo real."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Entendido", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: Colors.amber.withValues(alpha: 0.2),
            child: Text(
              number,
              style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

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
        appBar: AppBar(title: const Text("Admin"), backgroundColor: const Color(0xFF16213E)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.family_restroom, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Debes crear al menos un perfil de niño", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                icon: const Icon(Icons.person_add),
                label: const Text("Crear Perfil"),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormularioPerfilScreen())),
              ),
            ],
          ),
        ),
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
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Panel de Padres",
                              style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.amber, size: 20),
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: () => _mostrarInfoFamilia(context),
                              tooltip: "Compartir código de familia",
                            ),
                          ],
                        ),
                      ),
                      // BOTÓN AGREGAR HIJO — Ahora prominente y visible
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormularioPerfilScreen())),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                Icon(Icons.person_add, color: Colors.white, size: 18),
                                SizedBox(width: 4),
                                Text("Hijo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _AccionRapida(
                      icono: Icons.storefront,
                      label: "Tienda (Premios)",
                      color: Colors.purple,
                      onTap: () => _mostrarDialogoTiendaAdmin(context),
                      semanticLabel: "Gestión de recompensas. Toca para ver y editar los premios de la tienda.",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AccionRapida(
                      icono: Icons.edit_note,
                      label: "Meta Principal",
                      color: Colors.blue,
                      onTap: () => _dialogoDefinirMeta(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _AccionRapida(
                      icono: Icons.warning_amber_rounded,
                      label: "Sanción / Multa",
                      color: Colors.red,
                      onTap: () => _mostrarDialogoSancion(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(), // Espacio vacío para balancear
                  ),
                ],
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

        // CANJES PENDIENTES
        if (perfil.solicitudesCanje.isNotEmpty) ...[
          const SizedBox(height: 20),
          FadeInDown(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple.shade200, width: 1.5),
                boxShadow: [BoxShadow(color: Colors.purple.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.card_giftcard, color: Colors.purple, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Text("Premios Solicitados (${perfil.solicitudesCanje.length})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple)),
                  ]),
                  const SizedBox(height: 12),
                  ...perfil.solicitudesCanje.map((solicitud) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.purple.shade100, child: Icon(Icons.star, color: Colors.purple.shade700, size: 22)),
                      title: Text(solicitud['nombre']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text("💰 \$${solicitud['costo']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: Colors.red.shade300, size: 28),
                            onPressed: () => perfilesProv.rechazarCanje(perfil.id, solicitud['idSolicitud']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green, size: 32),
                            onPressed: () => perfilesProv.aprobarCanje(perfil.id, solicitud),
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

        // MISIONES EXISTENTES AGRUPADAS
        Builder(
          builder: (context) {
            final Map<String, List<Tarea>> tareasAgrupadas = {};
            for (var tarea in todasLasTareas) {
              if (!tareasAgrupadas.containsKey(tarea.nombre)) {
                tareasAgrupadas[tarea.nombre] = [];
              }
              tareasAgrupadas[tarea.nombre]!.add(tarea);
            }

            final nombresOrdenados = tareasAgrupadas.keys.toList()..sort();
            final bloqueOrder = {'manana': 0, 'tarde': 1, 'noche': 2};

            return Column(
              children: nombresOrdenados.map((nombreGrupo) {
                final tareasDelGrupo = tareasAgrupadas[nombreGrupo]!;
                tareasDelGrupo.sort((a, b) => (bloqueOrder[a.bloque] ?? 3).compareTo(bloqueOrder[b.bloque] ?? 3));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24, top: 16, bottom: 8),
                      child: Text(
                        nombreGrupo.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, color: color.shade700, fontSize: 13, letterSpacing: 1.2),
                      ),
                    ),
                    ...tareasDelGrupo.map((tarea) {
                      final esAprobada = tarea.ultimoDiaCompletado == tareaProv.fechaIdHoy;

                      // Accesibilidad: Usar colores sólidos de alto contraste en lugar de opacidad
                      return Semantics(
                        label: esAprobada 
                            ? "¡Misión cumplida! ${tarea.nombre}. Ya está aprobada por hoy." 
                            : "Misión: ${tarea.nombre}. Toca para ver opciones de edición.",
                        button: !esAprobada,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: esAprobada ? AppTheme.accessibleGrey : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: ListTile(
                            minVerticalPadding: 16, // Asegura altura de toque > 48dp
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: esAprobada ? Colors.white.withValues(alpha: 0.5) : color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(tarea.icono, color: esAprobada ? AppTheme.highContrastGrey : color, size: 24),
                            ),
                            title: Text(
                              tarea.nombre, 
                              style: TextStyle(
                                fontWeight: FontWeight.w600, 
                                fontSize: 16,
                                color: esAprobada ? AppTheme.highContrastGrey : Colors.black87,
                              )
                            ),
                            subtitle: Text(
                              "${_bloqueLabel(tarea.bloque)} • ${tarea.esObligatoria ? '🔑 Obligatoria' : '💰 ${tarea.puntos} pts'}",
                              style: TextStyle(
                                color: esAprobada ? AppTheme.highContrastGrey : Colors.grey.shade600, 
                                fontSize: 14,
                              ),
                            ),
                            trailing: esAprobada
                              ? const Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: Icon(Icons.check_circle, color: Colors.green, size: 30),
                                )
                              : Row(
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
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            );
          }
        ),
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

  void _mostrarDialogoTiendaAdmin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetTiendaAdmin(perfilId: perfil.id, perfilesProv: perfilesProv),
    );
  }
}

// ============ QUICK ACTION BUTTON ============

class _AccionRapida extends StatelessWidget {
  final IconData icono;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? semanticLabel;

  const _AccionRapida({
    required this.icono,
    required this.label,
    required this.color,
    required this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? "Acción: $label",
      button: true,
      hint: "Toca para abrir $label",
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 80), // WCAG: Altura mínima
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }
}

// ============ TIENDA BOTTOM SHEET ============

class _BottomSheetTiendaAdmin extends StatefulWidget {
  final String perfilId;
  final PerfilesProvider perfilesProv;

  const _BottomSheetTiendaAdmin({required this.perfilId, required this.perfilesProv});

  @override
  State<_BottomSheetTiendaAdmin> createState() => _BottomSheetTiendaAdminState();
}

class _BottomSheetTiendaAdminState extends State<_BottomSheetTiendaAdmin> {
  final _nombreCtrl = TextEditingController();
  final _costoCtrl = TextEditingController();
  String? _idPremioEdicion;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _costoCtrl.dispose();
    super.dispose();
  }

  void _limpiarFormulario() {
    _nombreCtrl.clear();
    _costoCtrl.clear();
    setState(() {
      _idPremioEdicion = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _guardarPremio() {
    if (_nombreCtrl.text.isNotEmpty && _costoCtrl.text.isNotEmpty) {
      final premio = {
        'id': _idPremioEdicion ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'nombre': _nombreCtrl.text,
        'costo': int.tryParse(_costoCtrl.text) ?? 0,
        'icono': 'card_giftcard',
      };
      
      if (_idPremioEdicion == null) {
        widget.perfilesProv.agregarPremioAlCatalogo(widget.perfilId, premio);
      } else {
        widget.perfilesProv.editarPremioEnCatalogo(widget.perfilId, premio);
      }
      
      _limpiarFormulario();
    }
  }

  void _prepararEdicion(Map<dynamic, dynamic> p) {
    setState(() {
      _idPremioEdicion = p['id']?.toString();
      _nombreCtrl.text = p['nombre']?.toString() ?? '';
      _costoCtrl.text = p['costo']?.toString() ?? '';
    });
  }

  void _confirmarEliminacion(Map<dynamic, dynamic> p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Eliminar premio?"),
        content: Text("¿Estás seguro de que quieres eliminar '${p['nombre']}' de la tienda?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR")),
          TextButton(
            onPressed: () {
              widget.perfilesProv.eliminarPremioDelCatalogo(widget.perfilId, p['id']?.toString() ?? '');
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Premio eliminado correctamente")));
            },
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final perfil = widget.perfilesProv.buscarPerfil(widget.perfilId);
    if (perfil == null) return const SizedBox();

    final premios = perfil.catalogoPremios;
    final bool editando = _idPremioEdicion != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(editando ? "📝 Editando Premio" : "🛒 Gestión de Tienda", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                ),
                if (editando) IconButton(icon: const Icon(Icons.cancel_outlined), onPressed: _limpiarFormulario),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            // Form to add/edit a prize
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: editando ? Colors.blue.shade50 : Colors.purple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: editando ? Colors.blue.shade200 : Colors.purple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(editando ? "Actualizar detalles del premio" : "Añadir nuevo premio", style: TextStyle(fontWeight: FontWeight.bold, color: editando ? Colors.blue : Colors.purple)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nombreCtrl,
                    decoration: InputDecoration(
                      labelText: "Nombre (ej. Media hora de TV)",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _costoCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Costo (pts)",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Semantics(
                        label: editando ? "Guardar cambios" : "Añadir premio al catálogo",
                        button: true,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: editando ? Colors.blue : Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(56, 56),
                          ),
                          onPressed: _guardarPremio,
                          child: Icon(editando ? Icons.check : Icons.add),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("Catálogo Actual", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (premios.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Aún no hay premios en la tienda. ¡Añade el primero!"),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: premios.length,
                  itemBuilder: (ctx, i) {
                    final p = premios[i];
                    return Card(
                      elevation: 0,
                      color: Colors.grey.shade100,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.star, color: Colors.white)),
                        title: Text(p['nombre']?.toString() ?? ''),
                        subtitle: Text("Costo: \$${p['costo']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                              onPressed: () => _prepararEdicion(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _confirmarEliminacion(p),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
