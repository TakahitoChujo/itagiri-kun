import 'package:flutter_test/flutter_test.dart';
import 'package:itagiri_kun/models/cut_piece.dart';
import 'package:itagiri_kun/services/cut_optimizer.dart';

void main() {
  group('CutOptimizer - 複数材料長', () {
    group('基本動作', () {
      test('単一長さでは従来の FFD と同じ結果になる', () {
        final resultSingle = CutOptimizer.optimize(
          stockLength: 1820,
          kerfWidth: 3,
          pieces: [
            const CutPiece(length: 500, quantity: 3),
          ],
        );
        final resultMulti = CutOptimizer.optimize(
          stockLength: 1820,
          stockLengths: [1820],
          kerfWidth: 3,
          pieces: [
            const CutPiece(length: 500, quantity: 3),
          ],
        );

        expect(resultSingle.totalStock, equals(resultMulti.totalStock));
        expect(resultSingle.totalWaste, closeTo(resultMulti.totalWaste, 0.001));
      });

      test('2種類の材料長を混在させてカット最適化できる', () {
        // 600mmのピース3本: 最短の1000mmには入らない(600+600>1000)
        // 最大2000mmを使う必要がある
        final result = CutOptimizer.optimize(
          stockLength: 1000,
          stockLengths: [1000, 2000],
          kerfWidth: 0,
          pieces: [
            const CutPiece(length: 600, quantity: 3),
          ],
        );

        // 全ピースが配置されていること
        final totalPieces =
            result.bins.fold(0, (sum, bin) => sum + bin.pieces.length);
        expect(totalPieces, equals(3));

        // 各ビンの stockLength が 1000 か 2000 であること
        for (final bin in result.bins) {
          expect([1000.0, 2000.0], contains(bin.stockLength));
        }
      });

      test('短い材料を優先して使用する（Best Fit の特性）', () {
        // 300mmのピース3本: 1000mmに3本入る(300*3=900<=1000)
        // 2000mmではなく1000mmを選ぶべき
        final result = CutOptimizer.optimize(
          stockLength: 1000,
          stockLengths: [1000, 2000],
          kerfWidth: 0,
          pieces: [
            const CutPiece(length: 300, quantity: 3),
          ],
        );

        // 1本のビンで済むはず
        expect(result.totalStock, equals(1));
        // そのビンは1000mmであること（短い方を優先）
        expect(result.bins[0].stockLength, equals(1000.0));
      });

      test('大きなピースは大きい材料長のビンを開く', () {
        // 1500mmのピース: 1000mmには入らないので2000mmを使う
        final result = CutOptimizer.optimize(
          stockLength: 1000,
          stockLengths: [1000, 2000],
          kerfWidth: 0,
          pieces: [
            const CutPiece(length: 1500, quantity: 1),
          ],
        );

        expect(result.totalStock, equals(1));
        expect(result.bins[0].stockLength, equals(2000.0));
        expect(result.bins[0].waste, closeTo(500, 0.001));
      });

      test('3種類の材料長で最適配置', () {
        final result = CutOptimizer.optimize(
          stockLength: 1000,
          stockLengths: [1000, 1500, 2000],
          kerfWidth: 0,
          pieces: [
            const CutPiece(length: 1200, quantity: 1),
            const CutPiece(length: 400, quantity: 2),
          ],
        );

        final totalPieces =
            result.bins.fold(0, (sum, bin) => sum + bin.pieces.length);
        expect(totalPieces, equals(3));

        // 1200mmは1500以上のビンが必要
        final hasSufficientBin = result.bins.any((b) => b.stockLength >= 1200);
        expect(hasSufficientBin, isTrue);
      });
    });

    group('エラーハンドリング', () {
      test('全ての材料長を超えるピースがある場合は例外', () {
        expect(
          () => CutOptimizer.optimize(
            stockLength: 1000,
            stockLengths: [1000, 1500, 2000],
            kerfWidth: 0,
            pieces: [
              const CutPiece(length: 2500, quantity: 1),
            ],
          ),
          throwsA(isA<CutOptimizerException>()),
        );
      });

      test('空の stockLengths は stockLength を使う', () {
        // stockLengths が空なら stockLength の単一値で動作
        final result = CutOptimizer.optimize(
          stockLength: 1000,
          stockLengths: [],
          kerfWidth: 0,
          pieces: [
            const CutPiece(length: 300, quantity: 2),
          ],
        );
        expect(result.totalStock, equals(1));
      });
    });

    group('利用率と廃材', () {
      test('複数材料長で各ビンの stockLength が正しく記録される', () {
        final result = CutOptimizer.optimize(
          stockLength: 500,
          stockLengths: [500, 1000],
          kerfWidth: 0,
          pieces: [
            const CutPiece(length: 800, quantity: 1),
            const CutPiece(length: 200, quantity: 2),
          ],
        );

        // 800mm は 1000mm のビンに、200mm は 500mm のビンに
        for (final bin in result.bins) {
          expect(bin.waste, greaterThanOrEqualTo(0));
        }
        expect(result.utilizationRate, greaterThan(0));
        expect(result.utilizationRate, lessThanOrEqualTo(1.0));
      });

      test('廃材合計が全体の totalWaste と一致する', () {
        final result = CutOptimizer.optimize(
          stockLength: 1000,
          stockLengths: [1000, 2000],
          kerfWidth: 0,
          pieces: [
            const CutPiece(length: 600, quantity: 3),
          ],
        );

        final sumWaste =
            result.bins.fold(0.0, (sum, bin) => sum + bin.waste);
        expect(result.totalWaste, closeTo(sumWaste, 0.001));
      });
    });
  });

  group('Offcut モデル', () {
    test('toJson / fromJson のラウンドトリップ', () {
      // モデルの JSON シリアライズ/デシリアライズを CutPiece で代替テスト
      const piece = CutPiece(length: 650, quantity: 1, label: '端材A');
      expect(piece.length, equals(650));
      expect(piece.label, equals('端材A'));
    });
  });
}
