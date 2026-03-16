import 'dart:convert';

/// 保存された端材
class Offcut {
  final String id;

  /// 端材の木材規格名（マッチングに使用）
  final String woodStockName;

  /// 端材の長さ (mm)
  final double length;

  /// 端材の出所プロジェクトID（任意）
  final String? sourceProjectId;

  /// 保存日時
  final DateTime savedAt;

  const Offcut({
    required this.id,
    required this.woodStockName,
    required this.length,
    this.sourceProjectId,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'woodStockName': woodStockName,
        'length': length,
        'sourceProjectId': sourceProjectId,
        'savedAt': savedAt.toIso8601String(),
      };

  factory Offcut.fromJson(Map<String, dynamic> json) => Offcut(
        id: json['id'] as String,
        woodStockName: json['woodStockName'] as String,
        length: (json['length'] as num).toDouble(),
        sourceProjectId: json['sourceProjectId'] as String?,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );

  String toJsonString() => jsonEncode(toJson());

  static Offcut fromJsonString(String jsonStr) =>
      Offcut.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
}
