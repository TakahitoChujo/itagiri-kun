/// 分数入力をパースするユーティリティ
///
/// 対応フォーマット:
/// - "1/2" → 0.5
/// - "3/8" → 0.375
/// - "1 1/2" → 1.5
/// - "2-3/4" → 2.75
/// - "12.5" → 12.5
/// - "100" → 100.0
class FractionParser {
  /// 分数文字列を double に変換する。
  /// パースできない場合は null を返す。
  static double? parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // 通常の数値
    final plain = double.tryParse(trimmed);
    if (plain != null) return plain;

    // 帯分数: "1 1/2" or "1-1/2"
    final mixedMatch =
        RegExp(r'^(\d+)\s*[\s\-]\s*(\d+)\s*/\s*(\d+)$').firstMatch(trimmed);
    if (mixedMatch != null) {
      final whole = int.parse(mixedMatch.group(1)!);
      final num = int.parse(mixedMatch.group(2)!);
      final den = int.parse(mixedMatch.group(3)!);
      if (den == 0) return null;
      return whole + num / den;
    }

    // 単純分数: "3/8"
    final fractionMatch =
        RegExp(r'^(\d+)\s*/\s*(\d+)$').firstMatch(trimmed);
    if (fractionMatch != null) {
      final num = int.parse(fractionMatch.group(1)!);
      final den = int.parse(fractionMatch.group(2)!);
      if (den == 0) return null;
      return num / den;
    }

    // フィート・インチ: 5'6 or 5'6-1/2
    final feetInchPattern = RegExp(
      r"^(\d+)'\s*(\d+(?:\s*[\s\-]\s*\d+/\d+)?)\s*$",
    );
    final feetInchMatch = feetInchPattern.firstMatch(trimmed);
    if (feetInchMatch != null) {
      final feet = int.parse(feetInchMatch.group(1)!);
      final inchStr = feetInchMatch.group(2)!;
      final inches = parse(inchStr);
      if (inches != null) {
        return feet * 304.8 + inches * 25.4;
      }
    }

    return null;
  }

  /// 一般的な分数の表示文字列を返す
  static String? toFractionString(double value) {
    if (value <= 0) return null;

    final whole = value.floor();
    final frac = value - whole;

    if (frac < 0.001) {
      return whole.toString();
    }

    // 一般的な分母（2, 4, 8, 16, 32）でチェック
    for (final den in [2, 4, 8, 16, 32]) {
      final num = (frac * den).round();
      if ((num / den - frac).abs() < 0.001) {
        final gcd = _gcd(num, den);
        final simplifiedNum = num ~/ gcd;
        final simplifiedDen = den ~/ gcd;
        if (whole > 0) {
          return '$whole $simplifiedNum/$simplifiedDen';
        }
        return '$simplifiedNum/$simplifiedDen';
      }
    }

    return value.toStringAsFixed(1);
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }
}
