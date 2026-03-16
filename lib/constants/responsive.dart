import 'package:flutter/material.dart';

/// レスポンシブ対応のための BuildContext 拡張
///
/// 画面幅に基づいてブレークポイントを判定し、
/// グリッド列数やアイコンサイズを自動調整する。
extension ResponsiveContext on BuildContext {
  /// 現在の画面幅
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// 小画面 (iPhone SE 等 width < 360)
  bool get isSmallScreen => screenWidth < 360;

  /// 大画面 (Pro Max・タブレット等 width > 428)
  bool get isLargeScreen => screenWidth > 428;

  /// 木材プリセットグリッドの列数
  ///   小画面: 2列 / 通常: 3列 / 大画面: 4列
  int get gridColumnCount {
    if (isSmallScreen) return 2;
    if (isLargeScreen) return 4;
    return 3;
  }

  /// 空状態アイコンのサイズ
  double get emptyIconSize => isSmallScreen ? 56.0 : 80.0;
}
