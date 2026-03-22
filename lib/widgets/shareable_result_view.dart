import 'package:flutter/material.dart';

import '../gen_l10n/app_localizations.dart';
import '../models/cut_result.dart';
import '../models/wood_stock.dart';
import 'cut_diagram.dart';

/// 共有用結果ビュー
///
/// 結果を画像として共有するための固定幅ウィジェット。
/// 360px幅 x 3倍解像度 = 1080px幅の画像を生成する。
class ShareableResultView extends StatelessWidget {
  final CutResult result;
  final WoodStock woodStock;
  final int stockLength;
  final List<int>? stockLengths;
  final double kerfWidth;
  final String projectName;
  final AppLocalizations l10n;

  const ShareableResultView({
    super.key,
    required this.result,
    required this.woodStock,
    required this.stockLength,
    this.stockLengths,
    required this.kerfWidth,
    required this.projectName,
    required this.l10n,
  });

  String get _stockLabel {
    final lengths = stockLengths;
    if (lengths == null || lengths.length <= 1) {
      return '${woodStock.name} (${stockLength}mm)';
    }
    final sorted = lengths.toList()..sort();
    return '${woodStock.name} (${sorted.map((l) => '${l}mm').join('/')})';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.light(useMaterial3: true);
    final cs = theme.colorScheme;

    return Theme(
      data: theme,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          width: 360,
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.carpenter, size: 20, color: cs.onPrimaryContainer),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(projectName,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface)),
                        Text(_stockLabel,
                            style:
                                TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Summary ──
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _stat(l10n.purchase,
                                '${result.newStockCount}', cs.primary)),
                        Container(
                            width: 1, height: 32, color: cs.outlineVariant),
                        Expanded(
                            child: _stat(
                                l10n.totalWaste,
                                '${result.totalWaste.toStringAsFixed(0)}mm',
                                cs.error)),
                        Container(
                            width: 1, height: 32, color: cs.outlineVariant),
                        Expanded(
                            child: _stat(
                                l10n.utilizationRate,
                                '${(result.utilizationRate * 100).toStringAsFixed(1)}%',
                                _utilizationColor())),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: result.utilizationRate,
                        minHeight: 6,
                        backgroundColor: cs.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            _utilizationColor()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Cut Layout ──
              Text(l10n.cutLayout,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface)),
              const SizedBox(height: 8),

              ...List.generate(result.bins.length, (index) {
                final bin = result.bins[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: bin.isFromOffcut
                                  ? cs.tertiaryContainer
                                  : cs.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (bin.isFromOffcut) ...[
                                  Icon(Icons.recycling,
                                      size: 11,
                                      color: cs.onTertiaryContainer),
                                  const SizedBox(width: 3),
                                ],
                                Text(l10n.stockNumber(index + 1),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: bin.isFromOffcut
                                          ? cs.onTertiaryContainer
                                          : cs.onPrimaryContainer,
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.piecesWaste1D(bin.pieces.length,
                                  bin.waste.toStringAsFixed(0)),
                              style: TextStyle(
                                  fontSize: 11, color: cs.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: CutDiagram(
                          bin: bin,
                          stockLength: bin.stockLength,
                          kerfWidth: kerfWidth,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // ── Footer ──
              const SizedBox(height: 8),
              Divider(color: cs.outlineVariant),
              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.carpenter,
                        size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(l10n.appName,
                        style: TextStyle(
                            fontSize: 11, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            textAlign: TextAlign.center),
      ],
    );
  }

  Color _utilizationColor() {
    if (result.utilizationRate >= 0.9) return Colors.green;
    if (result.utilizationRate >= 0.7) return Colors.orange;
    return Colors.red;
  }
}
