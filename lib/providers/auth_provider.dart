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
    
    // Si tenemos usuario pero no PIN local, intentamos traerlo de Firestore
    if (_usuarioActual != null && pinPadre.isEmpty) {
      await _sincronizarPinDesdeNube();
    }

    isLoading = false;
    notifyListeners();
  }

  bool get existeAdmin => _cajaConfig?.get('setup_completo', defaultValue: false) ?? false;
  String get pinPadre => _cajaConfig?.get('pin_padre', defaultValue: '') ?? '';
  String get emailPadre => _cajaConfig?.get('email_padre', defaultValue: '') ?? '';
  bool get estaAprobado => _cajaConfig?.get('aprobado', defaultValue: true) ?? true;

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

      // 2. Guardar en Firestore la config de la familia
      await _db.collection('familias').doc(_usuarioActual!.uid).set({
        'pin_padre': pin,
        'email_padre': email,
        'fecha_creacion': FieldValue.serverTimestamp(),
        'aprobado': true, // Nuevos usuarios se auto-aprueban por defecto
      });

      // 3. Guardar localmente para acceso rápido offline
      await _cajaConfig!.put('pin_padre', pin);
      await _cajaConfig!.put('email_padre', email);
      await _cajaConfig!.put('setup_completo', true);
      await _cajaConfig!.put('aprobado', true);

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
    final doc = await _db.collection('familias').doc(_usuarioActual!.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      await _cajaConfig!.put('pin_padre', data['pin_padre']);
      await _cajaConfig!.put('email_padre', data['email_padre']);
      await _cajaConfig!.put('setup_completo', true);
      await _cajaConfig!.put('aprobado', data['aprobado'] ?? true);
    }
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
