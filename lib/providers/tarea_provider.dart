import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/tarea_model.dart';
import 'package:intl/intl.dart';

class TareaProvider extends ChangeNotifier {
  Box<Tarea>? _cajaTareas;
  bool isLoading = true;

  int get _fechaIdHoy {
    final now = DateTime.now();
    return (now.year * 10000) + (now.month * 100) + now.day;
  }

  Future<void> inicializar() async {
    _cajaTareas = await Hive.openBox<Tarea>('caja_tareas_v6');
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

  List<Tarea> _tareasDelPerfil(String perfilId) {
    if (_cajaTareas == null || !_cajaTareas!.isOpen) return [];
    return _cajaTareas!.values.where((t) => t.perfilId == perfilId).toList();
  }

  List<Tarea> listaTareasActivas(String perfilId) {
    final tareasDeHoy = _filtrarTareasPorFecha(_tareasDelPerfil(perfilId), DateTime.now());
    return tareasDeHoy.where((t) {
      if (t.bloque == 'sancion') return false;
      bool completadaHoy = (t.estado == 'aprobada' && t.ultimoDiaCompletado == _fechaIdHoy);
      return !completadaHoy;
    }).toList();
  }

  List<Tarea> _filtrarTareasPorFecha(List<Tarea> tareas, DateTime fecha) {
    return tareas.where((t) {
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

  List<Tarea> tareasManana(String perfilId) => listaTareasActivas(perfilId).where((t) => t.bloque == 'manana').toList();
  List<Tarea> tareasTarde(String perfilId) => listaTareasActivas(perfilId).where((t) => t.bloque == 'tarde').toList();
  List<Tarea> tareasNoche(String perfilId) => listaTareasActivas(perfilId).where((t) => t.bloque == 'noche').toList();

  List<Tarea> listaHistorialHoy(String perfilId) {
    return _tareasDelPerfil(perfilId).where((t) {
      bool esDeHoy = t.ultimoDiaCompletado == _fechaIdHoy;
      bool estaAprobada = t.estado == 'aprobada';
      return esDeHoy && estaAprobada;
    }).toList();
  }

  List<Tarea> listaTodasLasTareas(String perfilId) {
    return _tareasDelPerfil(perfilId).where((t) => t.bloque != 'sancion').toList();
  }

  List<Tarea> tareasPorRevisar(String perfilId) {
    return _tareasDelPerfil(perfilId).where((t) => t.estado == 'revision').toList();
  }

  List<Tarea> todasTareasPorRevisarGoblal() {
    if (_cajaTareas == null || !_cajaTareas!.isOpen) return [];
    return _cajaTareas!.values.where((t) => t.estado == 'revision').toList();
  }

  Future<void> agregarTarea({
    required String nombre, required int puntos, required bool obligatoria,
    required IconData icon, required String bloque, required String tipoRecurrencia,
    List<int> diasSemana = const [1,2,3,4,5,6,7], DateTime? fechaEspecifica,
    required String perfilId,
  }) async {
    final nuevaTarea = Tarea(
        nombre: nombre, puntos: puntos, esObligatoria: obligatoria,
        iconoCodePoint: icon.codePoint, bloque: bloque,
        tipoRecurrencia: tipoRecurrencia, diasSemana: diasSemana,
        fechaEspecifica: fechaEspecifica, perfilId: perfilId,
    );
    await _cajaTareas!.add(nuevaTarea);
    notifyListeners();
  }

  Future<void> editarTarea(Tarea tarea, {
    required String nombre, required int puntos, required bool obligatoria,
    required IconData icon, required String bloque, required String tipoRecurrencia,
    List<int> diasSemana = const [1, 2, 3, 4, 5, 6, 7], DateTime? fechaEspecifica,
  }) async {
    tarea.nombre = nombre; tarea.puntos = puntos; tarea.esObligatoria = obligatoria;
    tarea.iconoCodePoint = icon.codePoint; tarea.bloque = bloque;
    tarea.tipoRecurrencia = tipoRecurrencia; tarea.diasSemana = diasSemana;
    tarea.fechaEspecifica = fechaEspecifica;
    await tarea.save();
    notifyListeners();
  }

  Future<void> eliminarTarea(Tarea tarea) async {
    await tarea.delete();
    notifyListeners();
  }

  Future<Tarea> aplicarSancion(String motivo, int monto, String perfilId) async {
    final sancion = Tarea(
      nombre: "Sanción: $motivo", puntos: -monto, esObligatoria: false,
      iconoCodePoint: Icons.warning_amber_rounded.codePoint, bloque: 'sancion',
      estado: 'aprobada', tipoRecurrencia: 'fecha_fija', fechaEspecifica: DateTime.now(),
      ultimoDiaCompletado: _fechaIdHoy, perfilId: perfilId,
    );
    await _cajaTareas!.add(sancion);
    notifyListeners();
    return sancion;
  }

  void solicitarRevision(Tarea tarea) {
    if (tarea.estado == 'pendiente') {
      tarea.estado = 'revision';
      tarea.save();
      notifyListeners();
    }
  }

  void rechazarTarea(Tarea tarea) {
    tarea.estado = 'pendiente';
    tarea.save();
    notifyListeners();
  }

  bool aprobarTarea(Tarea tarea) {
    if (tarea.estado == 'revision') {
      tarea.estado = 'aprobada';
      tarea.ultimoDiaCompletado = _fechaIdHoy;
      tarea.save();
      notifyListeners();
      return true;
    }
    return false;
  }
  
  bool aprobarTareaManual(Tarea tarea) {
    bool yaEstabaPagada = (tarea.estado == 'aprobada' && tarea.ultimoDiaCompletado == _fechaIdHoy);
    tarea.estado = 'aprobada';
    tarea.ultimoDiaCompletado = _fechaIdHoy;
    tarea.save();
    notifyListeners();
    return !yaEstabaPagada;
  }

  // Permite un pequeño margen para tareas matutinas (Ej. hasta las 13:00) si lo desea el admin
  String get bloqueActual {
    final hora = DateTime.now().hour;
    if (hora >= 5 && hora < 12) return 'manana';
    if (hora >= 12 && hora < 18) return 'tarde';
    return 'noche';
  }
  
  bool esBloqueActivo(String bloqueTarea) => bloqueTarea == bloqueActual;
}
