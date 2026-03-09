import '../models/sheet_models.dart';

/// 2D カット最適化例外
class SheetCutOptimizerException implements Exception {
  final String message;
  const SheetCutOptimizerException(this.message);

  @override
  String toString() => 'SheetCutOptimizerException: $message';
}

/// ギロチンカットによる 2D ビンパッキング最適化サービス
///
/// 合板など板材のカットを最適化する。
/// Best Area Fit + Guillotine Split アルゴリズムを使用。
class SheetCutOptimizer {
  /// 2D カット最適化を実行する。
  static SheetCutResult optimize({
    required double sheetWidth,
    required double sheetHeight,
    required double kerfWidth,
    required List<SheetPiece> pieces,
  }) {
    if (sheetWidth <= 0 || sheetHeight <= 0) {
      throw const SheetCutOptimizerException('板材のサイズは正の値でなければなりません。');
    }
    if (kerfWidth < 0) {
      throw const SheetCutOptimizerException('カーフ幅は0以上でなければなりません。');
    }

    if (pieces.isEmpty) {
      return const SheetCutResult(
        bins: [],
        totalSheets: 0,
        totalWasteArea: 0,
        utilizationRate: 1.0,
      );
    }

    // 全ピースを展開
    final expanded = <_ExpandedPiece>[];
    for (final piece in pieces) {
      for (var i = 0; i < piece.quantity; i++) {
        expanded.add(_ExpandedPiece(
          width: piece.width,
          height: piece.height,
          label: piece.label,
          canRotate: piece.canRotate,
        ));
      }
    }

    // バリデーション: 板に収まるかチェック
    for (final piece in expanded) {
      final fitsNormal =
          piece.width <= sheetWidth && piece.height <= sheetHeight;
      final fitsRotated = piece.canRotate &&
          piece.height <= sheetWidth &&
          piece.width <= sheetHeight;
      if (!fitsNormal && !fitsRotated) {
        throw SheetCutOptimizerException(
          '部材 (${piece.width}x${piece.height}mm) が板材 (${sheetWidth}x${sheetHeight}mm) に収まりません。'
          '${piece.label != null ? " ラベル: ${piece.label}" : ""}',
        );
      }
    }

    // 面積の大きい順にソート
    expanded.sort((a, b) => (b.width * b.height).compareTo(a.width * a.height));

    // ビンパッキング
    final bins = <_WorkingSheet>[];

    for (final piece in expanded) {
      var placed = false;

      // 既存シートに配置を試みる
      for (final sheet in bins) {
        if (sheet.tryPlace(piece, kerfWidth)) {
          placed = true;
          break;
        }
      }

      // 新しいシートを追加
      if (!placed) {
        final newSheet = _WorkingSheet(
          width: sheetWidth,
          height: sheetHeight,
        );
        if (!newSheet.tryPlace(piece, kerfWidth)) {
          throw SheetCutOptimizerException(
            '部材を配置できません: ${piece.width}x${piece.height}mm',
          );
        }
        bins.add(newSheet);
      }
    }

    // 結果を構築
    final resultBins = bins.map((sheet) {
      final placedPieces = sheet.placedPieces
          .map((p) => SheetPlacedPiece(
                x: p.x,
                y: p.y,
                width: p.width,
                height: p.height,
                rotated: p.rotated,
                label: p.label,
              ))
          .toList();
      final usedArea =
          placedPieces.fold(0.0, (sum, p) => sum + p.width * p.height);
      final wasteArea = sheetWidth * sheetHeight - usedArea;
      return SheetCutBin(
        pieces: placedPieces,
        wasteArea: wasteArea,
        sheetWidth: sheetWidth,
        sheetHeight: sheetHeight,
      );
    }).toList();

    final totalSheets = resultBins.length;
    final totalSheetArea = sheetWidth * sheetHeight * totalSheets;
    final totalWaste =
        resultBins.fold(0.0, (sum, bin) => sum + bin.wasteArea);
    final utilizationRate =
        totalSheetArea > 0 ? (totalSheetArea - totalWaste) / totalSheetArea : 0.0;

    return SheetCutResult(
      bins: resultBins,
      totalSheets: totalSheets,
      totalWasteArea: totalWaste,
      utilizationRate: utilizationRate,
    );
  }
}

/// 内部用: 展開されたピース
class _ExpandedPiece {
  final double width;
  final double height;
  final String? label;
  final bool canRotate;

  const _ExpandedPiece({
    required this.width,
    required this.height,
    this.label,
    this.canRotate = true,
  });
}

/// 内部用: 配置されたピース（位置情報付き）
class _PlacedPiece {
  final double x;
  final double y;
  final double width;
  final double height;
  final bool rotated;
  final String? label;

  const _PlacedPiece({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotated = false,
    this.label,
  });
}

/// 内部用: 空き矩形
class _FreeRect {
  final double x;
  final double y;
  final double width;
  final double height;

  const _FreeRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  double get area => width * height;
}

/// 内部用: 作業中のシート
class _WorkingSheet {
  final double width;
  final double height;
  final List<_PlacedPiece> placedPieces = [];
  final List<_FreeRect> freeRects = [];

  _WorkingSheet({required this.width, required this.height}) {
    freeRects.add(_FreeRect(x: 0, y: 0, width: width, height: height));
  }

  /// ピースの配置を試みる。成功したら true を返す。
  bool tryPlace(_ExpandedPiece piece, double kerf) {
    _FreeRect? bestRect;
    int bestIndex = -1;
    bool bestRotated = false;
    double bestScore = double.infinity;

    for (var i = 0; i < freeRects.length; i++) {
      final rect = freeRects[i];

      // 通常配置
      if (piece.width <= rect.width && piece.height <= rect.height) {
        final score = rect.area - piece.width * piece.height;
        if (score < bestScore) {
          bestScore = score;
          bestRect = rect;
          bestIndex = i;
          bestRotated = false;
        }
      }

      // 回転配置
      if (piece.canRotate &&
          piece.height <= rect.width &&
          piece.width <= rect.height) {
        final score = rect.area - piece.width * piece.height;
        if (score < bestScore) {
          bestScore = score;
          bestRect = rect;
          bestIndex = i;
          bestRotated = true;
        }
      }
    }

    if (bestRect == null) return false;

    final placedW = bestRotated ? piece.height : piece.width;
    final placedH = bestRotated ? piece.width : piece.height;

    placedPieces.add(_PlacedPiece(
      x: bestRect.x,
      y: bestRect.y,
      width: placedW,
      height: placedH,
      rotated: bestRotated,
      label: piece.label,
    ));

    // ギロチン分割: 配置した矩形を除去し、残りの空き領域を追加
    freeRects.removeAt(bestIndex);

    // 右側の余り
    final rightWidth = bestRect.width - placedW - kerf;
    if (rightWidth > 0) {
      freeRects.add(_FreeRect(
        x: bestRect.x + placedW + kerf,
        y: bestRect.y,
        width: rightWidth,
        height: bestRect.height,
      ));
    }

    // 下側の余り
    final bottomHeight = bestRect.height - placedH - kerf;
    if (bottomHeight > 0) {
      freeRects.add(_FreeRect(
        x: bestRect.x,
        y: bestRect.y + placedH + kerf,
        width: placedW,
        height: bottomHeight,
      ));
    }

    return true;
  }
}
