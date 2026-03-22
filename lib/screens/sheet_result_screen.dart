import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../gen_l10n/app_localizations.dart';
import '../models/sheet_models.dart';
import '../models/sheet_project.dart';
import '../providers/project_provider.dart';
import '../services/storage_service.dart';
import '../services/export_service.dart';
import '../widgets/sheet_cut_diagram.dart';
import '../widgets/ad_banner.dart';

/// 2D カット結果画面
class SheetResultScreen extends ConsumerStatefulWidget {
  final SheetCutResult result;
  final SheetStock sheetStock;
  final List<SheetPiece> pieces;
  final double kerfWidth;
  final SheetProject? existingProject;

  const SheetResultScreen({
    super.key,
    required this.result,
    required this.sheetStock,
    required this.pieces,
    required this.kerfWidth,
    this.existingProject,
  });

  @override
  ConsumerState<SheetResultScreen> createState() => _SheetResultScreenState();
}

class _SheetResultScreenState extends ConsumerState<SheetResultScreen> {
  final _priceController = TextEditingController();
  double? _unitPrice;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingProject?.unitPrice != null) {
      _unitPrice = widget.existingProject!.unitPrice;
      _priceController.text = _unitPrice!.toStringAsFixed(0);
    } else if (widget.sheetStock.price != null) {
      _unitPrice = widget.sheetStock.price!.toDouble();
      _priceController.text = widget.sheetStock.price.toString();
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
        title: Text(l10n.resultTitle2D),
        actions: [
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
          Text(
            l10n.cutLayout,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
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
                        child: Text(
                          l10n.sheetNumber(index + 1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.piecesWaste2D(bin.pieces.length, bin.wasteArea.toStringAsFixed(0)),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SheetCutDiagram(
                        bin: bin,
                        sheetWidth: widget.sheetStock.width,
                        sheetHeight: widget.sheetStock.height,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: bin.pieces.map((piece) {
                        final label = piece.label != null && piece.label!.isNotEmpty
                            ? '${piece.label}: ${piece.width.toStringAsFixed(0)}x${piece.height.toStringAsFixed(0)}mm'
                            : '${piece.width.toStringAsFixed(0)}x${piece.height.toStringAsFixed(0)}mm';
                        return Chip(
                          label: Text(label, style: const TextStyle(fontSize: 11)),
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
                Flexible(
                  child: Text(
                    '${widget.sheetStock.name} (${widget.sheetStock.sizeLabel})',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.sheetsCount(widget.result.totalSheets),
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
            Row(
              children: [
                Icon(Icons.delete_outline, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Text(l10n.totalWaste, style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text(
                  '${widget.result.totalWasteArea.toStringAsFixed(0)} mm\u00B2',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.pie_chart_outline, color: _utilizationColor(colorScheme)),
                const SizedBox(width: 12),
                Text(l10n.utilizationRate, style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text(
                  '${(widget.result.utilizationRate * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _utilizationColor(colorScheme),
                      ),
                ),
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
    final totalCost = _unitPrice != null ? _unitPrice! * widget.result.totalSheets : null;

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
                Text(l10n.unitPriceLabelSheet, style: Theme.of(context).textTheme.bodyMedium),
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
                l10n.costFormulaSheet(widget.result.totalSheets, _unitPrice!.toStringAsFixed(0), totalCost.toStringAsFixed(0)),
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

  Future<void> _onExport(String format) async {
    if (_exporting) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _exporting = true);

    try {
      final project = SheetProject(
        id: widget.existingProject?.id ?? const Uuid().v4(),
        name: widget.existingProject?.name ?? l10n.defaultSheetProjectName(widget.sheetStock.name),
        sheetStock: widget.sheetStock,
        pieces: widget.pieces,
        kerfWidth: widget.kerfWidth,
        result: widget.result,
        unitPrice: _unitPrice,
      );

      String filePath;
      switch (format) {
        case 'pdf':
          filePath = await ExportService.exportSheetToPdf(project, unitPrice: _unitPrice);
          break;
        case 'csv':
          filePath = await ExportService.exportSheetToCsv(project);
          break;
        case 'json':
          filePath = await ExportService.exportSheetToJson(project);
          break;
        default:
          return;
      }

      await ExportService.shareFile(filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _onSave(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    if (widget.existingProject != null) {
      final updated = widget.existingProject!.copyWith(
        sheetStock: widget.sheetStock,
        pieces: widget.pieces,
        kerfWidth: widget.kerfWidth,
        result: widget.result,
        unitPrice: _unitPrice,
        updatedAt: DateTime.now(),
      );
      await StorageService.saveSheetProject(updated);

      if (context.mounted) {
        ref.invalidate(sheetProjectsProvider);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.projectUpdated)));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      return;
    }

    final name = await _showNameDialog(context);
    if (name == null || name.isEmpty) return;

    final project = SheetProject(
      id: const Uuid().v4(),
      name: name,
      sheetStock: widget.sheetStock,
      pieces: widget.pieces,
      kerfWidth: widget.kerfWidth,
      result: widget.result,
      unitPrice: _unitPrice,
    );

    await StorageService.saveSheetProject(project);

    if (context.mounted) {
      ref.invalidate(sheetProjectsProvider);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.projectSaved(name))));
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<String?> _showNameDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final defaultName = l10n.defaultSheetProjectName(widget.sheetStock.name);
    String currentValue = defaultName;

    return showDialog<String>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.projectNameDialogTitle),
          content: TextFormField(
            initialValue: defaultName,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.materialName, border: const OutlineInputBorder(), hintText: l10n.projectNameHint),
            onChanged: (value) => currentValue = value,
            onFieldSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, null), child: Text(l10n.cancel)),
            FilledButton(onPressed: () => Navigator.pop(context, currentValue), child: Text(l10n.save)),
          ],
        );
      },
    );
  }
}
