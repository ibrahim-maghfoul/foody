// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteRecipeAdapter extends TypeAdapter<FavoriteRecipe> {
  @override
  final int typeId = 0;

  @override
  FavoriteRecipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteRecipe()
      ..title = fields[0] as String
      ..image = fields[1] as String
      ..id = fields[2] as String
      ..note = fields[3] as String
      ..tips = fields[4] as String
      ..categorie = fields[5] as String
      ..difficulty = fields[6] as String
      ..nutritions = (fields[7] as List).cast<dynamic>()
      ..instructions = (fields[8] as List).cast<dynamic>()
      ..ingredients = (fields[9] as List).cast<dynamic>()
      ..methods = (fields[10] as List).cast<dynamic>()
      ..rate = fields[11] as int;
  }

  @override
  void write(BinaryWriter writer, FavoriteRecipe obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.image)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.tips)
      ..writeByte(5)
      ..write(obj.categorie)
      ..writeByte(6)
      ..write(obj.difficulty)
      ..writeByte(7)
      ..write(obj.nutritions)
      ..writeByte(8)
      ..write(obj.instructions)
      ..writeByte(9)
      ..write(obj.ingredients)
      ..writeByte(10)
      ..write(obj.methods)
      ..writeByte(11)
      ..write(obj.rate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteRecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
