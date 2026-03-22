import 'dart:async';

import 'package:flutter/material.dart';

import '../gen_l10n/app_localizations.dart';
import '../models/cut_result.dart';
import '../models/wood_stock.dart';
import '../services/storage_service.dart';

/// カットチェックリスト画面
class ChecklistScreen extends StatefulWidget {
  final CutResult result;
  final WoodStock woodStock;
  final int stockLength;
  final String projectName;
  final String? projectId;

  const ChecklistScreen({
    super.key,
    required this.result,
    required this.woodStock,
    required this.stockLength,
    required this.projectName,
    this.projectId,
  });

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final Map<String, bool> _checkedItems = {};
  Timer? _saveDebounce;

  int get _resultHash =>
      widget.result.bins.length.hashCode ^
      widget.result.totalStock.hashCode ^
      widget.result.totalWaste.hashCode;

  int get _totalPieces {
    int count = 0;
    for (final bin in widget.result.bins) {
      count += bin.pieces.length;
    }
    return count;
  }

  int get _checkedCount => _checkedItems.values.where((v) => v).length;

  double get _progress {
    final total = _totalPieces;
    if (total == 0) return 0.0;
    return _checkedCount / total;
  }

  int _binCheckedCount(int binIndex) {
    final bin = widget.result.bins[binIndex];
    int count = 0;
    for (int i = 0; i < bin.pieces.length; i++) {
      if (_checkedItems['${binIndex}_$i'] == true) count++;
    }
    return count;
  }

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _saveChecklistNow();
    super.dispose();
  }

  void _loadChecklist() {
    if (widget.projectId == null) return;
    final saved = StorageService.loadChecklist(widget.projectId!, _resultHash);
    if (saved != null) {
      _checkedItems.addAll(saved);
    }
  }

  void _scheduleSave() {
    if (widget.projectId == null) return;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 300), _saveChecklistNow);
  }

  void _saveChecklistNow() {
    if (widget.projectId == null) return;
    // 全キーを初期化してから保存（未チェックの項目もfalseとして保存）
    final allChecks = <String, bool>{};
    for (int binIndex = 0; binIndex < widget.result.bins.length; binIndex++) {
      final bin = widget.result.bins[binIndex];
      for (int pieceIndex = 0; pieceIndex < bin.pieces.length; pieceIndex++) {
        final key = '${binIndex}_$pieceIndex';
        allChecks[key] = _checkedItems[key] ?? false;
      }
    }
    StorageService.saveChecklist(widget.projectId!, allChecks, _resultHash);
  }

  void _checkCompletion() {
    if (_checkedCount == _totalPieces && _totalPieces > 0) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.celebration, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.checklistComplete)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.checklistTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              avatar: Icon(
                Icons.check_circle_outline,
                size: 18,
                color: _checkedCount == _totalPieces && _totalPieces > 0
                    ? Colors.green
                    : colorScheme.onSurfaceVariant,
              ),
              label: Text(
                l10n.checklistProgress(_checkedCount, _totalPieces),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: _progress,
            minHeight: 4,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              _checkedCount == _totalPieces && _totalPieces > 0
                  ? Colors.green
                  : colorScheme.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(Icons.content_cut, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.projectName} - ${widget.woodStock.name} (${widget.stockLength}mm)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: widget.result.bins.length,
              itemBuilder: (context, binIndex) => _buildBinSection(context, binIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBinSection(BuildContext context, int binIndex) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final bin = widget.result.bins[binIndex];
    final binChecked = _binCheckedCount(binIndex);
    final binTotal = bin.pieces.length;
    final allChecked = binChecked == binTotal;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: allChecked
                          ? Colors.green.withValues(alpha: 0.15)
                          : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.stockNumber(binIndex + 1),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: allChecked ? Colors.green : colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '端材: ${bin.waste.toStringAsFixed(0)}mm',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '$binChecked/$binTotal',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: allChecked ? Colors.green : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...List.generate(bin.pieces.length, (pieceIndex) {
              final piece = bin.pieces[pieceIndex];
              final key = '${binIndex}_$pieceIndex';
              final isChecked = _checkedItems[key] ?? false;
              final seqPrefix = piece.sequenceOrder > 0
                  ? '${piece.sequenceOrder}. '
                  : '';
              final label = piece.label != null && piece.label!.isNotEmpty
                  ? '$seqPrefix${piece.label!}'
                  : '${seqPrefix}Piece ${pieceIndex + 1}';

              return CheckboxListTile(
                value: isChecked,
                onChanged: (value) {
                  setState(() {
                    _checkedItems[key] = value ?? false;
                  });
                  _scheduleSave();
                  _checkCompletion();
                },
                title: Text(
                  label,
                  style: TextStyle(
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                    color: isChecked ? colorScheme.onSurface.withValues(alpha: 0.4) : null,
                  ),
                ),
                subtitle: Text(
                  '${piece.length.toStringAsFixed(0)} mm',
                  style: TextStyle(
                    color: isChecked
                        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              );
            }),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
