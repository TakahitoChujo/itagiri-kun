import '../models/cut_piece.dart';
import '../models/cut_result.dart';

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
  ///
  /// Returns [CutResult] 最適化されたカット配置結果
  ///
  /// Throws [CutOptimizerException] 素材より長い部材がある場合
  static CutResult optimize({
    required double stockLength,
    List<double>? stockLengths,
    required double kerfWidth,
    required List<CutPiece> pieces,
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

    // 3. ビンパッキング
    final bins = <_WorkingBin>[];

    if (effectiveLengths.length == 1) {
      // 単一長さ: First Fit Decreasing（従来の挙動）
      _firstFitDecreasing(expandedPieces, effectiveLengths[0], kerfWidth, bins);
    } else {
      // 複数長さ: Best Fit Decreasing with heterogeneous bins
      _bestFitDecreasingMulti(expandedPieces, effectiveLengths, kerfWidth, bins);
    }

    // 4. 結果を構築
    final resultBins = bins.map((bin) {
      final resultPieces = bin.pieces
          .map((p) => CutPieceResult(length: p.length, label: p.label))
          .toList();
      return CutBin(
        pieces: resultPieces,
        waste: bin.remainingLength,
        stockLength: bin.stockLength,
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

  /// First Fit Decreasing（単一材料長）
  static void _firstFitDecreasing(
    List<_ExpandedPiece> pieces,
    double stockLength,
    double kerfWidth,
    List<_WorkingBin> bins,
  ) {
    for (final piece in pieces) {
      var placed = false;
      for (final bin in bins) {
        if (bin.canFit(piece.length, kerfWidth)) {
          bin.addPiece(piece, kerfWidth);
          placed = true;
          break;
        }
      }
      if (!placed) {
        final newBin = _WorkingBin(stockLength: stockLength);
        newBin.addPiece(piece, kerfWidth);
        bins.add(newBin);
      }
    }
  }

  /// Best Fit Decreasing（複数材料長）
  ///
  /// 各ピースを「残りスペースが最小で収まるビン」に配置する。
  /// 既存ビンに入らない場合は、ピースが収まる最小の材料長で新規ビンを作成する。
  static void _bestFitDecreasingMulti(
    List<_ExpandedPiece> pieces,
    List<double> sortedLengths, // 昇順ソート済み
    double kerfWidth,
    List<_WorkingBin> bins,
  ) {
    for (final piece in pieces) {
      // Best Fit: 残りスペースが最小で piece が入るビンを探す
      _WorkingBin? bestBin;
      double bestRemaining = double.infinity;

      for (final bin in bins) {
        if (bin.canFit(piece.length, kerfWidth)) {
          final remaining = bin.remainingLength -
              (bin.pieces.isEmpty ? piece.length : kerfWidth + piece.length);
          if (remaining < bestRemaining) {
            bestRemaining = remaining;
            bestBin = bin;
          }
        }
      }

      if (bestBin != null) {
        bestBin.addPiece(piece, kerfWidth);
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
  final List<_ExpandedPiece> pieces = [];

  /// 現在使用している長さ（ピース + カーフ）
  double _usedLength = 0;

  _WorkingBin({required this.stockLength});

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
