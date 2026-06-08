import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Box? _cajaConfig;
  bool isLoading = true;
  User? _usuarioActual;

  User? get usuario => _usuarioActual;
  String get uid => _usuarioActual?.uid ?? '';
  bool get estaAutenticado => _usuarioActual != null;

  Future<void> inicializar() async {
    _cajaConfig = await Hive.openBox('caja_auth_v2');
    _usuarioActual = _auth.currentUser;
    
    // Si tenemos usuario, sincronizamos y validamos migración desde la nube
    if (_usuarioActual != null) {
      try {
        await _sincronizarPinDesdeNube();
      } catch (e) {
        // En caso de error de red, permitimos iniciar offline si ya tenemos PIN local
        if (pinPadre.isEmpty) {
          rethrow;
        }
      }
    }

    isLoading = false;
    notifyListeners();
  }

  bool get existeAdmin => _cajaConfig?.get('setup_completo', defaultValue: false) ?? false;
  String get pinPadre => _cajaConfig?.get('pin_padre', defaultValue: '') ?? '';
  String get emailPadre => _cajaConfig?.get('email_padre', defaultValue: '') ?? '';
  bool get estaAprobado => _cajaConfig?.get('aprobado', defaultValue: true) ?? true;

  String get familiaId {
    final cached = _cajaConfig?.get('familia_id', defaultValue: '') ?? '';
    if (cached.isNotEmpty) return cached;
    return uid.isNotEmpty ? 'FAM_$uid' : '';
  }

  Future<void> registrarAdmin({
    required String email,
    required String password,
    required String pin,
  }) async {
    try {
      // 1. Crear usuario en Firebase
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _usuarioActual = credential.user;

      // Generar ID de familia único legible (MK-XXXXXX)
      final rand = Random();
      final randCode = 'MK-${100000 + rand.nextInt(900000)}';

      // 2. Guardar en Firestore el mapeo usuario -> familia
      await _db.collection('usuarios').doc(_usuarioActual!.uid).set({
        'email': email,
        'familiaId': randCode,
        'fecha_registro': FieldValue.serverTimestamp(),
      });

      // 3. Guardar en Firestore la config de la familia
      await _db.collection('familias').doc(randCode).set({
        'pin_padre': pin,
        'email_padre': email,
        'fecha_creacion': FieldValue.serverTimestamp(),
        'aprobado': true, // Nuevos usuarios se auto-aprueban por defecto
        'padres': [_usuarioActual!.uid],
      });

      // 4. Guardar localmente para acceso rápido offline
      await _cajaConfig!.put('pin_padre', pin);
      await _cajaConfig!.put('email_padre', email);
      await _cajaConfig!.put('setup_completo', true);
      await _cajaConfig!.put('aprobado', true);
      await _cajaConfig!.put('familia_id', randCode);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loginPadre(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _usuarioActual = credential.user;
      await _sincronizarPinDesdeNube();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _sincronizarPinDesdeNube() async {
    if (_usuarioActual == null) return;

    // 1. Buscar en la colección /usuarios
    final userDoc = await _db.collection('usuarios').doc(_usuarioActual!.uid).get();
    String famId = '';
    bool necesitaMigracionOCreacion = false;

    if (userDoc.exists) {
      famId = userDoc.data()?['familiaId'] ?? '';
      if (famId.isNotEmpty) {
        final famDoc = await _db.collection('familias').doc(famId).get();
        if (!famDoc.exists) {
          necesitaMigracionOCreacion = true;
        }
      } else {
        necesitaMigracionOCreacion = true;
      }
    } else {
      necesitaMigracionOCreacion = true;
    }

    if (!necesitaMigracionOCreacion) {
      // Todo está bien, la familia existe
    } else {
      // Intentar migrar cuenta clásica a co-parenting
      final oldFamDoc = await _db.collection('familias').doc(_usuarioActual!.uid).get();
      if (oldFamDoc.exists) {
        famId = 'FAM_${_usuarioActual!.uid}';
        
        // A. Crear usuario
        await _db.collection('usuarios').doc(_usuarioActual!.uid).set({
          'email': _usuarioActual!.email ?? '',
          'familiaId': famId,
          'fecha_registro': FieldValue.serverTimestamp(),
        });

        // B. Clonar datos de familia al nuevo ID
        final oldData = oldFamDoc.data()!;
        oldData['padres'] = [_usuarioActual!.uid];
        await _db.collection('familias').doc(famId).set(oldData);

        // C. Clonar subcolecciones (perfiles y tareas)
        // Clonar perfiles
        final perfilesSnapshot = await _db.collection('familias').doc(_usuarioActual!.uid).collection('perfiles').get();
        for (var doc in perfilesSnapshot.docs) {
          await _db.collection('familias').doc(famId).collection('perfiles').doc(doc.id).set(doc.data());
        }
        // Clonar tareas
        final tareasSnapshot = await _db.collection('familias').doc(_usuarioActual!.uid).collection('tareas').get();
        for (var doc in tareasSnapshot.docs) {
          await _db.collection('familias').doc(famId).collection('tareas').doc(doc.id).set(doc.data());
        }

        // Eliminar la familia anterior para no dejar basura
        await _db.collection('familias').doc(_usuarioActual!.uid).delete();
      } else {
        // Nueva cuenta de Firebase sin datos de familia y sin usuario (error o cuenta vacía)
        if (famId.isEmpty) {
          final rand = Random();
          famId = 'MK-${100000 + rand.nextInt(900000)}';
        }
        await _db.collection('usuarios').doc(_usuarioActual!.uid).set({
          'email': _usuarioActual!.email ?? '',
          'familiaId': famId,
          'fecha_registro': FieldValue.serverTimestamp(),
        });
        await _db.collection('familias').doc(famId).set({
          'pin_padre': '0000', // PIN provisional
          'email_padre': _usuarioActual!.email ?? '',
          'fecha_creacion': FieldValue.serverTimestamp(),
          'aprobado': true,
          'padres': [_usuarioActual!.uid],
        });
      }
    }

    if (famId.isNotEmpty) {
      final doc = await _db.collection('familias').doc(famId).get();
      if (doc.exists) {
        final data = doc.data()!;
        await _cajaConfig!.put('pin_padre', data['pin_padre']);
        await _cajaConfig!.put('email_padre', data['email_padre']);
        await _cajaConfig!.put('setup_completo', true);
        await _cajaConfig!.put('aprobado', data['aprobado'] ?? true);
        await _cajaConfig!.put('familia_id', famId);
      }
    }
  }

  Future<void> unirseAFamilia(String codigoFamilia) async {
    if (_usuarioActual == null) return;
    
    // 1. Verificar que la familia exista
    final famDoc = await _db.collection('familias').doc(codigoFamilia).get();
    if (!famDoc.exists) {
      throw Exception("El código de familia no es válido ⛔");
    }

    // 2. Crear/Actualizar usuario
    await _db.collection('usuarios').doc(_usuarioActual!.uid).set({
      'email': _usuarioActual!.email ?? '',
      'familiaId': codigoFamilia,
      'fecha_registro': FieldValue.serverTimestamp(),
    });

    // 3. Añadir a la lista de padres en la familia
    await _db.collection('familias').doc(codigoFamilia).update({
      'padres': FieldValue.arrayUnion([_usuarioActual!.uid]),
    });

    // 4. Sincronizar localmente
    final data = famDoc.data()!;
    await _cajaConfig!.put('pin_padre', data['pin_padre']);
    await _cajaConfig!.put('email_padre', data['email_padre']);
    await _cajaConfig!.put('setup_completo', true);
    await _cajaConfig!.put('aprobado', data['aprobado'] ?? true);
    await _cajaConfig!.put('familia_id', codigoFamilia);

    notifyListeners();
  }

  Future<void> recomprobarAprobacion() async {
    isLoading = true;
    notifyListeners();
    try {
      await _sincronizarPinDesdeNube();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
    _usuarioActual = null;
    if (_cajaConfig != null) {
      await _cajaConfig!.clear(); // Limpiamos PIN y setup_completo local
    }
    notifyListeners();
  }
}
