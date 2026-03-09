import 'package:hive/hive.dart';

import 'wood_stock.dart';
import 'cut_piece.dart';
import 'cut_result.dart';

/// プロジェクトモデル
/// 1つのカット計算プロジェクトを表す。Hive で永続化される。
class Project extends HiveObject {
  /// 一意な識別子 (UUID)
  String id;

  /// プロジェクト名
  String name;

  /// 使用する木材規格
  WoodStock woodStock;

  /// 選択した素材の長さ (mm)
  int stockLength;

  /// 必要な部材リスト
  List<CutPiece> pieces;

  /// 鋸刃の幅 (mm)
  double kerfWidth;

  /// 計算結果（未計算の場合は null）
  CutResult? result;

  /// 作成日時
  DateTime createdAt;

  /// 更新日時
  DateTime updatedAt;

  /// 素材1本あたりの単価 (円)。null = 未設定
  double? unitPrice;

  Project({
    required this.id,
    required this.name,
    required this.woodStock,
    required this.stockLength,
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

  /// 部材の合計長さ (mm)
  double get totalPieceLength =>
      pieces.fold(0.0, (sum, p) => sum + p.length * p.quantity);

  /// 合計コスト (円)。単価未設定 or 結果未計算なら null
  double? get totalCost {
    if (unitPrice == null || result == null) return null;
    return unitPrice! * result!.totalStock;
  }

  Project copyWith({
    String? id,
    String? name,
    WoodStock? woodStock,
    int? stockLength,
    List<CutPiece>? pieces,
    double? kerfWidth,
    CutResult? result,
    double? unitPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      woodStock: woodStock ?? this.woodStock,
      stockLength: stockLength ?? this.stockLength,
      pieces: pieces ?? List<CutPiece>.from(this.pieces),
      kerfWidth: kerfWidth ?? this.kerfWidth,
      result: result ?? this.result,
      unitPrice: unitPrice ?? this.unitPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Project(id: $id, name: $name, woodStock: ${woodStock.name}, '
      'stockLength: $stockLength, pieces: ${pieces.length})';
}

/// Hive TypeAdapter for Project (typeId: 5)
class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 5;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return Project(
      id: fields[0] as String,
      name: fields[1] as String,
      woodStock: fields[2] as WoodStock,
      stockLength: fields[3] as int,
      pieces: (fields[4] as List).cast<CutPiece>(),
      kerfWidth: fields[5] as double,
      result: fields[6] as CutResult?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      unitPrice: fields[9] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(10) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.woodStock)
      ..writeByte(3)
      ..write(obj.stockLength)
      ..writeByte(4)
      ..write(obj.pieces)
      ..writeByte(5)
      ..write(obj.kerfWidth)
      ..writeByte(6)
      ..write(obj.result)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.unitPrice);
  }
}
