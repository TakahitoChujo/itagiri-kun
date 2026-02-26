import 'package:hive/hive.dart';

/// 必要部材モデル
/// カットしたい部材の長さ・数量・ラベルを保持する。
class CutPiece {
  /// 部材の長さ (mm)
  final double length;

  /// 必要数量
  final int quantity;

  /// 任意ラベル（例: '棚板', '脚' など）
  final String? label;

  const CutPiece({
    required this.length,
    required this.quantity,
    this.label,
  });

  /// 部材を数量分展開して個別リストにする
  List<CutPiece> expand() {
    return List.generate(
      quantity,
      (_) => CutPiece(length: length, quantity: 1, label: label),
    );
  }

  CutPiece copyWith({
    double? length,
    int? quantity,
    String? label,
  }) {
    return CutPiece(
      length: length ?? this.length,
      quantity: quantity ?? this.quantity,
      label: label ?? this.label,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CutPiece &&
          runtimeType == other.runtimeType &&
          length == other.length &&
          quantity == other.quantity &&
          label == other.label;

  @override
  int get hashCode => length.hashCode ^ quantity.hashCode ^ label.hashCode;

  @override
  String toString() =>
      'CutPiece(length: $length, quantity: $quantity, label: $label)';
}

/// Hive TypeAdapter for CutPiece (typeId: 1)
class CutPieceAdapter extends TypeAdapter<CutPiece> {
  @override
  final int typeId = 1;

  @override
  CutPiece read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return CutPiece(
      length: fields[0] as double,
      quantity: fields[1] as int,
      label: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CutPiece obj) {
    writer
      ..writeByte(3) // number of fields
      ..writeByte(0)
      ..write(obj.length)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.label);
  }
}
