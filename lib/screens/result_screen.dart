import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/wood_stock.dart';
import '../models/cut_piece.dart';
import '../models/cut_result.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../services/storage_service.dart';
import '../widgets/cut_diagram.dart';

/// 計算結果画面
///
/// 最適化計算の結果を表示し、プロジェクトとして保存できる。
class ResultScreen extends ConsumerWidget {
  final CutResult result;
  final WoodStock woodStock;
  final int stockLength;
  final List<CutPiece> pieces;
  final double kerfWidth;
  final Project? existingProject;

  const ResultScreen({
    super.key,
    required this.result,
    required this.woodStock,
    required this.stockLength,
    required this.pieces,
    required this.kerfWidth,
    this.existingProject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('計算結果'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // サマリーカード
          _buildSummaryCard(context),
          const SizedBox(height: 24),

          // 各ビンのカット図
          Text(
            'カット配置',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),

          ...List.generate(result.bins.length, (index) {
            final bin = result.bins[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ビン番号ヘッダー
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${index + 1}本目',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${bin.pieces.length}ピース / 端材: ${bin.waste.toStringAsFixed(0)}mm',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // カット図
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CutDiagram(
                        bin: bin,
                        stockLength: stockLength.toDouble(),
                        kerfWidth: kerfWidth,
                      ),
                    ),
                  ),

                  // ピースの詳細リスト
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: bin.pieces.map((piece) {
                        return Chip(
                          label: Text(
                            piece.label != null && piece.label!.isNotEmpty
                                ? '${piece.label}: ${piece.length.toStringAsFixed(0)}mm'
                                : '${piece.length.toStringAsFixed(0)}mm',
                            style: const TextStyle(fontSize: 11),
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // 保存ボタン
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _onSave(context, ref),
              icon: const Icon(Icons.save),
              label: const Text('プロジェクトを保存'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// サマリーカード
  Widget _buildSummaryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 購入数
            Row(
              children: [
                Icon(Icons.shopping_cart, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  '購入',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                Text(
                  '${woodStock.name} (${stockLength}mm)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${result.totalStock}本',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // 端材合計
            Row(
              children: [
                Icon(Icons.delete_outline,
                    color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Text(
                  '端材合計',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                Text(
                  '${result.totalWaste.toStringAsFixed(0)} mm',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),

            // 利用率
            Row(
              children: [
                Icon(Icons.pie_chart_outline, color: _utilizationColor(colorScheme)),
                const SizedBox(width: 12),
                Text(
                  '利用率',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                Text(
                  '${(result.utilizationRate * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _utilizationColor(colorScheme),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 利用率バー
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: result.utilizationRate,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                    _utilizationColor(colorScheme)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 利用率に応じた色
  Color _utilizationColor(ColorScheme colorScheme) {
    if (result.utilizationRate >= 0.9) {
      return Colors.green;
    } else if (result.utilizationRate >= 0.7) {
      return Colors.orange;
    } else {
      return colorScheme.error;
    }
  }

  /// プロジェクト保存
  Future<void> _onSave(BuildContext context, WidgetRef ref) async {
    // 既存プロジェクトがある場合はそのまま上書き保存
    if (existingProject != null) {
      final updated = existingProject!.copyWith(
        woodStock: woodStock,
        stockLength: stockLength,
        pieces: pieces,
        kerfWidth: kerfWidth,
        result: result,
        updatedAt: DateTime.now(),
      );
      await StorageService.saveProject(updated);
      ref.invalidate(projectsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('プロジェクトを更新しました')),
        );
        // ホームへ戻る
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      return;
    }

    // 新規保存: 名前入力ダイアログ
    final name = await _showNameDialog(context);
    if (name == null || name.isEmpty) return;

    final project = Project(
      id: const Uuid().v4(),
      name: name,
      woodStock: woodStock,
      stockLength: stockLength,
      pieces: pieces,
      kerfWidth: kerfWidth,
      result: result,
    );

    await StorageService.saveProject(project);
    ref.invalidate(projectsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('「$name」を保存しました')),
      );
      // ホームへ戻る
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  /// プロジェクト名入力ダイアログ
  Future<String?> _showNameDialog(BuildContext context) async {
    final controller = TextEditingController(
        text: '${woodStock.name} カットプラン');

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('プロジェクト名'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '名前',
            border: OutlineInputBorder(),
            hintText: '例: 本棚用カット',
          ),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }
}
