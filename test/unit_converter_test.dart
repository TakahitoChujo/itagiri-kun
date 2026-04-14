import 'package:flutter_test/flutter_test.dart';
import 'package:itagiri_kun/services/unit_converter.dart';

void main() {
  group('UnitConverter', () {
    group('mm → 他単位', () {
      test('mm → cm', () {
        expect(UnitConverter.convert(100, LengthUnit.mm, LengthUnit.cm),
            closeTo(10.0, 0.001));
      });

      test('mm → inch', () {
        // 25.4mm = 1 inch
        expect(UnitConverter.convert(25.4, LengthUnit.mm, LengthUnit.inch),
            closeTo(1.0, 0.001));
      });

      test('mm → 尺', () {
        // 303.030303mm = 1尺
        expect(
            UnitConverter.convert(303.030303, LengthUnit.mm, LengthUnit.shaku),
            closeTo(1.0, 0.001));
      });

      test('mm → 寸', () {
        // 30.3030303mm = 1寸
        expect(UnitConverter.convert(30.3030303, LengthUnit.mm, LengthUnit.sun),
            closeTo(1.0, 0.001));
      });
    });

    group('他単位 → mm', () {
      test('cm → mm', () {
        expect(UnitConverter.convert(10, LengthUnit.cm, LengthUnit.mm),
            closeTo(100.0, 0.001));
      });

      test('inch → mm', () {
        expect(UnitConverter.convert(1, LengthUnit.inch, LengthUnit.mm),
            closeTo(25.4, 0.001));
      });

      test('尺 → mm', () {
        expect(UnitConverter.convert(1, LengthUnit.shaku, LengthUnit.mm),
            closeTo(303.030303, 0.001));
      });

      test('寸 → mm', () {
        expect(UnitConverter.convert(1, LengthUnit.sun, LengthUnit.mm),
            closeTo(30.3030303, 0.001));
      });
    });

    group('同一単位の変換', () {
      test('mm → mm は同値', () {
        expect(UnitConverter.convert(1234, LengthUnit.mm, LengthUnit.mm),
            equals(1234));
      });

      test('cm → cm は同値', () {
        expect(UnitConverter.convert(56.78, LengthUnit.cm, LengthUnit.cm),
            equals(56.78));
      });
    });

    group('0とゼロ値', () {
      test('0mm は全て0', () {
        expect(UnitConverter.convert(0, LengthUnit.mm, LengthUnit.cm),
            equals(0));
        expect(UnitConverter.convert(0, LengthUnit.mm, LengthUnit.inch),
            equals(0));
        expect(UnitConverter.convert(0, LengthUnit.mm, LengthUnit.shaku),
            equals(0));
        expect(UnitConverter.convert(0, LengthUnit.mm, LengthUnit.sun),
            equals(0));
      });
    });

    group('相互変換の一貫性', () {
      test('mm→cm→mm ラウンドトリップ', () {
        const original = 1820.0;
        final cm = UnitConverter.convert(original, LengthUnit.mm, LengthUnit.cm);
        final back = UnitConverter.convert(cm, LengthUnit.cm, LengthUnit.mm);
        expect(back, closeTo(original, 0.001));
      });

      test('mm→inch→mm ラウンドトリップ', () {
        const original = 2438.0;
        final inch =
            UnitConverter.convert(original, LengthUnit.mm, LengthUnit.inch);
        final back =
            UnitConverter.convert(inch, LengthUnit.inch, LengthUnit.mm);
        expect(back, closeTo(original, 0.001));
      });

      test('尺→寸 変換（1尺 = 10寸）', () {
        final sun =
            UnitConverter.convert(1, LengthUnit.shaku, LengthUnit.sun);
        expect(sun, closeTo(10.0, 0.001));
      });

      test('寸→尺 変換（10寸 = 1尺）', () {
        final shaku =
            UnitConverter.convert(10, LengthUnit.sun, LengthUnit.shaku);
        expect(shaku, closeTo(1.0, 0.001));
      });
    });

    group('convertAll', () {
      test('1000mm を全単位に変換', () {
        final result =
            UnitConverter.convertAll(1000, LengthUnit.mm);

        expect(result[LengthUnit.mm], closeTo(1000, 0.001));
        expect(result[LengthUnit.cm], closeTo(100, 0.001));
        expect(result[LengthUnit.inch], closeTo(1000 / 25.4, 0.001));
        expect(result[LengthUnit.shaku], closeTo(1000 / 303.030303, 0.001));
        expect(result[LengthUnit.sun], closeTo(1000 / 30.3030303, 0.001));
        expect(result.length, equals(LengthUnit.values.length));
      });

      test('0 を全単位に変換すると全て0', () {
        final result = UnitConverter.convertAll(0, LengthUnit.mm);
        for (final entry in result.entries) {
          expect(entry.value, equals(0),
              reason: '${entry.key} should be 0');
        }
      });
    });

    group('実用的な変換', () {
      test('2x4材 1820mm = 71.65 inch', () {
        expect(
            UnitConverter.convert(1820, LengthUnit.mm, LengthUnit.inch),
            closeTo(71.6535, 0.01));
      });

      test('6尺 ≈ 1818mm (6 × 303.03)', () {
        expect(
            UnitConverter.convert(6, LengthUnit.shaku, LengthUnit.mm),
            closeTo(1818.18, 0.01));
      });

      test('1 inch = 2.54 cm', () {
        expect(UnitConverter.convert(1, LengthUnit.inch, LengthUnit.cm),
            closeTo(2.54, 0.001));
      });
    });
  });

  group('LengthUnit', () {
    test('全単位にシンボルがある', () {
      for (final unit in LengthUnit.values) {
        expect(unit.symbol, isNotEmpty);
      }
    });

    test('全単位に日本語・英語ラベルがある', () {
      for (final unit in LengthUnit.values) {
        expect(unit.labelJa, isNotEmpty);
        expect(unit.labelEn, isNotEmpty);
      }
    });

    test('5種類の単位が定義されている', () {
      expect(LengthUnit.values.length, equals(5));
    });
  });
}
