import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'tarea_model.dart';

class TareaProvider extends ChangeNotifier {
  Box<Tarea>? _cajaTareas;
  Box? _cajaConfig;
  bool isLoading = true;

  // --- GETTERS ---
  List<Tarea> get listaTareas {
    if (_cajaTareas == null || !_cajaTareas!.isOpen) return [];
    return _cajaTareas!.values.toList();
  }

  List<Tarea> get tareasManana => listaTareas.where((t) => t.bloque == 'manana').toList();
  List<Tarea> get tareasTarde => listaTareas.where((t) => t.bloque == 'tarde').toList();
  List<Tarea> get tareasNoche => listaTareas.where((t) => t.bloque == 'noche').toList();

  // --- NUEVOS GETTERS DE CONFIGURACIÓN (OPCIÓN A) ---
  // Verifica si ya se hizo el setup inicial
  bool get existeAdmin => _cajaConfig?.get('setup_completo', defaultValue: false) ?? false;

  // Datos del Padre
  String get pinPadre => _cajaConfig?.get('pin_padre', defaultValue: '') ?? '';

  // Datos del Hijo (Gestionados por el padre)
  String get nombreHijo => _cajaConfig?.get('nombre_hijo', defaultValue: 'Hijo') ?? 'Hijo';

  // Meta de ahorro
  double get metaAhorro => _cajaConfig?.get('meta', defaultValue: 2000000.0) ?? 2000000.0;

  // Lógica del Reloj
  String get bloqueActual {
    final hora = DateTime.now().hour;
    if (hora >= 5 && hora < 12) return 'manana';
    if (hora >= 12 && hora < 18) return 'tarde';
    return 'noche';
  }

  bool esBloqueActivo(String bloqueTarea) => bloqueTarea == bloqueActual;

  int get totalDinero {
    int total = 0;
    for (var tarea in listaTareas) {
      if (tarea.estaCompletada) total += tarea.puntos;
    }
    return total;
  }

  // --- INICIALIZACIÓN ---
  Future<void> inicializar() async {
    _cajaTareas = await Hive.openBox<Tarea>('caja_tareas_v5');
    _cajaConfig = await Hive.openBox('caja_config');

    // Datos por defecto SOLO si está vacío (Tareas de ejemplo)
    if (_cajaTareas!.isEmpty) {
      await _agregarTarea("Cepillarse Dientes", 0, true, Icons.cleaning_services, 'manana');
      await _agregarTarea("Recoger Pijama", 660, false, Icons.checkroom, 'manana');
    }

    isLoading = false;
    notifyListeners();
  }

  // --- NUEVA LÓGICA: SETUP DE PRIMERA VEZ ---
  Future<void> registrarAdminInicial(String nuevoPin, String nombreHijoInicial) async {
    await _cajaConfig!.put('pin_padre', nuevoPin);
    await _cajaConfig!.put('nombre_hijo', nombreHijoInicial);
    await _cajaConfig!.put('setup_completo', true); // Marca que ya no es primera vez
    notifyListeners();
  }

  // --- GESTIÓN DE PERFILES (PADRE CONTROLA TODO) ---
  Future<void> actualizarConfiguracionHijo(String nuevoNombre) async {
    await _cajaConfig!.put('nombre_hijo', nuevoNombre);
    notifyListeners();
  }

  Future<void> cambiarPinPadre(String nuevoPin) async {
    await _cajaConfig!.put('pin_padre', nuevoPin);
    notifyListeners();
  }

  // --- GESTIÓN DE TAREAS ---
  Future<void> agregarTarea(String nombre, int puntos, bool obligatoria, IconData icon, String bloque) async {
    final nuevaTarea = Tarea(
      nombre: nombre,
      puntos: puntos,
      esObligatoria: obligatoria,
      iconoCodePoint: icon.codePoint,
      bloque: bloque,
    );
    await _cajaTareas!.add(nuevaTarea);
    notifyListeners();
  }

  Future<void> _agregarTarea(String nombre, int puntos, bool obligatoria, IconData icon, String bloque) async {
    await _cajaTareas!.add(Tarea(
      nombre: nombre,
      puntos: puntos,
      esObligatoria: obligatoria,
      iconoCodePoint: icon.codePoint,
      bloque: bloque,
    ));
  }

  Future<void> eliminarTarea(Tarea tarea) async {
    await tarea.delete();
    notifyListeners();
  }

  Future<void> editarTarea(Tarea tarea, String nombre, int puntos, bool obligatoria, IconData icon, String bloque) async {
    tarea.nombre = nombre;
    tarea.puntos = puntos;
    tarea.esObligatoria = obligatoria;
    tarea.iconoCodePoint = icon.codePoint;
    tarea.bloque = bloque;
    await tarea.save();
    notifyListeners();
  }

  Future<void> actualizarMeta(double nuevaMeta) async {
    await _cajaConfig!.put('meta', nuevaMeta);
    notifyListeners();
  }

  void cambiarEstadoTarea(Tarea tarea, bool completada) {
    if (!esBloqueActivo(tarea.bloque)) return;
    tarea.estaCompletada = completada;
    tarea.save();
    notifyListeners();
  }

  void resetearDia() {
    for (var tarea in listaTareas) {
      tarea.estaCompletada = false;
      tarea.save();
    }
    notifyListeners();
  }
}