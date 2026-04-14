import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:itagiri_kun/models/offcut.dart';

void main() {
  final testDate = DateTime(2024, 6, 15, 10, 30, 0);

  group('Offcut', () {
    test('基本的なインスタンス生成', () {
      final offcut = Offcut(
        id: 'offcut-1',
        woodStockName: '2x4',
        length: 350,
        sourceProjectId: 'proj-1',
        savedAt: testDate,
      );

      expect(offcut.id, equals('offcut-1'));
      expect(offcut.woodStockName, equals('2x4'));
      expect(offcut.length, equals(350));
      expect(offcut.sourceProjectId, equals('proj-1'));
      expect(offcut.savedAt, equals(testDate));
    });

    test('sourceProjectId なしで生成', () {
      final offcut = Offcut(
        id: 'offcut-2',
        woodStockName: '1x4',
        length: 200,
        savedAt: testDate,
      );

      expect(offcut.sourceProjectId, isNull);
    });

    group('JSON シリアライゼーション', () {
      test('toJson → fromJson ラウンドトリップ', () {
        final original = Offcut(
          id: 'offcut-1',
          woodStockName: '2x4',
          length: 350.5,
          sourceProjectId: 'proj-1',
          savedAt: testDate,
        );

        final json = original.toJson();
        final restored = Offcut.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.woodStockName, equals(original.woodStockName));
        expect(restored.length, equals(original.length));
        expect(restored.sourceProjectId, equals(original.sourceProjectId));
        expect(restored.savedAt, equals(original.savedAt));
      });

      test('sourceProjectId が null のラウンドトリップ', () {
        final original = Offcut(
          id: 'offcut-2',
          woodStockName: '1x4',
          length: 200,
          savedAt: testDate,
        );

        final json = original.toJson();
        final restored = Offcut.fromJson(json);

        expect(restored.sourceProjectId, isNull);
      });

      test('toJson の形式が正しい', () {
        final offcut = Offcut(
          id: 'offcut-1',
          woodStockName: '2x4',
          length: 350,
          sourceProjectId: 'proj-1',
          savedAt: testDate,
        );

        final json = offcut.toJson();
        expect(json['id'], equals('offcut-1'));
        expect(json['woodStockName'], equals('2x4'));
        expect(json['length'], equals(350));
        expect(json['sourceProjectId'], equals('proj-1'));
        expect(json['savedAt'], isA<String>());
      });
    });

    group('JSON文字列シリアライゼーション', () {
      test('toJsonString → fromJsonString ラウンドトリップ', () {
        final original = Offcut(
          id: 'offcut-1',
          woodStockName: '2x4',
          length: 450,
          savedAt: testDate,
        );

        final jsonStr = original.toJsonString();
        final restored = Offcut.fromJsonString(jsonStr);

        expect(restored.id, equals(original.id));
        expect(restored.woodStockName, equals(original.woodStockName));
        expect(restored.length, equals(original.length));
      });

      test('toJsonString は有効な JSON 文字列を返す', () {
        final offcut = Offcut(
          id: 'test',
          woodStockName: 'test',
          length: 100,
          savedAt: testDate,
        );

        final jsonStr = offcut.toJsonString();
        expect(() => jsonDecode(jsonStr), returnsNormally);
      });
    });

    group('length のバリエーション', () {
      test('小数点付き長さ', () {
        final offcut = Offcut(
          id: 'test',
          woodStockName: '2x4',
          length: 350.75,
          savedAt: testDate,
        );

        final json = offcut.toJson();
        final restored = Offcut.fromJson(json);
        expect(restored.length, closeTo(350.75, 0.001));
      });

      test('整数値の長さ (num → double 変換)', () {
        final json = {
          'id': 'test',
          'woodStockName': '2x4',
          'length': 350, // int
          'savedAt': testDate.toIso8601String(),
        };

        final offcut = Offcut.fromJson(json);
        expect(offcut.length, equals(350.0));
        expect(offcut.length, isA<double>());
      });
    });
  });
}
