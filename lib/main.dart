import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
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
        // USAMOS UN CONTROLADOR PARA DECIDIR QUÉ PANTALLA MOSTRAR
        home: const ControladorInicio(),
      ),
    );
  }
}

// --- CONTROLADOR DE INICIO (DECIDE SI ES SETUP O LOGIN) ---
class ControladorInicio extends StatelessWidget {
  const ControladorInicio({super.key});

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<TareaProvider>(context);

    if (proveedor.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // LÓGICA DE FLUJO: Si no hay admin, vamos al SETUP. Si hay, al LOGIN.
    if (!proveedor.existeAdmin) {
      return const PantallaSetup();
    } else {
      return const PantallaSeleccionRol();
    }
  }
}

// --- NUEVA PANTALLA: SETUP INICIAL (PRIMERA VEZ) ---
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
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50)
                          ),
                          onPressed: () {
                            if (_pinCtrl.text.length < 4) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("El PIN debe tener 4 dígitos")));
                              return;
                            }
                            if (_pinCtrl.text != _confirmPinCtrl.text) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Los PIN no coinciden")));
                              return;
                            }
                            if (_nombreHijoCtrl.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Escribe el nombre de tu hijo")));
                              return;
                            }

                            // GUARDAR Y FINALIZAR SETUP
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

// --- PANTALLA DE SELECCIÓN DE ROL (LOGIN) ---
class PantallaSeleccionRol extends StatelessWidget {
  const PantallaSeleccionRol({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos al proveedor para obtener el nombre dinámico del hijo
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
                const Text(
                  "Misión: Switch 2",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 50),

                // BOTÓN HIJO (DINÁMICO)
                _BotonRol(
                  titulo: "Soy ${proveedor.nombreHijo}", // NOMBRE DESDE HIVE
                  subtitulo: "¡A ganar puntos!",
                  icono: Icons.gamepad,
                  colorFondo: Colors.white,
                  colorTexto: Colors.indigo,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaPrincipal()));
                  },
                ),

                const SizedBox(height: 20),

                // BOTÓN PADRES (ADMIN)
                _BotonRol(
                  titulo: "Soy Papá / Mamá",
                  subtitulo: "Zona de Control",
                  icono: Icons.admin_panel_settings,
                  colorFondo: Colors.indigo[700]!,
                  colorTexto: Colors.white,
                  onTap: () {
                    _mostrarLoginPadre(context, proveedor);
                  },
                ),
                const SizedBox(height: 20),
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
          decoration: const InputDecoration(labelText: "Introduce tu PIN", prefixIcon: Icon(Icons.lock)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              // VERIFICACIÓN CONTRA HIVE (NO HARDCODED)
              if (pinController.text == proveedor.pinPadre) {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaAdmin()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("PIN Incorrecto ⛔"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Entrar"),
          )
        ],
      ),
    );
  }
}

// ... (El widget _BotonRol sigue igual que antes) ...
class _BotonRol extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color colorFondo;
  final Color colorTexto;
  final VoidCallback onTap;

  const _BotonRol({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.colorFondo,
    required this.colorTexto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          children: [
            Icon(icono, size: 40, color: colorTexto),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorTexto),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitulo,
                    style: TextStyle(fontSize: 14, color: colorTexto.withOpacity(0.7)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ... (PantallaPrincipal sigue igual, solo asegúrate de actualizar el Título en el AppBar si quieres que diga el nombre dinámico) ...
class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<TareaProvider>(context);
    // ... (resto del código igual) ...
    // BUSCA LA LÍNEA DEL TEXTO "Misiones de Josue" y cámbiala por:
    // Text("Misiones de ${proveedor.nombreHijo} 🚀", ...)

    // Aquí pongo solo el comienzo para referencia, el resto se mantiene igual al archivo original
    if (proveedor.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final dineroActual = proveedor.totalDinero;
    final meta = proveedor.metaAhorro;
    double porcentaje = (meta > 0) ? (dineroActual / meta).clamp(0.0, 1.0) : 0.0;
    String bloqueActual = proveedor.bloqueActual;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                      // CAMBIO AQUÍ:
                      Text("Misiones de ${proveedor.nombreHijo} 🚀", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 40),
                    ],
                  ),
                  // ... RESTO DEL HEADER IGUAL
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

  // _crearSeccion se mantiene igual...
  Widget _crearSeccion(String titulo, Color colorBase, List<Tarea> tareas, TareaProvider proveedor, bool esBloqueActivo) {
    // ... código original ...
    // (Copiar la implementación original de _crearSeccion aquí)
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
          bool puedeEditar = esBloqueActivo;
          return Opacity(
            opacity: opacidad,
            child: Card(
              elevation: puedeEditar ? 3 : 0,
              margin: const EdgeInsets.only(bottom: 10),
              color: puedeEditar ? null : Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: tarea.estaCompletada ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
              ),
              child: ListTile(
                enabled: puedeEditar,
                leading: CircleAvatar(
                  backgroundColor: tarea.estaCompletada ? Colors.green[100] : (puedeEditar ? colorBase.withOpacity(0.1) : Colors.grey[300]),
                  child: Icon(tarea.icono, color: tarea.estaCompletada ? Colors.green[800] : (puedeEditar ? colorBase : Colors.grey)),
                ),
                title: Text(tarea.nombre, style: TextStyle(decoration: tarea.estaCompletada ? TextDecoration.lineThrough : null, color: tarea.estaCompletada ? Colors.grey : Colors.black87)),
                subtitle: Text(tarea.esObligatoria ? "🔑 Obligatorio" : "💰 + \$${tarea.puntos}", style: TextStyle(color: tarea.esObligatoria ? Colors.red : (puedeEditar ? Colors.green[700] : Colors.grey), fontWeight: FontWeight.bold)),
                trailing: Checkbox(
                  value: tarea.estaCompletada,
                  activeColor: Colors.green,
                  shape: const CircleBorder(),
                  onChanged: puedeEditar ? (valor) => proveedor.cambiarEstadoTarea(tarea, valor ?? false) : null,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// --- PANTALLA ADMIN (ACTUALIZADA PARA OPCIÓN A) ---
class PantallaAdmin extends StatelessWidget {
  const PantallaAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<TareaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración Padre 🛠️"),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _mostrarFormularioTarea(context, null),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            // --- NUEVA SECCIÓN: GESTIÓN DE PERFIL DEL HIJO ---
            Card(
              margin: const EdgeInsets.all(16),
              color: Colors.indigo[50],
              child: ListTile(
                leading: const Icon(Icons.face, color: Colors.indigo, size: 30),
                title: Text("Perfil de ${proveedor.nombreHijo}", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Editar nombre visible"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.indigo),
                  onPressed: () => _editarNombreHijo(context, proveedor),
                ),
              ),
            ),

            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              elevation: 4,
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.savings, color: Colors.white)),
                title: const Text("Meta de Ahorro", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("\$ ${proveedor.metaAhorro.toInt()}", style: const TextStyle(fontSize: 16, color: Colors.green)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_square, color: Colors.indigo),
                  onPressed: () => _editarMeta(context, proveedor),
                ),
              ),
            ),

            // ... (Resto de la lista de tareas igual) ...
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text("Gestionar Tareas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo)),
            ),

            if (proveedor.listaTareas.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No hay tareas creadas"))),

            ...proveedor.listaTareas.map((tarea) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Icon(tarea.icono, color: Colors.indigo),
                title: Text(tarea.nombre, style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text("${tarea.bloque.toUpperCase()} - \$${tarea.puntos}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _mostrarFormularioTarea(context, tarea),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmarBorrar(context, proveedor, tarea),
                    ),
                  ],
                ),
              ),
            )),

            // Botón Reiniciar (Igual)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.restart_alt, color: Colors.orange),
                label: const Text("Reiniciar Día Manualmente (Pruebas)", style: TextStyle(color: Colors.orange)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange)),
                onPressed: () {
                  proveedor.resetearDia();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Día reiniciado")));
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- NUEVO DIÁLOGO PARA EDITAR NOMBRE ---
  void _editarNombreHijo(BuildContext context, TareaProvider proveedor) {
    final controller = TextEditingController(text: proveedor.nombreHijo);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Nombre del Hijo/a"),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: "Nombre"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                proveedor.actualizarConfiguracionHijo(controller.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Guardar"),
          )
        ],
      ),
    );
  }

  // ... (Resto de métodos _editarMeta, _confirmarBorrar, etc. iguales) ...
  void _editarMeta(BuildContext context, TareaProvider proveedor) {
    final controller = TextEditingController(text: proveedor.metaAhorro.toInt().toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cambiar Meta"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Monto", prefixText: "\$ "),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              proveedor.actualizarMeta(double.tryParse(controller.text) ?? 2000000);
              Navigator.pop(ctx);
            },
            child: const Text("Guardar"),
          )
        ],
      ),
    );
  }

  void _confirmarBorrar(BuildContext context, TareaProvider proveedor, Tarea tarea) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Tarea"),
        content: Text("¿Borrar '${tarea.nombre}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")),
          TextButton(
            onPressed: () {
              proveedor.eliminarTarea(tarea);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Sí, borrar"),
          ),
        ],
      ),
    );
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

// ... FormularioTarea sigue igual ...
class FormularioTarea extends StatefulWidget {
  final Tarea? tarea;
  const FormularioTarea({super.key, this.tarea});

  @override
  State<FormularioTarea> createState() => _FormularioTareaState();
}
// (Copia el resto de la clase FormularioTarea del archivo original, no requiere cambios de lógica)
class _FormularioTareaState extends State<FormularioTarea> {
  final _nombreCtrl = TextEditingController();
  final _puntosCtrl = TextEditingController();
  String _bloque = 'manana';
  bool _esObligatoria = false;
  IconData _icono = Icons.star;

  final List<IconData> _iconosDisponibles = [
    Icons.cleaning_services, Icons.checkroom, Icons.local_dining, Icons.piano,
    Icons.menu_book, Icons.backpack, Icons.bed, Icons.school, Icons.pets,
    Icons.sports_soccer, Icons.computer, Icons.star, Icons.directions_bike, Icons.pool
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = Provider.of<TareaProvider>(context, listen: false);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 20;

    return Padding(
      padding: EdgeInsets.only(
          bottom: bottomPadding,
          left: 20, right: 20, top: 20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.tarea == null ? "Nueva Tarea" : "Editar Tarea", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))
            ],
          ),
          const SizedBox(height: 15),

          TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: "Nombre Tarea", prefixIcon: Icon(Icons.task_alt))),
          const SizedBox(height: 10),

          TextField(controller: _puntosCtrl, decoration: const InputDecoration(labelText: "Puntos / Dinero", prefixIcon: Icon(Icons.monetization_on)), keyboardType: TextInputType.number),
          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            value: _bloque,
            decoration: const InputDecoration(labelText: "Horario / Bloque", prefixIcon: Icon(Icons.schedule)),
            items: const [
              DropdownMenuItem(value: 'manana', child: Text("🌞 Mañana")),
              DropdownMenuItem(value: 'tarde', child: Text("⛅ Tarde")),
              DropdownMenuItem(value: 'noche', child: Text("🌙 Noche")),
            ],
            onChanged: (val) => setState(() => _bloque = val!),
          ),

          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("¿Es Obligatoria? (Llave)", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Si no la hace, no cobra el día."),
            value: _esObligatoria,
            activeColor: Colors.red,
            onChanged: (val) => setState(() => _esObligatoria = val),
          ),

          const SizedBox(height: 10),
          const Text("Elige un Icono:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _iconosDisponibles.map((icon) => GestureDetector(
                onTap: () => setState(() => _icono = icon),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: _icono == icon ? Colors.indigo : Colors.grey[200],
                      shape: BoxShape.circle,
                      border: _icono == icon ? Border.all(color: Colors.amber, width: 2) : null
                  ),
                  child: Icon(icon, color: _icono == icon ? Colors.white : Colors.black54),
                ),
              )).toList(),
            ),
          ),

          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3
            ),
            onPressed: () {
              if (_nombreCtrl.text.isEmpty) return;

              if (widget.tarea == null) {
                proveedor.agregarTarea(_nombreCtrl.text, int.tryParse(_puntosCtrl.text) ?? 0, _esObligatoria, _icono, _bloque);
              } else {
                proveedor.editarTarea(widget.tarea!, _nombreCtrl.text, int.tryParse(_puntosCtrl.text) ?? 0, _esObligatoria, _icono, _bloque);
              }
              Navigator.pop(context);
            },
            child: const Text("GUARDAR TAREA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}