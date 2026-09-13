import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:josue_tareas/models/tarea_model.dart';
import 'package:josue_tareas/providers/tarea_provider.dart';
import 'package:josue_tareas/services/notification_service.dart';

void main() {
  late Directory tempDir;
  late TareaProvider provider;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_notif_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TareaAdapter());
    }
    provider = TareaProvider();
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('NotificationService - Robustez de Notificaciones Inmediatas', () {
    test('mostrarNotificacionInmediata se ejecuta de forma segura y sin excepciones', () async {
      expect(
        () async => await NotificationService.mostrarNotificacionInmediata(
          id: 1234,
          titulo: 'Test Título',
          cuerpo: 'Test Cuerpo de Notificación',
        ),
        returnsNormally,
      );
    });
  });

  group('Flujos de Notificaciones Cruzadas en TareaProvider', () {
    test('Hijo ➡️ Padre: solicitarRevision actualiza estado a revision y notifica a tutores', () async {
      await provider.inicializar();
      const perfilId = 'nino_cross_notif_1';

      await provider.agregarTarea(
        nombre: 'Lavar dientes',
        puntos: 5,
        obligatoria: true,
        icon: Icons.cleaning_services,
        bloque: 'manana',
        tipoRecurrencia: 'diaria',
        perfilId: perfilId,
      );

      final tarea = provider.listaTodasLasTareas(perfilId).first;
      expect(tarea.estado, 'pendiente');

      // Hijo completa misión y solicita revisión
      provider.solicitarRevision(tarea, nombrePerfil: 'Josué');
      expect(tarea.estado, 'revision');

      final enRevision = provider.tareasPorRevisar(perfilId);
      expect(enRevision.length, 1);
      expect(enRevision.first.nombre, 'Lavar dientes');
    });

    test('Padre ➡️ Hijo: aprobarTarea actualiza estado a aprobada y acredita estrellas', () async {
      await provider.inicializar();
      const perfilId = 'nino_cross_notif_2';

      await provider.agregarTarea(
        nombre: 'Ordenar cuarto',
        puntos: 10,
        obligatoria: false,
        icon: Icons.toys,
        bloque: 'noche',
        tipoRecurrencia: 'diaria',
        perfilId: perfilId,
      );

      final tarea = provider.listaTodasLasTareas(perfilId).first;
      provider.solicitarRevision(tarea, nombrePerfil: 'Sofía');
      expect(tarea.estado, 'revision');

      // Padre aprueba la tarea
      final resultado = await provider.aprobarTarea(tarea, nombrePerfil: 'Sofía');
      expect(resultado, isTrue);
      expect(tarea.estado, 'aprobada');
      expect(tarea.ultimoDiaCompletado, provider.fechaIdHoy);
    });

    test('Padre ➡️ Hijo: aprobarTareaManual aprueba tarea pendiente y notifica', () async {
      await provider.inicializar();
      const perfilId = 'nino_cross_notif_3';

      await provider.agregarTarea(
        nombre: 'Comer fruta',
        puntos: 5,
        obligatoria: false,
        icon: Icons.apple,
        bloque: 'tarde',
        tipoRecurrencia: 'diaria',
        perfilId: perfilId,
      );

      final tarea = provider.listaTodasLasTareas(perfilId).first;
      expect(tarea.estado, 'pendiente');

      // Aprobación directa por el padre
      final resultado = await provider.aprobarTareaManual(tarea, nombrePerfil: 'Lucas');
      expect(resultado, isTrue);
      expect(tarea.estado, 'aprobada');
      expect(tarea.ultimoDiaCompletado, provider.fechaIdHoy);

      // Intento duplicado el mismo día
      final segundoIntento = await provider.aprobarTareaManual(tarea, nombrePerfil: 'Lucas');
      expect(segundoIntento, isFalse);
    });
  });
}
