import 'package:flutter_test/flutter_test.dart';

import 'package:itagiri_kun/utils/fraction_parser.dart';

void main() {
  group('FractionParser.parse', () {
    test('parses plain integers', () {
      expect(FractionParser.parse('100'), 100.0);
      expect(FractionParser.parse('0'), 0.0);
      expect(FractionParser.parse('42'), 42.0);
    });

    test('parses plain decimals', () {
      expect(FractionParser.parse('12.5'), 12.5);
      expect(FractionParser.parse('0.75'), 0.75);
      expect(FractionParser.parse('100.25'), 100.25);
    });

    test('parses simple fractions', () {
      expect(FractionParser.parse('1/2'), 0.5);
      expect(FractionParser.parse('3/8'), 0.375);
      expect(FractionParser.parse('1/4'), 0.25);
      expect(FractionParser.parse('7/16'), 7 / 16);
    });

    test('parses mixed fractions with space', () {
      expect(FractionParser.parse('1 1/2'), 1.5);
      expect(FractionParser.parse('2 3/4'), 2.75);
      expect(FractionParser.parse('10 1/8'), 10.125);
    });

    test('parses mixed fractions with hyphen', () {
      expect(FractionParser.parse('1-1/2'), 1.5);
      expect(FractionParser.parse('3-3/8'), 3.375);
    });

    test('handles division by zero', () {
      expect(FractionParser.parse('1/0'), isNull);
      expect(FractionParser.parse('5 3/0'), isNull);
    });

    test('returns null for empty or invalid input', () {
      expect(FractionParser.parse(''), isNull);
      expect(FractionParser.parse('abc'), isNull);
      expect(FractionParser.parse('  '), isNull);
    });

    test('handles whitespace', () {
      expect(FractionParser.parse('  100  '), 100.0);
      expect(FractionParser.parse(' 1 / 2 '), 0.5);
      expect(FractionParser.parse('  3  1/4  '), 3.25);
    });

    test('parses feet-inch format', () {
      // 5' 6 = 5 feet 6 inches = 5*304.8 + 6*25.4 = 1676.4 mm
      final result = FractionParser.parse("5'6");
      expect(result, closeTo(1676.4, 0.1));
    });
  });

  group('FractionParser.toFractionString', () {
    test('converts whole numbers', () {
      expect(FractionParser.toFractionString(5.0), '5');
      expect(FractionParser.toFractionString(100.0), '100');
    });

    test('converts common fractions', () {
      expect(FractionParser.toFractionString(0.5), '1/2');
      expect(FractionParser.toFractionString(0.25), '1/4');
      expect(FractionParser.toFractionString(0.75), '3/4');
      expect(FractionParser.toFractionString(0.375), '3/8');
    });

    test('converts mixed fractions', () {
      expect(FractionParser.toFractionString(1.5), '1 1/2');
      expect(FractionParser.toFractionString(2.75), '2 3/4');
      expect(FractionParser.toFractionString(3.125), '3 1/8');
    });

    test('returns null for non-positive values', () {
      expect(FractionParser.toFractionString(0), isNull);
      expect(FractionParser.toFractionString(-1), isNull);
    });

    test('returns decimal for non-standard fractions', () {
      final result = FractionParser.toFractionString(1.3);
      expect(result, '1.3');
    });
  });
}
