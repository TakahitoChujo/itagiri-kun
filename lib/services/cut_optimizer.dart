import '../models/cut_piece.dart';
import '../models/cut_result.dart';

/// カット最適化例外
class CutOptimizerException implements Exception {
  final String message;
  const CutOptimizerException(this.message);

  @override
  String toString() => 'CutOptimizerException: $message';
}

/// 1Dビンパッキング（First Fit Decreasing）による
/// 木材カット最適化サービス。
///
/// 与えられた部材リストを、できるだけ少ない本数の素材に
/// 効率よく配置する。鋸刃の幅（カーフ）も考慮する。
class CutOptimizer {
  /// カット最適化を実行する。
  ///
  /// [stockLength] 素材1本の長さ (mm)
  /// [kerfWidth] 鋸刃の幅 (mm)。各ピース間に加算される。
  /// [pieces] カットしたい部材リスト
  ///
  /// Returns [CutResult] 最適化されたカット配置結果
  ///
  /// Throws [CutOptimizerException] 素材より長い部材がある場合
  static CutResult optimize({
    required double stockLength,
    required double kerfWidth,
    required List<CutPiece> pieces,
  }) {
    // バリデーション
    if (stockLength <= 0) {
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

    // 素材より長い部材がないかチェック
    for (final piece in expandedPieces) {
      if (piece.length > stockLength) {
        throw CutOptimizerException(
          '部材 (${piece.length}mm) が素材の長さ (${stockLength}mm) を超えています。'
          '${piece.label != null ? " ラベル: ${piece.label}" : ""}',
        );
      }
    }

    // 2. 長い順にソート（降順） -- First Fit Decreasing
    expandedPieces.sort((a, b) => b.length.compareTo(a.length));

    // 3. ビンパッキング
    final bins = <_WorkingBin>[];

    for (final piece in expandedPieces) {
      var placed = false;

      // 既存のビンに入るか試す（First Fit）
      for (final bin in bins) {
        if (bin.canFit(piece.length, kerfWidth)) {
          bin.addPiece(piece, kerfWidth);
          placed = true;
          break;
        }
      }

      // 入らなければ新しいビンを追加
      if (!placed) {
        final newBin = _WorkingBin(stockLength: stockLength);
        newBin.addPiece(piece, kerfWidth);
        bins.add(newBin);
      }
    }

    // 4. 結果を構築
    final resultBins = bins.map((bin) {
      final resultPieces = bin.pieces
          .map((p) => CutPieceResult(length: p.length, label: p.label))
          .toList();
      return CutBin(
        pieces: resultPieces,
        waste: bin.remainingLength,
        stockLength: stockLength,
      );
    }).toList();

    final totalStock = resultBins.length;
    final totalWaste =
        resultBins.fold(0.0, (sum, bin) => sum + bin.waste);
    final totalStockLength = stockLength * totalStock;
    final utilizationRate =
        totalStockLength > 0 ? (totalStockLength - totalWaste) / totalStockLength : 0.0;

    return CutResult(
      bins: resultBins,
      totalStock: totalStock,
      totalWaste: totalWaste,
      utilizationRate: utilizationRate,
    );
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
  ///
  /// ビンにすでにピースがある場合は、カーフ幅分も必要になる。
  bool canFit(double pieceLength, double kerfWidth) {
    if (pieces.isEmpty) {
      // 最初のピース: カーフ不要
      return pieceLength <= stockLength;
    }
    // 既存のピースがある場合: カーフ + ピース分のスペースが必要
    return _usedLength + kerfWidth + pieceLength <= stockLength;
  }

  /// ピースをビンに追加する。
  void addPiece(_ExpandedPiece piece, double kerfWidth) {
    if (pieces.isNotEmpty) {
      // 既存ピースとの間にカーフを追加
      _usedLength += kerfWidth;
    }
    _usedLength += piece.length;
    pieces.add(piece);
  }
}
