import 'package:flutter/material.dart';

/// 板取りくん アプリ全体のカラーパレット
///
/// 木材・DIYをイメージした温かみのある配色。
/// Material Design 3 準拠。
class AppColors {
  AppColors._(); // インスタンス化防止

  // ──────────────────────────────────────────
  // プライマリ（木材の温かみ）
  // ──────────────────────────────────────────
  static const primary = Color(0xFF8B6914); // ダークウッド
  static const primaryLight = Color(0xFFBE9B4B); // ライトウッド
  static const primaryDark = Color(0xFF5A4200); // ディープウッド

  // ──────────────────────────────────────────
  // セカンダリ（アクセント - 自然の緑）
  // ──────────────────────────────────────────
  static const secondary = Color(0xFF2E7D32); // フォレストグリーン
  static const secondaryLight = Color(0xFF60AD5E); // ライトグリーン

  // ──────────────────────────────────────────
  // 背景・サーフェス
  // ──────────────────────────────────────────
  static const background = Color(0xFFFAF8F5); // オフホワイト（木目風）
  static const surface = Color(0xFFFFFFFF); // ピュアホワイト
  static const surfaceVariant = Color(0xFFF5F0E8); // クリームベージュ

  // ──────────────────────────────────────────
  // カット図用の色（6色ローテーション）
  // ──────────────────────────────────────────
  /// カットされた部材に割り当てる色。
  /// インデックス % cutColors.length で循環して使う。
  static const cutColors = [
    Color(0xFF4CAF50), // グリーン
    Color(0xFF2196F3), // ブルー
    Color(0xFFFF9800), // オレンジ
    Color(0xFF9C27B0), // パープル
    Color(0xFFE91E63), // ピンク
    Color(0xFF00BCD4), // シアン
  ];

  // ──────────────────────────────────────────
  // 端材（余り部分の表示用）
  // ──────────────────────────────────────────
  static const waste = Color(0xFFE0E0E0); // 端材の背景
  static const wastePattern = Color(0xFFBDBDBD); // 端材のハッチングパターン

  // ──────────────────────────────────────────
  // 利用率インジケーター
  // ──────────────────────────────────────────
  static const utilizationGood = Color(0xFF4CAF50); // 90% 以上
  static const utilizationFair = Color(0xFFFF9800); // 70-90%
  static const utilizationPoor = Color(0xFFF44336); // 70% 未満

  /// 利用率 (0.0 - 1.0) に応じた色を返す。
  static Color utilizationColor(double rate) {
    if (rate >= 0.9) return utilizationGood;
    if (rate >= 0.7) return utilizationFair;
    return utilizationPoor;
  }

  // ──────────────────────────────────────────
  // テキスト
  // ──────────────────────────────────────────
  static const textPrimary = Color(0xFF212121); // メインテキスト
  static const textSecondary = Color(0xFF757575); // 補助テキスト
  static const textOnPrimary = Color(0xFFFFFFFF); // プライマリ上のテキスト

  // ──────────────────────────────────────────
  // セマンティック
  // ──────────────────────────────────────────
  static const error = Color(0xFFD32F2F); // エラー
  static const success = Color(0xFF388E3C); // 成功
  static const warning = Color(0xFFF57C00); // 警告
}
