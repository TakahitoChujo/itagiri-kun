import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/wood_stock.dart';
import '../models/cut_piece.dart';
import '../models/cut_result.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../services/storage_service.dart';
import '../services/export_service.dart';
import '../widgets/cut_diagram.dart';
import '../widgets/ad_banner.dart';
import 'checklist_screen.dart';

/// 計算結果画面
class ResultScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final _priceController = TextEditingController();
  double? _unitPrice;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    // 既存プロジェクトまたはプリセットの参考価格を初期値に
    if (widget.existingProject?.unitPrice != null) {
      _unitPrice = widget.existingProject!.unitPrice;
      _priceController.text = _unitPrice!.toStringAsFixed(0);
    } else {
      final presetPrice = widget.woodStock.priceForLength(widget.stockLength);
      if (presetPrice != null) {
        _unitPrice = presetPrice.toDouble();
        _priceController.text = presetPrice.toString();
      }
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('計算結果'),
        actions: [
          // チェックリスト
          IconButton(
            icon: const Icon(Icons.checklist),
            tooltip: 'カットチェックリスト',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChecklistScreen(
                    result: widget.result,
                    woodStock: widget.woodStock,
                    stockLength: widget.stockLength,
                    projectName: widget.existingProject?.name ?? '${widget.woodStock.name} カットプラン',
                  ),
                ),
              );
            },
          ),
          // エクスポートメニュー
          PopupMenuButton<String>(
            icon: const Icon(Icons.share),
            tooltip: 'エクスポート',
            onSelected: _onExport,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'pdf', child: ListTile(leading: Icon(Icons.picture_as_pdf), title: Text('PDF'), dense: true)),
              const PopupMenuItem(value: 'csv', child: ListTile(leading: Icon(Icons.table_chart), title: Text('CSV'), dense: true)),
              const PopupMenuItem(value: 'json', child: ListTile(leading: Icon(Icons.code), title: Text('JSON'), dense: true)),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(context),
          const SizedBox(height: 16),
          _buildCostCard(context),
          const SizedBox(height: 24),
          Text('カット配置',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...List.generate(widget.result.bins.length, (index) {
            final bin = widget.result.bins[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${index + 1}本目',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onPrimaryContainer)),
                      ),
                      const SizedBox(width: 8),
                      Text('${bin.pieces.length}ピース / 端材: ${bin.waste.toStringAsFixed(0)}mm',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CutDiagram(bin: bin, stockLength: widget.stockLength.toDouble(), kerfWidth: widget.kerfWidth),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Wrap(
                      spacing: 6, runSpacing: 4,
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
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
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
          const SizedBox(height: 16),
          const AdBanner(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text('購入', style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text('${widget.woodStock.name} (${widget.stockLength}mm)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
                  child: Text('${widget.result.totalStock}本',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer)),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.delete_outline, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Text('端材合計', style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text('${widget.result.totalWaste.toStringAsFixed(0)} mm',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.pie_chart_outline, color: _utilizationColor(colorScheme)),
                const SizedBox(width: 12),
                Text('利用率', style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text('${(widget.result.utilizationRate * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold, color: _utilizationColor(colorScheme))),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: widget.result.utilizationRate,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(_utilizationColor(colorScheme)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 材料費見積もりカード
  Widget _buildCostCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalCost = _unitPrice != null ? _unitPrice! * widget.result.totalStock : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text('材料費の見積もり',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('素材1本あたりの単価:', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      suffixText: '円',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _unitPrice = double.tryParse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
            if (totalCost != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('合計金額', style: Theme.of(context).textTheme.titleSmall),
                    Text('¥${totalCost.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold, color: colorScheme.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.result.totalStock}本 x ¥${_unitPrice!.toStringAsFixed(0)} = ¥${totalCost.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _utilizationColor(ColorScheme colorScheme) {
    if (widget.result.utilizationRate >= 0.9) return Colors.green;
    if (widget.result.utilizationRate >= 0.7) return Colors.orange;
    return colorScheme.error;
  }

  /// エクスポート
  Future<void> _onExport(String format) async {
    if (_exporting) return;
    setState(() => _exporting = true);

    try {
      // 一時的な Project を作成
      final project = Project(
        id: widget.existingProject?.id ?? const Uuid().v4(),
        name: widget.existingProject?.name ?? '${widget.woodStock.name} カットプラン',
        woodStock: widget.woodStock,
        stockLength: widget.stockLength,
        pieces: widget.pieces,
        kerfWidth: widget.kerfWidth,
        result: widget.result,
        unitPrice: _unitPrice,
      );

      String filePath;
      switch (format) {
        case 'pdf':
          filePath = await ExportService.exportToPdf(project, unitPrice: _unitPrice);
          break;
        case 'csv':
          filePath = await ExportService.exportToCsv(project);
          break;
        case 'json':
          filePath = await ExportService.exportToJson(project);
          break;
        default:
          return;
      }

      await ExportService.shareFile(filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エクスポートに失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  /// プロジェクト保存
  Future<void> _onSave(BuildContext context, WidgetRef ref) async {
    if (widget.existingProject != null) {
      final updated = widget.existingProject!.copyWith(
        woodStock: widget.woodStock,
        stockLength: widget.stockLength,
        pieces: widget.pieces,
        kerfWidth: widget.kerfWidth,
        result: widget.result,
        unitPrice: _unitPrice,
        updatedAt: DateTime.now(),
      );
      await StorageService.saveProject(updated);
      ref.invalidate(projectsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('プロジェクトを更新しました')));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      return;
    }

    final name = await _showNameDialog(context);
    if (name == null || name.isEmpty) return;

    final project = Project(
      id: const Uuid().v4(),
      name: name,
      woodStock: widget.woodStock,
      stockLength: widget.stockLength,
      pieces: widget.pieces,
      kerfWidth: widget.kerfWidth,
      result: widget.result,
      unitPrice: _unitPrice,
    );

    await StorageService.saveProject(project);
    ref.invalidate(projectsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('「$name」を保存しました')));
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<String?> _showNameDialog(BuildContext context) async {
    final controller = TextEditingController(text: '${widget.woodStock.name} カットプラン');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('プロジェクト名'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: '名前', border: OutlineInputBorder(), hintText: '例: 本棚用カット'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('キャンセル')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('保存')),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}
