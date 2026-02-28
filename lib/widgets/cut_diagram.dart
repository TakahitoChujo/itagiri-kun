import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/cut_result.dart';

/// カット図で使用する色パレット（6色ローテーション）
const List<Color> _pieceColors = [
  Color(0xFF42A5F5), // Blue
  Color(0xFF66BB6A), // Green
  Color(0xFFFFA726), // Orange
  Color(0xFFAB47BC), // Purple
  Color(0xFFEF5350), // Red
  Color(0xFF26C6DA), // Cyan
];

/// カット図ウィジェット
///
/// 1本の素材に対するカット配置を視覚的に表現する。
/// CustomPainter を使い、素材全体を長方形で描画し、
/// 各ピースを色分けした長方形、カーフを細い線、端材をハッチングで表示する。
class CutDiagram extends StatelessWidget {
  final CutBin bin;
  final double stockLength;
  final double kerfWidth;

  const CutDiagram({
    super.key,
    required this.bin,
    required this.stockLength,
    this.kerfWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${bin.pieces.length}ピースのカット図。'
          '端材${bin.waste.toStringAsFixed(0)}mm。'
          '利用率${(bin.utilizationRate * 100).toStringAsFixed(0)}%。',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          const height = 80.0;

          return SizedBox(
            width: width,
            height: height,
            child: CustomPaint(
              size: Size(width, height),
              painter: _CutDiagramPainter(
                bin: bin,
                stockLength: stockLength,
                kerfWidth: kerfWidth,
                colorScheme: Theme.of(context).colorScheme,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CutDiagramPainter extends CustomPainter {
  final CutBin bin;
  final double stockLength;
  final double kerfWidth;
  final ColorScheme colorScheme;

  _CutDiagramPainter({
    required this.bin,
    required this.stockLength,
    required this.kerfWidth,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double barY = 20.0;
    final double barHeight = size.height - 36;
    final double barWidth = size.width - 4;
    const double barX = 2.0;

    // 素材全体の背景（グレー）
    final bgPaint = Paint()
      ..color = colorScheme.surfaceContainerHighest
      ..style = PaintingStyle.fill;
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(barX, barY, barWidth, barHeight),
      const Radius.circular(4),
    );
    canvas.drawRRect(bgRect, bgPaint);

    // 素材の枠線
    final borderPaint = Paint()
      ..color = colorScheme.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(bgRect, borderPaint);

    if (stockLength <= 0) return;

    // カーフ描画用のペイント
    final kerfPaint = Paint()
      ..color = colorScheme.onSurface.withAlpha(80)
      ..style = PaintingStyle.fill;

    double currentX = barX;

    // 各ピースを描画
    for (var i = 0; i < bin.pieces.length; i++) {
      final piece = bin.pieces[i];
      final pieceWidth = (piece.length / stockLength) * barWidth;
      final color = _pieceColors[i % _pieceColors.length];

      // ピースの長方形
      final piecePaint = Paint()
        ..color = color.withAlpha(216)
        ..style = PaintingStyle.fill;
      final pieceRect = Rect.fromLTWH(currentX, barY, pieceWidth, barHeight);

      // クリッピングして角丸内に収める
      canvas.save();
      canvas.clipRRect(bgRect);
      canvas.drawRect(pieceRect, piecePaint);
      canvas.restore();

      // ピースの境界線
      final pieceBorderPaint = Paint()
        ..color = color.withAlpha(102)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.save();
      canvas.clipRRect(bgRect);
      canvas.drawRect(pieceRect, pieceBorderPaint);
      canvas.restore();

      // ピースの長さテキスト
      final labelText = piece.label != null && piece.label!.isNotEmpty
          ? '${piece.label}\n${piece.length.toStringAsFixed(0)}'
          : piece.length.toStringAsFixed(0);

      if (pieceWidth > 30) {
        _drawText(
          canvas,
          labelText,
          Offset(currentX + pieceWidth / 2, barY + barHeight / 2),
          math.min(11, math.max(8, pieceWidth / 5)),
          Colors.white,
          pieceWidth - 4,
        );
      }

      currentX += pieceWidth;

      // カーフ（鋸刃幅）の描画：ピース間のみ
      if (kerfWidth > 0 && i < bin.pieces.length - 1) {
        final kerfVisualWidth = (kerfWidth / stockLength) * barWidth;
        final kerfRect =
            Rect.fromLTWH(currentX, barY, kerfVisualWidth, barHeight);
        canvas.save();
        canvas.clipRRect(bgRect);
        canvas.drawRect(kerfRect, kerfPaint);
        canvas.restore();
        currentX += kerfVisualWidth;
      }
    }

    // 端材部分（ハッチング）
    if (bin.waste > 0) {
      final wasteStartX = currentX;
      final wasteWidth = barX + barWidth - wasteStartX;

      if (wasteWidth > 0) {
        final wasteRect =
            Rect.fromLTWH(wasteStartX, barY, wasteWidth, barHeight);

        // 端材の薄い色
        final wastePaint = Paint()
          ..color = colorScheme.errorContainer.withAlpha(102)
          ..style = PaintingStyle.fill;
        canvas.save();
        canvas.clipRRect(bgRect);
        canvas.drawRect(wasteRect, wastePaint);

        // 斜線ハッチング
        final hatchPaint = Paint()
          ..color = colorScheme.error.withAlpha(64)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

        const hatchSpacing = 6.0;
        for (double x = wasteStartX - barHeight;
            x < wasteStartX + wasteWidth;
            x += hatchSpacing) {
          canvas.drawLine(
            Offset(x, barY + barHeight),
            Offset(x + barHeight, barY),
            hatchPaint,
          );
        }
        canvas.restore();

        // 端材の長さテキスト
        if (wasteWidth > 25) {
          _drawText(
            canvas,
            bin.waste.toStringAsFixed(0),
            Offset(wasteStartX + wasteWidth / 2, barY + barHeight / 2),
            math.min(10, math.max(7, wasteWidth / 5)),
            colorScheme.error,
            wasteWidth - 4,
          );
        }
      }
    }

    // 上部に総長さ表示
    _drawText(
      canvas,
      '${stockLength.toStringAsFixed(0)} mm',
      Offset(size.width / 2, 10),
      11,
      colorScheme.onSurface.withAlpha(179),
      size.width,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize,
    Color color,
    double maxWidth,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 2,
      ellipsis: '',
    );
    textPainter.layout(maxWidth: maxWidth);
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _CutDiagramPainter oldDelegate) {
    return oldDelegate.bin != bin ||
        oldDelegate.stockLength != stockLength ||
        oldDelegate.kerfWidth != kerfWidth ||
        oldDelegate.colorScheme != colorScheme;
  }
}
