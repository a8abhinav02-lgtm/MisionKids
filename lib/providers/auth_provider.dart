import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AuthProvider extends ChangeNotifier {
  Box? _cajaConfig;
  bool isLoading = true;

  Future<void> inicializar() async {
    _cajaConfig = await Hive.openBox('caja_auth_v2'); // Nueva caja limpia
    isLoading = false;
    notifyListeners();
  }

  bool get existeAdmin => _cajaConfig?.get('setup_completo', defaultValue: false) ?? false;
  String get pinPadre => _cajaConfig?.get('pin_padre', defaultValue: '') ?? '';

  Future<void> registrarAdmin(String nuevoPin) async {
    await _cajaConfig!.put('pin_padre', nuevoPin);
    await _cajaConfig!.put('setup_completo', true);
    notifyListeners();
  }
}
