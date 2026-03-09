import 'package:hive/hive.dart';

/// 板材（合板）規格モデル
class SheetStock extends HiveObject {
  String name;
  double width;
  double height;
  double thickness;
  int? price;

  SheetStock({
    required this.name,
    required this.width,
    required this.height,
    required this.thickness,
    this.price,
  });

  String get sizeLabel =>
      '${width.toStringAsFixed(0)} x ${height.toStringAsFixed(0)} mm';

  SheetStock copyWith({
    String? name,
    double? width,
    double? height,
    double? thickness,
    int? price,
  }) {
    return SheetStock(
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      thickness: thickness ?? this.thickness,
      price: price ?? this.price,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SheetStock &&
          name == other.name &&
          width == other.width &&
          height == other.height &&
          thickness == other.thickness;

  @override
  int get hashCode =>
      name.hashCode ^ width.hashCode ^ height.hashCode ^ thickness.hashCode;

  @override
  String toString() =>
      'SheetStock(name: $name, ${width}x${height}x${thickness}mm)';
}

/// 2D カット用入力ピース
class SheetPiece {
  final double width;
  final double height;
  final int quantity;
  final String? label;
  final bool canRotate;

  const SheetPiece({
    required this.width,
    required this.height,
    required this.quantity,
    this.label,
    this.canRotate = true,
  });

  double get area => width * height;

  SheetPiece copyWith({
    double? width,
    double? height,
    int? quantity,
    String? label,
    bool? canRotate,
  }) {
    return SheetPiece(
      width: width ?? this.width,
      height: height ?? this.height,
      quantity: quantity ?? this.quantity,
      label: label ?? this.label,
      canRotate: canRotate ?? this.canRotate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SheetPiece &&
          width == other.width &&
          height == other.height &&
          quantity == other.quantity &&
          label == other.label;

  @override
  int get hashCode =>
      width.hashCode ^ height.hashCode ^ quantity.hashCode ^ label.hashCode;
}

/// 配置済みピース（結果用）
class SheetPlacedPiece {
  final double x;
  final double y;
  final double width;
  final double height;
  final bool rotated;
  final String? label;

  const SheetPlacedPiece({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotated = false,
    this.label,
  });

  double get area => width * height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SheetPlacedPiece &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ width.hashCode ^ height.hashCode;

  @override
  String toString() =>
      'SheetPlacedPiece(${x},${y} ${width}x${height} rotated=$rotated)';
}

/// 1枚の板材に対するカット配置
class SheetCutBin {
  final List<SheetPlacedPiece> pieces;
  final double wasteArea;
  final double sheetWidth;
  final double sheetHeight;

  const SheetCutBin({
    required this.pieces,
    required this.wasteArea,
    required this.sheetWidth,
    required this.sheetHeight,
  });

  double get sheetArea => sheetWidth * sheetHeight;
  double get usedArea => sheetArea - wasteArea;
  double get utilizationRate => sheetArea > 0 ? usedArea / sheetArea : 0.0;

  @override
  String toString() =>
      'SheetCutBin(pieces: ${pieces.length}, waste: $wasteArea)';
}

/// 2D カット計算の最終結果
class SheetCutResult {
  final List<SheetCutBin> bins;
  final int totalSheets;
  final double totalWasteArea;
  final double utilizationRate;

  const SheetCutResult({
    required this.bins,
    required this.totalSheets,
    required this.totalWasteArea,
    required this.utilizationRate,
  });

  @override
  String toString() =>
      'SheetCutResult(sheets: $totalSheets, waste: $totalWasteArea, '
      'util: ${(utilizationRate * 100).toStringAsFixed(1)}%)';
}

// --- Hive TypeAdapters ---

class SheetStockAdapter extends TypeAdapter<SheetStock> {
  @override
  final int typeId = 6;

  @override
  SheetStock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return SheetStock(
      name: fields[0] as String,
      width: fields[1] as double,
      height: fields[2] as double,
      thickness: fields[3] as double,
      price: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SheetStock obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.width)
      ..writeByte(2)
      ..write(obj.height)
      ..writeByte(3)
      ..write(obj.thickness)
      ..writeByte(4)
      ..write(obj.price);
  }
}

class SheetPlacedPieceAdapter extends TypeAdapter<SheetPlacedPiece> {
  @override
  final int typeId = 7;

  @override
  SheetPlacedPiece read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return SheetPlacedPiece(
      x: fields[0] as double,
      y: fields[1] as double,
      width: fields[2] as double,
      height: fields[3] as double,
      rotated: fields[4] as bool,
      label: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SheetPlacedPiece obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.x)
      ..writeByte(1)
      ..write(obj.y)
      ..writeByte(2)
      ..write(obj.width)
      ..writeByte(3)
      ..write(obj.height)
      ..writeByte(4)
      ..write(obj.rotated)
      ..writeByte(5)
      ..write(obj.label);
  }
}

class SheetCutBinAdapter extends TypeAdapter<SheetCutBin> {
  @override
  final int typeId = 8;

  @override
  SheetCutBin read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return SheetCutBin(
      pieces: (fields[0] as List).cast<SheetPlacedPiece>(),
      wasteArea: fields[1] as double,
      sheetWidth: fields[2] as double,
      sheetHeight: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SheetCutBin obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.pieces)
      ..writeByte(1)
      ..write(obj.wasteArea)
      ..writeByte(2)
      ..write(obj.sheetWidth)
      ..writeByte(3)
      ..write(obj.sheetHeight);
  }
}

class SheetCutResultAdapter extends TypeAdapter<SheetCutResult> {
  @override
  final int typeId = 9;

  @override
  SheetCutResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return SheetCutResult(
      bins: (fields[0] as List).cast<SheetCutBin>(),
      totalSheets: fields[1] as int,
      totalWasteArea: fields[2] as double,
      utilizationRate: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SheetCutResult obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.bins)
      ..writeByte(1)
      ..write(obj.totalSheets)
      ..writeByte(2)
      ..write(obj.totalWasteArea)
      ..writeByte(3)
      ..write(obj.utilizationRate);
  }
}
