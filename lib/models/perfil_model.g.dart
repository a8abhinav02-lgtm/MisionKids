// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'perfil_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PerfilAdapter extends TypeAdapter<Perfil> {
  @override
  final int typeId = 1;

  @override
  Perfil read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Perfil(
      id: fields[0] as String,
      nombre: fields[1] as String,
      tematica: fields[2] as String,
      colorPrimario: fields[3] as String,
      saldo: fields[4] as int,
      metaAhorro: fields[5] as double,
      nombreMeta: fields[6] as String,
      historialVictorias: (fields[7] as List)
          .map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList(),
      frecuenciaRecordatorio: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Perfil obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.tematica)
      ..writeByte(3)
      ..write(obj.colorPrimario)
      ..writeByte(4)
      ..write(obj.saldo)
      ..writeByte(5)
      ..write(obj.metaAhorro)
      ..writeByte(6)
      ..write(obj.nombreMeta)
      ..writeByte(7)
      ..write(obj.historialVictorias)
      ..writeByte(8)
      ..write(obj.frecuenciaRecordatorio);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerfilAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
