import 'package:flutter_test/flutter_test.dart';
import 'package:itagiri_kun/models/sheet_models.dart';
import 'package:itagiri_kun/services/sheet_cut_optimizer.dart';

void main() {
  group('SheetCutOptimizer', () {
    group('基本ケース', () {
      test('1枚の板に収まるピース', () {
        final result = SheetCutOptimizer.optimize(
          sheetWidth: 910,
          sheetHeight: 1820,
          kerfWidth: 3,
          pieces: [
            SheetPiece(width: 400, height: 400, quantity: 2),
          ],
        );

        expect(result.totalSheets, equals(1));
        expect(result.bins.length, equals(1));
        expect(result.bins[0].pieces.length, equals(2));
        expect(result.utilizationRate, greaterThan(0));
        expect(result.utilizationRate, lessThanOrEqualTo(1.0));
      });

      test('複数枚必要なケース', () {
        final result = SheetCutOptimizer.optimize(
          sheetWidth: 910,
          sheetHeight: 1820,
          kerfWidth: 3,
          pieces: [
            SheetPiece(width: 800, height: 800, quantity: 4),
          ],
        );

        // 910x1820 に 800x800 は最大1枚ずつしか入らない（2枚目は1820-800-3=1017, 800<1017 なので入るかも）
        // 実際の結果は配置アルゴリズムに依存するが、少なくとも2枚以上
        expect(result.totalSheets, greaterThanOrEqualTo(2));
        final totalPieces = result.bins.fold(0, (sum, bin) => sum + bin.pieces.length);
        expect(totalPieces, equals(4));
      });
    });

    group('回転', () {
      test('回転して収まるピース', () {
        final result = SheetCutOptimizer.optimize(
          sheetWidth: 500,
          sheetHeight: 1000,
          kerfWidth: 0,
          pieces: [
            SheetPiece(width: 900, height: 400, quantity: 1, canRotate: true),
          ],
        );

        // 900x400 は 500x1000 に通常配置では入らない
        // 回転して 400x900 なら 500x1000 に収まる
        expect(result.totalSheets, equals(1));
        expect(result.bins[0].pieces[0].rotated, isTrue);
      });
    });

    group('エラーハンドリング', () {
      test('板より大きいピースは例外', () {
        expect(
          () => SheetCutOptimizer.optimize(
            sheetWidth: 500,
            sheetHeight: 500,
            kerfWidth: 0,
            pieces: [
              SheetPiece(width: 600, height: 600, quantity: 1, canRotate: false),
            ],
          ),
          throwsA(isA<SheetCutOptimizerException>()),
        );
      });

      test('板サイズが0以下は例外', () {
        expect(
          () => SheetCutOptimizer.optimize(
            sheetWidth: 0,
            sheetHeight: 1000,
            kerfWidth: 0,
            pieces: [SheetPiece(width: 100, height: 100, quantity: 1)],
          ),
          throwsA(isA<SheetCutOptimizerException>()),
        );
      });

      test('カーフ幅が負は例外', () {
        expect(
          () => SheetCutOptimizer.optimize(
            sheetWidth: 1000,
            sheetHeight: 1000,
            kerfWidth: -1,
            pieces: [SheetPiece(width: 100, height: 100, quantity: 1)],
          ),
          throwsA(isA<SheetCutOptimizerException>()),
        );
      });

      test('空リストは0枚', () {
        final result = SheetCutOptimizer.optimize(
          sheetWidth: 910,
          sheetHeight: 1820,
          kerfWidth: 3,
          pieces: [],
        );
        expect(result.totalSheets, equals(0));
        expect(result.bins, isEmpty);
      });
    });

    group('カーフ幅0', () {
      test('カーフなしでぴったり収まる', () {
        final result = SheetCutOptimizer.optimize(
          sheetWidth: 1000,
          sheetHeight: 1000,
          kerfWidth: 0,
          pieces: [
            SheetPiece(width: 500, height: 1000, quantity: 2),
          ],
        );

        expect(result.totalSheets, equals(1));
        expect(result.totalWasteArea, closeTo(0, 1));
      });
    });

    group('利用率', () {
      test('利用率が正しく計算される', () {
        final result = SheetCutOptimizer.optimize(
          sheetWidth: 1000,
          sheetHeight: 1000,
          kerfWidth: 0,
          pieces: [
            SheetPiece(width: 500, height: 500, quantity: 1),
          ],
        );

        // 1枚使用、250000/1000000 = 25%
        expect(result.totalSheets, equals(1));
        expect(result.utilizationRate, closeTo(0.25, 0.01));
      });
    });
  });
}
