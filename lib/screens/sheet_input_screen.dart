import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sheet_models.dart';
import '../providers/settings_provider.dart';
import '../services/sheet_cut_optimizer.dart';
import 'sheet_result_screen.dart';

/// 2D 部材入力画面
class SheetInputScreen extends ConsumerStatefulWidget {
  final SheetStock sheetStock;

  const SheetInputScreen({
    super.key,
    required this.sheetStock,
  });

  @override
  ConsumerState<SheetInputScreen> createState() => _SheetInputScreenState();
}

class _SheetInputScreenState extends ConsumerState<SheetInputScreen> {
  List<SheetPiece> _pieces = [const SheetPiece(width: 0, height: 0, quantity: 1)];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('部材を入力 (2D)'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar: const Icon(Icons.crop_square, size: 16),
              label: Text(
                '${widget.sheetStock.name} ${widget.sheetStock.width.toStringAsFixed(0)}x${widget.sheetStock.height.toStringAsFixed(0)}mm',
                style: const TextStyle(fontSize: 11),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '切り出したいサイズ (2D)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '鋸刃の幅: ${settings.kerfWidth.toStringAsFixed(1)} mm',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),

                // 列ヘッダー
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      _headerLabel(context, '幅(mm)', flex: 2),
                      const SizedBox(width: 6),
                      _headerLabel(context, '高さ(mm)', flex: 2),
                      const SizedBox(width: 6),
                      _headerLabel(context, '数量', flex: 1),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),

                // 入力行
                ...List.generate(_pieces.length, (index) {
                  return _buildInputRow(index);
                }),

                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _pieces.add(const SheetPiece(width: 0, height: 0, quantity: 1));
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('サイズを追加'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _onCalculate,
                  icon: const Icon(Icons.calculate),
                  label: const Text('計算する'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerLabel(BuildContext context, String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildInputRow(int index) {
    final piece = _pieces[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: piece.width > 0 ? piece.width.toStringAsFixed(0) : '',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final w = double.tryParse(value) ?? 0;
                setState(() {
                  _pieces[index] = piece.copyWith(width: w);
                });
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: piece.height > 0 ? piece.height.toStringAsFixed(0) : '',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final h = double.tryParse(value) ?? 0;
                setState(() {
                  _pieces[index] = piece.copyWith(height: h);
                });
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 1,
            child: TextFormField(
              initialValue: piece.quantity.toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final q = int.tryParse(value) ?? 1;
                setState(() {
                  _pieces[index] = piece.copyWith(quantity: q);
                });
              },
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 40,
            child: _pieces.length > 1
                ? IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _pieces.removeAt(index);
                      });
                    },
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _onCalculate() {
    final validPieces = <SheetPiece>[];
    final errors = <String>[];

    for (var i = 0; i < _pieces.length; i++) {
      final piece = _pieces[i];
      if (piece.width <= 0 || piece.height <= 0) {
        errors.add('${i + 1}行目: 幅と高さを入力してください');
        continue;
      }
      if (piece.quantity <= 0) {
        errors.add('${i + 1}行目: 数量を1以上にしてください');
        continue;
      }
      final fitsNormal = piece.width <= widget.sheetStock.width &&
          piece.height <= widget.sheetStock.height;
      final fitsRotated = piece.height <= widget.sheetStock.width &&
          piece.width <= widget.sheetStock.height;
      if (!fitsNormal && !fitsRotated) {
        errors.add(
            '${i + 1}行目: サイズ(${piece.width.toStringAsFixed(0)}x${piece.height.toStringAsFixed(0)}mm)が板材に収まりません');
        continue;
      }
      validPieces.add(piece);
    }

    if (errors.isNotEmpty) {
      _showErrorDialog(errors);
      return;
    }
    if (validPieces.isEmpty) {
      _showErrorDialog(['部材を1つ以上入力してください']);
      return;
    }

    final settings = ref.read(settingsProvider);
    try {
      final result = SheetCutOptimizer.optimize(
        sheetWidth: widget.sheetStock.width,
        sheetHeight: widget.sheetStock.height,
        kerfWidth: settings.kerfWidth,
        pieces: validPieces,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SheetResultScreen(
            result: result,
            sheetStock: widget.sheetStock,
          ),
        ),
      );
    } on SheetCutOptimizerException catch (e) {
      _showErrorDialog([e.message]);
    }
  }

  void _showErrorDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('入力エラー'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors
              .map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber, size: 16,
                            color: Theme.of(context).colorScheme.error),
                        const SizedBox(width: 8),
                        Expanded(child: Text(e, style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                  ))
              .toList(),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
