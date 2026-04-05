import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tarea_model.dart';
import 'package:intl/intl.dart';

class TareaProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Box<Tarea>? _cajaTareas;
  
  bool isLoading = true;
  String _uid = '';
  List<Tarea> _tareasFirestore = [];

  int get _fechaIdHoy {
    final now = DateTime.now();
    return (now.year * 10000) + (now.month * 100) + now.day;
  }

  String get uid => _uid;

  List<Tarea> get _todasLasTareasData {
    return _tareasFirestore.isNotEmpty ? _tareasFirestore : (_cajaTareas?.values.toList() ?? []);
  }

  void updateUid(String newUid) {
    if (_uid != newUid) {
      _uid = newUid;
      if (_uid.isNotEmpty) {
        _escucharTareas();
      }
    }
  }

  bool _inicializacionIniciada = false;

  Future<void> inicializar() async {
    if (_inicializacionIniciada) return;
    _inicializacionIniciada = true;

    _cajaTareas = await Hive.openBox<Tarea>('caja_tareas_v6');
    if (_uid.isNotEmpty) {
      await _migrarHiveAFirestore();
      _escucharTareas();
    }
    _verificarNuevoDia();
    isLoading = false;
    notifyListeners();
  }

  void _escucharTareas() {
    if (_uid.isEmpty) return;
    _db.collection('familias').doc(_uid).collection('tareas')
      .snapshots().listen((snapshot) {
        _tareasFirestore = snapshot.docs.map((doc) {
          final data = doc.data();
          return Tarea.fromMap(data);
        }).toList();
        _verificarNuevoDia();
        notifyListeners();
      });
  }

  Future<void> _migrarHiveAFirestore() async {
    if (_uid.isEmpty || _cajaTareas == null) return;
    
    final tareasLocales = _cajaTareas!.values.toList();
    if (tareasLocales.isEmpty) return;

    // 1. Traer perfiles de Firestore para corregir IDs de perfil si es necesario
    final perfilesSnapshot = await _db.collection('familias').doc(_uid).collection('perfiles').get();
    final perfilesNube = perfilesSnapshot.docs.map((doc) => doc.data()).toList();

    // 2. Traer tareas existentes en Firestore
    final tareasSnapshot = await _db.collection('familias').doc(_uid).collection('tareas').get();
    final tareasNube = tareasSnapshot.docs.map((doc) => Tarea.fromMap(doc.data())).toList();

    for (var tLocal in tareasLocales) {
      // ¿Existe ya una tarea idéntica (mismo nombre y perfil)?
      // Primero, intentamos encontrar el perfil actual en la nube por nombre (caso de unificación)
      // Buscamos el nombre del perfil original en Hive (necesitaríamos acceso a PerfilesProvider o al box de perfiles)
      // Pero podemos simplificar: si el tLocal.id ya está en tareasNube, no hacemos nada.
      
      final existeEnNube = tareasNube.any((tn) => tn.id == tLocal.id || (tn.nombre == tLocal.nombre && tn.perfilId == tLocal.perfilId));

      if (!existeEnNube) {
        // Generamos ID si no tiene
        if (tLocal.id.isEmpty) {
          tLocal.id = DateTime.now().millisecondsSinceEpoch.toString() + tareasLocales.indexOf(tLocal).toString();
        }
        await _db.collection('familias').doc(_uid).collection('tareas').doc(tLocal.id).set(tLocal.toMap());
      }
    }
  }

  void _verificarNuevoDia() {
    final hoyId = _fechaIdHoy;
    bool huboCambio = false;
    WriteBatch? batch;
    if (_uid.isNotEmpty) batch = _db.batch();

    for (var tarea in _todasLasTareasData) {
      if (tarea.tipoRecurrencia != 'fecha_fija') {
        if (tarea.ultimoDiaCompletado != hoyId && tarea.estado == 'aprobada') {
          tarea.estado = 'pendiente';
          huboCambio = true;
          if (_uid.isNotEmpty && batch != null) {
            final docRef = _db.collection('familias').doc(_uid).collection('tareas').doc(tarea.id);
            batch.update(docRef, {'estado': 'pendiente'});
          } else {
            tarea.save();
          }
        }
      }
    }
    
    if (batch != null && huboCambio) {
      batch.commit();
    }
    if (huboCambio) notifyListeners();
  }

  List<Tarea> _tareasDelPerfil(String perfilId) {
    return _todasLasTareasData.where((t) => t.perfilId == perfilId).toList();
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
    return _todasLasTareasData.where((t) => t.estado == 'revision').toList();
  }

  Future<void> agregarTarea({
    required String nombre, required int puntos, required bool obligatoria,
    required IconData icon, required String bloque, required String tipoRecurrencia,
    List<int> diasSemana = const [1,2,3,4,5,6,7], DateTime? fechaEspecifica,
    required String perfilId,
  }) async {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final nuevaTarea = Tarea(
        id: newId,
        nombre: nombre, puntos: puntos, esObligatoria: obligatoria,
        iconoCodePoint: icon.codePoint, bloque: bloque,
        tipoRecurrencia: tipoRecurrencia, diasSemana: diasSemana,
        fechaEspecifica: fechaEspecifica, perfilId: perfilId,
    );

    if (_uid.isNotEmpty) {
      await _db.collection('familias').doc(_uid).collection('tareas').doc(newId).set(nuevaTarea.toMap());
    } else {
      await _cajaTareas!.add(nuevaTarea);
    }
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

    if (_uid.isNotEmpty) {
      await _db.collection('familias').doc(_uid).collection('tareas').doc(tarea.id).update(tarea.toMap());
    } else {
      await tarea.save();
    }
    notifyListeners();
  }

  Future<void> eliminarTarea(Tarea tarea) async {
    if (_uid.isNotEmpty) {
      await _db.collection('familias').doc(_uid).collection('tareas').doc(tarea.id).delete();
    } else {
      await tarea.delete();
    }
    notifyListeners();
  }

  Future<Tarea> aplicarSancion(String motivo, int monto, String perfilId) async {
    final newId = "S_${DateTime.now().millisecondsSinceEpoch}";
    final sancion = Tarea(
      id: newId,
      nombre: "Sanción: $motivo", puntos: -monto, esObligatoria: false,
      iconoCodePoint: Icons.warning_amber_rounded.codePoint, bloque: 'sancion',
      estado: 'aprobada', tipoRecurrencia: 'fecha_fija', fechaEspecifica: DateTime.now(),
      ultimoDiaCompletado: _fechaIdHoy, perfilId: perfilId,
    );
    
    if (_uid.isNotEmpty) {
      await _db.collection('familias').doc(_uid).collection('tareas').doc(newId).set(sancion.toMap());
    } else {
      await _cajaTareas!.add(sancion);
    }
    notifyListeners();
    return sancion;
  }

  void solicitarRevision(Tarea tarea) {
    if (tarea.estado == 'pendiente') {
      tarea.estado = 'revision';
      if (_uid.isNotEmpty) {
        _db.collection('familias').doc(_uid).collection('tareas').doc(tarea.id).update({'estado': 'revision'});
      } else {
        tarea.save();
      }
      notifyListeners();
    }
  }

  void rechazarTarea(Tarea tarea) {
    tarea.estado = 'pendiente';
    if (_uid.isNotEmpty) {
      _db.collection('familias').doc(_uid).collection('tareas').doc(tarea.id).update({'estado': 'pendiente'});
    } else {
      tarea.save();
    }
    notifyListeners();
  }

  Future<bool> aprobarTarea(Tarea tarea) async {
    if (tarea.estado == 'revision') {
      if (_uid.isNotEmpty) {
        final docRef = _db.collection('familias').doc(_uid).collection('tareas').doc(tarea.id);
        try {
          return await _db.runTransaction((transaction) async {
            final snapshot = await transaction.get(docRef);
            if (!snapshot.exists) return false;
            final data = snapshot.data()!;
            if (data['estado'] == 'revision') {
              transaction.update(docRef, {
                'estado': 'aprobada',
                'ultimoDiaCompletado': _fechaIdHoy,
              });
              return true;
            }
            return false;
          });
        } catch (e) {
          return false;
        }
      } else {
        tarea.estado = 'aprobada';
        tarea.ultimoDiaCompletado = _fechaIdHoy;
        await tarea.save();
        notifyListeners();
        return true;
      }
    }
    return false;
  }
  
  Future<bool> aprobarTareaManual(Tarea tarea) async {
    bool yaEstabaPagada = (tarea.estado == 'aprobada' && tarea.ultimoDiaCompletado == _fechaIdHoy);
    if (_uid.isNotEmpty) {
      final docRef = _db.collection('familias').doc(_uid).collection('tareas').doc(tarea.id);
      try {
        return await _db.runTransaction((transaction) async {
          final snapshot = await transaction.get(docRef);
          if (!snapshot.exists) return false;
          final data = snapshot.data()!;
          bool pagadaNube = (data['estado'] == 'aprobada' && data['ultimoDiaCompletado'] == _fechaIdHoy);
          if (!pagadaNube) {
            transaction.update(docRef, {
              'estado': 'aprobada',
              'ultimoDiaCompletado': _fechaIdHoy,
            });
            return true;
          }
          return false;
        });
      } catch (e) {
        return false;
      }
    } else {
      if (!yaEstabaPagada) {
        tarea.estado = 'aprobada';
        tarea.ultimoDiaCompletado = _fechaIdHoy;
        await tarea.save();
        notifyListeners();
        return true;
      }
      return false;
    }
  }

  bool tieneObligatoriasPendientes(String perfilId) {
    final tareasHoy = listaTareasActivas(perfilId);
    final bloque = bloqueActual;
    
    final bloquesSecuencia = ['manana', 'tarde', 'noche'];
    final indiceActual = bloquesSecuencia.indexOf(bloque);

    return tareasHoy.any((t) {
      if (!t.esObligatoria) return false;
      if (t.estado != 'pendiente') return false; // Si ya se envió a revisión o se aprobó, cuenta como hecha por el niño

      final indiceTarea = bloquesSecuencia.indexOf(t.bloque);
      if (indiceTarea == -1) return false;

      // Bloquear si hay una obligatoria pendiente del bloque actual o de los anteriores
      return indiceTarea <= indiceActual;
    });
  }

  String get bloqueActual {
    final hora = DateTime.now().hour;
    if (hora >= 5 && hora < 12) return 'manana';
    if (hora >= 12 && hora < 18) return 'tarde';
    return 'noche';
  }
  
  bool esBloqueActivo(String bloqueTarea) => bloqueTarea == bloqueActual;
}
