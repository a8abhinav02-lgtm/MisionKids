import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:josue_tareas/models/tarea_model.dart';
import 'package:josue_tareas/providers/tarea_provider.dart';
import 'package:josue_tareas/ui/widgets/plantillas_tareas_modal.dart';

void main() {
  late Directory tempDir;
  late TareaProvider provider;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_plantillas_test_');
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

  group('Plantillas de Tareas - Catálogo', () {
    test('Catálogo contiene plantillas organizadas en categorías válidas', () {
      final plantillas = PlantillasTareasModal.plantillasDisponibles;
      expect(plantillas, isNotEmpty);
      expect(plantillas.length, greaterThanOrEqualTo(10));

      for (var p in plantillas) {
        expect(p.nombre, isNotEmpty);
        expect(p.puntos, greaterThan(0));
        expect(['manana', 'tarde', 'noche'], contains(p.bloque));
        expect(['higiene', 'orden', 'estudio', 'salud'], contains(p.categoria));
      }
    });

    test('Creación de tarea a partir de una plantilla rápida', () async {
      await provider.inicializar();
      const perfilId = 'nino_test_1';
      final plantilla = PlantillasTareasModal.plantillasDisponibles.first;

      await provider.agregarTarea(
        nombre: plantilla.nombre,
        puntos: plantilla.puntos,
        obligatoria: plantilla.esObligatoria,
        icon: plantilla.icono,
        bloque: plantilla.bloque,
        tipoRecurrencia: 'diaria',
        perfilId: perfilId,
      );

      final tareas = provider.listaTodasLasTareas(perfilId);
      expect(tareas.length, 1);
      expect(tareas.first.nombre, plantilla.nombre);
      expect(tareas.first.puntos, plantilla.puntos);
      expect(tareas.first.bloque, plantilla.bloque);
      expect(tareas.first.esObligatoria, plantilla.esObligatoria);
    });
  });

  group('TareaProvider - Métricas y Analíticas de Hábitos', () {
    test('Cálculo de tasa de cumplimiento diario y conteo por bloques', () async {
      await provider.inicializar();
      const perfilId = 'nino_test_2';

      // 1. Sin tareas programadas -> 0.0
      expect(provider.porcentajeCumplimientoHoy(perfilId), 0.0);

      // 2. Agregar 3 tareas: 1 mañana, 1 tarde, 1 noche
      await provider.agregarTarea(
        nombre: 'Tender cama',
        puntos: 5,
        obligatoria: true,
        icon: Icons.bed,
        bloque: 'manana',
        tipoRecurrencia: 'diaria',
        perfilId: perfilId,
      );
      await provider.agregarTarea(
        nombre: 'Deberes',
        puntos: 15,
        obligatoria: true,
        icon: Icons.school,
        bloque: 'tarde',
        tipoRecurrencia: 'diaria',
        perfilId: perfilId,
      );
      await provider.agregarTarea(
        nombre: 'Guardar juguetes',
        puntos: 10,
        obligatoria: false,
        icon: Icons.toys,
        bloque: 'noche',
        tipoRecurrencia: 'diaria',
        perfilId: perfilId,
      );

      final conteo = provider.conteoPorBloque(perfilId);
      expect(conteo['manana'], 1);
      expect(conteo['tarde'], 1);
      expect(conteo['noche'], 1);

      // Todas pendientes -> 0.0
      expect(provider.porcentajeCumplimientoHoy(perfilId), 0.0);

      // 3. Completar/aprobar 1 tarea (la de mañana)
      final tareaManana = provider.tareasManana(perfilId).first;
      provider.solicitarRevision(tareaManana);
      await provider.aprobarTarea(tareaManana);

      // 1 de 3 completada -> 0.333...
      final ratio = provider.porcentajeCumplimientoHoy(perfilId);
      expect(ratio, closeTo(1 / 3, 0.01));

      final completadasBloques = provider.conteoCompletadasPorBloque(perfilId);
      expect(completadasBloques['manana'], 1);
      expect(completadasBloques['tarde'], 0);
      expect(completadasBloques['noche'], 0);

      // 4. Completar las otras dos tareas
      final tareaTarde = provider.tareasTarde(perfilId).first;
      provider.solicitarRevision(tareaTarde);
      await provider.aprobarTarea(tareaTarde);

      final tareaNoche = provider.tareasNoche(perfilId).first;
      provider.solicitarRevision(tareaNoche);
      await provider.aprobarTarea(tareaNoche);

      // 3 de 3 completadas -> 1.0 (100%)
      expect(provider.porcentajeCumplimientoHoy(perfilId), 1.0);
    });
  });
}
