import 'package:hive/hive.dart';

/// ユーザーが保存したカスタム木材プリセット
class CustomWoodPreset extends HiveObject {
  String id;
  String name;
  double width;
  double height;
  List<int> lengths;
  String? category;
  List<int>? prices;
  DateTime createdAt;

  CustomWoodPreset({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.lengths,
    this.category,
    this.prices,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  CustomWoodPreset copyWith({
    String? id,
    String? name,
    double? width,
    double? height,
    List<int>? lengths,
    String? category,
    List<int>? prices,
  }) {
    return CustomWoodPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      lengths: lengths ?? List<int>.from(this.lengths),
      category: category ?? this.category,
      prices: prices ?? (this.prices != null ? List<int>.from(this.prices!) : null),
      createdAt: createdAt,
    );
  }

  @override
  String toString() => 'CustomWoodPreset(name: $name, ${width}x$height)';
}

/// Hive TypeAdapter for CustomWoodPreset (typeId: 12)
class CustomWoodPresetAdapter extends TypeAdapter<CustomWoodPreset> {
  @override
  final int typeId = 12;

  @override
  CustomWoodPreset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return CustomWoodPreset(
      id: fields[0] as String,
      name: fields[1] as String,
      width: fields[2] as double,
      height: fields[3] as double,
      lengths: (fields[4] as List).cast<int>(),
      category: fields[5] as String?,
      prices: (fields[6] as List?)?.cast<int>(),
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CustomWoodPreset obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.width)
      ..writeByte(3)..write(obj.height)
      ..writeByte(4)..write(obj.lengths)
      ..writeByte(5)..write(obj.category)
      ..writeByte(6)..write(obj.prices)
      ..writeByte(7)..write(obj.createdAt);
  }
}

/// ユーザーが保存したカスタム合板プリセット
class CustomSheetPreset extends HiveObject {
  String id;
  String name;
  double width;
  double height;
  double thickness;
  int? price;
  DateTime createdAt;

  CustomSheetPreset({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.thickness,
    this.price,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  CustomSheetPreset copyWith({
    String? id,
    String? name,
    double? width,
    double? height,
    double? thickness,
    int? price,
  }) {
    return CustomSheetPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      thickness: thickness ?? this.thickness,
      price: price ?? this.price,
      createdAt: createdAt,
    );
  }

  @override
  String toString() => 'CustomSheetPreset(name: $name, ${width}x${height}x$thickness)';
}

/// Hive TypeAdapter for CustomSheetPreset (typeId: 13)
class CustomSheetPresetAdapter extends TypeAdapter<CustomSheetPreset> {
  @override
  final int typeId = 13;

  @override
  CustomSheetPreset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return CustomSheetPreset(
      id: fields[0] as String,
      name: fields[1] as String,
      width: fields[2] as double,
      height: fields[3] as double,
      thickness: fields[4] as double,
      price: fields[5] as int?,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CustomSheetPreset obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.width)
      ..writeByte(3)..write(obj.height)
      ..writeByte(4)..write(obj.thickness)
      ..writeByte(5)..write(obj.price)
      ..writeByte(6)..write(obj.createdAt);
  }
}
