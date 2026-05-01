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

  @HiveField(8)
  int frecuenciaRecordatorio; // En minutos, por defecto 10

  @HiveField(9)
  List<Map<dynamic, dynamic>> catalogoPremios; // Lista de premios disponibles

  @HiveField(10)
  List<Map<dynamic, dynamic>> solicitudesCanje; // Lista de solicitudes de canje en espera

  Perfil({
    required this.id,
    required this.nombre,
    required this.tematica,
    required this.colorPrimario,
    this.saldo = 0,
    this.metaAhorro = 0.0,
    this.nombreMeta = '',
    this.historialVictorias = const [],
    this.frecuenciaRecordatorio = 10,
    this.catalogoPremios = const [],
    this.solicitudesCanje = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'tematica': tematica,
      'colorPrimario': colorPrimario,
      'saldo': saldo,
      'metaAhorro': metaAhorro,
      'nombreMeta': nombreMeta,
      'historialVictorias': historialVictorias,
      'frecuenciaRecordatorio': frecuenciaRecordatorio,
      'catalogoPremios': catalogoPremios,
      'solicitudesCanje': solicitudesCanje,
    };
  }

  factory Perfil.fromMap(Map<String, dynamic> map) {
    return Perfil(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      tematica: map['tematica'] ?? 'ninja',
      colorPrimario: map['colorPrimario'] ?? 'azul',
      saldo: (map['saldo'] as num?)?.toInt() ?? 0,
      metaAhorro: (map['metaAhorro'] as num?)?.toDouble() ?? 0.0,
      nombreMeta: map['nombreMeta'] ?? '',
      historialVictorias: List<Map<dynamic, dynamic>>.from(map['historialVictorias'] ?? []),
      frecuenciaRecordatorio: (map['frecuenciaRecordatorio'] as num?)?.toInt() ?? 10,
      catalogoPremios: List<Map<dynamic, dynamic>>.from(map['catalogoPremios'] ?? []),
      solicitudesCanje: List<Map<dynamic, dynamic>>.from(map['solicitudesCanje'] ?? []),
    );
  }
}
