import 'package:hive/hive.dart';

/// 木材規格モデル
/// ホームセンターで販売されている規格材の情報を保持する。
class WoodStock extends HiveObject {
  /// 規格名 (例: '2x4', '1x6')
  String name;

  /// 幅 (mm)
  double width;

  /// 高さ (mm)
  double height;

  /// 選択可能な長さ一覧 (mm)
  List<int> lengths;

  /// カテゴリ (例: 'SPF', '合板', '集成材')
  String? category;

  /// 長さごとの参考価格 (円) — lengths と同じインデックス
  List<int>? prices;

  WoodStock({
    required this.name,
    required this.width,
    required this.height,
    required this.lengths,
    this.category,
    this.prices,
  });

  /// 断面サイズの表示用文字列 (例: '38 x 89 mm')
  String get sectionLabel => '${width.toStringAsFixed(0)} x ${height.toStringAsFixed(0)} mm';

  /// 指定長さの参考価格を取得する (null = 未設定)
  int? priceForLength(int length) {
    if (prices == null) return null;
    final idx = lengths.indexOf(length);
    if (idx < 0 || idx >= prices!.length) return null;
    return prices![idx];
  }

  /// コピーを作成する
  WoodStock copyWith({
    String? name,
    double? width,
    double? height,
    List<int>? lengths,
    String? category,
    List<int>? prices,
  }) {
    return WoodStock(
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      lengths: lengths ?? List<int>.from(this.lengths),
      category: category ?? this.category,
      prices: prices ?? (this.prices != null ? List<int>.from(this.prices!) : null),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WoodStock &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          width == other.width &&
          height == other.height &&
          _listEquals(lengths, other.lengths) &&
          category == other.category;

  @override
  int get hashCode =>
      name.hashCode ^ width.hashCode ^ height.hashCode ^ lengths.hashCode ^ category.hashCode;

  @override
  String toString() =>
      'WoodStock(name: $name, width: $width, height: $height, lengths: $lengths)';

  static bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Hive TypeAdapter for WoodStock (typeId: 0)
class WoodStockAdapter extends TypeAdapter<WoodStock> {
  @override
  final int typeId = 0;

  @override
  WoodStock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return WoodStock(
      name: fields[0] as String,
      width: fields[1] as double,
      height: fields[2] as double,
      lengths: (fields[3] as List).cast<int>(),
      category: fields[4] as String?,
      prices: (fields[5] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, WoodStock obj) {
    writer
      ..writeByte(6) // number of fields
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.width)
      ..writeByte(2)
      ..write(obj.height)
      ..writeByte(3)
      ..write(obj.lengths)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.prices);
  }
}
