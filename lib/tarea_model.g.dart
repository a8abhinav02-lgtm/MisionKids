// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tarea_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TareaAdapter extends TypeAdapter<Tarea> {
  @override
  final int typeId = 0;

  @override
  Tarea read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tarea(
      nombre: fields[0] as String,
      puntos: fields[1] as int,
      esObligatoria: fields[2] as bool,
      estaCompletada: fields[3] as bool,
      iconoCodePoint: fields[4] as int,
      bloque: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Tarea obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.puntos)
      ..writeByte(2)
      ..write(obj.esObligatoria)
      ..writeByte(3)
      ..write(obj.estaCompletada)
      ..writeByte(4)
      ..write(obj.iconoCodePoint)
      ..writeByte(5)
      ..write(obj.bloque);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TareaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
