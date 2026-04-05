import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:animate_do/animate_do.dart';

import '../../providers/perfiles_provider.dart';
import '../../providers/tarea_provider.dart';
import '../../models/tarea_model.dart';
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
                              GestureDetector(
                                onTap: () {
                                  perfilesProv.limpiarPerfilActivo();
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
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
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistorialScreen())),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
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
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amber,
                                        foregroundColor: Colors.black87,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                        elevation: 6,
                                        shadowColor: Colors.amber.withValues(alpha: 0.5),
                                      ),
                                      icon: const Icon(Icons.celebration, size: 24),
                                      label: Text("¡RECLAMAR ${nombreMeta.toUpperCase()}!", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      onPressed: () {
                                        _confettiController.play();
                                        _mostrarDialogoReclamar(context, perfilesProv, perfilActual.id, nombreMeta, meta);
                                      },
                                    ),
                                  ],
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

  Widget _crearSeccion(String titulo, Color colorBase, List<Tarea> tareas, TareaProvider tareaProv, PerfilesProvider perfilesProv, bool esBloqueActivo, MaterialColor perfilColor) {
    if (tareas.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sección header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: esBloqueActivo ? colorBase.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: esBloqueActivo ? colorBase : Colors.grey)),
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

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: colorCard,
              borderRadius: BorderRadius.circular(16),
              border: tarea.esObligatoria ? Border.all(color: Colors.red.shade200, width: 1.5) : null,
              boxShadow: [
                if (interactuable) BoxShadow(color: colorBase.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3)),
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
                        backgroundColor: colorBase,
                        duration: const Duration(seconds: 2),
                      )
                    );
                  }
                } : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: interactuable
                              ? LinearGradient(colors: [colorBase.withValues(alpha: 0.15), colorBase.withValues(alpha: 0.05)])
                              : LinearGradient(colors: [Colors.grey.shade100, Colors.grey.shade200]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(tarea.icono, color: interactuable ? colorBase : Colors.grey, size: 26),
                      ),
                      const SizedBox(width: 14),
                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tarea.nombre, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: interactuable ? Colors.black87 : Colors.grey)),
                            const SizedBox(height: 2),
                            Text(
                              tarea.estaEnRevision 
                                ? "⏳ En espera de aprobación..." 
                                : (tarea.esObligatoria ? "🔑 Obligatorio" : "💰 + \$${tarea.puntos}"),
                              style: TextStyle(
                                color: tarea.estaEnRevision ? Colors.orange : (tarea.esObligatoria ? Colors.red : Colors.green.shade600), 
                                fontWeight: FontWeight.w600, 
                                fontSize: 13
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
                                color: colorBase.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.touch_app, color: colorBase, size: 24),
                            )
                          : Icon(iconStatus, color: colorStatus, size: 30),
                    ],
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
