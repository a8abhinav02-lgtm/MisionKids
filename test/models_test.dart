import 'package:flutter_test/flutter_test.dart';
import 'package:josue_tareas/models/tarea_model.dart';
import 'package:josue_tareas/models/perfil_model.dart';

void main() {
  group('Tarea Model Tests', () {
    test('Creación de Tarea con valores por defecto', () {
      final tarea = Tarea(
        nombre: 'Lavar los platos',
        puntos: 10,
        esObligatoria: true,
        iconoCodePoint: 58000,
        bloque: 'manana',
        perfilId: 'perfil-123',
      );

      expect(tarea.nombre, 'Lavar los platos');
      expect(tarea.puntos, 10);
      expect(tarea.esObligatoria, true);
      expect(tarea.estado, 'pendiente');
      expect(tarea.estaPendiente, true);
      expect(tarea.estaEnRevision, false);
      expect(tarea.estaAprobada, false);
      expect(tarea.tipoRecurrencia, 'diaria');
      expect(tarea.diasSemana, [1, 2, 3, 4, 5, 6, 7]);
    });

    test('Estados de la tarea', () {
      final tarea = Tarea(
        nombre: 'Hacer deberes',
        puntos: 15,
        esObligatoria: false,
        iconoCodePoint: 58001,
        bloque: 'tarde',
        perfilId: 'perfil-123',
        estado: 'revision',
      );

      expect(tarea.estaPendiente, false);
      expect(tarea.estaEnRevision, true);
      expect(tarea.estaAprobada, false);

      tarea.estado = 'aprobada';
      expect(tarea.estaPendiente, false);
      expect(tarea.estaEnRevision, false);
      expect(tarea.estaAprobada, true);
    });

    test('Serialización toMap y fromMap', () {
      final tareaOriginal = Tarea(
        id: 'tarea-abc',
        nombre: 'Ordenar cuarto',
        puntos: 20,
        esObligatoria: true,
        estado: 'pendiente',
        iconoCodePoint: 58002,
        bloque: 'noche',
        tipoRecurrencia: 'semanal',
        diasSemana: [1, 3, 5],
        ultimoDiaCompletado: 5,
        perfilId: 'perfil-456',
      );

      final map = tareaOriginal.toMap();
      expect(map['id'], 'tarea-abc');
      expect(map['nombre'], 'Ordenar cuarto');
      expect(map['puntos'], 20);
      expect(map['esObligatoria'], true);
      expect(map['bloque'], 'noche');
      expect(map['tipoRecurrencia'], 'semanal');
      expect(map['diasSemana'], [1, 3, 5]);

      final tareaReconstruida = Tarea.fromMap(map);
      expect(tareaReconstruida.id, tareaOriginal.id);
      expect(tareaReconstruida.nombre, tareaOriginal.nombre);
      expect(tareaReconstruida.puntos, tareaOriginal.puntos);
      expect(tareaReconstruida.esObligatoria, tareaOriginal.esObligatoria);
      expect(tareaReconstruida.bloque, tareaOriginal.bloque);
      expect(tareaReconstruida.diasSemana, [1, 3, 5]);
      expect(tareaReconstruida.ultimoDiaCompletado, 5);
      expect(tareaReconstruida.perfilId, 'perfil-456');
    });
  });

  group('Perfil Model Tests', () {
    test('Creación de Perfil con valores por defecto', () {
      final perfil = Perfil(
        id: 'perfil-001',
        nombre: 'Josué',
        tematica: 'espacio',
        colorPrimario: 'azul',
      );

      expect(perfil.id, 'perfil-001');
      expect(perfil.nombre, 'Josué');
      expect(perfil.tematica, 'espacio');
      expect(perfil.colorPrimario, 'azul');
      expect(perfil.saldo, 0);
      expect(perfil.metaAhorro, 0.0);
      expect(perfil.frecuenciaRecordatorio, 10);
      expect(perfil.historialVictorias, isEmpty);
      expect(perfil.catalogoPremios, isEmpty);
      expect(perfil.solicitudesCanje, isEmpty);
    });

    test('Serialización toMap y fromMap de Perfil', () {
      final perfilOriginal = Perfil(
        id: 'perfil-002',
        nombre: 'Sofía',
        tematica: 'ninja',
        colorPrimario: 'verde',
        saldo: 150,
        metaAhorro: 500.0,
        nombreMeta: 'Bicicleta',
        frecuenciaRecordatorio: 15,
      );

      final map = perfilOriginal.toMap();
      expect(map['id'], 'perfil-002');
      expect(map['nombre'], 'Sofía');
      expect(map['saldo'], 150);
      expect(map['metaAhorro'], 500.0);
      expect(map['nombreMeta'], 'Bicicleta');

      final perfilReconstruido = Perfil.fromMap(map);
      expect(perfilReconstruido.id, perfilOriginal.id);
      expect(perfilReconstruido.nombre, perfilOriginal.nombre);
      expect(perfilReconstruido.tematica, perfilOriginal.tematica);
      expect(perfilReconstruido.colorPrimario, perfilOriginal.colorPrimario);
      expect(perfilReconstruido.saldo, perfilOriginal.saldo);
      expect(perfilReconstruido.metaAhorro, perfilOriginal.metaAhorro);
      expect(perfilReconstruido.nombreMeta, perfilOriginal.nombreMeta);
      expect(perfilReconstruido.frecuenciaRecordatorio, 15);
    });
  });
}
