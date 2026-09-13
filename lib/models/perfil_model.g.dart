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
      catalogoPremios: (fields[9] as List)
          .map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList(),
      solicitudesCanje: (fields[10] as List)
          .map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList(),
      rachaActual: fields[11] != null ? fields[11] as int : 0,
      mejorRacha: fields[12] != null ? fields[12] as int : 0,
      ultimoDiaRacha: fields[13] != null ? fields[13] as int : 0,
      medallas: fields[14] != null ? (fields[14] as List).cast<String>() : const [],
    );
  }

  @override
  void write(BinaryWriter writer, Perfil obj) {
    writer
      ..writeByte(15)
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
      ..write(obj.frecuenciaRecordatorio)
      ..writeByte(9)
      ..write(obj.catalogoPremios)
      ..writeByte(10)
      ..write(obj.solicitudesCanje)
      ..writeByte(11)
      ..write(obj.rachaActual)
      ..writeByte(12)
      ..write(obj.mejorRacha)
      ..writeByte(13)
      ..write(obj.ultimoDiaRacha)
      ..writeByte(14)
      ..write(obj.medallas);
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
