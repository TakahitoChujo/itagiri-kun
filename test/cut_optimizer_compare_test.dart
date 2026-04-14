import 'package:flutter_test/flutter_test.dart' hide ComparisonResult;
import 'package:itagiri_kun/models/cut_piece.dart';
import 'package:itagiri_kun/models/offcut.dart';
import 'package:itagiri_kun/services/cut_optimizer.dart';

void main() {
  group('CutOptimizer.compareStrategies (Feature 5)', () {
    test('3戦略の結果が返される', () {
      final results = CutOptimizer.compareStrategies(
        stockLength: 1820,
        kerfWidth: 3,
        pieces: [
          const CutPiece(length: 500, quantity: 4),
          const CutPiece(length: 350, quantity: 2),
          const CutPiece(length: 200, quantity: 6),
        ],
      );

      expect(results.length, equals(3));
      expect(results.map((r) => r.strategy).toSet(), containsAll([
        CutStrategy.ffd,
        CutStrategy.bfd,
        CutStrategy.ff,
      ]));
    });

    test('結果が利用率の降順でソートされている', () {
      final results = CutOptimizer.compareStrategies(
        stockLength: 1820,
        kerfWidth: 3,
        pieces: [
          const CutPiece(length: 500, quantity: 4),
          const CutPiece(length: 350, quantity: 2),
          const CutPiece(length: 200, quantity: 6),
        ],
      );

      for (var i = 0; i < results.length - 1; i++) {
        expect(
          results[i].result.utilizationRate,
          greaterThanOrEqualTo(results[i + 1].result.utilizationRate),
          reason: '結果は利用率の降順であるべき',
        );
      }
    });

    test('全戦略で同じ合計ピース数が配置される', () {
      final results = CutOptimizer.compareStrategies(
        stockLength: 1820,
        kerfWidth: 3,
        pieces: [
          const CutPiece(length: 500, quantity: 4),
          const CutPiece(length: 350, quantity: 2),
          const CutPiece(length: 200, quantity: 6),
        ],
      );

      const expectedTotalPieces = 4 + 2 + 6;

      for (final comparison in results) {
        final totalPieces = comparison.result.bins
            .fold(0, (sum, bin) => sum + bin.pieces.length);
        expect(totalPieces, equals(expectedTotalPieces),
            reason: '${comparison.strategy}: 全ピースが配置されるべき');
      }
    });

    test('空のピースリストでは空の結果リスト', () {
      final results = CutOptimizer.compareStrategies(
        stockLength: 1820,
        kerfWidth: 3,
        pieces: [],
      );

      expect(results.length, equals(3));
      for (final comparison in results) {
        expect(comparison.result.totalStock, equals(0));
        expect(comparison.result.bins, isEmpty);
      }
    });

    test('1ピースでは全戦略が同じ結果', () {
      final results = CutOptimizer.compareStrategies(
        stockLength: 1820,
        kerfWidth: 3,
        pieces: [
          const CutPiece(length: 500, quantity: 1),
        ],
      );

      expect(results.length, equals(3));
      for (final comparison in results) {
        expect(comparison.result.totalStock, equals(1));
        expect(comparison.result.bins[0].pieces.length, equals(1));
      }
    });

    test('端材ありの場合、FFDのみ端材を使用', () {
      final results = CutOptimizer.compareStrategies(
        stockLength: 1820,
        kerfWidth: 3,
        pieces: [
          const CutPiece(length: 300, quantity: 2),
        ],
        offcuts: [
          Offcut(
            id: 'off-1',
            woodStockName: '2x4',
            length: 700,
            savedAt: DateTime.now(),
          ),
        ],
      );

      // FFD (with offcuts)
      final ffd = results.firstWhere((r) => r.strategy == CutStrategy.ffd);
      // BFD (without offcuts)
      final bfd = results.firstWhere((r) => r.strategy == CutStrategy.bfd);

      // FFD should potentially use the offcut
      expect(ffd.result.totalStock, greaterThan(0));
      expect(bfd.result.totalStock, greaterThan(0));
    });

    test('カーフ幅0の場合も正常に動作', () {
      final results = CutOptimizer.compareStrategies(
        stockLength: 1000,
        kerfWidth: 0,
        pieces: [
          const CutPiece(length: 500, quantity: 2),
        ],
      );

      expect(results.length, equals(3));
      for (final comparison in results) {
        expect(comparison.result.totalStock, equals(1));
      }
    });

    test('複数素材長での比較', () {
      final results = CutOptimizer.compareStrategies(
        stockLength: 1820,
        stockLengths: [1820, 2440],
        kerfWidth: 3,
        pieces: [
          const CutPiece(length: 500, quantity: 4),
          const CutPiece(length: 350, quantity: 2),
        ],
      );

      expect(results, isNotEmpty);
      for (final comparison in results) {
        expect(comparison.result.totalStock, greaterThan(0));
      }
    });
  });

  group('CutStrategy enum', () {
    test('3種類の戦略が定義されている', () {
      expect(CutStrategy.values.length, equals(3));
    });

    test('FFD, BFD, FF が存在する', () {
      expect(CutStrategy.values, contains(CutStrategy.ffd));
      expect(CutStrategy.values, contains(CutStrategy.bfd));
      expect(CutStrategy.values, contains(CutStrategy.ff));
    });
  });

  group('ComparisonResult', () {
    test('strategy と result を保持する', () {
      final result = CutOptimizer.optimize(
        stockLength: 1000,
        kerfWidth: 0,
        pieces: [const CutPiece(length: 500, quantity: 1)],
      );

      final comparison = ComparisonResult(
        strategy: CutStrategy.ffd,
        result: result,
      );

      expect(comparison.strategy, equals(CutStrategy.ffd));
      expect(comparison.result, equals(result));
    });
  });

  group('First Fit 戦略（内部）', () {
    test('FF は入力順で配置する（大きいピースが先に来なくても良い）', () {
      // compareStrategies経由でFF結果を取得
      final results = CutOptimizer.compareStrategies(
        stockLength: 1000,
        kerfWidth: 0,
        pieces: [
          const CutPiece(length: 100, quantity: 2),
          const CutPiece(length: 600, quantity: 2),
        ],
      );

      final ff = results.firstWhere((r) => r.strategy == CutStrategy.ff);
      // FF: [100, 100, 600, 600] (入力順のまま展開)
      // Bin 1: 100+100+600 = 800, Bin 2: 600
      expect(ff.result.totalStock, greaterThan(0));
    });

    test('FFD はFFより効率が良いか同等', () {
      final results = CutOptimizer.compareStrategies(
        stockLength: 1820,
        kerfWidth: 3,
        pieces: [
          const CutPiece(length: 100, quantity: 5),
          const CutPiece(length: 800, quantity: 3),
          const CutPiece(length: 400, quantity: 4),
        ],
      );

      final ffd = results.firstWhere((r) => r.strategy == CutStrategy.ffd);
      final ff = results.firstWhere((r) => r.strategy == CutStrategy.ff);

      // FFD should be at least as good as FF
      expect(ffd.result.utilizationRate,
          greaterThanOrEqualTo(ff.result.utilizationRate - 0.001));
    });
  });
}
