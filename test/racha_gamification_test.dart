import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:josue_tareas/models/perfil_model.dart';
import 'package:josue_tareas/providers/perfiles_provider.dart';

void main() {
  late Directory tempDir;
  late PerfilesProvider provider;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_racha_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PerfilAdapter());
    }
    provider = PerfilesProvider();
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Perfil Model - Gamificación', () {
    test('Valores por defecto de racha y medallas', () {
      final perfil = Perfil(
        id: 'nino-001',
        nombre: 'Josué',
        tematica: 'espacio',
        colorPrimario: 'azul',
      );

      expect(perfil.rachaActual, 0);
      expect(perfil.mejorRacha, 0);
      expect(perfil.ultimoDiaRacha, 0);
      expect(perfil.medallas, isEmpty);
    });

    test('Serialización toMap y fromMap incluye racha y medallas', () {
      final perfil = Perfil(
        id: 'nino-002',
        nombre: 'Sofía',
        tematica: 'ninja',
        colorPrimario: 'verde',
        rachaActual: 5,
        mejorRacha: 10,
        ultimoDiaRacha: 20260905,
        medallas: ['bronce_3'],
      );

      final map = perfil.toMap();
      expect(map['rachaActual'], 5);
      expect(map['mejorRacha'], 10);
      expect(map['ultimoDiaRacha'], 20260905);
      expect(map['medallas'], ['bronce_3']);

      final reconstruido = Perfil.fromMap(map);
      expect(reconstruido.rachaActual, 5);
      expect(reconstruido.mejorRacha, 10);
      expect(reconstruido.ultimoDiaRacha, 20260905);
      expect(reconstruido.medallas, ['bronce_3']);
    });
  });

  group('PerfilesProvider - Lógica de Racha y Medallas', () {
    test('Día 1: Inicia racha en 1', () async {
      await provider.inicializar();
      await provider.crearPerfil(nombre: 'Lucas', tematica: 'espacio', colorPrimario: 'azul');
      final perfilId = provider.todosLosPerfiles.first.id;

      // Primer día (20260901)
      final exito = await provider.registrarProgresoRacha(perfilId, 20260901);
      expect(exito, isTrue);

      final perfil = provider.buscarPerfil(perfilId)!;
      expect(perfil.rachaActual, 1);
      expect(perfil.mejorRacha, 1);
      expect(perfil.ultimoDiaRacha, 20260901);
      expect(perfil.medallas, isEmpty);
    });

    test('Mismo día: No incrementa dos veces la racha', () async {
      await provider.inicializar();
      await provider.crearPerfil(nombre: 'Lucas', tematica: 'espacio', colorPrimario: 'azul');
      final perfilId = provider.todosLosPerfiles.first.id;

      await provider.registrarProgresoRacha(perfilId, 20260901);
      final segundoIntento = await provider.registrarProgresoRacha(perfilId, 20260901);
      expect(segundoIntento, isFalse);

      final perfil = provider.buscarPerfil(perfilId)!;
      expect(perfil.rachaActual, 1);
    });

    test('Días consecutivos: Incrementa racha y otorga medalla al día 3', () async {
      await provider.inicializar();
      await provider.crearPerfil(nombre: 'Lucas', tematica: 'espacio', colorPrimario: 'azul');
      final perfilId = provider.todosLosPerfiles.first.id;

      // Día 1
      await provider.registrarProgresoRacha(perfilId, 20260901);
      // Día 2 consecutivo
      await provider.registrarProgresoRacha(perfilId, 20260902);
      expect(provider.buscarPerfil(perfilId)!.rachaActual, 2);

      // Día 3 consecutivo ➔ Debe otorgar medalla bronce_3
      await provider.registrarProgresoRacha(perfilId, 20260903);
      final p3 = provider.buscarPerfil(perfilId)!;
      expect(p3.rachaActual, 3);
      expect(p3.mejorRacha, 3);
      expect(p3.medallas, contains('bronce_3'));
    });

    test('Día perdido: Reinicia racha a 1 pero conserva mejorRacha', () async {
      await provider.inicializar();
      await provider.crearPerfil(nombre: 'Lucas', tematica: 'espacio', colorPrimario: 'azul');
      final perfilId = provider.todosLosPerfiles.first.id;

      // Racha hasta día 3
      await provider.registrarProgresoRacha(perfilId, 20260901);
      await provider.registrarProgresoRacha(perfilId, 20260902);
      await provider.registrarProgresoRacha(perfilId, 20260903);
      expect(provider.buscarPerfil(perfilId)!.mejorRacha, 3);

      // Salto al día 20260906 (perdió el 4 y 5)
      await provider.registrarProgresoRacha(perfilId, 20260906);
      final pReinicio = provider.buscarPerfil(perfilId)!;
      expect(pReinicio.rachaActual, 1);
      expect(pReinicio.mejorRacha, 3); // Conserva el récord previo
      expect(pReinicio.medallas, contains('bronce_3')); // Conserva medallas ganadas
    });
  });
}
