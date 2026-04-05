import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/perfil_model.dart';

class PerfilesProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Box<Perfil>? _cajaPerfiles;
  
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

  void updateUid(String newUid) {
    if (_uid != newUid) {
      _uid = newUid;
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
     return todosLosPerfiles.firstWhere((p) => p.id == id, orElse: () => null as Perfil);
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
}
