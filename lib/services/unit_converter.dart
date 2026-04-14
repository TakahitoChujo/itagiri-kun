/// 単位換算ユーティリティ
///
/// mm, cm, inch, 尺, 寸 の相互変換を提供する。
class UnitConverter {
  UnitConverter._();

  // --- 基本変換係数 (全て mm 基準) ---
  static const double mmPerCm = 10.0;
  static const double mmPerInch = 25.4;
  static const double mmPerShaku = 303.030303; // 1尺 = 10/33 m
  static const double mmPerSun = 30.3030303;   // 1寸 = 1/33 m

  /// 指定値を [from] 単位から [to] 単位に変換する
  static double convert(double value, LengthUnit from, LengthUnit to) {
    if (from == to) return value;
    final mm = _toMm(value, from);
    return _fromMm(mm, to);
  }

  /// 指定値を全単位に変換した Map を返す
  static Map<LengthUnit, double> convertAll(double value, LengthUnit from) {
    final mm = _toMm(value, from);
    return {
      for (final unit in LengthUnit.values) unit: _fromMm(mm, unit),
    };
  }

  static double _toMm(double value, LengthUnit unit) {
    switch (unit) {
      case LengthUnit.mm:
        return value;
      case LengthUnit.cm:
        return value * mmPerCm;
      case LengthUnit.inch:
        return value * mmPerInch;
      case LengthUnit.shaku:
        return value * mmPerShaku;
      case LengthUnit.sun:
        return value * mmPerSun;
    }
  }

  static double _fromMm(double mm, LengthUnit unit) {
    switch (unit) {
      case LengthUnit.mm:
        return mm;
      case LengthUnit.cm:
        return mm / mmPerCm;
      case LengthUnit.inch:
        return mm / mmPerInch;
      case LengthUnit.shaku:
        return mm / mmPerShaku;
      case LengthUnit.sun:
        return mm / mmPerSun;
    }
  }
}

/// 長さの単位
enum LengthUnit {
  mm('mm', 'ミリメートル', 'Millimeters'),
  cm('cm', 'センチメートル', 'Centimeters'),
  inch('in', 'インチ', 'Inches'),
  shaku('尺', '尺', 'Shaku'),
  sun('寸', '寸', 'Sun');

  final String symbol;
  final String labelJa;
  final String labelEn;

  const LengthUnit(this.symbol, this.labelJa, this.labelEn);
}
