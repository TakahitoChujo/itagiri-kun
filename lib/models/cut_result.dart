import 'package:hive/hive.dart';

/// カット配置内の1ピースの結果
class CutPieceResult {
  /// ピースの長さ (mm)
  final double length;

  /// ラベル（任意）
  final String? label;

  const CutPieceResult({
    required this.length,
    this.label,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CutPieceResult &&
          runtimeType == other.runtimeType &&
          length == other.length &&
          label == other.label;

  @override
  int get hashCode => length.hashCode ^ label.hashCode;

  @override
  String toString() => 'CutPieceResult(length: $length, label: $label)';
}

/// 1本の素材に対するカット配置
class CutBin {
  /// この素材に配置されたピース一覧
  final List<CutPieceResult> pieces;

  /// 端材の長さ (mm)
  final double waste;

  /// 素材の長さ (mm)
  final double stockLength;

  const CutBin({
    required this.pieces,
    required this.waste,
    required this.stockLength,
  });

  /// この素材の利用率 (0.0 ~ 1.0)
  double get utilizationRate =>
      stockLength > 0 ? (stockLength - waste) / stockLength : 0.0;

  /// この素材に配置されたピースの合計長さ (mm)
  double get usedLength =>
      pieces.fold(0.0, (sum, p) => sum + p.length);

  @override
  String toString() =>
      'CutBin(pieces: ${pieces.length}, waste: $waste, stockLength: $stockLength)';
}

/// カット計算の最終結果
class CutResult {
  /// 各素材のカット配置一覧
  final List<CutBin> bins;

  /// 必要な素材の総本数
  final int totalStock;

  /// 端材の合計 (mm)
  final double totalWaste;

  /// 全体の利用率 (0.0 ~ 1.0)
  final double utilizationRate;

  const CutResult({
    required this.bins,
    required this.totalStock,
    required this.totalWaste,
    required this.utilizationRate,
  });

  @override
  String toString() =>
      'CutResult(totalStock: $totalStock, totalWaste: $totalWaste, '
      'utilizationRate: ${(utilizationRate * 100).toStringAsFixed(1)}%)';
}

// --- Hive TypeAdapters ---

/// Hive TypeAdapter for CutPieceResult (typeId: 2)
class CutPieceResultAdapter extends TypeAdapter<CutPieceResult> {
  @override
  final int typeId = 2;

  @override
  CutPieceResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return CutPieceResult(
      length: fields[0] as double,
      label: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CutPieceResult obj) {
    writer
      ..writeByte(2) // number of fields
      ..writeByte(0)
      ..write(obj.length)
      ..writeByte(1)
      ..write(obj.label);
  }
}

/// Hive TypeAdapter for CutBin (typeId: 3)
class CutBinAdapter extends TypeAdapter<CutBin> {
  @override
  final int typeId = 3;

  @override
  CutBin read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return CutBin(
      pieces: (fields[0] as List).cast<CutPieceResult>(),
      waste: fields[1] as double,
      stockLength: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CutBin obj) {
    writer
      ..writeByte(3) // number of fields
      ..writeByte(0)
      ..write(obj.pieces)
      ..writeByte(1)
      ..write(obj.waste)
      ..writeByte(2)
      ..write(obj.stockLength);
  }
}

/// Hive TypeAdapter for CutResult (typeId: 4)
class CutResultAdapter extends TypeAdapter<CutResult> {
  @override
  final int typeId = 4;

  @override
  CutResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return CutResult(
      bins: (fields[0] as List).cast<CutBin>(),
      totalStock: fields[1] as int,
      totalWaste: fields[2] as double,
      utilizationRate: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CutResult obj) {
    writer
      ..writeByte(4) // number of fields
      ..writeByte(0)
      ..write(obj.bins)
      ..writeByte(1)
      ..write(obj.totalStock)
      ..writeByte(2)
      ..write(obj.totalWaste)
      ..writeByte(3)
      ..write(obj.utilizationRate);
  }
}
