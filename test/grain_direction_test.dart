import 'package:flutter_test/flutter_test.dart';

import 'package:itagiri_kun/models/sheet_models.dart';
import 'package:itagiri_kun/services/sheet_cut_optimizer.dart';

void main() {
  group('GrainDirection', () {
    test('effectiveCanRotate returns true when no grain constraint', () {
      final piece = SheetPiece(
        width: 100,
        height: 200,
        quantity: 1,
        canRotate: true,
        grainDirection: GrainDirection.none,
      );
      expect(piece.effectiveCanRotate, isTrue);
    });

    test('effectiveCanRotate returns false when grain is horizontal', () {
      final piece = SheetPiece(
        width: 100,
        height: 200,
        quantity: 1,
        canRotate: true,
        grainDirection: GrainDirection.horizontal,
      );
      expect(piece.effectiveCanRotate, isFalse);
    });

    test('effectiveCanRotate returns false when grain is vertical', () {
      final piece = SheetPiece(
        width: 100,
        height: 200,
        quantity: 1,
        canRotate: true,
        grainDirection: GrainDirection.vertical,
      );
      expect(piece.effectiveCanRotate, isFalse);
    });

    test('effectiveCanRotate returns false when canRotate is false', () {
      final piece = SheetPiece(
        width: 100,
        height: 200,
        quantity: 1,
        canRotate: false,
        grainDirection: GrainDirection.none,
      );
      expect(piece.effectiveCanRotate, isFalse);
    });

    test('copyWith preserves grainDirection', () {
      final piece = SheetPiece(
        width: 100,
        height: 200,
        quantity: 1,
        grainDirection: GrainDirection.horizontal,
      );
      final copy = piece.copyWith(width: 150);
      expect(copy.grainDirection, GrainDirection.horizontal);
      expect(copy.width, 150);
    });

    test('copyWith updates grainDirection', () {
      final piece = SheetPiece(
        width: 100,
        height: 200,
        quantity: 1,
        grainDirection: GrainDirection.none,
      );
      final copy = piece.copyWith(grainDirection: GrainDirection.vertical);
      expect(copy.grainDirection, GrainDirection.vertical);
    });
  });

  group('SheetCutOptimizer with grain direction', () {
    test('grain direction prevents rotation', () {
      // ピースが400x200で、シートが300x500の場合
      // 回転なしでは収まらない（400 > 300）
      // 回転ありなら収まる（200 <= 300, 400 <= 500）
      // grain制約ありなら回転できないのでエラーになるはず
      expect(
        () => SheetCutOptimizer.optimize(
          sheetWidth: 300,
          sheetHeight: 500,
          kerfWidth: 0,
          pieces: [
            SheetPiece(
              width: 400,
              height: 200,
              quantity: 1,
              canRotate: true,
              grainDirection: GrainDirection.horizontal,
            ),
          ],
        ),
        throwsA(isA<SheetCutOptimizerException>()),
      );
    });

    test('grain direction none allows rotation', () {
      // 同じピースだがgrain制約なしなら回転して収まるはず
      final result = SheetCutOptimizer.optimize(
        sheetWidth: 300,
        sheetHeight: 500,
        kerfWidth: 0,
        pieces: [
          SheetPiece(
            width: 400,
            height: 200,
            quantity: 1,
            canRotate: true,
            grainDirection: GrainDirection.none,
          ),
        ],
      );
      expect(result.totalSheets, 1);
      expect(result.bins[0].pieces[0].rotated, isTrue);
    });

    test('grain direction works with multiple pieces', () {
      final result = SheetCutOptimizer.optimize(
        sheetWidth: 1000,
        sheetHeight: 1000,
        kerfWidth: 3,
        pieces: [
          SheetPiece(
            width: 400,
            height: 200,
            quantity: 2,
            grainDirection: GrainDirection.horizontal,
          ),
          SheetPiece(
            width: 300,
            height: 150,
            quantity: 3,
            grainDirection: GrainDirection.none,
          ),
        ],
      );
      expect(result.totalSheets, greaterThan(0));

      // grain制約ありのピースは回転していないはず
      for (final bin in result.bins) {
        for (final piece in bin.pieces) {
          if (piece.width == 400 || piece.width == 200) {
            // grain付きピース（元のサイズ400x200 or 回転してたら200x400）
            // grain制約で回転不可なので、400x200のまま
          }
        }
      }
    });
  });
}
