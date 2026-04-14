import 'package:flutter/material.dart';

import '../gen_l10n/app_localizations.dart';
import '../services/cut_optimizer.dart';

/// 最適化戦略の比較結果画面
class CompareResultsScreen extends StatelessWidget {
  final List<ComparisonResult> results;

  const CompareResultsScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.comparisonResults)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildStrategyCard(context, results[index], index == 0);
        },
      ),
    );
  }

  Widget _buildStrategyCard(
      BuildContext context, ComparisonResult comparison, bool isBest) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final result = comparison.result;

    return Card(
      elevation: isBest ? 3 : 1,
      shape: isBest
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colorScheme.primary, width: 2),
            )
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(_strategyName(l10n, comparison.strategy),
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                if (isBest)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(l10n.bestResult,
                        style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildStatRow(context,
                icon: Icons.shopping_cart_outlined,
                label: l10n.stocksUsed,
                value: '${result.totalStock}'),
            const SizedBox(height: 8),
            _buildStatRow(context,
                icon: Icons.delete_outline,
                label: l10n.wasteAmount,
                value: '${result.totalWaste.toStringAsFixed(0)} mm'),
            const SizedBox(height: 8),
            _buildStatRow(context,
                icon: Icons.pie_chart_outline,
                label: l10n.utilizationRate,
                value:
                    '${(result.utilizationRate * 100).toStringAsFixed(1)}%',
                valueColor:
                    _utilizationColor(result.utilizationRate, colorScheme)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: result.utilizationRate,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                    _utilizationColor(result.utilizationRate, colorScheme)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: isBest
                  ? FilledButton.icon(
                      onPressed: () => Navigator.pop(context, result),
                      icon: const Icon(Icons.check),
                      label: Text(l10n.useThisLayout),
                    )
                  : OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context, result),
                      icon: const Icon(Icons.check),
                      label: Text(l10n.useThisLayout),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context,
      {required IconData icon,
      required String label,
      required String value,
      Color? valueColor}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant))),
        Text(value,
            style: textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600, color: valueColor)),
      ],
    );
  }

  String _strategyName(AppLocalizations l10n, CutStrategy strategy) {
    switch (strategy) {
      case CutStrategy.ffd:
        return l10n.strategyFFD;
      case CutStrategy.bfd:
        return l10n.strategyBFD;
      case CutStrategy.ff:
        return l10n.strategyFF;
    }
  }

  Color _utilizationColor(double rate, ColorScheme colorScheme) {
    if (rate >= 0.9) return Colors.green;
    if (rate >= 0.7) return Colors.orange;
    return colorScheme.error;
  }
}
