import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../gen_l10n/app_localizations.dart';
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
  final List<int>? stockLengths;
  final List<CutPiece> pieces;
  final double kerfWidth;
  final Project? existingProject;

  const ResultScreen({
    super.key,
    required this.result,
    required this.woodStock,
    required this.stockLength,
    this.stockLengths,
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resultTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist),
            tooltip: l10n.checklistTooltip,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChecklistScreen(
                    result: widget.result,
                    woodStock: widget.woodStock,
                    stockLength: widget.stockLength,
                    projectName: widget.existingProject?.name ?? l10n.defaultProjectName(widget.woodStock.name),
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.share),
            tooltip: l10n.exportTooltip,
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
          Text(l10n.cutLayout,
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
                        child: Text(l10n.stockNumber(index + 1),
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.onPrimaryContainer)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(l10n.piecesWaste1D(bin.pieces.length, bin.waste.toStringAsFixed(0)),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                      ),
                      if (bin.waste >= 50)
                        TextButton.icon(
                          onPressed: () => _onSaveOffcut(context, bin.waste),
                          icon: const Icon(Icons.save_alt, size: 14),
                          label: Text(l10n.saveOffcut, style: const TextStyle(fontSize: 11)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
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
              label: Text(l10n.saveProject),
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
    final l10n = AppLocalizations.of(context);
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
                Text(l10n.purchase, style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text(_stockLengthLabel,
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
                Text(l10n.totalWaste, style: Theme.of(context).textTheme.titleSmall),
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
                Text(l10n.utilizationRate, style: Theme.of(context).textTheme.titleSmall),
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

  Widget _buildCostCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
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
                Text(l10n.costEstimate,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(l10n.unitPriceLabel, style: Theme.of(context).textTheme.bodyMedium),
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
                    Text(l10n.totalCostLabel, style: Theme.of(context).textTheme.titleSmall),
                    Text('¥${totalCost.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold, color: colorScheme.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.costFormula(widget.result.totalStock, _unitPrice!.toStringAsFixed(0), totalCost.toStringAsFixed(0)),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// AppBar・サマリーカード用の長さラベル
  String get _stockLengthLabel {
    final lengths = widget.stockLengths;
    if (lengths == null || lengths.length <= 1) {
      return '${widget.woodStock.name} (${widget.stockLength}mm)';
    }
    final sorted = lengths.toList()..sort();
    return '${widget.woodStock.name} (${sorted.map((l) => '${l}mm').join('/')})';
  }

  Color _utilizationColor(ColorScheme colorScheme) {
    if (widget.result.utilizationRate >= 0.9) return Colors.green;
    if (widget.result.utilizationRate >= 0.7) return Colors.orange;
    return colorScheme.error;
  }

  Future<void> _onExport(String format) async {
    if (_exporting) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _exporting = true);

    try {
      final project = Project(
        id: widget.existingProject?.id ?? const Uuid().v4(),
        name: widget.existingProject?.name ?? l10n.defaultProjectName(widget.woodStock.name),
        woodStock: widget.woodStock,
        stockLength: widget.stockLength,
        stockLengths: widget.stockLengths,
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
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _onSaveOffcut(BuildContext context, double wasteLength) async {
    final l10n = AppLocalizations.of(context);
    await StorageService.saveOffcut(
      woodStockName: widget.woodStock.name,
      length: wasteLength,
      sourceProjectId: widget.existingProject?.id,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.offcutSaved(wasteLength.toStringAsFixed(0)))),
      );
    }
  }

  Future<void> _onSave(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    if (widget.existingProject != null) {
      final updated = widget.existingProject!.copyWith(
        woodStock: widget.woodStock,
        stockLength: widget.stockLength,
        stockLengths: widget.stockLengths,
        pieces: widget.pieces,
        kerfWidth: widget.kerfWidth,
        result: widget.result,
        unitPrice: _unitPrice,
        updatedAt: DateTime.now(),
      );
      await StorageService.saveProject(updated);
      ref.invalidate(projectsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.projectUpdated)));
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
      stockLengths: widget.stockLengths,
      pieces: widget.pieces,
      kerfWidth: widget.kerfWidth,
      result: widget.result,
      unitPrice: _unitPrice,
    );

    await StorageService.saveProject(project);
    ref.invalidate(projectsProvider);

    if (context.mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.projectSaved(name))));
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<String?> _showNameDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: l10n.defaultProjectName(widget.woodStock.name));
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.projectNameDialogTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.materialName, border: const OutlineInputBorder(), hintText: l10n.projectNameHint),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, null), child: Text(l10n.cancel)),
            FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: Text(l10n.save)),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }
}
