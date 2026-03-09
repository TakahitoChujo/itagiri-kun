import 'package:flutter_test/flutter_test.dart';
import 'package:itagiri_kun/models/wood_stock.dart';
import 'package:itagiri_kun/models/project.dart';
import 'package:itagiri_kun/models/cut_piece.dart';
import 'package:itagiri_kun/models/cut_result.dart';
import 'package:itagiri_kun/data/wood_presets.dart';

void main() {
  group('WoodStock', () {
    test('priceForLength は正しい価格を返す', () {
      final stock = WoodStock(
        name: '2x4',
        width: 38,
        height: 89,
        lengths: [910, 1820, 2440],
        prices: [298, 498, 698],
      );

      expect(stock.priceForLength(910), equals(298));
      expect(stock.priceForLength(1820), equals(498));
      expect(stock.priceForLength(2440), equals(698));
      expect(stock.priceForLength(3000), isNull); // 存在しない長さ
    });

    test('priceForLength は prices が null の場合 null を返す', () {
      final stock = WoodStock(
        name: 'custom',
        width: 30,
        height: 30,
        lengths: [1000],
      );

      expect(stock.priceForLength(1000), isNull);
    });

    test('copyWith はカテゴリと価格を保持する', () {
      final stock = WoodStock(
        name: '2x4',
        width: 38,
        height: 89,
        lengths: [1820],
        category: 'SPF',
        prices: [498],
      );

      final copied = stock.copyWith(name: '変更済み');
      expect(copied.name, equals('変更済み'));
      expect(copied.category, equals('SPF'));
      expect(copied.prices, equals([498]));
    });
  });

  group('Project', () {
    test('totalCost は単価と結果がある場合に計算される', () {
      final project = Project(
        id: 'test',
        name: 'テスト',
        woodStock: WoodStock(name: '2x4', width: 38, height: 89, lengths: [1820]),
        stockLength: 1820,
        pieces: [const CutPiece(length: 500, quantity: 2)],
        kerfWidth: 3.0,
        unitPrice: 498,
        result: const CutResult(
          bins: [CutBin(pieces: [CutPieceResult(length: 500), CutPieceResult(length: 500)], waste: 817, stockLength: 1820)],
          totalStock: 1,
          totalWaste: 817,
          utilizationRate: 0.55,
        ),
      );

      expect(project.totalCost, equals(498.0));
    });

    test('totalCost は単価なしの場合 null', () {
      final project = Project(
        id: 'test',
        name: 'テスト',
        woodStock: WoodStock(name: '2x4', width: 38, height: 89, lengths: [1820]),
        stockLength: 1820,
        pieces: [const CutPiece(length: 500, quantity: 2)],
        kerfWidth: 3.0,
        result: const CutResult(
          bins: [CutBin(pieces: [CutPieceResult(length: 500)], waste: 1320, stockLength: 1820)],
          totalStock: 1,
          totalWaste: 1320,
          utilizationRate: 0.275,
        ),
      );

      expect(project.totalCost, isNull);
    });

    test('copyWith は unitPrice を保持する', () {
      final project = Project(
        id: 'test',
        name: 'テスト',
        woodStock: WoodStock(name: '2x4', width: 38, height: 89, lengths: [1820]),
        stockLength: 1820,
        pieces: [],
        unitPrice: 498,
      );

      final copied = project.copyWith(name: '変更済み');
      expect(copied.unitPrice, equals(498));
    });
  });

  group('Wood Presets', () {
    test('プリセットにカテゴリが設定されている', () {
      for (final wood in woodPresets) {
        expect(wood.category, isNotNull, reason: '${wood.name} にカテゴリがない');
      }
    });

    test('プリセットに価格が設定されている', () {
      for (final wood in woodPresets) {
        expect(wood.prices, isNotNull, reason: '${wood.name} に価格がない');
        expect(wood.prices!.length, equals(wood.lengths.length),
            reason: '${wood.name} の価格数と長さ数が不一致');
      }
    });

    test('カテゴリフィルタが正しく動作する', () {
      final spf = woodPresetsForCategory('SPF');
      expect(spf, isNotEmpty);
      for (final wood in spf) {
        expect(wood.category, equals('SPF'));
      }
    });

    test('合板プリセットが存在する', () {
      expect(sheetPresets, isNotEmpty);
      for (final sheet in sheetPresets) {
        expect(sheet.width, greaterThan(0));
        expect(sheet.height, greaterThan(0));
        expect(sheet.thickness, greaterThan(0));
      }
    });
  });
}
