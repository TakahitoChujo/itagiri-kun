import 'package:flutter_test/flutter_test.dart';
import 'package:itagiri_kun/providers/settings_provider.dart';

void main() {
  group('Settings', () {
    test('デフォルト値が正しい', () {
      const settings = Settings();
      expect(settings.kerfWidth, equals(3.0));
      expect(settings.unit, equals(MeasurementUnit.mm));
      expect(settings.language, equals(AppLanguage.system));
    });

    test('copyWith でフィールドを個別に更新できる', () {
      const original = Settings(kerfWidth: 3.0, unit: MeasurementUnit.mm, language: AppLanguage.system);

      final withKerf = original.copyWith(kerfWidth: 5.0);
      expect(withKerf.kerfWidth, equals(5.0));
      expect(withKerf.unit, equals(MeasurementUnit.mm));
      expect(withKerf.language, equals(AppLanguage.system));

      final withUnit = original.copyWith(unit: MeasurementUnit.cm);
      expect(withUnit.kerfWidth, equals(3.0));
      expect(withUnit.unit, equals(MeasurementUnit.cm));

      final withLang = original.copyWith(language: AppLanguage.en);
      expect(withLang.language, equals(AppLanguage.en));
      expect(withLang.unit, equals(MeasurementUnit.mm));
    });
  });

  group('AppLanguage', () {
    test('toLocale: system は null を返す', () {
      expect(AppLanguage.system.toLocale(), isNull);
    });

    test('toLocale: ja は Locale("ja") を返す', () {
      final locale = AppLanguage.ja.toLocale();
      expect(locale, isNotNull);
      expect(locale!.languageCode, equals('ja'));
    });

    test('toLocale: en は Locale("en") を返す', () {
      final locale = AppLanguage.en.toLocale();
      expect(locale, isNotNull);
      expect(locale!.languageCode, equals('en'));
    });

    test('全 AppLanguage 値が定義されている', () {
      expect(AppLanguage.values.length, equals(3));
      expect(AppLanguage.values, containsAll([AppLanguage.system, AppLanguage.ja, AppLanguage.en]));
    });
  });

  group('MeasurementUnit', () {
    test('全 MeasurementUnit 値が定義されている', () {
      expect(MeasurementUnit.values.length, equals(2));
      expect(MeasurementUnit.values, containsAll([MeasurementUnit.mm, MeasurementUnit.cm]));
    });
  });
}
