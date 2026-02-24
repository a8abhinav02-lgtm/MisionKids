import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math';

import 'tarea_model.dart';
import 'tarea_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TareaAdapter());
  runApp(const MiAppTareas());
}

class MiAppTareas extends StatelessWidget {
  const MiAppTareas({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TareaProvider()..inicializar(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Misión Switch 2',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFFF0F4F8),
          useMaterial3: true,
          fontFamily: 'Roboto',
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        home: const ControladorInicio(),
      ),
    );
  }
}

// --- CONTROLADOR DE INICIO ---
class ControladorInicio extends StatelessWidget {
  const ControladorInicio({super.key});

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<TareaProvider>(context);

    if (proveedor.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!proveedor.existeAdmin) return const PantallaSetup();
    return const PantallaSeleccionRol();
  }
}

// --- PANTALLA SETUP ---
class PantallaSetup extends StatefulWidget {
  const PantallaSetup({super.key});
  @override
  State<PantallaSetup> createState() => _PantallaSetupState();
}

class _PantallaSetupState extends State<PantallaSetup> {
  final _pinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  final _nombreHijoCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(Icons.security, size: 80, color: Colors.amber),
                  const SizedBox(height: 20),
                  const Text("Bienvenido Padre/Madre", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        const Text("1. Crea tu PIN de Administrador", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextField(controller: _pinCtrl, keyboardType: TextInputType.number, obscureText: true, decoration: const InputDecoration(labelText: "PIN (4 dígitos)")),
                        const SizedBox(height: 10),
                        TextField(controller: _confirmPinCtrl, keyboardType: TextInputType.number, obscureText: true, decoration: const InputDecoration(labelText: "Confirmar PIN")),
                        const Divider(height: 30),
                        const Text("2. ¿Cómo se llama tu hijo/a?", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextField(controller: _nombreHijoCtrl, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: "Nombre")),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                          onPressed: () {
                            if (_pinCtrl.text.length < 4 || _pinCtrl.text != _confirmPinCtrl.text || _nombreHijoCtrl.text.isEmpty) return;
                            final prov = Provider.of<TareaProvider>(context, listen: false);
                            prov.registrarAdminInicial(_pinCtrl.text, _nombreHijoCtrl.text);
                          },
                          child: const Text("GUARDAR Y COMENZAR"),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- PANTALLA SELECCIÓN ROL ---
class PantallaSeleccionRol extends StatelessWidget {
  const PantallaSeleccionRol({super.key});
  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<TareaProvider>(context);
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                FadeInDown(duration: const Duration(seconds: 1), child: const Icon(Icons.rocket_launch, size: 80, color: Colors.amber)),
                const SizedBox(height: 20),
                FadeInDown(delay: const Duration(milliseconds: 200), child: const Text("Misión: Switch 2", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white))),
                const SizedBox(height: 50),
                FadeInLeft(delay: const Duration(milliseconds: 400), child: _BotonRol(titulo: "Soy ${proveedor.nombreHijo}", subtitulo: "¡A ganar puntos!", icono: Icons.gamepad, colorFondo: Colors.white, colorTexto: Colors.indigo, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaPrincipal())))),
                const SizedBox(height: 20),
                FadeInRight(delay: const Duration(milliseconds: 600), child: _BotonRol(titulo: "Soy Papá / Mamá", subtitulo: "Zona de Control", icono: Icons.admin_panel_settings, colorFondo: Colors.indigo[700]!, colorTexto: Colors.white, onTap: () => _mostrarLoginPadre(context, proveedor))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarLoginPadre(BuildContext context, TareaProvider proveedor) {
    final TextEditingController pinController = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Zona de Padres 🔒"), content: TextField(controller: pinController, keyboardType: TextInputType.number, obscureText: true, autofocus: true, decoration: const InputDecoration(labelText: "PIN", prefixIcon: Icon(Icons.lock))), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")), ElevatedButton(onPressed: () { if (pinController.text == proveedor.pinPadre) { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaAdmin())); } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PIN Incorrecto ⛔"), backgroundColor: Colors.red)); } }, child: const Text("Entrar"))]));
  }
}

class _BotonRol extends StatelessWidget {
  final String titulo, subtitulo;
  final IconData icono;
  final Color colorFondo, colorTexto;
  final VoidCallback onTap;
  const _BotonRol({required this.titulo, required this.subtitulo, required this.icono, required this.colorFondo, required this.colorTexto, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(width: MediaQuery.of(context).size.width * 0.85, constraints: const BoxConstraints(maxWidth: 400), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: colorFondo, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 5))]), child: Row(children: [Icon(icono, size: 40, color: colorTexto), const SizedBox(width: 20), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(titulo, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorTexto)), Text(subtitulo, style: TextStyle(fontSize: 14, color: colorTexto.withOpacity(0.7)))]))])));
  }
}

// --- PANTALLA PRINCIPAL (HIJO) ---
class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});
  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
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
    final proveedor = Provider.of<TareaProvider>(context);

    final dineroActual = proveedor.totalDinero;
    final meta = proveedor.metaAhorro;
    final nombreMeta = proveedor.nombreMeta;

    // Lógica de estados del reto
    bool hayMetaDefinida = meta > 0;
    bool metaCumplida = hayMetaDefinida && dineroActual >= meta;

    double porcentaje = 0.0;
    if (hayMetaDefinida && dineroActual > 0) porcentaje = (dineroActual / meta).clamp(0.0, 1.0);

    String bloqueActual = proveedor.bloqueActual;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Column(
              children: [
                // HEADER DINÁMICO
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.indigo, Colors.blueAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
                          Text("Misiones de ${proveedor.nombreHijo} 🚀", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.emoji_events, color: Colors.amber, size: 30),
                            tooltip: "Salón de la Fama",
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaHistorial()));
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ZONA DE PROGRESO / META
                      if (!hayMetaDefinida) ...[
                        // ESTADO: ESPERANDO MISIÓN
                        const Card(
                          color: Colors.white24,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.hourglass_empty, color: Colors.white),
                                SizedBox(width: 10),
                                Text("¡Pide a Papá una nueva misión!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        )
                      ] else if (metaCumplida) ...[
                        // ESTADO: META CUMPLIDA (BOTÓN DE CANJE)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.indigo,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                          ),
                          icon: const Icon(Icons.check_circle, size: 30),
                          label: Text("¡RECLAMAR ${nombreMeta.toUpperCase()}!", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          onPressed: () {
                            _confettiController.play();
                            _mostrarDialogoReclamar(context, proveedor);
                          },
                        )
                      ] else ...[
                        // ESTADO: EN PROGRESO
                        Text("Meta: $nombreMeta (\$${meta.toInt()})", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(value: porcentaje, minHeight: 20, backgroundColor: Colors.black26, color: Colors.amber),
                        ),
                      ],

                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("\$ $dineroActual", style: TextStyle(color: dineroActual < 0 ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
                          if(hayMetaDefinida && !metaCumplida)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
                              child: Text("${(porcentaje * 100).toStringAsFixed(1)} %", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 20)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: proveedor.listaTareasActivas.isEmpty
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                        SizedBox(height: 20),
                        Text("¡Todo listo por ahora! 🎉", style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  )
                      : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      FadeInUp(delay: const Duration(milliseconds: 200), child: _crearSeccion("🌞 Mañana", Colors.orange, proveedor.tareasManana, proveedor, bloqueActual == 'manana')),
                      const SizedBox(height: 20),
                      FadeInUp(delay: const Duration(milliseconds: 400), child: _crearSeccion("⛅ Tarde", Colors.blue, proveedor.tareasTarde, proveedor, bloqueActual == 'tarde')),
                      const SizedBox(height: 20),
                      FadeInUp(delay: const Duration(milliseconds: 600), child: _crearSeccion("🌙 Noche", Colors.indigo, proveedor.tareasNoche, proveedor, bloqueActual == 'noche')),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),

          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            gravity: 0.3,
            numberOfParticles: 50,
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoReclamar(BuildContext context, TareaProvider proveedor) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("🎉 ¡FELICIDADES! 🎉", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.card_giftcard, size: 60, color: Colors.indigo),
              const SizedBox(height: 20),
              Text("Has conseguido: ${proveedor.nombreMeta}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              Text("Costo: \$${proveedor.metaAhorro.toInt()}"),
              const SizedBox(height: 20),
              const Text("Se descontará de tus ahorros y podrás empezar una nueva misión.", textAlign: TextAlign.center),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              onPressed: () {
                proveedor.reclamarPremio();
                Navigator.pop(ctx); // Cierra diálogo
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Premio reclamado! Disfrútalo.")));
              },
              child: const Text("¡CANJEAR AHORA!"),
            )
          ],
        )
    );
  }

  Widget _crearSeccion(String titulo, Color colorBase, List<Tarea> tareas, TareaProvider proveedor, bool esBloqueActivo) {
    if (tareas.isEmpty) return const SizedBox.shrink();
    final Color colorTexto = esBloqueActivo ? colorBase : Colors.grey;
    final double opacidad = esBloqueActivo ? 1.0 : 0.6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 8, bottom: 10), child: Row(children: [Text(titulo, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorTexto)), if (esBloqueActivo) Pulse(infinite: true, child: const Padding(padding: EdgeInsets.only(left: 8.0), child: Icon(Icons.star, color: Colors.amber, size: 20))), if (!esBloqueActivo) const Padding(padding: EdgeInsets.only(left: 8.0), child: Icon(Icons.lock_clock, color: Colors.grey, size: 18))])),
        ...tareas.map((tarea) {
          Color colorCard = Colors.white;
          IconData iconStatus = Icons.check_box_outline_blank;
          Color colorStatus = Colors.grey;
          if (tarea.estaEnRevision) { colorCard = Colors.orange[50]!; iconStatus = Icons.hourglass_top; colorStatus = Colors.orange; }
          bool interactuable = tarea.estaPendiente && esBloqueActivo;
          return Opacity(opacity: opacidad, child: Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), boxShadow: [if (interactuable) BoxShadow(color: colorBase.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]), child: Card(elevation: 0, margin: EdgeInsets.zero, color: colorCard, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: tarea.esObligatoria ? BorderSide(color: Colors.red.shade300, width: 1.5) : BorderSide.none), child: ListTile(enabled: interactuable, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: LinearGradient(colors: interactuable ? [colorBase.withOpacity(0.2), colorBase.withOpacity(0.05)] : [Colors.grey.shade200, Colors.grey.shade300], begin: Alignment.topLeft, end: Alignment.bottomRight), shape: BoxShape.circle), child: Icon(tarea.icono, color: interactuable ? colorBase : Colors.grey, size: 28)), title: Text(tarea.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)), subtitle: Text(tarea.esObligatoria ? "🔑 Obligatorio" : "💰 + \$${tarea.puntos}", style: TextStyle(color: tarea.esObligatoria ? Colors.red : Colors.green[700], fontWeight: FontWeight.w600)), trailing: interactuable ? IconButton(icon: const Icon(Icons.check_box_outline_blank, size: 34, color: Colors.grey), onPressed: () { _confettiController.play(); proveedor.solicitarRevision(tarea); }) : Icon(iconStatus, color: colorStatus, size: 34)))));
        }),
      ],
    );
  }
}

// --- PANTALLA HISTORIAL (CON VICTORIAS) ---
class PantallaHistorial extends StatelessWidget {
  const PantallaHistorial({super.key});

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<TareaProvider>(context);
    final historialDia = proveedor.listaHistorialHoy;
    final historialVictorias = proveedor.historialVictorias; // Lista de premios ganados

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Salón de la Fama 🏆"),
          backgroundColor: Colors.indigo,
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
                // Invertimos la lista para ver lo más reciente primero
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
    );
  }
}

// --- PANTALLA ADMIN ---
class PantallaAdmin extends StatelessWidget {
  const PantallaAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<TareaProvider>(context);

    // Datos de Meta
    final double dineroActual = proveedor.totalDinero.toDouble();
    final double meta = proveedor.metaAhorro;
    final String nombreMeta = proveedor.nombreMeta;
    final bool hayMeta = meta > 0;

    double porcentaje = 0.0;
    if (hayMeta && dineroActual > 0) porcentaje = (dineroActual / meta).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text("Panel de Control 🛠️"), backgroundColor: Colors.grey[800], foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nueva Tarea", style: TextStyle(color: Colors.white)),
        onPressed: () => _mostrarFormularioTarea(context, null),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            // SECCIÓN DE META / RETO ACTUAL
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("🎯 Reto Actual", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      if (hayMeta) IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _dialogoDefinirMeta(context, proveedor))
                    ]),
                    const Divider(),
                    if (!hayMeta) ...[
                      const Text("No hay un reto activo. Josué está esperando una misión.", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                          icon: const Icon(Icons.add_task),
                          label: const Text("DEFINIR NUEVO RETO"),
                          onPressed: () => _dialogoDefinirMeta(context, proveedor),
                        ),
                      )
                    ] else ...[
                      Text(nombreMeta, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(value: porcentaje, minHeight: 10, color: Colors.green, backgroundColor: Colors.grey[200]),
                      const SizedBox(height: 5),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("\$${dineroActual.toInt()} acumulados"),
                        Text("Meta: \$${meta.toInt()}"),
                      ]),
                    ]
                  ],
                ),
              ),
            ),

            // BOTÓN DE SANCIÓN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                label: const Text("Aplicar Sanción / Multa", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                onPressed: () => _mostrarDialogoSancion(context, proveedor),
              ),
            ),

            // LISTA DE TAREAS POR REVISAR (Igual que antes)
            if (proveedor.tareasPorRevisar.isNotEmpty)
              FadeInDown(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.orange)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [Icon(Icons.notifications_active, color: Colors.orange), SizedBox(width: 10), Text("Tareas esperando aprobación", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange))]),
                      const SizedBox(height: 10),
                      ...proveedor.tareasPorRevisar.map((tarea) => Card(
                        elevation: 0,
                        color: Colors.white,
                        child: ListTile(
                          leading: Icon(tarea.icono, color: Colors.grey),
                          title: Text(tarea.nombre),
                          subtitle: Text("\$ ${tarea.puntos}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => proveedor.rechazarTarea(tarea)),
                              IconButton(icon: const Icon(Icons.check_circle, color: Colors.green, size: 30), onPressed: () => proveedor.aprobarTarea(tarea)),
                            ],
                          ),
                        ),
                      ))
                    ],
                  ),
                ),
              ),

            const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15), child: Text("Inventario de Misiones (Reutilizables)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey))),

            ...proveedor.listaTodasLasTareas.map((tarea) {
              final hoyId = int.parse(DateFormat('yyyyMMdd').format(DateTime.now()));
              bool yaAprobadaHoy = tarea.estado == 'aprobada' && tarea.ultimoDiaCompletado == hoyId;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.indigo.withOpacity(0.1), child: Icon(tarea.icono, color: Colors.indigo, size: 20)),
                  title: Text(tarea.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text("${tarea.bloque.toUpperCase()} • 💰 ${tarea.puntos}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!yaAprobadaHoy) IconButton(icon: const Icon(Icons.check_circle_outline, color: Colors.green), onPressed: () => _confirmarAprobacionManual(context, proveedor, tarea)),
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _mostrarFormularioTarea(context, tarea)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmarBorrar(context, proveedor, tarea)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // --- NUEVO DIÁLOGO PARA DEFINIR META ---
  void _dialogoDefinirMeta(BuildContext context, TareaProvider proveedor) {
    final nombreCtrl = TextEditingController(text: proveedor.nombreMeta);
    final montoCtrl = TextEditingController(text: proveedor.metaAhorro > 0 ? proveedor.metaAhorro.toInt().toString() : '');

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("Definir Nuevo Reto 🎯"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre del Premio", hintText: "Ej: Nintendo Switch, Cine...")),
          const SizedBox(height: 10),
          TextField(controller: montoCtrl, decoration: const InputDecoration(labelText: "Costo (Puntos)", prefixText: "\$ "), keyboardType: TextInputType.number),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
        ElevatedButton(onPressed: () {
          if (nombreCtrl.text.isNotEmpty && montoCtrl.text.isNotEmpty) {
            proveedor.definirNuevaMeta(nombreCtrl.text, double.tryParse(montoCtrl.text) ?? 0);
            Navigator.pop(ctx);
          }
        }, child: const Text("Guardar Meta"))
      ],
    ));
  }

  void _mostrarDialogoSancion(BuildContext context, TareaProvider proveedor) {
    final motivoCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("⚠️ Aplicar Sanción"), content: Column(mainAxisSize: MainAxisSize.min, children: [const Text("Esto restará saldo."), TextField(controller: motivoCtrl, decoration: const InputDecoration(labelText: "Motivo")), TextField(controller: montoCtrl, decoration: const InputDecoration(labelText: "Monto"), keyboardType: TextInputType.number)]), actions: [ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), onPressed: () { if (motivoCtrl.text.isNotEmpty && montoCtrl.text.isNotEmpty) { proveedor.aplicarSancion(motivoCtrl.text, int.tryParse(montoCtrl.text) ?? 0); Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sanción aplicada."))); } }, child: const Text("Aplicar"))]));
  }

  void _confirmarAprobacionManual(BuildContext context, TareaProvider proveedor, Tarea tarea) {
    proveedor.aprobarTareaManual(tarea);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aprobada manualmente")));
  }

  void _confirmarBorrar(BuildContext context, TareaProvider proveedor, Tarea tarea) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Eliminar"), content: Text("¿Borrar ${tarea.nombre}?"), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")), TextButton(onPressed: () { proveedor.eliminarTarea(tarea); Navigator.pop(ctx); }, child: const Text("Sí"))]));
  }

  void _mostrarFormularioTarea(BuildContext context, Tarea? tareaExistente) {
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))), builder: (_) => FormularioTarea(tarea: tareaExistente));
  }
}

// --- FORMULARIO TAREA (Igual que V2.4) ---
class FormularioTarea extends StatefulWidget {
  final Tarea? tarea;
  const FormularioTarea({super.key, this.tarea});
  @override
  State<FormularioTarea> createState() => _FormularioTareaState();
}

class _FormularioTareaState extends State<FormularioTarea> {
  final _nombreCtrl = TextEditingController();
  final _puntosCtrl = TextEditingController();
  String _bloque = 'manana';
  bool _esObligatoria = false;
  IconData _icono = Icons.star;
  String _tipoRecurrencia = 'diaria';
  List<int> _diasSeleccionados = [1, 2, 3, 4, 5, 6, 7];
  DateTime? _fechaFija;

  final List<Map<String, dynamic>> _plantillas = [
    {"nombre": "Cepillarse Dientes", "puntos": "0", "obligatoria": true, "icono": Icons.cleaning_services, "bloque": "manana", "recurrencia": "diaria"},
    {"nombre": "Bañarse", "puntos": "0", "obligatoria": true, "icono": Icons.bathtub, "bloque": "manana", "recurrencia": "diaria"},
    {"nombre": "Hacer la Cama", "puntos": "100", "obligatoria": true, "icono": Icons.bed, "bloque": "manana", "recurrencia": "diaria"},
    {"nombre": "Hacer Tareas Escuela", "puntos": "500", "obligatoria": true, "icono": Icons.school, "bloque": "tarde", "recurrencia": "semanal"},
    {"nombre": "Recoger Juguetes", "puntos": "200", "obligatoria": false, "icono": Icons.toys, "bloque": "noche", "recurrencia": "diaria"},
  ];
  final List<IconData> _iconosDisponibles = [Icons.cleaning_services, Icons.checkroom, Icons.local_dining, Icons.piano, Icons.menu_book, Icons.backpack, Icons.bed, Icons.school, Icons.pets, Icons.sports_soccer, Icons.computer, Icons.star, Icons.directions_bike, Icons.pool, Icons.bathtub, Icons.toys, Icons.roller_skating];

  @override
  void initState() {
    super.initState();
    if (widget.tarea != null) {
      _nombreCtrl.text = widget.tarea!.nombre;
      _puntosCtrl.text = widget.tarea!.puntos.toString();
      _bloque = widget.tarea!.bloque;
      _esObligatoria = widget.tarea!.esObligatoria;
      _icono = widget.tarea!.icono;
      _tipoRecurrencia = widget.tarea!.tipoRecurrencia;
      _diasSeleccionados = List.from(widget.tarea!.diasSemana);
      _fechaFija = widget.tarea!.fechaEspecifica;
    }
  }

  void _cargarPlantilla(Map<String, dynamic> plantilla) {
    setState(() {
      _nombreCtrl.text = plantilla["nombre"];
      _puntosCtrl.text = plantilla["puntos"];
      _esObligatoria = plantilla["obligatoria"];
      _icono = plantilla["icono"];
      _bloque = plantilla["bloque"];
      _tipoRecurrencia = plantilla["recurrencia"];
      _diasSeleccionados = [1, 2, 3, 4, 5, 6, 7];
    });
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<TareaProvider>(context, listen: false);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding, left: 20, right: 20, top: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(widget.tarea == null ? "Nueva Misión" : "Editar Misión", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]),
            if (widget.tarea == null) ...[ const SizedBox(height: 10), const Text("🚀 Rutinas Rápidas:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)), SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _plantillas.map((p) => Padding(padding: const EdgeInsets.only(right: 8.0), child: ActionChip(avatar: Icon(p['icono'], size: 16, color: Colors.white), label: Text(p['nombre']), backgroundColor: Colors.indigo.shade300, labelStyle: const TextStyle(color: Colors.white, fontSize: 12), onPressed: () => _cargarPlantilla(p)))).toList())), const Divider(height: 25)],
            TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: "Nombre Tarea", prefixIcon: Icon(Icons.task_alt))),
            const SizedBox(height: 10),
            Row(children: [Expanded(child: TextField(controller: _puntosCtrl, decoration: const InputDecoration(labelText: "Puntos", prefixIcon: Icon(Icons.monetization_on)), keyboardType: TextInputType.number)), const SizedBox(width: 10), Expanded(child: Container(decoration: BoxDecoration(color: _esObligatoria ? Colors.red[50] : Colors.grey[100], borderRadius: BorderRadius.circular(12), border: _esObligatoria ? Border.all(color: Colors.red.shade300) : null), child: SwitchListTile(title: const Text("Llave 🔑", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: const Text("Obligatoria", style: TextStyle(fontSize: 10)), value: _esObligatoria, activeColor: Colors.red, dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10), onChanged: (val) => setState(() => _esObligatoria = val))))]),
            const SizedBox(height: 15),
            const Text("Frecuencia:", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(spacing: 8.0, children: [ChoiceChip(label: const Text("Diaria"), selected: _tipoRecurrencia == 'diaria', onSelected: (val) => setState(() => _tipoRecurrencia = 'diaria')), ChoiceChip(label: const Text("Días Específicos"), selected: _tipoRecurrencia == 'semanal', onSelected: (val) => setState(() => _tipoRecurrencia = 'semanal')), ChoiceChip(label: const Text("Reto Único (Fecha)"), selected: _tipoRecurrencia == 'fecha_fija', onSelected: (val) => setState(() => _tipoRecurrencia = 'fecha_fija'))]),
            if (_tipoRecurrencia == 'semanal') Wrap(spacing: 5, children: [for (var i = 1; i <= 7; i++) FilterChip(label: Text(['L','M','X','J','V','S','D'][i-1]), selected: _diasSeleccionados.contains(i), onSelected: (selected) { setState(() { if (selected) { _diasSeleccionados.add(i); } else { _diasSeleccionados.remove(i); } }); })]),
            if (_tipoRecurrencia == 'fecha_fija') ListTile(title: Text(_fechaFija == null ? "Seleccionar Fecha" : DateFormat('dd/MM/yyyy').format(_fechaFija!)), leading: const Icon(Icons.calendar_today, color: Colors.indigo), tileColor: Colors.grey[200], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), onTap: () async { final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030)); if (picked != null) setState(() => _fechaFija = picked); }),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(value: _bloque, items: const [DropdownMenuItem(value: 'manana', child: Text("🌞 Mañana")), DropdownMenuItem(value: 'tarde', child: Text("⛅ Tarde")), DropdownMenuItem(value: 'noche', child: Text("🌙 Noche"))], onChanged: (val) => setState(() => _bloque = val!)),
            const SizedBox(height: 10),
            SizedBox(height: 60, child: ListView(scrollDirection: Axis.horizontal, children: _iconosDisponibles.map((icon) => GestureDetector(onTap: () => setState(() => _icono = icon), child: Container(margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _icono == icon ? Colors.indigo : Colors.grey[200], shape: BoxShape.circle), child: Icon(icon, color: _icono == icon ? Colors.white : Colors.black54)))).toList())),
            const SizedBox(height: 20),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)), onPressed: () {
              if (_nombreCtrl.text.isEmpty) return;
              if (widget.tarea == null) {
                proveedor.agregarTarea(nombre: _nombreCtrl.text, puntos: int.tryParse(_puntosCtrl.text) ?? 0, obligatoria: _esObligatoria, icon: _icono, bloque: _bloque, tipoRecurrencia: _tipoRecurrencia, diasSemana: _diasSeleccionados, fechaEspecifica: _fechaFija);
              } else {
                proveedor.editarTarea(widget.tarea!, nombre: _nombreCtrl.text, puntos: int.tryParse(_puntosCtrl.text) ?? 0, obligatoria: _esObligatoria, icon: _icono, bloque: _bloque, tipoRecurrencia: _tipoRecurrencia, diasSemana: _diasSeleccionados, fechaEspecifica: _fechaFija);
              }
              Navigator.pop(context);
            }, child: Text(widget.tarea == null ? "CREAR MISIÓN" : "GUARDAR CAMBIOS")),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}