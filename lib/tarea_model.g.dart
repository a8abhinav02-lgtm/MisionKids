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
      estado: fields[3] as String,
      iconoCodePoint: fields[4] as int,
      bloque: fields[5] as String,
      tipoRecurrencia: fields[6] as String,
      diasSemana: (fields[7] as List).cast<int>(),
      fechaEspecifica: fields[8] as DateTime?,
      ultimoDiaCompletado: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Tarea obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.puntos)
      ..writeByte(2)
      ..write(obj.esObligatoria)
      ..writeByte(3)
      ..write(obj.estado)
      ..writeByte(4)
      ..write(obj.iconoCodePoint)
      ..writeByte(5)
      ..write(obj.bloque)
      ..writeByte(6)
      ..write(obj.tipoRecurrencia)
      ..writeByte(7)
      ..write(obj.diasSemana)
      ..writeByte(8)
      ..write(obj.fechaEspecifica)
      ..writeByte(9)
      ..write(obj.ultimoDiaCompletado);
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
