import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../gen_l10n/app_localizations.dart';
import '../models/wood_stock.dart';
import '../models/cut_piece.dart';
import '../models/offcut.dart';
import '../models/project.dart';
import '../providers/settings_provider.dart';
import '../services/cut_optimizer.dart';
import '../utils/undo_redo_stack.dart';
import '../widgets/piece_input_row.dart';
import 'result_screen.dart';

/// 必要部材入力画面
class PiecesInputScreen extends ConsumerStatefulWidget {
  final WoodStock woodStock;
  final int stockLength;
  final List<int>? stockLengths;
  final List<Offcut>? offcuts;
  final List<CutPiece>? templatePieces;
  final Project? existingProject;

  const PiecesInputScreen({
    super.key,
    required this.woodStock,
    required this.stockLength,
    this.stockLengths,
    this.offcuts,
    this.templatePieces,
    this.existingProject,
  });

  @override
  ConsumerState<PiecesInputScreen> createState() => _PiecesInputScreenState();
}

class _PiecesInputScreenState extends ConsumerState<PiecesInputScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<CutPiece> _pieces;
  late UndoRedoStack<List<CutPiece>> _history;

  /// 実効素材長リスト
  List<int> get _effectiveLengths =>
      widget.stockLengths ??
      widget.existingProject?.stockLengths ??
      [widget.stockLength];

  int get _maxStockLength =>
      _effectiveLengths.reduce((a, b) => a > b ? a : b);

  @override
  void initState() {
    super.initState();
    if (widget.existingProject != null &&
        widget.existingProject!.pieces.isNotEmpty) {
      _pieces = List.from(widget.existingProject!.pieces);
    } else if (widget.templatePieces != null &&
        widget.templatePieces!.isNotEmpty) {
      _pieces = List.from(widget.templatePieces!);
    } else {
      _pieces = [const CutPiece(length: 0, quantity: 1)];
    }
    _history = UndoRedoStack(List<CutPiece>.from(_pieces));
  }

  void _pushHistory() {
    _history.push(List<CutPiece>.from(_pieces));
  }

  void _onUndo() {
    if (!_history.canUndo) return;
    setState(() {
      _pieces = List<CutPiece>.from(_history.undo());
    });
  }

  void _onRedo() {
    if (!_history.canRedo) return;
    setState(() {
      _pieces = List<CutPiece>.from(_history.redo());
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context);
    final lengths = _effectiveLengths..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingProject != null
            ? widget.existingProject!.name
            : l10n.enterPieces),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: l10n.undo,
            onPressed: _history.canUndo ? _onUndo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: l10n.redo,
            onPressed: _history.canRedo ? _onRedo : null,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar: const Icon(Icons.straighten, size: 16),
              label: Text(
                lengths.length == 1
                    ? '${widget.woodStock.name} ${lengths.first}mm'
                    : '${widget.woodStock.name} ${lengths.map((l) => '${l}mm').join('+')}',
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    l10n.sizesToCut,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.kerfWidthLabel(settings.kerfWidth.toStringAsFixed(1)),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            l10n.columnLength,
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
                            l10n.columnQuantity,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(width: 44),
                      ],
                    ),
                  ),

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
                      onEditingComplete: () {
                        _pushHistory();
                      },
                      onDelete: () {
                        setState(() {
                          _pieces.removeAt(index);
                        });
                        _pushHistory();
                      },
                    );
                  }),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: _addPiece,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addSize),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
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
                    label: Text(l10n.calculate),
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

  void _addPiece() {
    setState(() {
      _pieces.add(const CutPiece(length: 0, quantity: 1));
    });
    _pushHistory();
  }

  void _onCalculate() {
    final l10n = AppLocalizations.of(context);
    final validPieces = <CutPiece>[];
    final errors = <String>[];

    for (var i = 0; i < _pieces.length; i++) {
      final piece = _pieces[i];

      if (piece.length <= 0) {
        errors.add(l10n.errorLengthRequired(i + 1));
        continue;
      }
      if (piece.quantity <= 0) {
        errors.add(l10n.errorQuantityRequired(i + 1));
        continue;
      }
      if (piece.length > _maxStockLength) {
        errors.add(l10n.errorLengthExceeds(
            i + 1,
            piece.length.toStringAsFixed(0),
            _maxStockLength.toString()));
        continue;
      }
      validPieces.add(piece);
    }

    if (errors.isNotEmpty) {
      _showErrorDialog(errors);
      return;
    }

    if (validPieces.isEmpty) {
      _showErrorDialog([l10n.errorNoPieces]);
      return;
    }

    final settings = ref.read(settingsProvider);
    final effectiveLengths = _effectiveLengths;
    try {
      final result = CutOptimizer.optimize(
        stockLength: effectiveLengths.first.toDouble(),
        stockLengths: effectiveLengths.length > 1
            ? effectiveLengths.map((l) => l.toDouble()).toList()
            : null,
        kerfWidth: settings.kerfWidth,
        pieces: validPieces,
        offcuts: widget.offcuts,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            woodStock: widget.woodStock,
            stockLength: effectiveLengths.first,
            stockLengths: effectiveLengths.length > 1 ? effectiveLengths : null,
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

  void _showErrorDialog(List<String> errors) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.inputError),
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
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
