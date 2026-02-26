import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wood_stock.dart';
import '../models/cut_piece.dart';
import '../models/project.dart';
import '../providers/settings_provider.dart';
import '../services/cut_optimizer.dart';
import '../widgets/piece_input_row.dart';
import 'result_screen.dart';

/// 必要部材入力画面
///
/// カットしたい部材の長さと数量を入力し、最適化計算を実行する。
class PiecesInputScreen extends ConsumerStatefulWidget {
  final WoodStock woodStock;
  final int stockLength;
  final Project? existingProject;

  const PiecesInputScreen({
    super.key,
    required this.woodStock,
    required this.stockLength,
    this.existingProject,
  });

  @override
  ConsumerState<PiecesInputScreen> createState() => _PiecesInputScreenState();
}

class _PiecesInputScreenState extends ConsumerState<PiecesInputScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<CutPiece> _pieces;

  @override
  void initState() {
    super.initState();
    if (widget.existingProject != null &&
        widget.existingProject!.pieces.isNotEmpty) {
      _pieces = List.from(widget.existingProject!.pieces);
    } else {
      // 最低1行の空行を用意
      _pieces = [const CutPiece(length: 0, quantity: 1)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingProject != null
            ? widget.existingProject!.name
            : '部材を入力'),
        actions: [
          // 素材情報チップ
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar: const Icon(Icons.straighten, size: 16),
              label: Text(
                '${widget.woodStock.name} ${widget.stockLength}mm',
                style: const TextStyle(fontSize: 12),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // 入力リスト
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ヘッダー
                  Text(
                    '切り出したいサイズ',
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
                        Expanded(
                          flex: 3,
                          child: Text(
                            '長さ(mm)',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '数量',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(width: 44), // 削除ボタン分のスペース
                      ],
                    ),
                  ),

                  // 部材入力行
                  ...List.generate(_pieces.length, (index) {
                    return PieceInputRow(
                      key: ValueKey('piece_$index'),
                      index: index,
                      piece: _pieces[index],
                      canDelete: _pieces.length > 1,
                      onChanged: (updated) {
                        setState(() {
                          _pieces[index] = updated;
                        });
                      },
                      onDelete: () {
                        setState(() {
                          _pieces.removeAt(index);
                        });
                      },
                    );
                  }),

                  const SizedBox(height: 16),

                  // 「+ サイズを追加」ボタン
                  OutlinedButton.icon(
                    onPressed: _addPiece,
                    icon: const Icon(Icons.add),
                    label: const Text('サイズを追加'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            // 計算ボタン（下部固定）
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
      ),
    );
  }

  /// 行を追加
  void _addPiece() {
    setState(() {
      _pieces.add(const CutPiece(length: 0, quantity: 1));
    });
  }

  /// 計算を実行
  void _onCalculate() {
    // バリデーション
    final validPieces = <CutPiece>[];
    final errors = <String>[];

    for (var i = 0; i < _pieces.length; i++) {
      final piece = _pieces[i];

      if (piece.length <= 0) {
        errors.add('${i + 1}行目: 長さを入力してください');
        continue;
      }
      if (piece.quantity <= 0) {
        errors.add('${i + 1}行目: 数量を1以上にしてください');
        continue;
      }
      if (piece.length > widget.stockLength) {
        errors.add(
            '${i + 1}行目: 長さ(${piece.length.toStringAsFixed(0)}mm)が素材長(${widget.stockLength}mm)を超えています');
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

    // 最適化計算を実行
    final settings = ref.read(settingsProvider);
    try {
      final result = CutOptimizer.optimize(
        stockLength: widget.stockLength.toDouble(),
        kerfWidth: settings.kerfWidth,
        pieces: validPieces,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            woodStock: widget.woodStock,
            stockLength: widget.stockLength,
            pieces: validPieces,
            kerfWidth: settings.kerfWidth,
            existingProject: widget.existingProject,
          ),
        ),
      );
    } on CutOptimizerException catch (e) {
      _showErrorDialog([e.message]);
    }
  }

  /// エラーダイアログ
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
                        Icon(
                          Icons.warning_amber,
                          size: 16,
                          color: Theme.of(context).colorScheme.error,
                        ),
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
