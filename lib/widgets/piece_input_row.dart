import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/cut_piece.dart';

/// 部材入力行ウィジェット
///
/// 長さ・数量・ラベルの入力フィールドと削除ボタンを1行に表示する。
class PieceInputRow extends StatelessWidget {
  final int index;
  final CutPiece piece;
  final ValueChanged<CutPiece> onChanged;
  final VoidCallback onDelete;
  final bool canDelete;

  const PieceInputRow({
    super.key,
    required this.index,
    required this.piece,
    required this.onChanged,
    required this.onDelete,
    this.canDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 長さ入力
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue:
                  piece.length > 0 ? piece.length.toStringAsFixed(0) : '',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: '長さ(mm)',
                hintText: '例: 500',
                isDense: true,
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                errorStyle: TextStyle(
                  fontSize: 10,
                  color: colorScheme.error,
                ),
              ),
              onChanged: (value) {
                final length = double.tryParse(value) ?? 0;
                onChanged(piece.copyWith(length: length));
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '入力してください';
                }
                final length = double.tryParse(value);
                if (length == null || length <= 0) {
                  return '正の値を入力';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          // 数量入力
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: piece.quantity > 0 ? piece.quantity.toString() : '',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: '数量',
                hintText: '例: 2',
                isDense: true,
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                errorStyle: TextStyle(
                  fontSize: 10,
                  color: colorScheme.error,
                ),
              ),
              onChanged: (value) {
                final quantity = int.tryParse(value) ?? 0;
                onChanged(piece.copyWith(quantity: quantity));
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '入力してください';
                }
                final qty = int.tryParse(value);
                if (qty == null || qty <= 0) {
                  return '1以上';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 4),
          // 削除ボタン
          SizedBox(
            width: 40,
            height: 48,
            child: IconButton(
              onPressed: canDelete ? onDelete : null,
              icon: Icon(
                Icons.close,
                color: canDelete
                    ? colorScheme.error
                    : colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              tooltip: '削除',
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
