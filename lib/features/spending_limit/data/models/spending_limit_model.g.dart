// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending_limit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpendingLimitModelAdapter extends TypeAdapter<SpendingLimitModel> {
  @override
  final int typeId = 4;

  @override
  SpendingLimitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpendingLimitModel(
      id: fields[0] as String,
      amount: fields[1] as double,
      period: fields[2] as String,
      startDateMillis: fields[3] as int,
      isActive: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SpendingLimitModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.period)
      ..writeByte(3)
      ..write(obj.startDateMillis)
      ..writeByte(4)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpendingLimitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
