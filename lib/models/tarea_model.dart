import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'tarea_model.g.dart';

@HiveType(typeId: 0)
class Tarea extends HiveObject {
  @HiveField(0)
  String nombre;

  @HiveField(1)
  int puntos;

  @HiveField(2)
  bool esObligatoria;

  @HiveField(3)
  String estado;

  @HiveField(4)
  int iconoCodePoint;

  @HiveField(5)
  String bloque; // 'manana', 'tarde', 'noche'

  @HiveField(6)
  String tipoRecurrencia; // 'diaria', 'semanal', 'fecha_fija'

  @HiveField(7)
  List<int> diasSemana; // [1, 2, 3, 4, 5, 6, 7]

  @HiveField(8)
  DateTime? fechaEspecifica;

  @HiveField(9)
  int ultimoDiaCompletado;

  @HiveField(10)
  String perfilId; // NUEVO: Para saber de qué niño es la tarea

  Tarea({
    required this.nombre,
    required this.puntos,
    required this.esObligatoria,
    this.estado = 'pendiente',
    required this.iconoCodePoint,
    required this.bloque,
    this.tipoRecurrencia = 'diaria',
    this.diasSemana = const [1,2,3,4,5,6,7],
    this.fechaEspecifica,
    this.ultimoDiaCompletado = 0,
    required this.perfilId,
  });

  IconData get icono => IconData(iconoCodePoint, fontFamily: 'MaterialIcons');

  // Helpers para saber el estado fácil
  bool get estaEnRevision => estado == 'revision';
  bool get estaAprobada => estado == 'aprobada';
  bool get estaPendiente => estado == 'pendiente';
}
