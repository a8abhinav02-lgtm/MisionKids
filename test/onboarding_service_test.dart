import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:josue_tareas/services/onboarding_service.dart';

void main() {
  late Directory tempDir;
  late OnboardingService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_onboarding_test_');
    Hive.init(tempDir.path);
    service = OnboardingService();
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('OnboardingService Tests', () {
    test('Onboarding Admin: valor inicial false y luego true tras marcar completado', () async {
      final inicial = await service.haVistoOnboardingAdmin();
      expect(inicial, isFalse);

      await service.marcarOnboardingAdminCompletado();
      final completado = await service.haVistoOnboardingAdmin();
      expect(completado, isTrue);
    });

    test('Onboarding Niño: almacena banderas independientes por cada perfilId', () async {
      expect(await service.haVistoOnboardingNino('nino-1'), isFalse);
      expect(await service.haVistoOnboardingNino('nino-2'), isFalse);

      await service.marcarOnboardingNinoCompletado('nino-1');

      expect(await service.haVistoOnboardingNino('nino-1'), isTrue);
      expect(await service.haVistoOnboardingNino('nino-2'), isFalse);
    });

    test('Reiniciar todos los onboardings restablece los estados a false', () async {
      await service.marcarOnboardingAdminCompletado();
      await service.marcarOnboardingNinoCompletado('nino-1');

      expect(await service.haVistoOnboardingAdmin(), isTrue);
      expect(await service.haVistoOnboardingNino('nino-1'), isTrue);

      await service.reiniciarTodosLosOnboardings();

      expect(await service.haVistoOnboardingAdmin(), isFalse);
      expect(await service.haVistoOnboardingNino('nino-1'), isFalse);
    });
  });
}
