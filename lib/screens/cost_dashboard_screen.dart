import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../gen_l10n/app_localizations.dart';
import '../models/project.dart';
import '../models/sheet_project.dart';
import '../services/storage_service.dart';

/// コスト分析ダッシュボード画面
class CostDashboardScreen extends StatefulWidget {
  const CostDashboardScreen({super.key});

  @override
  State<CostDashboardScreen> createState() => _CostDashboardScreenState();
}

class _CostDashboardScreenState extends State<CostDashboardScreen> {
  List<Project> _projects = [];
  List<SheetProject> _sheetProjects = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _projects = StorageService.loadProjects();
      _sheetProjects = StorageService.loadSheetProjects();
    });
  }

  List<_ProjectSummary> get _allSummaries {
    final summaries = <_ProjectSummary>[];
    for (final p in _projects) {
      if (p.result != null) {
        summaries.add(_ProjectSummary(
          name: p.name,
          utilization: p.result!.utilizationRate,
          cost: p.totalCost,
          updatedAt: p.updatedAt,
        ));
      }
    }
    for (final sp in _sheetProjects) {
      if (sp.result != null) {
        summaries.add(_ProjectSummary(
          name: sp.name,
          utilization: sp.result!.utilizationRate,
          cost: sp.totalCost,
          updatedAt: sp.updatedAt,
        ));
      }
    }
    summaries.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    return summaries;
  }

  double get _totalCost =>
      _allSummaries.fold(0.0, (sum, s) => sum + (s.cost ?? 0));

  double get _averageUtilization {
    final list = _allSummaries;
    if (list.isEmpty) return 0;
    return list.fold(0.0, (sum, s) => sum + s.utilization) / list.length;
  }

  int get _totalProjectCount => _projects.length + _sheetProjects.length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.costDashboard)),
      body: _allSummaries.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart_rounded, size: 80,
                      color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(l10n.noDataForChart,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryCards(l10n, colorScheme),
                  const SizedBox(height: 24),
                  _buildUtilizationChart(l10n, colorScheme),
                  const SizedBox(height: 24),
                  _buildCostChart(l10n, colorScheme),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards(AppLocalizations l10n, ColorScheme colorScheme) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _SummaryCard(
          label: l10n.totalSpent,
          value: '¥${_totalCost.toStringAsFixed(0)}',
          icon: Icons.payments_outlined,
          color: colorScheme.primary,
          backgroundColor: colorScheme.primaryContainer,
        ),
        _SummaryCard(
          label: l10n.averageUtilization,
          value: '${(_averageUtilization * 100).toStringAsFixed(1)}%',
          icon: Icons.donut_large_rounded,
          color: colorScheme.tertiary,
          backgroundColor: colorScheme.tertiaryContainer,
        ),
        _SummaryCard(
          label: l10n.totalProjects,
          value: '$_totalProjectCount',
          icon: Icons.folder_outlined,
          color: colorScheme.secondary,
          backgroundColor: colorScheme.secondaryContainer,
        ),
      ],
    );
  }

  Widget _buildUtilizationChart(AppLocalizations l10n, ColorScheme colorScheme) {
    final data = _allSummaries.length > 10
        ? _allSummaries.sublist(_allSummaries.length - 10)
        : _allSummaries;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up_rounded, size: 20,
                    color: colorScheme.tertiary),
                const SizedBox(width: 8),
                Text(l10n.averageUtilization,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${data[group.x].name}\n${rod.toY.toStringAsFixed(1)}%',
                          TextStyle(
                            color: colorScheme.onInverseSurface,
                            fontWeight: FontWeight.w600, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true, reservedSize: 40, interval: 25,
                        getTitlesWidget: (value, meta) => Text('${value.toInt()}%',
                            style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true, reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                          return SideTitleWidget(
                            meta: meta,
                            child: Transform.rotate(angle: -0.5,
                              child: Text(_truncate(data[idx].name, 5),
                                  style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant))),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true, drawVerticalLine: false, horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5), strokeWidth: 1),
                  ),
                  barGroups: List.generate(data.length, (i) {
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: data[i].utilization * 100,
                        width: max(8, 200 / data.length),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter, end: Alignment.topCenter,
                          colors: [colorScheme.tertiary.withValues(alpha: 0.6), colorScheme.tertiary],
                        ),
                      ),
                    ]);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostChart(AppLocalizations l10n, ColorScheme colorScheme) {
    final costData = _allSummaries.where((s) => s.cost != null && s.cost! > 0).toList();
    if (costData.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(children: [
                Icon(Icons.payments_outlined, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(l10n.totalSpent, style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 32),
              Icon(Icons.bar_chart_rounded, size: 48, color: colorScheme.outline),
              const SizedBox(height: 8),
              Text(l10n.noDataForChart, style: TextStyle(color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    final data = costData.length > 10 ? costData.sublist(costData.length - 10) : costData;
    final maxCost = data.fold(0.0, (double m, s) => s.cost! > m ? s.cost! : m);
    final maxY = _ceilToNice(maxCost);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.payments_outlined, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(l10n.totalSpent, style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY, minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${data[group.x].name}\n¥${rod.toY.toStringAsFixed(0)}',
                          TextStyle(color: colorScheme.onInverseSurface,
                              fontWeight: FontWeight.w600, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true, reservedSize: 48,
                        interval: maxY > 0 ? maxY / 4 : 1,
                        getTitlesWidget: (value, meta) => Text('¥${value.toInt()}',
                            style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true, reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                          return SideTitleWidget(
                            meta: meta,
                            child: Transform.rotate(angle: -0.5,
                              child: Text(_truncate(data[idx].name, 5),
                                  style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant))),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true, drawVerticalLine: false,
                    horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5), strokeWidth: 1),
                  ),
                  barGroups: List.generate(data.length, (i) {
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: data[i].cost!,
                        width: max(8, 200 / data.length),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter, end: Alignment.topCenter,
                          colors: [colorScheme.primary.withValues(alpha: 0.6), colorScheme.primary],
                        ),
                      ),
                    ]);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncate(String text, int maxLen) {
    if (text.length <= maxLen) return text;
    return '${text.substring(0, maxLen)}...';
  }

  double _ceilToNice(double value) {
    if (value <= 0) return 100;
    final magnitude = pow(10, (log(value) / ln10).floor()).toDouble();
    final normalized = value / magnitude;
    if (normalized <= 1) return magnitude;
    if (normalized <= 2) return 2 * magnitude;
    if (normalized <= 5) return 5 * magnitude;
    return 10 * magnitude;
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _SummaryCard({
    required this.label, required this.value, required this.icon,
    required this.color, required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        elevation: 0, color: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 10),
              Text(value, style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: color.withValues(alpha: 0.8))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectSummary {
  final String name;
  final double utilization;
  final double? cost;
  final DateTime updatedAt;

  const _ProjectSummary({
    required this.name, required this.utilization,
    this.cost, required this.updatedAt,
  });
}
