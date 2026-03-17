import 'package:flutter/material.dart';

import '../gen_l10n/app_localizations.dart';
import '../models/sheet_models.dart';
import '../widgets/sheet_cut_diagram.dart';

/// 2D カット結果画面
class SheetResultScreen extends StatelessWidget {
  final SheetCutResult result;
  final SheetStock sheetStock;

  const SheetResultScreen({
    super.key,
    required this.result,
    required this.sheetStock,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resultTitle2D),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(context),
          const SizedBox(height: 24),
          Text(
            l10n.cutLayout,
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
                        sheetWidth: sheetStock.width,
                        sheetHeight: sheetStock.height,
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
                    '${sheetStock.name} (${sheetStock.sizeLabel})',
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
                    '${result.totalSheets}枚',
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
                  '${result.totalWasteArea.toStringAsFixed(0)} mm²',
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
                  '${(result.utilizationRate * 100).toStringAsFixed(1)}%',
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
                value: result.utilizationRate,
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

  Color _utilizationColor(ColorScheme colorScheme) {
    if (result.utilizationRate >= 0.9) return Colors.green;
    if (result.utilizationRate >= 0.7) return Colors.orange;
    return colorScheme.error;
  }
}
