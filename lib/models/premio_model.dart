class Premio {
  final String id;
  final String nombre;
  final int costo;
  final String icono; // IconData name or identifier

  Premio({
    required this.id,
    required this.nombre,
    required this.costo,
    this.icono = 'card_giftcard',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'costo': costo,
      'icono': icono,
    };
  }

  factory Premio.fromMap(Map<dynamic, dynamic> map) {
    return Premio(
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      costo: (map['costo'] as num?)?.toInt() ?? 0,
      icono: map['icono']?.toString() ?? 'card_giftcard',
    );
  }
}
