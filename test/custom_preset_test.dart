import 'package:flutter_test/flutter_test.dart';
import 'package:itagiri_kun/models/custom_preset.dart';

void main() {
  group('CustomWoodPreset', () {
    test('基本的なインスタンス生成', () {
      final preset = CustomWoodPreset(
        id: 'test-id',
        name: 'テスト木材',
        width: 30,
        height: 40,
        lengths: [1820, 2440],
        category: '角材',
        prices: [500, 700],
      );

      expect(preset.id, equals('test-id'));
      expect(preset.name, equals('テスト木材'));
      expect(preset.width, equals(30));
      expect(preset.height, equals(40));
      expect(preset.lengths, equals([1820, 2440]));
      expect(preset.category, equals('角材'));
      expect(preset.prices, equals([500, 700]));
      expect(preset.createdAt, isNotNull);
    });

    test('オプショナルフィールドなしで生成', () {
      final preset = CustomWoodPreset(
        id: 'id-1',
        name: 'シンプル',
        width: 30,
        height: 40,
        lengths: [1820],
      );

      expect(preset.category, isNull);
      expect(preset.prices, isNull);
    });

    test('copyWith で部分更新', () {
      final original = CustomWoodPreset(
        id: 'id-1',
        name: '元の名前',
        width: 30,
        height: 40,
        lengths: [1820],
        category: '角材',
      );

      final copied = original.copyWith(name: '新しい名前', width: 45);

      expect(copied.name, equals('新しい名前'));
      expect(copied.width, equals(45));
      expect(copied.height, equals(40)); // 変更なし
      expect(copied.id, equals('id-1')); // 変更なし
      expect(copied.category, equals('角材')); // 変更なし
    });

    test('copyWith は lengths をディープコピーする', () {
      final original = CustomWoodPreset(
        id: 'id-1',
        name: 'テスト',
        width: 30,
        height: 40,
        lengths: [1820, 2440],
      );

      final copied = original.copyWith();
      copied.lengths.add(3000);

      expect(original.lengths.length, equals(2));
      expect(copied.lengths.length, equals(3));
    });

    test('copyWith は prices をディープコピーする', () {
      final original = CustomWoodPreset(
        id: 'id-1',
        name: 'テスト',
        width: 30,
        height: 40,
        lengths: [1820],
        prices: [500, 700],
      );

      final copied = original.copyWith();
      copied.prices!.add(900);

      expect(original.prices!.length, equals(2));
      expect(copied.prices!.length, equals(3));
    });

    test('toString に名前とサイズが含まれる', () {
      final preset = CustomWoodPreset(
        id: 'id-1',
        name: 'テスト',
        width: 30,
        height: 40,
        lengths: [1820],
      );

      expect(preset.toString(), contains('テスト'));
      expect(preset.toString(), contains('30'));
      expect(preset.toString(), contains('40'));
    });

    test('createdAt のデフォルト値が現在時刻', () {
      final before = DateTime.now();
      final preset = CustomWoodPreset(
        id: 'id-1',
        name: 'テスト',
        width: 30,
        height: 40,
        lengths: [1820],
      );
      final after = DateTime.now();

      expect(preset.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue);
      expect(preset.createdAt.isBefore(after.add(const Duration(seconds: 1))),
          isTrue);
    });
  });

  group('CustomSheetPreset', () {
    test('基本的なインスタンス生成', () {
      final preset = CustomSheetPreset(
        id: 'sheet-id',
        name: 'テスト合板',
        width: 1820,
        height: 910,
        thickness: 12,
        price: 3000,
      );

      expect(preset.id, equals('sheet-id'));
      expect(preset.name, equals('テスト合板'));
      expect(preset.width, equals(1820));
      expect(preset.height, equals(910));
      expect(preset.thickness, equals(12));
      expect(preset.price, equals(3000));
    });

    test('price なしで生成', () {
      final preset = CustomSheetPreset(
        id: 'id-1',
        name: 'シンプル',
        width: 1820,
        height: 910,
        thickness: 12,
      );

      expect(preset.price, isNull);
    });

    test('copyWith で部分更新', () {
      final original = CustomSheetPreset(
        id: 'id-1',
        name: '元の名前',
        width: 1820,
        height: 910,
        thickness: 12,
        price: 3000,
      );

      final copied = original.copyWith(
        name: '新しい名前',
        price: 4000,
      );

      expect(copied.name, equals('新しい名前'));
      expect(copied.price, equals(4000));
      expect(copied.width, equals(1820)); // 変更なし
      expect(copied.thickness, equals(12)); // 変更なし
    });

    test('toString に名前とサイズが含まれる', () {
      final preset = CustomSheetPreset(
        id: 'id-1',
        name: 'テスト',
        width: 1820,
        height: 910,
        thickness: 12,
      );

      expect(preset.toString(), contains('テスト'));
      expect(preset.toString(), contains('1820'));
      expect(preset.toString(), contains('910'));
      expect(preset.toString(), contains('12'));
    });
  });

  group('CustomWoodPresetAdapter', () {
    test('typeId が 12', () {
      final adapter = CustomWoodPresetAdapter();
      expect(adapter.typeId, equals(12));
    });
  });

  group('CustomSheetPresetAdapter', () {
    test('typeId が 13', () {
      final adapter = CustomSheetPresetAdapter();
      expect(adapter.typeId, equals(13));
    });
  });
}
