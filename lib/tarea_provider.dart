import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'tarea_model.dart';

class TareaProvider extends ChangeNotifier {
  Box<Tarea>? _cajaTareas;
  Box? _cajaConfig;
  bool isLoading = true;

  // --- HELPER DE FECHA ---
  int get _fechaIdHoy {
    final now = DateTime.now();
    return (now.year * 10000) + (now.month * 100) + now.day;
  }

  // --- GETTERS PRINCIPALES ---

  List<Tarea> get listaTareasActivas {
    if (_cajaTareas == null || !_cajaTareas!.isOpen) return [];

    final tareasDeHoy = _filtrarTareasPorFecha(DateTime.now());

    return tareasDeHoy.where((t) {
      if (t.bloque == 'sancion') return false;
      bool completadaHoy = (t.estado == 'aprobada' && t.ultimoDiaCompletado == _fechaIdHoy);
      return !completadaHoy;
    }).toList();
  }

  List<Tarea> get listaHistorialHoy {
    if (_cajaTareas == null || !_cajaTareas!.isOpen) return [];
    return _cajaTareas!.values.where((t) {
      bool esDeHoy = t.ultimoDiaCompletado == _fechaIdHoy;
      bool estaAprobada = t.estado == 'aprobada';
      return esDeHoy && estaAprobada;
    }).toList();
  }

  List<Tarea> get listaTodasLasTareas {
    if (_cajaTareas == null || !_cajaTareas!.isOpen) return [];
    return _cajaTareas!.values.where((t) => t.bloque != 'sancion').toList();
  }

  List<Tarea> get tareasPorRevisar {
    if (_cajaTareas == null) return [];
    return _cajaTareas!.values.where((t) => t.estado == 'revision').toList();
  }

  // Lógica de Recurrencia
  List<Tarea> _filtrarTareasPorFecha(DateTime fecha) {
    return _cajaTareas!.values.where((t) {
      if (t.tipoRecurrencia == 'diaria') return true;
      if (t.tipoRecurrencia == 'semanal') return t.diasSemana.contains(fecha.weekday);
      if (t.tipoRecurrencia == 'fecha_fija' && t.fechaEspecifica != null) {
        return t.fechaEspecifica!.year == fecha.year &&
            t.fechaEspecifica!.month == fecha.month &&
            t.fechaEspecifica!.day == fecha.day;
      }
      return false;
    }).toList();
  }

  List<Tarea> get tareasManana => listaTareasActivas.where((t) => t.bloque == 'manana').toList();
  List<Tarea> get tareasTarde => listaTareasActivas.where((t) => t.bloque == 'tarde').toList();
  List<Tarea> get tareasNoche => listaTareasActivas.where((t) => t.bloque == 'noche').toList();

  // --- CONFIGURACIÓN Y METAS ---

  bool get existeAdmin => _cajaConfig?.get('setup_completo', defaultValue: false) ?? false;
  String get pinPadre => _cajaConfig?.get('pin_padre', defaultValue: '') ?? '';
  String get nombreHijo => _cajaConfig?.get('nombre_hijo', defaultValue: 'Hijo') ?? 'Hijo';

  double get metaAhorro => _cajaConfig?.get('meta', defaultValue: 0.0) ?? 0.0;
  String get nombreMeta => _cajaConfig?.get('nombre_meta', defaultValue: '') ?? '';

  List<Map<dynamic, dynamic>> get historialVictorias {
    final lista = _cajaConfig?.get('historial_victorias', defaultValue: []) ?? [];
    return List<Map<dynamic, dynamic>>.from(lista);
  }

  String get bloqueActual {
    final hora = DateTime.now().hour;
    if (hora >= 5 && hora < 12) return 'manana';
    if (hora >= 12 && hora < 18) return 'tarde';
    return 'noche';
  }

  bool esBloqueActivo(String bloqueTarea) => bloqueTarea == bloqueActual;

  // --- FINANZAS ---
  int get totalDinero {
    if (_cajaConfig == null) return 0;
    return _cajaConfig!.get('saldo_billetera', defaultValue: 0);
  }

  Future<void> _agregarDinero(int cantidad) async {
    int saldoActual = totalDinero;
    await _cajaConfig!.put('saldo_billetera', saldoActual + cantidad);
    notifyListeners();
  }

  // --- INICIALIZACIÓN (CON MIGRACIONES) ---
  Future<void> inicializar() async {
    _cajaTareas = await Hive.openBox<Tarea>('caja_tareas_v5');
    _cajaConfig = await Hive.openBox('caja_config');

    // Migración V2.5: Billetera Persistente
    if (!_cajaConfig!.containsKey('saldo_billetera')) {
      int saldoCalculado = 0;
      for (var tarea in _cajaTareas!.values) {
        if (tarea.estado == 'aprobada' && tarea.puntos > 0) saldoCalculado += tarea.puntos;
      }
      await _cajaConfig!.put('saldo_billetera', saldoCalculado);
    }

    // MIGRACIÓN V3.1: Corregir nombres vacíos en el historial (Caso Expansion Pack)
    // Obtenemos la lista tal cual está guardada
    var rawHistorial = _cajaConfig!.get('historial_victorias', defaultValue: []);

    if (rawHistorial is List && rawHistorial.isNotEmpty) {
      List<Map<dynamic, dynamic>> historialModificable = [];
      bool cambiosNecesarios = false;

      for (var entry in rawHistorial) {
        // Clonamos el mapa para asegurarnos de que sea modificable
        Map<dynamic, dynamic> mapaEntry = Map<dynamic, dynamic>.from(entry as Map);

        // Verificamos si falta el nombre
        if (mapaEntry['nombre'] == null || mapaEntry['nombre'].toString().trim().isEmpty) {
          mapaEntry['nombre'] = "Expansion Pack Nintendo"; // ¡Aquí está la corrección!
          cambiosNecesarios = true;
        }
        historialModificable.add(mapaEntry);
      }

      // Si encontramos algo que corregir, guardamos la lista actualizada
      if (cambiosNecesarios) {
        await _cajaConfig!.put('historial_victorias', historialModificable);
        debugPrint("Migración completada: Se asignó nombre al trofeo histórico.");
      }
    }

    _verificarNuevoDia();
    isLoading = false;
    notifyListeners();
  }

  void _verificarNuevoDia() {
    final hoyId = _fechaIdHoy;
    for (var tarea in _cajaTareas!.values) {
      if (tarea.tipoRecurrencia != 'fecha_fija') {
        if (tarea.ultimoDiaCompletado != hoyId && (tarea.estado == 'aprobada' || tarea.estado == 'revision')) {
          tarea.estado = 'pendiente';
          tarea.save();
        }
      }
    }
  }

  // --- LÓGICA V3.0: CICLO DE METAS ---

  Future<void> definirNuevaMeta(String nombre, double monto) async {
    await _cajaConfig!.put('nombre_meta', nombre);
    await _cajaConfig!.put('meta', monto);
    notifyListeners();
  }

  Future<void> reclamarPremio() async {
    final costoMeta = metaAhorro.toInt();
    final nombrePremio = nombreMeta;

    if (totalDinero >= costoMeta && costoMeta > 0) {
      // A. Pago
      await _agregarDinero(-costoMeta);

      // B. Historial
      final nuevaVictoria = {
        'nombre': nombrePremio,
        'fecha': DateTime.now().toIso8601String(),
        'costo': costoMeta,
      };

      final historial = historialVictorias;
      historial.add(nuevaVictoria);
      await _cajaConfig!.put('historial_victorias', historial);

      // C. Reset Meta
      await _cajaConfig!.put('meta', 0.0);
      await _cajaConfig!.put('nombre_meta', '');

      notifyListeners();
    }
  }

  // --- GESTIÓN DE TAREAS ---

  Future<void> aplicarSancion(String motivo, int monto) async {
    await _agregarDinero(-monto);
    final sancion = Tarea(
      nombre: "Sanción: $motivo",
      puntos: -monto,
      esObligatoria: false,
      iconoCodePoint: Icons.warning_amber_rounded.codePoint,
      bloque: 'sancion',
      estado: 'aprobada',
      tipoRecurrencia: 'fecha_fija',
      fechaEspecifica: DateTime.now(),
      ultimoDiaCompletado: _fechaIdHoy,
    );
    await _cajaTareas!.add(sancion);
    notifyListeners();
  }

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

  Future<void> editarTarea(
      Tarea tarea, {
        required String nombre,
        required int puntos,
        required bool obligatoria,
        required IconData icon,
        required String bloque,
        required String tipoRecurrencia,
        List<int> diasSemana = const [1, 2, 3, 4, 5, 6, 7],
        DateTime? fechaEspecifica,
      }) async {
    tarea.nombre = nombre;
    tarea.puntos = puntos;
    tarea.esObligatoria = obligatoria;
    tarea.iconoCodePoint = icon.codePoint;
    tarea.bloque = bloque;
    tarea.tipoRecurrencia = tipoRecurrencia;
    tarea.diasSemana = diasSemana;
    tarea.fechaEspecifica = fechaEspecifica;
    await tarea.save();
    notifyListeners();
  }

  Future<void> eliminarTarea(Tarea tarea) async {
    await tarea.delete();
    notifyListeners();
  }

  // --- CONFIGURACIÓN ADMIN ---
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

  // --- FLUJO OPERATIVO ---
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
      tarea.ultimoDiaCompletado = _fechaIdHoy;
      tarea.save();
      _agregarDinero(tarea.puntos);
    }
  }

  void aprobarTareaManual(Tarea tarea) {
    bool yaEstabaPagada = (tarea.estado == 'aprobada' && tarea.ultimoDiaCompletado == _fechaIdHoy);
    tarea.estado = 'aprobada';
    tarea.ultimoDiaCompletado = _fechaIdHoy;
    tarea.save();
    if (!yaEstabaPagada) _agregarDinero(tarea.puntos);
    notifyListeners();
  }

  void rechazarTarea(Tarea tarea) {
    tarea.estado = 'pendiente';
    tarea.save();
    notifyListeners();
  }
}