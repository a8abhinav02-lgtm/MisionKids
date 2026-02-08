import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'tarea_model.dart';

class TareaProvider extends ChangeNotifier {
  Box<Tarea>? _cajaTareas;
  Box? _cajaConfig;
  bool isLoading = true;

  // --- GETTERS ---

  // 1. LISTA MAESTRA (Solo tareas que tocan HOY - Para el Niño)
  List<Tarea> get listaTareasHoy {
    if (_cajaTareas == null || !_cajaTareas!.isOpen) return [];
    final hoy = DateTime.now();

    return _cajaTareas!.values.where((t) {
      // Lógica de Recurrencia: ¿Esta tarea debe aparecer hoy?
      if (t.tipoRecurrencia == 'diaria') return true;

      if (t.tipoRecurrencia == 'semanal') {
        // weekday: 1=Lunes, 7=Domingo
        return t.diasSemana.contains(hoy.weekday);
      }

      if (t.tipoRecurrencia == 'fecha_fija' && t.fechaEspecifica != null) {
        return t.fechaEspecifica!.year == hoy.year &&
            t.fechaEspecifica!.month == hoy.month &&
            t.fechaEspecifica!.day == hoy.day;
      }

      return false; // Por defecto no mostrar
    }).toList();
  }

  // 2. NUEVO: INVENTARIO TOTAL (Para el Admin - Muestra TODO sin filtrar fecha)
  List<Tarea> get listaTodasLasTareas {
    if (_cajaTareas == null || !_cajaTareas!.isOpen) return [];
    return _cajaTareas!.values.toList();
  }

  // Filtros por bloque (Solo de las visibles hoy)
  List<Tarea> get tareasManana => listaTareasHoy.where((t) => t.bloque == 'manana').toList();
  List<Tarea> get tareasTarde => listaTareasHoy.where((t) => t.bloque == 'tarde').toList();
  List<Tarea> get tareasNoche => listaTareasHoy.where((t) => t.bloque == 'noche').toList();

  // 3. Tareas esperando validación de Papá
  List<Tarea> get tareasPorRevisar {
    if (_cajaTareas == null) return [];
    return _cajaTareas!.values.where((t) => t.estado == 'revision').toList();
  }

  // Configuración
  bool get existeAdmin => _cajaConfig?.get('setup_completo', defaultValue: false) ?? false;
  String get pinPadre => _cajaConfig?.get('pin_padre', defaultValue: '') ?? '';
  String get nombreHijo => _cajaConfig?.get('nombre_hijo', defaultValue: 'Hijo') ?? 'Hijo';
  double get metaAhorro => _cajaConfig?.get('meta', defaultValue: 2000000.0) ?? 2000000.0;

  // Lógica del Reloj
  String get bloqueActual {
    final hora = DateTime.now().hour;
    if (hora >= 5 && hora < 12) return 'manana';
    if (hora >= 12 && hora < 18) return 'tarde';
    return 'noche';
  }

  bool esBloqueActivo(String bloqueTarea) => bloqueTarea == bloqueActual;

  // DINERO: Solo suma si está 'aprobada'
  int get totalDinero {
    if (_cajaTareas == null) return 0;
    int total = 0;
    for (var tarea in _cajaTareas!.values) {
      if (tarea.estado == 'aprobada') total += tarea.puntos;
    }
    return total;
  }

  // --- INICIALIZACIÓN ---
  Future<void> inicializar() async {
    _cajaTareas = await Hive.openBox<Tarea>('caja_tareas_v5');
    _cajaConfig = await Hive.openBox('caja_config');

    _verificarNuevoDia();

    isLoading = false;
    notifyListeners();
  }

  void _verificarNuevoDia() {
    final hoyDiaAnio = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;

    for (var tarea in _cajaTareas!.values) {
      if (tarea.tipoRecurrencia != 'fecha_fija') {
        if (tarea.ultimoDiaCompletado != hoyDiaAnio && (tarea.estado == 'aprobada' || tarea.estado == 'revision')) {
          tarea.estado = 'pendiente';
          tarea.save();
        }
      }
    }
  }

  // --- SETUP ---
  Future<void> registrarAdminInicial(String nuevoPin, String nombreHijoInicial) async {
    await _cajaConfig!.put('pin_padre', nuevoPin);
    await _cajaConfig!.put('nombre_hijo', nombreHijoInicial);
    await _cajaConfig!.put('setup_completo', true);
    notifyListeners();
  }

  Future<void> actualizarConfiguracionHijo(String nuevoNombre) async {
    await _cajaConfig!.put('nombre_hijo', nuevoNombre);
    notifyListeners();
  }

  // --- GESTIÓN DE TAREAS ---
  Future<void> agregarTarea({
    required String nombre,
    required int puntos,
    required bool obligatoria,
    required IconData icon,
    required String bloque,
    required String tipoRecurrencia,
    List<int> diasSemana = const [1,2,3,4,5,6,7],
    DateTime? fechaEspecifica,
  }) async {
    final nuevaTarea = Tarea(
        nombre: nombre,
        puntos: puntos,
        esObligatoria: obligatoria,
        iconoCodePoint: icon.codePoint,
        bloque: bloque,
        estado: 'pendiente',
        tipoRecurrencia: tipoRecurrencia,
        diasSemana: diasSemana,
        fechaEspecifica: fechaEspecifica,
        ultimoDiaCompletado: 0
    );
    await _cajaTareas!.add(nuevaTarea);
    notifyListeners();
  }

  Future<void> eliminarTarea(Tarea tarea) async {
    await tarea.delete();
    notifyListeners();
  }

  Future<void> actualizarMeta(double nuevaMeta) async {
    await _cajaConfig!.put('meta', nuevaMeta);
    notifyListeners();
  }

  // --- FLUJO DE VALIDACIÓN ---
  void solicitarRevision(Tarea tarea) {
    if (tarea.estado == 'pendiente') {
      tarea.estado = 'revision';
      tarea.save();
      notifyListeners();
    }
  }

  void aprobarTarea(Tarea tarea) {
    if (tarea.estado == 'revision') {
      tarea.estado = 'aprobada';
      tarea.ultimoDiaCompletado = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
      tarea.save();
      notifyListeners();
    }
  }

  void rechazarTarea(Tarea tarea) {
    tarea.estado = 'pendiente';
    tarea.save();
    notifyListeners();
  }
}