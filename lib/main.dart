import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Necesario para formatear fechas
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

    if (proveedor.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!proveedor.existeAdmin) {
      return const PantallaSetup();
    } else {
      return const PantallaSeleccionRol();
    }
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.security, size: 80, color: Colors.amber),
                  const SizedBox(height: 20),
                  const Text("Bienvenido Padre/Madre", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text("Configuración Inicial", style: TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        const Text("1. Crea tu PIN de Administrador", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _pinCtrl,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: "PIN (4 dígitos)", prefixIcon: Icon(Icons.lock_outline)),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _confirmPinCtrl,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: "Confirmar PIN", prefixIcon: Icon(Icons.lock)),
                        ),
                        const Divider(height: 30),
                        const Text("2. ¿Cómo se llama tu hijo/a?", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nombreHijoCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(labelText: "Nombre del Hijo", prefixIcon: Icon(Icons.face)),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                          onPressed: () {
                            if (_pinCtrl.text.length < 4) return;
                            if (_pinCtrl.text != _confirmPinCtrl.text) return;
                            if (_nombreHijoCtrl.text.isEmpty) return;

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rocket_launch, size: 80, color: Colors.amber),
                const SizedBox(height: 20),
                const Text("Misión: Switch 2", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 50),
                _BotonRol(
                  titulo: "Soy ${proveedor.nombreHijo}",
                  subtitulo: "¡A ganar puntos!",
                  icono: Icons.gamepad,
                  colorFondo: Colors.white,
                  colorTexto: Colors.indigo,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaPrincipal())),
                ),
                const SizedBox(height: 20),
                _BotonRol(
                  titulo: "Soy Papá / Mamá",
                  subtitulo: "Zona de Control",
                  icono: Icons.admin_panel_settings,
                  colorFondo: Colors.indigo[700]!,
                  colorTexto: Colors.white,
                  onTap: () => _mostrarLoginPadre(context, proveedor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarLoginPadre(BuildContext context, TareaProvider proveedor) {
    final TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Zona de Padres 🔒"),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(labelText: "PIN de seguridad", prefixIcon: Icon(Icons.lock)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              if (pinController.text == proveedor.pinPadre) {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaAdmin()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PIN Incorrecto ⛔"), backgroundColor: Colors.red));
              }
            },
            child: const Text("Entrar"),
          )
        ],
      ),
    );
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: colorFondo, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 5))]),
        child: Row(
          children: [
            Icon(icono, size: 40, color: colorTexto),
            const SizedBox(width: 20),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(titulo, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorTexto)),
                Text(subtitulo, style: TextStyle(fontSize: 14, color: colorTexto.withOpacity(0.7))),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PANTALLA PRINCIPAL (HIJO) ---
class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<TareaProvider>(context);

    if (proveedor.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final dineroActual = proveedor.totalDinero;
    final meta = proveedor.metaAhorro;
    double porcentaje = (meta > 0) ? (dineroActual / meta).clamp(0.0, 1.0) : 0.0;
    String bloqueActual = proveedor.bloqueActual;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70), onPressed: () => Navigator.pop(context)),
                      Text("Misiones de ${proveedor.nombreHijo} 🚀", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text("Meta: \$${meta.toInt()}", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(value: porcentaje, minHeight: 20, backgroundColor: Colors.black26, color: Colors.amber),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("\$ $dineroActual", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                        child: Text("${(porcentaje * 100).toStringAsFixed(1)} %", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _crearSeccion("🌞 Mañana", Colors.orange, proveedor.tareasManana, proveedor, bloqueActual == 'manana'),
                  const SizedBox(height: 20),
                  _crearSeccion("⛅ Tarde", Colors.blue, proveedor.tareasTarde, proveedor, bloqueActual == 'tarde'),
                  const SizedBox(height: 20),
                  _crearSeccion("🌙 Noche", Colors.indigo, proveedor.tareasNoche, proveedor, bloqueActual == 'noche'),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _crearSeccion(String titulo, Color colorBase, List<Tarea> tareas, TareaProvider proveedor, bool esBloqueActivo) {
    if (tareas.isEmpty) return const SizedBox.shrink();
    final Color colorTexto = esBloqueActivo ? colorBase : Colors.grey;
    final double opacidad = esBloqueActivo ? 1.0 : 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 10),
          child: Row(
            children: [
              Text(titulo, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorTexto)),
              if (esBloqueActivo) const Padding(padding: EdgeInsets.only(left: 8.0), child: Icon(Icons.star, color: Colors.amber, size: 20)),
              if (!esBloqueActivo) const Padding(padding: EdgeInsets.only(left: 8.0), child: Icon(Icons.lock_clock, color: Colors.grey, size: 18))
            ],
          ),
        ),
        ...tareas.map((tarea) {
          // Lógica Visual de Estado
          Color colorCard = Colors.white;
          IconData iconStatus = Icons.check_box_outline_blank;
          Color colorStatus = Colors.grey;
          String textoStatus = "Pendiente";

          if (tarea.estaEnRevision) {
            colorCard = Colors.orange[50]!;
            iconStatus = Icons.hourglass_top;
            colorStatus = Colors.orange;
            textoStatus = "Revisando...";
          } else if (tarea.estaAprobada) {
            colorCard = Colors.green[50]!;
            iconStatus = Icons.check_circle;
            colorStatus = Colors.green;
            textoStatus = "¡Aprobada!";
          }

          // Solo se puede interactuar si es pendiente y el bloque es activo
          bool interactuable = tarea.estaPendiente && esBloqueActivo;

          return Opacity(
            opacity: opacidad,
            child: Card(
              elevation: interactuable ? 3 : 1,
              margin: const EdgeInsets.only(bottom: 10),
              color: colorCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: tarea.esObligatoria ? const BorderSide(color: Colors.red, width: 1) : BorderSide.none,
              ),
              child: ListTile(
                enabled: interactuable,
                leading: CircleAvatar(
                  backgroundColor: colorStatus.withOpacity(0.1),
                  child: Icon(tarea.icono, color: colorStatus),
                ),
                title: Text(tarea.nombre, style: TextStyle(fontWeight: FontWeight.bold, color: tarea.estaAprobada ? Colors.grey : Colors.black87)),
                subtitle: Text(tarea.esObligatoria ? "🔑 Obligatorio" : "💰 + \$${tarea.puntos}"),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (tarea.estaPendiente)
                      IconButton(
                        icon: const Icon(Icons.check_box_outline_blank, size: 30),
                        onPressed: interactuable ? () => proveedor.solicitarRevision(tarea) : null,
                      ),
                    if (!tarea.estaPendiente)
                      Icon(iconStatus, color: colorStatus, size: 30),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// --- PANTALLA ADMIN (PADRE) - VERSIÓN 2.1 DASHBOARD Y CATÁLOGO ---
class PantallaAdmin extends StatelessWidget {
  const PantallaAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<TareaProvider>(context);

    // Cálculos para la gráfica de progreso
    final double dineroActual = proveedor.totalDinero.toDouble();
    final double meta = proveedor.metaAhorro;
    final double porcentaje = (meta > 0) ? (dineroActual / meta).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Control 🛠️"),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),
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
            // --- SECCIÓN 1: NOTIFICACIONES DE REVISIÓN ---
            if (proveedor.tareasPorRevisar.isNotEmpty)
              Container(
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

            // --- SECCIÓN 2: DASHBOARD DE PROGRESO ---
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Progreso de Ahorro", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(icon: const Icon(Icons.edit, size: 20, color: Colors.grey), onPressed: () => _editarMeta(context, proveedor)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("\$ ${dineroActual.toInt()}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
                        Text("Meta: \$ ${meta.toInt()}", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: porcentaje,
                        minHeight: 15,
                        backgroundColor: Colors.grey[200],
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text("${(porcentaje * 100).toStringAsFixed(1)}% completado", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),

            // --- SECCIÓN 3: PERFIL HIJO ---
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.indigo[50],
              elevation: 0,
              child: ListTile(
                leading: const Icon(Icons.face, color: Colors.indigo),
                title: Text("Perfil de ${proveedor.nombreHijo}", style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.indigo), onPressed: () => _editarNombreHijo(context, proveedor)),
              ),
            ),

            const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15), child: Text("Inventario Total de Misiones", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo))),

            // --- SECCIÓN 4: CATÁLOGO COMPLETO ---
            if (proveedor.listaTodasLasTareas.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No hay tareas registradas."))),

            ...proveedor.listaTodasLasTareas.map((tarea) {
              String infoFrecuencia = "";
              if (tarea.tipoRecurrencia == 'diaria') infoFrecuencia = "Todos los días";
              else if (tarea.tipoRecurrencia == 'fecha_fija') infoFrecuencia = "📅 ${tarea.fechaEspecifica != null ? DateFormat('dd/MM/yyyy').format(tarea.fechaEspecifica!) : '?'}";
              else if (tarea.tipoRecurrencia == 'semanal') {
                const diasLetras = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                final diasTexto = tarea.diasSemana.map((d) => diasLetras[d-1]).join(", ");
                infoFrecuencia = "Semana: $diasTexto";
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.withOpacity(0.1),
                    child: Icon(tarea.icono, color: Colors.indigo, size: 20),
                  ),
                  title: Text(tarea.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${tarea.bloque.toUpperCase()} • $infoFrecuencia", style: const TextStyle(fontSize: 12)),
                      if(tarea.esObligatoria) const Text("🔑 Obligatoria", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold))
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmarBorrar(context, proveedor, tarea),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _editarNombreHijo(BuildContext context, TareaProvider proveedor) {
    final controller = TextEditingController(text: proveedor.nombreHijo);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Nombre del Hijo/a"),
        content: TextField(controller: controller, textCapitalization: TextCapitalization.words),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () { if(controller.text.isNotEmpty) { proveedor.actualizarConfiguracionHijo(controller.text); Navigator.pop(ctx); } }, child: const Text("Guardar"))
        ],
      ),
    );
  }

  void _editarMeta(BuildContext context, TareaProvider proveedor) {
    final controller = TextEditingController(text: proveedor.metaAhorro.toInt().toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cambiar Meta"),
        content: TextField(controller: controller, keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () { proveedor.actualizarMeta(double.tryParse(controller.text) ?? 2000000); Navigator.pop(ctx); }, child: const Text("Guardar"))
        ],
      ),
    );
  }

  void _confirmarBorrar(BuildContext context, TareaProvider proveedor, Tarea tarea) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Eliminar Tarea"), content: Text("¿Borrar '${tarea.nombre}'?"), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")), TextButton(onPressed: () { proveedor.eliminarTarea(tarea); Navigator.pop(ctx); }, style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text("Sí, borrar"))]));
  }

  void _mostrarFormularioTarea(BuildContext context, Tarea? tareaExistente) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => FormularioTarea(tarea: tareaExistente),
    );
  }
}

// --- FORMULARIO TAREA (VERSIÓN 2.2 - CORRECCIÓN UI + PATINAJE) ---
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

  // Variables de Recurrencia
  String _tipoRecurrencia = 'diaria';
  List<int> _diasSeleccionados = [1, 2, 3, 4, 5, 6, 7]; // Todos los días por defecto
  DateTime? _fechaFija;

  // LISTA DE PLANTILLAS PREDEFINIDAS
  final List<Map<String, dynamic>> _plantillas = [
    {
      "nombre": "Cepillarse Dientes",
      "puntos": "0",
      "obligatoria": true,
      "icono": Icons.cleaning_services,
      "bloque": "manana",
      "recurrencia": "diaria"
    },
    {
      "nombre": "Bañarse",
      "puntos": "50",
      "obligatoria": true,
      "icono": Icons.bathtub,
      "bloque": "manana",
      "recurrencia": "diaria"
    },
    {
      "nombre": "Hacer la Cama",
      "puntos": "100",
      "obligatoria": true,
      "icono": Icons.bed,
      "bloque": "manana",
      "recurrencia": "diaria"
    },
    {
      "nombre": "Hacer Tareas Escuela",
      "puntos": "500",
      "obligatoria": true,
      "icono": Icons.school,
      "bloque": "tarde",
      "recurrencia": "semanal"
    },
    {
      "nombre": "Recoger Juguetes",
      "puntos": "200",
      "obligatoria": false,
      "icono": Icons.toys,
      "bloque": "noche",
      "recurrencia": "diaria"
    },
    {
      "nombre": "Alistar Maleta",
      "puntos": "100",
      "obligatoria": true,
      "icono": Icons.backpack,
      "bloque": "noche",
      "recurrencia": "semanal"
    },
    // NUEVA RUTINA: PATINAJE
    {
      "nombre": "Practicar Patinaje",
      "puntos": "300",
      "obligatoria": false,
      "icono": Icons.roller_skating,
      "bloque": "tarde",
      "recurrencia": "semanal"
    },
  ];

  final List<IconData> _iconosDisponibles = [
    Icons.cleaning_services, Icons.checkroom, Icons.local_dining, Icons.piano,
    Icons.menu_book, Icons.backpack, Icons.bed, Icons.school, Icons.pets,
    Icons.sports_soccer, Icons.computer, Icons.star, Icons.directions_bike,
    Icons.pool, Icons.bathtub, Icons.toys, Icons.roller_skating // Agregado icono patinaje
  ];

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

      if (plantilla["nombre"].toString().contains("Escuela") || plantilla["nombre"].toString().contains("Maleta")) {
        _diasSeleccionados = [1, 2, 3, 4, 5];
        _tipoRecurrencia = 'semanal';
      } else {
        _diasSeleccionados = [1, 2, 3, 4, 5, 6, 7];
        _tipoRecurrencia = 'diaria';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Plantilla cargada. Ajusta el horario si es necesario."), duration: const Duration(seconds: 1))
    );
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<TareaProvider>(context, listen: false);

    // CORRECCIÓN UI: Agregamos el padding inferior del sistema (SafeArea inferior) al cálculo
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding, left: 20, right: 20, top: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Nueva Misión", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
              ],
            ),

            if (widget.tarea == null) ...[
              const SizedBox(height: 10),
              const Text("🚀 Rutinas Rápidas:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _plantillas.map((plantilla) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        avatar: Icon(plantilla['icono'], size: 16, color: Colors.white),
                        label: Text(plantilla['nombre']),
                        backgroundColor: Colors.indigo.shade300,
                        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                        onPressed: () => _cargarPlantilla(plantilla),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 25),
            ],

            TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: "Nombre Tarea", prefixIcon: Icon(Icons.task_alt))),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(controller: _puntosCtrl, decoration: const InputDecoration(labelText: "Puntos", prefixIcon: Icon(Icons.monetization_on)), keyboardType: TextInputType.number),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _esObligatoria ? Colors.red[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: _esObligatoria ? Border.all(color: Colors.red.shade300) : null,
                    ),
                    child: SwitchListTile(
                      title: const Text("Llave 🔑", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text("Obligatoria", style: TextStyle(fontSize: 10)),
                      value: _esObligatoria,
                      activeColor: Colors.red,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      onChanged: (val) => setState(() => _esObligatoria = val),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Text("Frecuencia:", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              children: [
                ChoiceChip(label: const Text("Diaria"), selected: _tipoRecurrencia == 'diaria', onSelected: (val) => setState(() => _tipoRecurrencia = 'diaria')),
                ChoiceChip(label: const Text("Días Específicos"), selected: _tipoRecurrencia == 'semanal', onSelected: (val) => setState(() => _tipoRecurrencia = 'semanal')),
                ChoiceChip(label: const Text("Reto Único (Fecha)"), selected: _tipoRecurrencia == 'fecha_fija', onSelected: (val) => setState(() => _tipoRecurrencia = 'fecha_fija')),
              ],
            ),

            if (_tipoRecurrencia == 'semanal')
              Wrap(
                spacing: 5,
                children: [
                  for (var i = 1; i <= 7; i++)
                    FilterChip(
                      label: Text(_diaLetra(i)),
                      selected: _diasSeleccionados.contains(i),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _diasSeleccionados.add(i);
                          } else {
                            _diasSeleccionados.remove(i);
                          }
                        });
                      },
                    )
                ],
              ),

            if (_tipoRecurrencia == 'fecha_fija')
              ListTile(
                title: Text(_fechaFija == null ? "Seleccionar Fecha" : DateFormat('dd/MM/yyyy').format(_fechaFija!)),
                leading: const Icon(Icons.calendar_today, color: Colors.indigo),
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                  if (picked != null) setState(() => _fechaFija = picked);
                },
              ),

            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _bloque,
              items: const [DropdownMenuItem(value: 'manana', child: Text("🌞 Mañana")), DropdownMenuItem(value: 'tarde', child: Text("⛅ Tarde")), DropdownMenuItem(value: 'noche', child: Text("🌙 Noche"))],
              onChanged: (val) => setState(() => _bloque = val!),
            ),

            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _iconosDisponibles.map((icon) => GestureDetector(
                  onTap: () => setState(() => _icono = icon),
                  child: Container(margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _icono == icon ? Colors.indigo : Colors.grey[200], shape: BoxShape.circle), child: Icon(icon, color: _icono == icon ? Colors.white : Colors.black54)),
                )).toList(),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
              onPressed: () {
                if (_nombreCtrl.text.isEmpty) return;

                if (_tipoRecurrencia == 'fecha_fija' && _fechaFija == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecciona una fecha para el reto")));
                  return;
                }

                proveedor.agregarTarea(
                    nombre: _nombreCtrl.text,
                    puntos: int.tryParse(_puntosCtrl.text) ?? 0,
                    obligatoria: _esObligatoria,
                    icon: _icono,
                    bloque: _bloque,
                    tipoRecurrencia: _tipoRecurrencia,
                    diasSemana: _diasSeleccionados,
                    fechaEspecifica: _fechaFija
                );
                Navigator.pop(context);
              },
              child: const Text("GUARDAR MISIÓN"),
            ),
            // CORRECCIÓN UI: Espacio extra al final para asegurar que se pueda hacer scroll y ver el botón
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  String _diaLetra(int dia) {
    const letras = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return letras[dia - 1];
  }
}