import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:animate_do/animate_do.dart';

import '../../providers/perfiles_provider.dart';
import '../../providers/tarea_provider.dart';
import '../../models/tarea_model.dart';
import '../../models/perfil_model.dart';
import '../../models/perfil_model.dart';
import '../themes/app_theme.dart';
import 'historial_screen.dart';

class HomeNinoScreen extends StatefulWidget {
  const HomeNinoScreen({super.key});

  @override
  State<HomeNinoScreen> createState() => _HomeNinoScreenState();
}

class _HomeNinoScreenState extends State<HomeNinoScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final perfilesProv = Provider.of<PerfilesProvider>(context);
    final tareaProv = Provider.of<TareaProvider>(context);

    final perfilActual = perfilesProv.perfilActivo;
    if (perfilActual == null) return const Scaffold(body: Center(child: Text("Sin Perfil")));

    final temaDelNino = AppTheme.getThemeByColor(perfilActual.colorPrimario);
    final color = AppTheme.colors[perfilActual.colorPrimario] ?? Colors.indigo;

    final dineroActual = perfilActual.saldo;
    final meta = perfilActual.metaAhorro;
    final nombreMeta = perfilActual.nombreMeta;

    bool hayMetaDefinida = meta > 0;
    bool metaCumplida = hayMetaDefinida && dineroActual >= meta;

    double porcentaje = 0.0;
    if (hayMetaDefinida && dineroActual > 0) porcentaje = (dineroActual / meta).clamp(0.0, 1.0);

    String bloqueActual = tareaProv.bloqueActual;

    return Theme(
      data: temaDelNino,
      child: Scaffold(
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.shade800, color.shade500],
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // ===== HEADER =====
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Column(
                        children: [
                          // Top Row
                          Row(
                            children: [
                              Semantics(
                                label: "Cerrar sesión y volver a selección de perfil",
                                button: true,
                                child: GestureDetector(
                                  onTap: () {
                                    perfilesProv.limpiarPerfilActivo();
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Column(
                                children: [
                                  Text(
                                    "¡Hola, ${perfilActual.nombre}!",
                                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    _saludoHora(),
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Semantics(
                                label: "Ver mis logros y salón de la fama",
                                button: true,
                                child: GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistorialScreen())),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.emoji_events, color: Colors.amber, size: 26),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Saldo
                          FadeInDown(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                              ),
                              child: Column(
                                children: [
                                  Text("Mi Saldo", style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "\$ $dineroActual",
                                    style: TextStyle(
                                      color: dineroActual < 0 ? Colors.redAccent : Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 36,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  if (hayMetaDefinida && !metaCumplida) ...[
                                    const SizedBox(height: 14),
                                    Text("🎯 $nombreMeta", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(value: porcentaje, minHeight: 12, backgroundColor: Colors.white24, color: Colors.amber),
                                    ),
                                    const SizedBox(height: 6),
                                    Text("${(porcentaje * 100).toStringAsFixed(1)}% completado", style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                                  ],
                                  if (!hayMetaDefinida)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text("¡Pide a Papá una nueva misión!", style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
                                    ),
                                  if (metaCumplida) ...[
                                    const SizedBox(height: 14),
                                    Semantics(
                                      label: "¡Felicidades! Toca aquí para reclamar tu premio principal: $nombreMeta",
                                      button: true,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber,
                                          foregroundColor: Colors.black87,
                                          minimumSize: const Size(200, 56), // Objetivo de toque amplio
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                          elevation: 6,
                                          shadowColor: Colors.amber.withValues(alpha: 0.5),
                                        ),
                                        icon: const Icon(Icons.celebration, size: 28),
                                        label: Text("¡RECLAMAR ${nombreMeta.toUpperCase()}!", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        onPressed: () {
                                          _confettiController.play();
                                          _mostrarDialogoReclamar(context, perfilesProv, perfilActual.id, nombreMeta, meta);
                                        },
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  Semantics(
                                    label: "¡Es hora de recompensas! Toca para ver la tienda de premios y canjear tus monedas.",
                                    button: true,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: color,
                                        minimumSize: const Size(double.infinity, 56), // Accesibilidad WCAG
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        elevation: 2,
                                      ),
                                      icon: const Icon(Icons.storefront, size: 28),
                                      label: const Text("Tienda de Premios", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      onPressed: () => _mostrarTiendaNino(context, perfilesProv, perfilActual, color),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // ===== TASK LIST =====
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0F4F8),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                          child: tareaProv.listaTareasActivas(perfilActual.id).isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 80, color: Colors.green.shade300),
                                    const SizedBox(height: 20),
                                    const Text("¡Todo listo por ahora! 🎉", style: TextStyle(fontSize: 18, color: Colors.grey)),
                                  ],
                                ),
                              )
                            : ListView(
                                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                                children: [
                                  FadeInUp(delay: const Duration(milliseconds: 200), child: _crearSeccion("🌞 Mañana", Colors.orange, tareaProv.tareasManana(perfilActual.id), tareaProv, perfilesProv, bloqueActual == 'manana', color)),
                                  const SizedBox(height: 16),
                                  FadeInUp(delay: const Duration(milliseconds: 400), child: _crearSeccion("⛅ Tarde", Colors.blue, tareaProv.tareasTarde(perfilActual.id), tareaProv, perfilesProv, bloqueActual == 'tarde', color)),
                                  const SizedBox(height: 16),
                                  FadeInUp(delay: const Duration(milliseconds: 600), child: _crearSeccion("🌙 Noche", Colors.indigo, tareaProv.tareasNoche(perfilActual.id), tareaProv, perfilesProv, bloqueActual == 'noche', color)),
                                  const SizedBox(height: 40),
                                ],
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple, Colors.amber],
              gravity: 0.2,
              numberOfParticles: 60,
            ),
          ],
        ),
      ),
    );
  }

  String _saludoHora() {
    final hora = DateTime.now().hour;
    if (hora >= 5 && hora < 12) return "Buenos días ☀️";
    if (hora >= 12 && hora < 18) return "Buenas tardes 🌤️";
    return "Buenas noches 🌙";
  }

  void _mostrarDialogoReclamar(BuildContext context, PerfilesProvider proveedor, String perfilId, String nombreMeta, double saldoMeta) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("🎉 ¡FELICIDADES! 🎉", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.amber.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.card_giftcard, size: 50, color: Colors.amber),
            ),
            const SizedBox(height: 20),
            Text("Has conseguido:", style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(nombreMeta, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 10),
            Text("Costo: \$${saldoMeta.toInt()}", style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black87, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () {
                proveedor.reclamarPremio(perfilId);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Premio reclamado! 🎁")));
              },
              child: const Text("¡CANJEAR AHORA!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _crearSeccion(String titulo, Color color, List<Tarea> tareas, TareaProvider tareaProv, PerfilesProvider perfilesProv, bool esBloqueActivo, MaterialColor perfilColor) {
    if (tareas.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sección header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: esBloqueActivo ? color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: esBloqueActivo ? color : Colors.grey)),
              if (esBloqueActivo) Pulse(infinite: true, child: const Padding(padding: EdgeInsets.only(left: 8.0), child: Icon(Icons.bolt, color: Colors.amber, size: 20))),
              const Spacer(),
              Text("${tareas.length} misión${tareas.length > 1 ? 'es' : ''}", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...tareas.map((tarea) {
          Color colorCard = Colors.white;
          IconData iconStatus = Icons.radio_button_unchecked;
          Color colorStatus = Colors.grey.shade400;

          if (tarea.estaEnRevision) {
            colorCard = Colors.orange.shade50;
            iconStatus = Icons.hourglass_bottom;
            colorStatus = Colors.orange;
          }

          bool interactuable = tarea.estaPendiente && esBloqueActivo;

          return Semantics(
            label: interactuable 
              ? "Misión disponible: ${tarea.nombre}. Toca para marcar como terminada." 
              : (tarea.estaEnRevision 
                  ? "Misión ${tarea.nombre} enviada. Esperando que papá o mamá la revisen." 
                  : "Misión ${tarea.nombre}. No disponible en este momento."),
            button: interactuable,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: colorCard,
                borderRadius: BorderRadius.circular(16),
                border: tarea.esObligatoria ? Border.all(color: Colors.red.shade200, width: 1.5) : null,
                boxShadow: [
                  if (interactuable) BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: interactuable ? () {
                    final perfilId = perfilesProv.perfilActivo?.id;
                    if (perfilId != null && !tarea.esObligatoria && tareaProv.tieneObligatoriasPendientes(perfilId)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("⚠️ ¡Primero envía a revisión tus llaves 🔑 obligatorias!"),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                          )
                        );
                      }
                      return;
                    }

                    _confettiController.play();
                    tareaProv.solicitarRevision(tarea);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("¡${tarea.nombre} enviada! Espera a revisión 🕒"),
                          backgroundColor: color,
                          duration: const Duration(seconds: 2),
                        )
                      );
                    }
                  } : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Aumentado para accesibilidad
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: interactuable
                                ? LinearGradient(colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)])
                                : LinearGradient(colors: [Colors.grey.shade100, Colors.grey.shade200]),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(tarea.icono, color: interactuable ? color : AppTheme.highContrastGrey, size: 28),
                        ),
                        const SizedBox(width: 14),
                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min, // Evita height fijo
                            children: [
                              Text(tarea.nombre, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: interactuable ? Colors.black87 : AppTheme.highContrastGrey)),
                              const SizedBox(height: 4),
                              Text(
                                tarea.estaEnRevision 
                                  ? "⏳ En espera de aprobación..." 
                                  : (tarea.esObligatoria ? "🔑 Obligatorio" : "💰 + \$${tarea.puntos}"),
                                style: TextStyle(
                                  color: tarea.estaEnRevision ? Colors.orange.shade800 : (tarea.esObligatoria ? Colors.red : Colors.green.shade700), 
                                  fontWeight: FontWeight.w600, 
                                  fontSize: 14
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status
                        interactuable
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.touch_app, color: color, size: 24),
                            )
                          : Icon(iconStatus, color: colorStatus, size: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
      ],
    );
  }
}

void _mostrarTiendaNino(BuildContext context, PerfilesProvider perfilesProv, Perfil perfil, MaterialColor color) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BottomSheetTiendaNino(perfil: perfil, perfilesProv: perfilesProv, color: color),
  );
}

class _BottomSheetTiendaNino extends StatelessWidget {
  final Perfil perfil;
  final PerfilesProvider perfilesProv;
  final MaterialColor color;

  const _BottomSheetTiendaNino({required this.perfil, required this.perfilesProv, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4F8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: ListenableBuilder(
        listenable: perfilesProv,
        builder: (context, _) {
          final p = perfilesProv.buscarPerfil(perfil.id) ?? perfil;
          final premios = p.catalogoPremios;
          final saldo = p.saldo;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text("🛒 Tienda de Premios", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                      child: Text("\$ $saldo", style: TextStyle(color: color.shade700, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (premios.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text("La tienda está vacía.\n¡Pídele a Papá que añada premios!", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: premios.length,
                      itemBuilder: (ctx, i) {
                        final premio = premios[i];
                        final int costo = premio['costo'] ?? 0;
                        final bool alcanza = saldo >= costo;

                        return Card(
                          elevation: 2,
                          color: alcanza ? Colors.white : AppTheme.accessibleGrey,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: alcanza ? color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.card_giftcard, color: alcanza ? color : AppTheme.highContrastGrey, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        premio['nombre']?.toString() ?? '', 
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold, 
                                          fontSize: 16, 
                                          color: alcanza ? Colors.black87 : AppTheme.highContrastGrey
                                        )
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "\$ $costo", 
                                        style: TextStyle(
                                          color: alcanza ? Colors.green.shade700 : AppTheme.highContrastGrey, 
                                          fontWeight: FontWeight.w600, 
                                          fontSize: 14
                                        )
                                      ),
                                    ],
                                  ),
                                ),
                                Semantics(
                                  label: alcanza 
                                      ? "¡Lo lograste! Canjear ${premio['nombre']} por $costo monedas" 
                                      : "Ahorro en progreso. Te faltan ${costo - saldo} monedas para este premio.",
                                  button: alcanza,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: alcanza ? color : AppTheme.accessibleGrey,
                                      foregroundColor: alcanza ? Colors.white : AppTheme.highContrastGrey,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      minimumSize: const Size(64, 48), // Accesibilidad WCAG
                                      elevation: alcanza ? 2 : 0,
                                    ),
                                    onPressed: alcanza ? () async {
                                      await perfilesProv.canjearPremio(perfil.id, premio);
                                      if (ctx.mounted) {
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("¡Premio ${premio['nombre']} canjeado! 🎉", style: const TextStyle(fontSize: 16))));
                                      }
                                    } : null,
                                    child: Text(alcanza ? "CANJEAR" : "LOCKED", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
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
          );
        }
      ),
    );
  }
}
