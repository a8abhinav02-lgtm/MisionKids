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
  bool estaCompletada;

  @HiveField(4)
  int iconoCodePoint;

  @HiveField(5)
  String bloque; // 'manana', 'tarde', 'noche'

  Tarea({
    required this.nombre,
    required this.puntos,
    required this.esObligatoria,
    this.estaCompletada = false,
    required this.iconoCodePoint,
    required this.bloque,
  });

  IconData get icono => IconData(iconoCodePoint, fontFamily: 'MaterialIcons');
}