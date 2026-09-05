import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FeedbackService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Obtiene de forma segura el nombre de la plataforma actual
  String get _currentPlatform {
    if (kIsWeb) return 'Web';
    try {
      if (Platform.isAndroid) return 'Android';
      if (Platform.isIOS) return 'iOS';
      if (Platform.isWindows) return 'Windows';
      if (Platform.isMacOS) return 'macOS';
      if (Platform.isLinux) return 'Linux';
    } catch (_) {}
    return 'Unknown';
  }

  /// Envía un nuevo mensaje de retroalimentación a la colección 'feedback'
  Future<void> submitFeedback({
    required String message,
    String category = 'Sugerencia',
    int? rating,
    String? userEmail,
    String? perfilNombre,
    String? perfilRol,
    String? familiaId,
  }) async {
    final user = _auth.currentUser;

    final feedbackData = <String, dynamic>{
      'message': message.trim(),
      'category': category,
      if (rating != null) 'rating': rating,
      'platform': _currentPlatform,
      'appVersion': '1.0.0+1',
      'timestamp': FieldValue.serverTimestamp(),
      'userId': user?.uid ?? 'anonimo',
      'userEmail': userEmail ?? user?.email ?? 'No registrado',
      'perfilNombre': perfilNombre ?? 'No especificado',
      'perfilRol': perfilRol ?? 'No especificado',
      'familiaId': familiaId ?? 'No especificado',
    };

    await _firestore.collection('feedback').add(feedbackData);
  }
}
