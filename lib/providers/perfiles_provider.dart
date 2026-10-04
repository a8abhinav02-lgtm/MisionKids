import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/perfil_model.dart';

class PerfilesProvider extends ChangeNotifier {
  final FirebaseFirestore? _customDb;
  Box<Perfil>? _cajaPerfiles;

  PerfilesProvider({FirebaseFirestore? firestore}) : _customDb = firestore;

  FirebaseFirestore get _db => _customDb ?? FirebaseFirestore.instance;
  
  bool isLoading = true;
  String _uid = '';
  Perfil? _perfilActivo;
  List<Perfil> _perfilesFirestore = [];
  
  Perfil? get perfilActivo => _perfilActivo;
  String get uid => _uid;

  List<Perfil> get todosLosPerfiles {
    // Retornamos los de Firestore si están cargados, si no, los de Hive
    return _perfilesFirestore.isNotEmpty ? _perfilesFirestore : (_cajaPerfiles?.values.toList() ?? []);
  }

  void updateFamiliaId(String newFamiliaId) {
    if (_uid != newFamiliaId) {
      _uid = newFamiliaId;
      if (_uid.isNotEmpty) {
        _escucharPerfiles();
      }
    }
  }

  bool _inicializacionIniciada = false;

  Future<void> inicializar() async {
    if (_inicializacionIniciada) return;
    _inicializacionIniciada = true;

    _cajaPerfiles = await Hive.openBox<Perfil>('caja_perfiles_v2');
    if (_uid.isNotEmpty) {
      await _migrarHiveAFirestore();
      _escucharPerfiles();
    }
    isLoading = false;
    notifyListeners();
  }

  void _escucharPerfiles() {
    if (_uid.isEmpty) return;
    _db.collection('familias').doc(_uid).collection('perfiles')
      .snapshots().listen((snapshot) {
        _perfilesFirestore = snapshot.docs.map((doc) => Perfil.fromMap(doc.data())).toList();
        notifyListeners();
      });
  }

  Future<void> _migrarHiveAFirestore() async {
    if (_uid.isEmpty || _cajaPerfiles == null) return;
    
    final perfilesLocal = _cajaPerfiles!.values.toList();
    if (perfilesLocal.isEmpty) return;

    // Traemos los nombres que ya existen en Firestore para evitar duplicados
    final snapshot = await _db.collection('familias').doc(_uid).collection('perfiles').get();
    final perfilesEnNube = snapshot.docs.map((doc) => Perfil.fromMap(doc.data())).toList();

    for (var pLocal in perfilesLocal) {
      // ¿Existe ya un perfil con este nombre en la nube?
      final coincidencia = perfilesEnNube.where(
        (pNube) => pNube.nombre.trim().toLowerCase() == pLocal.nombre.trim().toLowerCase()
      ).firstOrNull;

      if (coincidencia != null) {
        // Si existe, sincronizamos el ID local para que coincida con la nube
        pLocal.id = coincidencia.id;
        // Opcional: Actualizar el resto de campos locales si la nube es más reciente
      } else {
        // Si no existe, lo subimos con su ID actual
        await _db.collection('familias').doc(_uid).collection('perfiles').doc(pLocal.id).set(pLocal.toMap());
      }
    }
  }

  void setPerfilActivo(Perfil perfil) {
    _perfilActivo = perfil;
    notifyListeners();
  }

  void limpiarPerfilActivo() {
    _perfilActivo = null;
    notifyListeners();
  }
  
  Perfil? buscarPerfil(String id) {
    final list = todosLosPerfiles.where((p) => p.id == id);
    return list.isEmpty ? null : list.first;
  }

  Future<void> crearPerfil({
    required String nombre, 
    required String tematica, 
    required String colorPrimario
  }) async {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final nuevo = Perfil(
      id: newId,
      nombre: nombre,
      tematica: tematica,
      colorPrimario: colorPrimario,
    );

    if (_uid.isNotEmpty) {
      await _db.collection('familias').doc(_uid).collection('perfiles').doc(newId).set(nuevo.toMap());
    } else {
      await _cajaPerfiles!.put(newId, nuevo);
    }
    notifyListeners();
  }

  Future<void> editarPerfil(Perfil perfil, String nombre, String tematica, String colorPrimario) async {
    perfil.nombre = nombre;
    perfil.tematica = tematica;
    perfil.colorPrimario = colorPrimario;
    
    if (_uid.isNotEmpty) {
      await _db.collection('familias').doc(_uid).collection('perfiles').doc(perfil.id).update(perfil.toMap());
    } else {
      await perfil.save();
    }
    notifyListeners();
  }

  Future<void> eliminarPerfil(Perfil perfil) async {
    if (_uid.isNotEmpty) {
      await _db.collection('familias').doc(_uid).collection('perfiles').doc(perfil.id).delete();
    } else {
      await perfil.delete();
    }
    
    if (_perfilActivo?.id == perfil.id) {
       _perfilActivo = null;
    }
    notifyListeners();
  }

  // --- Finanzas ---
  Future<void> agregarDinero(String perfilId, int cantidad) async {
    final perfil = todosLosPerfiles.firstWhere((p) => p.id == perfilId);
    perfil.saldo += cantidad;

    if (_uid.isNotEmpty) {
      await _db.collection('familias').doc(_uid).collection('perfiles').doc(perfilId).update({'saldo': FieldValue.increment(cantidad)});
    } else {
      await perfil.save();
    }
    notifyListeners();
  }

  Future<void> definirNuevaMeta(String perfilId, String nombre, double monto) async {
    final perfil = todosLosPerfiles.firstWhere((p) => p.id == perfilId);
    perfil.nombreMeta = nombre;
    perfil.metaAhorro = monto;

    if (_uid.isNotEmpty) {
      await _db.collection('familias').doc(_uid).collection('perfiles').doc(perfilId).update({
        'nombreMeta': nombre,
        'metaAhorro': monto,
      });
    } else {
      await perfil.save();
    }
    notifyListeners();
  }

  Future<void> reclamarPremio(String perfilId) async {
    final perfil = todosLosPerfiles.firstWhere((p) => p.id == perfilId);
    final costoMeta = perfil.metaAhorro.toInt();
    final nombrePremio = perfil.nombreMeta;

    if (perfil.saldo >= costoMeta && costoMeta > 0) {
      perfil.saldo -= costoMeta;

      final nuevaVictoria = {
        'nombre': nombrePremio,
        'fecha': DateTime.now().toIso8601String(),
        'costo': costoMeta,
      };

      final List<Map<dynamic, dynamic>> historial = List.from(perfil.historialVictorias);
      historial.add(nuevaVictoria);
      
      perfil.historialVictorias = historial;
      perfil.metaAhorro = 0.0;
      perfil.nombreMeta = '';

      if (_uid.isNotEmpty) {
        await _db.collection('familias').doc(_uid).collection('perfiles').doc(perfilId).update({
          'saldo': FieldValue.increment(-costoMeta),
          'historialVictorias': historial,
          'metaAhorro': 0.0,
          'nombreMeta': '',
        });
      } else {
        await perfil.save();
      }
      notifyListeners();
    }
  }

  // --- Gamificación y Rachas Diarias ---

  Future<bool> registrarProgresoRacha(String perfilId, int fechaIdHoy) async {
    final perfil = todosLosPerfiles.where((p) => p.id == perfilId).firstOrNull;
    if (perfil == null) return false;

    // Si ya se registró la racha hoy, evitar duplicados
    if (perfil.ultimoDiaRacha == fechaIdHoy) {
      return false;
    }

    final fechaIdAyer = _calcularFechaIdAyer(fechaIdHoy);

    if (perfil.ultimoDiaRacha == fechaIdAyer) {
      // Día consecutivo: racha sigue viva
      perfil.rachaActual += 1;
    } else {
      // Racha rota o primera vez que inicia
      perfil.rachaActual = 1;
    }

    if (perfil.rachaActual > perfil.mejorRacha) {
      perfil.mejorRacha = perfil.rachaActual;
    }

    perfil.ultimoDiaRacha = fechaIdHoy;

    // Asignación de medallas de hitos
    final medallasActuales = List<String>.from(perfil.medallas);
    bool ganoNuevaMedalla = false;

    if (perfil.rachaActual >= 3 && !medallasActuales.contains('bronce_3')) {
      medallasActuales.add('bronce_3');
      ganoNuevaMedalla = true;
    }
    if (perfil.rachaActual >= 7 && !medallasActuales.contains('plata_7')) {
      medallasActuales.add('plata_7');
      ganoNuevaMedalla = true;
    }
    if (perfil.rachaActual >= 14 && !medallasActuales.contains('oro_14')) {
      medallasActuales.add('oro_14');
      ganoNuevaMedalla = true;
    }
    if (perfil.rachaActual >= 30 && !medallasActuales.contains('diamante_30')) {
      medallasActuales.add('diamante_30');
      ganoNuevaMedalla = true;
    }

    if (ganoNuevaMedalla) {
      perfil.medallas = medallasActuales;
    }

    if (_uid.isNotEmpty) {
      await _db.collection('familias').doc(_uid).collection('perfiles').doc(perfilId).update({
        'rachaActual': perfil.rachaActual,
        'mejorRacha': perfil.mejorRacha,
        'ultimoDiaRacha': perfil.ultimoDiaRacha,
        'medallas': perfil.medallas,
      });
    } else {
      await perfil.save();
    }

    notifyListeners();
    return true;
  }

  int _calcularFechaIdAyer(int fechaIdHoy) {
    final anio = fechaIdHoy ~/ 10000;
    final mes = (fechaIdHoy % 10000) ~/ 100;
    final dia = fechaIdHoy % 100;
    final fecha = DateTime(anio, mes, dia).subtract(const Duration(days: 1));
    return (fecha.year * 10000) + (fecha.month * 100) + fecha.day;
  }

  // --- Tienda de Premios ---
  
  Future<void> agregarPremioAlCatalogo(String perfilId, Map<String, dynamic> premioData) async {
    final perfil = todosLosPerfiles.firstWhere((p) => p.id == perfilId);
    
    final catalogo = List<Map<dynamic, dynamic>>.from(perfil.catalogoPremios);
    catalogo.add(premioData);
    
    perfil.catalogoPremios = catalogo;

    if (_uid.isNotEmpty) {
      await _db.collection('familias').doc(_uid).collection('perfiles').doc(perfilId).update({
        'catalogoPremios': catalogo,
      });
    } else {
      await perfil.save();
    }
    notifyListeners();
  }

  Future<void> eliminarPremioDelCatalogo(String perfilId, String premioId) async {
    final perfil = todosLosPerfiles.firstWhere((p) => p.id == perfilId);
    
    final catalogo = List<Map<dynamic, dynamic>>.from(perfil.catalogoPremios);
    catalogo.removeWhere((p) => p['id'] == premioId);
    
    perfil.catalogoPremios = catalogo;

    if (_uid.isNotEmpty) {
      await _db.collection('familias').doc(_uid).collection('perfiles').doc(perfilId).update({
        'catalogoPremios': catalogo,
      });
    } else {
      await perfil.save();
    }
    notifyListeners();
  }

  Future<void> editarPremioEnCatalogo(String perfilId, Map<dynamic, dynamic> premioEditado) async {
    final perfil = todosLosPerfiles.firstWhere((p) => p.id == perfilId);
    
    final catalogo = List<Map<dynamic, dynamic>>.from(perfil.catalogoPremios);
    final index = catalogo.indexWhere((p) => p['id'] == premioEditado['id']);
    
    if (index != -1) {
      catalogo[index] = premioEditado;
      perfil.catalogoPremios = catalogo;

      if (_uid.isNotEmpty) {
        await _db.collection('familias').doc(_uid).collection('perfiles').doc(perfilId).update({
          'catalogoPremios': catalogo,
        });
      } else {
        await perfil.save();
      }
      notifyListeners();
    }
  }

  Future<void> solicitarCanje(String perfilId, Map<dynamic, dynamic> premioData) async {
    final perfil = todosLosPerfiles.firstWhere((p) => p.id == perfilId);
    final int costo = (premioData['costo'] as num?)?.toInt() ?? 0;

    if (perfil.saldo >= costo && costo > 0) {
      perfil.saldo -= costo; // Reserva temporal

      final solicitud = {
        'idSolicitud': DateTime.now().millisecondsSinceEpoch.toString(),
        'premioId': premioData['id'],
        'nombre': premioData['nombre'],
        'costo': costo,
        'fecha': DateTime.now().toIso8601String(),
      };

      final List<Map<dynamic, dynamic>> solicitudes = List.from(perfil.solicitudesCanje);
      solicitudes.add(solicitud);
      perfil.solicitudesCanje = solicitudes;

      if (_uid.isNotEmpty) {
        await _db.collection('familias').doc(_uid).collection('perfiles').doc(perfilId).update({
          'saldo': FieldValue.increment(-costo),
          'solicitudesCanje': solicitudes,
        });
      } else {
        await perfil.save();
      }
      notifyListeners();
    }
  }

  Future<void> aprobarCanje(String perfilId, Map<dynamic, dynamic> solicitud) async {
    final perfil = todosLosPerfiles.firstWhere((p) => p.id == perfilId);
    
    final List<Map<dynamic, dynamic>> solicitudes = List.from(perfil.solicitudesCanje);
    solicitudes.removeWhere((s) => s['idSolicitud'] == solicitud['idSolicitud']);
    perfil.solicitudesCanje = solicitudes;

    final victoria = {
      'nombre': solicitud['nombre'],
      'fecha': DateTime.now().toIso8601String(),
      'costo': solicitud['costo'],
    };

    final List<Map<dynamic, dynamic>> historial = List.from(perfil.historialVictorias);
    historial.add(victoria);
    perfil.historialVictorias = historial;

    final List<Map<dynamic, dynamic>> catalogo = List.from(perfil.catalogoPremios);
    catalogo.removeWhere((p) => p['id'] == solicitud['premioId']);
    perfil.catalogoPremios = catalogo;

    if (_uid.isNotEmpty) {
      await _db.collection('familias').doc(_uid).collection('perfiles').doc(perfilId).update({
        'solicitudesCanje': solicitudes,
        'historialVictorias': historial,
        'catalogoPremios': catalogo,
      });
    } else {
      await perfil.save();
    }
    notifyListeners();
  }

  Future<void> rechazarCanje(String perfilId, String idSolicitud) async {
    final perfil = todosLosPerfiles.firstWhere((p) => p.id == perfilId);
    
    final solicitud = perfil.solicitudesCanje.firstWhere((s) => s['idSolicitud'] == idSolicitud, orElse: () => {});
    if (solicitud.isEmpty) return;

    final int costo = (solicitud['costo'] as num?)?.toInt() ?? 0;

    final List<Map<dynamic, dynamic>> solicitudes = List.from(perfil.solicitudesCanje);
    solicitudes.removeWhere((s) => s['idSolicitud'] == idSolicitud);
    perfil.solicitudesCanje = solicitudes;
    
    perfil.saldo += costo; // Reembolso

    if (_uid.isNotEmpty) {
      await _db.collection('familias').doc(_uid).collection('perfiles').doc(perfilId).update({
        'solicitudesCanje': solicitudes,
        'saldo': FieldValue.increment(costo),
      });
    } else {
      await perfil.save();
    }
    notifyListeners();
  }
}
