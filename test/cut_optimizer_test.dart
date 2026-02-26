import 'package:flutter_test/flutter_test.dart';
import 'package:itagiri_kun/models/cut_piece.dart';
import 'package:itagiri_kun/models/cut_result.dart';
import 'package:itagiri_kun/services/cut_optimizer.dart';

void main() {
  group('CutOptimizer', () {
    group('基本ケース', () {
      test('2x4(1820mm), カーフ3mm, [500x4, 350x2, 200x6] で 3本必要', () {
        final result = CutOptimizer.optimize(
          stockLength: 1820,
          kerfWidth: 3,
          pieces: [
            const CutPiece(length: 500, quantity: 4),
            const CutPiece(length: 350, quantity: 2),
            const CutPiece(length: 200, quantity: 6),
          ],
        );

        // 3本の素材が必要
        expect(result.totalStock, equals(3));
        expect(result.bins.length, equals(3));

        // 全ピースが配置されていることを確認
        final totalPieces =
            result.bins.fold(0, (sum, bin) => sum + bin.pieces.length);
        expect(totalPieces, equals(12)); // 4 + 2 + 6 = 12

        // 各ビンの端材が0以上であること
        for (final bin in result.bins) {
          expect(bin.waste, greaterThanOrEqualTo(0));
          expect(bin.stockLength, equals(1820));
        }

        // 利用率は0より大きく1以下
        expect(result.utilizationRate, greaterThan(0));
        expect(result.utilizationRate, lessThanOrEqualTo(1.0));

        // 端材合計の検証
        expect(result.totalWaste, greaterThanOrEqualTo(0));
        // totalWaste = 全素材長 - (全ピース長 + 全カーフ長)
        // 全素材長 = 1820 * 3 = 5460
        // 全ピース長 = 500*4 + 350*2 + 200*6 = 2000+700+1200 = 3900
        // カーフはビンごとに (ピース数-1) 個ずつ
        expect(result.totalWaste, equals(1820.0 * 3 - _usedInBins(result.bins)));
      });

      test('FFD により長いピースが先に配置される', () {
        final result = CutOptimizer.optimize(
          stockLength: 1000,
          kerfWidth: 0,
          pieces: [
            const CutPiece(length: 100, quantity: 2),
            const CutPiece(length: 600, quantity: 2),
          ],
        );

        // 長い方(600)が先に配置されるはず
        // Bin 1: [600, 100] = 700 or [600, 600] won't fit... 600+600=1200>1000
        // Bin 1: 600 + 100 = 700, Bin 2: 600 + 100 = 700 -> 2本
        // もしくは Bin 1: 600+600 は入らないので Bin 1: 600, 100 = 700, Bin 2: 600, 100 = 700
        expect(result.totalStock, equals(2));

        // 最初のビンの最初のピースが600mmであること（FFDの順序）
        expect(result.bins[0].pieces.first.length, equals(600));
      });
    });

    group('1本に収まるケース', () {
      test('小さい部材が1本に収まる', () {
        final result = CutOptimizer.optimize(
          stockLength: 1820,
          kerfWidth: 3,
          pieces: [
            const CutPiece(length: 300, quantity: 3),
          ],
        );

        // 300 + 3 + 300 + 3 + 300 = 906 <= 1820 → 1本
        expect(result.totalStock, equals(1));
        expect(result.bins.length, equals(1));
        expect(result.bins[0].pieces.length, equals(3));
        expect(result.bins[0].waste, closeTo(1820 - 906, 0.001));
      });

      test('1つの部材が1本に収まる', () {
        final result = CutOptimizer.optimize(
          stockLength: 1820,
          kerfWidth: 3,
          pieces: [
            const CutPiece(length: 1000, quantity: 1),
          ],
        );

        expect(result.totalStock, equals(1));
        expect(result.bins[0].pieces.length, equals(1));
        expect(result.bins[0].waste, equals(820));
      });
    });

    group('ちょうどぴったりのケース', () {
      test('カーフなしでぴったり収まる', () {
        final result = CutOptimizer.optimize(
          stockLength: 1000,
          kerfWidth: 0,
          pieces: [
            const CutPiece(length: 500, quantity: 2),
          ],
        );

        // 500 + 500 = 1000 → ぴったり
        expect(result.totalStock, equals(1));
        expect(result.bins[0].waste, closeTo(0, 0.001));
        expect(result.utilizationRate, closeTo(1.0, 0.001));
      });

      test('カーフありでぴったり収まる', () {
        final result = CutOptimizer.optimize(
          stockLength: 1003,
          kerfWidth: 3,
          pieces: [
            const CutPiece(length: 500, quantity: 2),
          ],
        );

        // 500 + 3 + 500 = 1003 → ぴったり
        expect(result.totalStock, equals(1));
        expect(result.bins[0].waste, closeTo(0, 0.001));
      });

      test('素材長と同じ長さの部材', () {
        final result = CutOptimizer.optimize(
          stockLength: 1820,
          kerfWidth: 3,
          pieces: [
            const CutPiece(length: 1820, quantity: 1),
          ],
        );

        // 1820 == 1820 → ぴったり1本
        expect(result.totalStock, equals(1));
        expect(result.bins[0].waste, closeTo(0, 0.001));
      });
    });

    group('エラーハンドリング', () {
      test('素材より大きい部材がある場合は例外', () {
        expect(
          () => CutOptimizer.optimize(
            stockLength: 1000,
            kerfWidth: 3,
            pieces: [
              const CutPiece(length: 1200, quantity: 1),
            ],
          ),
          throwsA(isA<CutOptimizerException>()),
        );
      });

      test('素材より大きい部材がある場合のエラーメッセージ', () {
        try {
          CutOptimizer.optimize(
            stockLength: 1000,
            kerfWidth: 3,
            pieces: [
              const CutPiece(length: 1200, quantity: 1, label: 'テスト板'),
            ],
          );
          fail('例外がスローされるべき');
        } on CutOptimizerException catch (e) {
          expect(e.message, contains('1200'));
          expect(e.message, contains('1000'));
          expect(e.message, contains('テスト板'));
        }
      });

      test('複数部材のうち1つが素材より大きい場合は例外', () {
        expect(
          () => CutOptimizer.optimize(
            stockLength: 1000,
            kerfWidth: 3,
            pieces: [
              const CutPiece(length: 500, quantity: 2),
              const CutPiece(length: 1500, quantity: 1),
            ],
          ),
          throwsA(isA<CutOptimizerException>()),
        );
      });

      test('素材の長さが0以下の場合は例外', () {
        expect(
          () => CutOptimizer.optimize(
            stockLength: 0,
            kerfWidth: 3,
            pieces: [
              const CutPiece(length: 100, quantity: 1),
            ],
          ),
          throwsA(isA<CutOptimizerException>()),
        );
      });

      test('カーフ幅が負の場合は例外', () {
        expect(
          () => CutOptimizer.optimize(
            stockLength: 1000,
            kerfWidth: -1,
            pieces: [
              const CutPiece(length: 100, quantity: 1),
            ],
          ),
          throwsA(isA<CutOptimizerException>()),
        );
      });
    });

    group('カーフ幅0mmの場合', () {
      test('カーフなしで最適に配置される', () {
        final result = CutOptimizer.optimize(
          stockLength: 1000,
          kerfWidth: 0,
          pieces: [
            const CutPiece(length: 400, quantity: 3),
            const CutPiece(length: 300, quantity: 2),
          ],
        );

        // カーフ0なので純粋にピース長だけで考える
        // 合計: 400*3 + 300*2 = 1200+600 = 1800
        // FFD: [400, 400, 400, 300, 300]
        // Bin 1: 400 + 400 = 800, +300 = 1100 > 1000 -> [400, 400] = 800
        // Wait: 400+400=800, 800+300=1100>1000? No, 800+300=1100>1000.
        // Bin 1: [400, 400], used=800, remain=200
        //   300: 800+300=1100>1000, skip
        // Bin 2: 400, remain=600
        //   300: 400+300=700, remain=300
        //   300: 700+300=1000, remain=0
        // Bin 2: [400, 300, 300], used=1000
        // → 2本
        expect(result.totalStock, equals(2));

        // 端材合計 = 200 (Bin 1) + 0 (Bin 2) = 200
        expect(result.totalWaste, closeTo(200, 0.001));
      });

      test('カーフ0で全て1本に入る場合', () {
        final result = CutOptimizer.optimize(
          stockLength: 1000,
          kerfWidth: 0,
          pieces: [
            const CutPiece(length: 250, quantity: 4),
          ],
        );

        // 250 * 4 = 1000 → ぴったり1本
        expect(result.totalStock, equals(1));
        expect(result.bins[0].waste, closeTo(0, 0.001));
      });
    });

    group('空のリスト', () {
      test('部材リストが空の場合は0本', () {
        final result = CutOptimizer.optimize(
          stockLength: 1820,
          kerfWidth: 3,
          pieces: [],
        );

        expect(result.totalStock, equals(0));
        expect(result.bins, isEmpty);
        expect(result.totalWaste, equals(0));
        expect(result.utilizationRate, equals(1.0));
      });

      test('数量が0の部材のみの場合は0本', () {
        final result = CutOptimizer.optimize(
          stockLength: 1820,
          kerfWidth: 3,
          pieces: [
            const CutPiece(length: 500, quantity: 0),
          ],
        );

        expect(result.totalStock, equals(0));
        expect(result.bins, isEmpty);
      });
    });

    group('ラベル', () {
      test('ラベルが結果に正しく引き継がれる', () {
        final result = CutOptimizer.optimize(
          stockLength: 1820,
          kerfWidth: 3,
          pieces: [
            const CutPiece(length: 500, quantity: 2, label: '棚板'),
            const CutPiece(length: 300, quantity: 1, label: '脚'),
          ],
        );

        // 全ピースのラベルを収集
        final allLabels = result.bins
            .expand((bin) => bin.pieces)
            .map((p) => p.label)
            .toList();

        // ラベル '棚板' が2つ、'脚' が1つ
        expect(allLabels.where((l) => l == '棚板').length, equals(2));
        expect(allLabels.where((l) => l == '脚').length, equals(1));
      });

      test('ラベルなしの部材は null のまま', () {
        final result = CutOptimizer.optimize(
          stockLength: 1820,
          kerfWidth: 3,
          pieces: [
            const CutPiece(length: 500, quantity: 1),
          ],
        );

        expect(result.bins[0].pieces[0].label, isNull);
      });
    });

    group('利用率の検証', () {
      test('利用率が正しく計算される', () {
        final result = CutOptimizer.optimize(
          stockLength: 1000,
          kerfWidth: 0,
          pieces: [
            const CutPiece(length: 500, quantity: 2),
          ],
        );

        // 1000mm中1000mm使用 → 利用率100%
        expect(result.utilizationRate, closeTo(1.0, 0.001));
      });

      test('複数ビンでの利用率', () {
        final result = CutOptimizer.optimize(
          stockLength: 1000,
          kerfWidth: 0,
          pieces: [
            const CutPiece(length: 600, quantity: 3),
          ],
        );

        // Bin 1: [600], waste=400
        // Bin 2: [600], waste=400
        // Bin 3: [600], waste=400
        // 利用率 = 1800 / 3000 = 0.6
        expect(result.totalStock, equals(3));
        expect(result.utilizationRate, closeTo(0.6, 0.001));
        expect(result.totalWaste, closeTo(1200, 0.001));
      });
    });

    group('カーフの境界条件', () {
      test('カーフにより1本に収まらなくなるケース', () {
        // カーフ0なら 500+500=1000 で1本に収まる
        final resultNoKerf = CutOptimizer.optimize(
          stockLength: 1000,
          kerfWidth: 0,
          pieces: [
            const CutPiece(length: 500, quantity: 2),
          ],
        );
        expect(resultNoKerf.totalStock, equals(1));

        // カーフ3mmだと 500+3+500=1003 > 1000 で2本必要
        final resultWithKerf = CutOptimizer.optimize(
          stockLength: 1000,
          kerfWidth: 3,
          pieces: [
            const CutPiece(length: 500, quantity: 2),
          ],
        );
        expect(resultWithKerf.totalStock, equals(2));
      });

      test('カーフがちょうど収まるギリギリ', () {
        // 500 + 3 + 497 = 1000 → ぴったり1本
        final result = CutOptimizer.optimize(
          stockLength: 1000,
          kerfWidth: 3,
          pieces: [
            const CutPiece(length: 500, quantity: 1),
            const CutPiece(length: 497, quantity: 1),
          ],
        );
        expect(result.totalStock, equals(1));
        expect(result.bins[0].waste, closeTo(0, 0.001));
      });
    });
  });
}

/// ビンの使用済み長さの合計を算出するヘルパー（テスト検証用）
double _usedInBins(List<CutBin> bins) {
  double total = 0;
  for (final bin in bins) {
    total += bin.stockLength - bin.waste;
  }
  return total;
}
