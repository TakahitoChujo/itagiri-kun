import '../models/cut_piece.dart';
import '../models/cut_result.dart';
import '../models/offcut.dart';

/// カット最適化例外
class CutOptimizerException implements Exception {
  final String message;
  const CutOptimizerException(this.message);

  @override
  String toString() => 'CutOptimizerException: $message';
}

/// 1Dビンパッキングによる木材カット最適化サービス。
///
/// 単一材料長: First Fit Decreasing (FFD)
/// 複数材料長: Best Fit Decreasing with heterogeneous bins
class CutOptimizer {
  /// カット最適化を実行する。
  ///
  /// [stockLength] 素材1本の長さ (mm)（単一長さの場合）
  /// [stockLengths] 利用可能な素材長リスト (mm)（複数長さの場合、優先）
  /// [kerfWidth] 鋸刃の幅 (mm)。各ピース間に加算される。
  /// [pieces] カットしたい部材リスト
  /// [offcuts] 再利用する保存済み端材リスト（優先的に消化される）
  ///
  /// Returns [CutResult] 最適化されたカット配置結果
  ///
  /// Throws [CutOptimizerException] 素材より長い部材がある場合
  static CutResult optimize({
    required double stockLength,
    List<double>? stockLengths,
    required double kerfWidth,
    required List<CutPiece> pieces,
    List<Offcut>? offcuts,
  }) {
    // 実効素材長リストを決定（昇順ソート）
    final effectiveLengths = stockLengths != null && stockLengths.isNotEmpty
        ? (List<double>.from(stockLengths)..sort())
        : [stockLength];

    // バリデーション
    if (effectiveLengths.any((l) => l <= 0)) {
      throw const CutOptimizerException('素材の長さは正の値でなければなりません。');
    }
    if (kerfWidth < 0) {
      throw const CutOptimizerException('カーフ幅は0以上でなければなりません。');
    }

    // 空のリストの場合は即座に結果を返す
    if (pieces.isEmpty) {
      return const CutResult(
        bins: [],
        totalStock: 0,
        totalWaste: 0,
        utilizationRate: 1.0,
      );
    }

    // 1. 全ての部材を展開して個別のリストにする
    final expandedPieces = <_ExpandedPiece>[];
    for (final piece in pieces) {
      for (var i = 0; i < piece.quantity; i++) {
        expandedPieces.add(_ExpandedPiece(
          length: piece.length,
          label: piece.label,
        ));
      }
    }

    final maxStockLength = effectiveLengths.last;

    // 素材より長い部材がないかチェック
    for (final piece in expandedPieces) {
      if (piece.length > maxStockLength) {
        throw CutOptimizerException(
          '部材 (${piece.length}mm) が最大素材長 (${maxStockLength}mm) を超えています。'
          '${piece.label != null ? " ラベル: ${piece.label}" : ""}',
        );
      }
    }

    // 2. 長い順にソート（降順） -- Decreasing
    expandedPieces.sort((a, b) => b.length.compareTo(a.length));

    // 3. 端材ビンを事前にセット（短い順でBest Fitに有利）
    final bins = <_WorkingBin>[];
    if (offcuts != null && offcuts.isNotEmpty) {
      final sortedOffcuts = List<Offcut>.from(offcuts)
        ..sort((a, b) => a.length.compareTo(b.length));
      for (final offcut in sortedOffcuts) {
        bins.add(_WorkingBin(
          stockLength: offcut.length,
          isFromOffcut: true,
          offcutId: offcut.id,
        ));
      }
    }

    // 4. ビンパッキング（端材ビンも含めて Best Fit）
    _bestFitDecreasingWithOffcuts(
      expandedPieces, effectiveLengths, kerfWidth, bins,
    );

    // 5. 空の端材ビンを除去（使われなかった端材）
    bins.removeWhere((bin) => bin.isFromOffcut && bin.pieces.isEmpty);

    // 6. 結果を構築（切断順序番号を付与）
    final resultBins = bins.map((bin) {
      final resultPieces = bin.pieces
          .asMap()
          .entries
          .map((e) => CutPieceResult(
                length: e.value.length,
                label: e.value.label,
                sequenceOrder: e.key + 1,
              ))
          .toList();
      return CutBin(
        pieces: resultPieces,
        waste: bin.remainingLength,
        stockLength: bin.stockLength,
        isFromOffcut: bin.isFromOffcut,
        offcutId: bin.offcutId,
      );
    }).toList();

    final totalStock = resultBins.length;
    final totalWaste = resultBins.fold(0.0, (sum, bin) => sum + bin.waste);
    final totalStockLength =
        resultBins.fold(0.0, (sum, bin) => sum + bin.stockLength);
    final utilizationRate = totalStockLength > 0
        ? (totalStockLength - totalWaste) / totalStockLength
        : 0.0;

    return CutResult(
      bins: resultBins,
      totalStock: totalStock,
      totalWaste: totalWaste,
      utilizationRate: utilizationRate,
    );
  }

  /// Best Fit Decreasing with offcut bins support
  ///
  /// 端材ビン（既にリストに入っている）を含めて、Best Fitでピースを配置する。
  /// 端材ビンに入る場合はそちらを優先する。
  static void _bestFitDecreasingWithOffcuts(
    List<_ExpandedPiece> pieces,
    List<double> sortedLengths,
    double kerfWidth,
    List<_WorkingBin> bins,
  ) {
    for (final piece in pieces) {
      // Best Fit: 残りスペースが最小で piece が入るビンを探す
      // 端材ビンを優先するため、端材ビンと新規ビンで別々に探す
      _WorkingBin? bestOffcutBin;
      double bestOffcutRemaining = double.infinity;
      _WorkingBin? bestNewBin;
      double bestNewRemaining = double.infinity;

      for (final bin in bins) {
        if (bin.canFit(piece.length, kerfWidth)) {
          final remaining = bin.remainingLength -
              (bin.pieces.isEmpty ? piece.length : kerfWidth + piece.length);
          if (bin.isFromOffcut) {
            if (remaining < bestOffcutRemaining) {
              bestOffcutRemaining = remaining;
              bestOffcutBin = bin;
            }
          } else {
            if (remaining < bestNewRemaining) {
              bestNewRemaining = remaining;
              bestNewBin = bin;
            }
          }
        }
      }

      // 端材ビンを優先
      if (bestOffcutBin != null) {
        bestOffcutBin.addPiece(piece, kerfWidth);
      } else if (bestNewBin != null) {
        bestNewBin.addPiece(piece, kerfWidth);
      } else {
        // 新規ビン: ピースが収まる最小の材料長を選ぶ
        double? chosenLength;
        for (final len in sortedLengths) {
          if (piece.length <= len) {
            chosenLength = len;
            break;
          }
        }
        if (chosenLength == null) {
          throw CutOptimizerException(
            '部材 (${piece.length}mm) がどの素材長にも収まりません。'
            '${piece.label != null ? " ラベル: ${piece.label}" : ""}',
          );
        }
        final newBin = _WorkingBin(stockLength: chosenLength);
        newBin.addPiece(piece, kerfWidth);
        bins.add(newBin);
      }
    }
  }
}

/// 内部用: 展開されたピース
class _ExpandedPiece {
  final double length;
  final String? label;

  const _ExpandedPiece({required this.length, this.label});
}

/// 内部用: 作業中のビン（1本の素材）
class _WorkingBin {
  final double stockLength;
  final bool isFromOffcut;
  final String? offcutId;
  final List<_ExpandedPiece> pieces = [];

  /// 現在使用している長さ（ピース + カーフ）
  double _usedLength = 0;

  _WorkingBin({
    required this.stockLength,
    this.isFromOffcut = false,
    this.offcutId,
  });

  /// 残りの長さ (mm)
  double get remainingLength => stockLength - _usedLength;

  /// 指定した長さのピースが入るかどうか判定する。
  bool canFit(double pieceLength, double kerfWidth) {
    if (pieces.isEmpty) {
      return pieceLength <= stockLength;
    }
    return _usedLength + kerfWidth + pieceLength <= stockLength;
  }

  /// ピースをビンに追加する。
  void addPiece(_ExpandedPiece piece, double kerfWidth) {
    if (pieces.isNotEmpty) {
      _usedLength += kerfWidth;
    }
    _usedLength += piece.length;
    pieces.add(piece);
  }
}
