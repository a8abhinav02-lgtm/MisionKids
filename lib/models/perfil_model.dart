import 'package:hive/hive.dart';

part 'perfil_model.g.dart';

@HiveType(typeId: 1)
class Perfil extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  String tematica; // Ej: "espacio", "ninja", "princesa", "deportes"

  @HiveField(3)
  String colorPrimario; // Ej: "azul", "rosa", "verde", "naranja"

  @HiveField(4)
  int saldo;

  @HiveField(5)
  double metaAhorro;

  @HiveField(6)
  String nombreMeta;

  @HiveField(7)
  List<Map<dynamic, dynamic>> historialVictorias;

  Perfil({
    required this.id,
    required this.nombre,
    required this.tematica,
    required this.colorPrimario,
    this.saldo = 0,
    this.metaAhorro = 0.0,
    this.nombreMeta = '',
    this.historialVictorias = const [],
  });
}
