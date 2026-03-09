import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/sheet_models.dart';

const List<Color> _pieceColors = [
  Color(0xFF42A5F5),
  Color(0xFF66BB6A),
  Color(0xFFFFA726),
  Color(0xFFAB47BC),
  Color(0xFFEF5350),
  Color(0xFF26C6DA),
];

/// 2D カット図ウィジェット
class SheetCutDiagram extends StatelessWidget {
  final SheetCutBin bin;
  final double sheetWidth;
  final double sheetHeight;

  const SheetCutDiagram({
    super.key,
    required this.bin,
    required this.sheetWidth,
    required this.sheetHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${bin.pieces.length}ピースの2Dカット図。'
          '利用率${(bin.utilizationRate * 100).toStringAsFixed(0)}%。',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final scale = availableWidth / sheetWidth;
          final diagramHeight = math.min(sheetHeight * scale, 300.0);
          final effectiveScale = math.min(scale, diagramHeight / sheetHeight);

          return SizedBox(
            width: sheetWidth * effectiveScale,
            height: diagramHeight,
            child: CustomPaint(
              size: Size(sheetWidth * effectiveScale, diagramHeight),
              painter: _SheetDiagramPainter(
                bin: bin,
                sheetWidth: sheetWidth,
                sheetHeight: sheetHeight,
                scale: effectiveScale,
                colorScheme: Theme.of(context).colorScheme,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SheetDiagramPainter extends CustomPainter {
  final SheetCutBin bin;
  final double sheetWidth;
  final double sheetHeight;
  final double scale;
  final ColorScheme colorScheme;

  _SheetDiagramPainter({
    required this.bin,
    required this.sheetWidth,
    required this.sheetHeight,
    required this.scale,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 板全体の背景
    final bgPaint = Paint()
      ..color = colorScheme.surfaceContainerHighest
      ..style = PaintingStyle.fill;
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(4),
    );
    canvas.drawRRect(bgRect, bgPaint);

    // 枠線
    final borderPaint = Paint()
      ..color = colorScheme.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(bgRect, borderPaint);

    // 各ピースを描画
    for (var i = 0; i < bin.pieces.length; i++) {
      final piece = bin.pieces[i];
      final color = _pieceColors[i % _pieceColors.length];

      final px = piece.x * scale;
      final py = piece.y * scale;
      final pw = piece.width * scale;
      final ph = piece.height * scale;

      // ピース塗りつぶし
      final piecePaint = Paint()
        ..color = color.withAlpha(216)
        ..style = PaintingStyle.fill;
      final pieceRect = Rect.fromLTWH(px, py, pw, ph);

      canvas.save();
      canvas.clipRRect(bgRect);
      canvas.drawRect(pieceRect, piecePaint);
      canvas.restore();

      // ピース枠線
      final pieceBorder = Paint()
        ..color = color.withAlpha(102)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.save();
      canvas.clipRRect(bgRect);
      canvas.drawRect(pieceRect, pieceBorder);
      canvas.restore();

      // ラベル描画
      if (pw > 25 && ph > 18) {
        final labelText = piece.label != null && piece.label!.isNotEmpty
            ? '${piece.label}\n${piece.width.toStringAsFixed(0)}x${piece.height.toStringAsFixed(0)}'
            : '${piece.width.toStringAsFixed(0)}x${piece.height.toStringAsFixed(0)}';

        final fontSize = math.min(11.0, math.max(7.0, math.min(pw, ph) / 6));
        _drawText(
          canvas,
          labelText,
          Offset(px + pw / 2, py + ph / 2),
          fontSize,
          Colors.white,
          pw - 4,
        );
      }
    }
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
      maxLines: 3,
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
  bool shouldRepaint(covariant _SheetDiagramPainter oldDelegate) {
    return oldDelegate.bin != bin ||
        oldDelegate.sheetWidth != sheetWidth ||
        oldDelegate.sheetHeight != sheetHeight ||
        oldDelegate.scale != scale;
  }
}
