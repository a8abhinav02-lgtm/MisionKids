import 'package:hive/hive.dart';

/// Servicio responsable de gestionar la persistencia y estado del Onboarding
/// diferenciado por perfil (Padre vs Niño) compatible con Web y Android.
class OnboardingService {
  static const String boxName = 'caja_onboarding_v1';
  static const String keyAdminVisto = 'onboarding_admin_visto';
  static const String keyNinoPrefix = 'onboarding_nino_visto_';

  Box? _box;

  Future<Box> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox(boxName);
    return _box!;
  }

  /// Verifica si el administrador/padre ya vio el onboarding de gestión
  Future<bool> haVistoOnboardingAdmin() async {
    final box = await _getBox();
    return box.get(keyAdminVisto, defaultValue: false) as bool;
  }

  /// Marca como completado el onboarding de administración
  Future<void> marcarOnboardingAdminCompletado() async {
    final box = await _getBox();
    await box.put(keyAdminVisto, true);
  }

  /// Verifica si un niño específico (por su perfilId) ya vio su onboarding temático
  Future<bool> haVistoOnboardingNino(String perfilId) async {
    final box = await _getBox();
    return box.get('$keyNinoPrefix$perfilId', defaultValue: false) as bool;
  }

  /// Marca como completado el onboarding para un perfil de niño
  Future<void> marcarOnboardingNinoCompletado(String perfilId) async {
    final box = await _getBox();
    await box.put('$keyNinoPrefix$perfilId', true);
  }

  /// Restablece todas las banderas de onboarding (útil para pruebas o soporte)
  Future<void> reiniciarTodosLosOnboardings() async {
    final box = await _getBox();
    await box.clear();
  }
}
