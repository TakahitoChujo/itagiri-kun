import 'package:hive/hive.dart';

import 'sheet_models.dart';

/// 2D 合板カットプロジェクトモデル
///
/// 1つの 2D カット計算プロジェクトを表す。Hive で永続化される。
class SheetProject extends HiveObject {
  /// 一意な識別子 (UUID)
  String id;

  /// プロジェクト名
  String name;

  /// 使用する合板規格
  SheetStock sheetStock;

  /// 必要な部材リスト
  List<SheetPiece> pieces;

  /// 鋸刃の幅 (mm)
  double kerfWidth;

  /// 計算結果（未計算の場合は null）
  SheetCutResult? result;

  /// 合板1枚あたりの単価 (円)。null = 未設定
  double? unitPrice;

  /// 作成日時
  DateTime createdAt;

  /// 更新日時
  DateTime updatedAt;

  SheetProject({
    required this.id,
    required this.name,
    required this.sheetStock,
    required this.pieces,
    this.kerfWidth = 3.0,
    this.result,
    this.unitPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 部材の合計数
  int get totalPieceCount =>
      pieces.fold(0, (sum, p) => sum + p.quantity);

  /// 部材の合計面積 (mm²)
  double get totalPieceArea =>
      pieces.fold(0.0, (sum, p) => sum + p.area * p.quantity);

  /// 合計コスト (円)。単価未設定 or 結果未計算なら null
  double? get totalCost {
    if (unitPrice == null || result == null) return null;
    return unitPrice! * result!.totalSheets;
  }

  SheetProject copyWith({
    String? id,
    String? name,
    SheetStock? sheetStock,
    List<SheetPiece>? pieces,
    double? kerfWidth,
    SheetCutResult? result,
    double? unitPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SheetProject(
      id: id ?? this.id,
      name: name ?? this.name,
      sheetStock: sheetStock ?? this.sheetStock,
      pieces: pieces ?? List<SheetPiece>.from(this.pieces),
      kerfWidth: kerfWidth ?? this.kerfWidth,
      result: result ?? this.result,
      unitPrice: unitPrice ?? this.unitPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'SheetProject(id: $id, name: $name, sheet: ${sheetStock.name}, '
      'pieces: ${pieces.length})';
}

/// Hive TypeAdapter for SheetProject (typeId: 11)
class SheetProjectAdapter extends TypeAdapter<SheetProject> {
  @override
  final int typeId = 11;

  @override
  SheetProject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return SheetProject(
      id: fields[0] as String,
      name: fields[1] as String,
      sheetStock: fields[2] as SheetStock,
      pieces: (fields[3] as List).cast<SheetPiece>(),
      kerfWidth: fields[4] as double,
      result: fields[5] as SheetCutResult?,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      unitPrice: fields[8] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, SheetProject obj) {
    writer
      ..writeByte(9) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.sheetStock)
      ..writeByte(3)
      ..write(obj.pieces)
      ..writeByte(4)
      ..write(obj.kerfWidth)
      ..writeByte(5)
      ..write(obj.result)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.unitPrice);
  }
}
