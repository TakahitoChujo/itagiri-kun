import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/wood_presets.dart';
import '../models/sheet_models.dart';
import 'sheet_input_screen.dart';

/// 合板（シート材）選択画面
class SheetSelectScreen extends StatefulWidget {
  const SheetSelectScreen({super.key});

  @override
  State<SheetSelectScreen> createState() => _SheetSelectScreenState();
}

class _SheetSelectScreenState extends State<SheetSelectScreen> {
  SheetStock? _selectedSheet;
  bool _isCustom = false;
  String _customName = 'カスタム合板';
  double _customWidth = 910;
  double _customHeight = 1820;
  double _customThickness = 12;

  @override
  void initState() {
    super.initState();
    if (sheetPresets.isNotEmpty) {
      _selectedSheet = sheetPresets[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('合板を選択')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('合板を選択',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            // 合板プリセットリスト
            ...sheetPresets.map((sheet) {
              final isSelected = !_isCustom && _selectedSheet == sheet;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
                child: ListTile(
                  title: Text(sheet.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${sheet.sizeLabel} / 厚さ ${sheet.thickness}mm'),
                  trailing: sheet.price != null
                      ? Text('¥${sheet.price}', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600))
                      : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    setState(() {
                      _isCustom = false;
                      _selectedSheet = sheet;
                    });
                  },
                ),
              );
            }),

            // カスタム
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _isCustom ? colorScheme.primary : colorScheme.outlineVariant,
                  width: _isCustom ? 2.5 : 1,
                ),
              ),
              child: ListTile(
                leading: const Icon(Icons.add),
                title: const Text('カスタムサイズ'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () => _showCustomDialog(context),
              ),
            ),

            const SizedBox(height: 24),

            // 選択サマリー
            if (_currentSheet != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_currentSheet!.name,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          Text('${_currentSheet!.sizeLabel} / 厚さ ${_currentSheet!.thickness}mm',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _currentSheet != null ? _onNext : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('次へ'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  SheetStock? get _currentSheet {
    if (_isCustom) {
      if (_customWidth > 0 && _customHeight > 0 && _customThickness > 0) {
        return SheetStock(
          name: _customName.isNotEmpty ? _customName : 'カスタム',
          width: _customWidth,
          height: _customHeight,
          thickness: _customThickness,
        );
      }
      return null;
    }
    return _selectedSheet;
  }

  Future<void> _showCustomDialog(BuildContext context) async {
    final nameCtl = TextEditingController(text: _customName);
    final widthCtl = TextEditingController(text: _customWidth > 0 ? _customWidth.toStringAsFixed(0) : '');
    final heightCtl = TextEditingController(text: _customHeight > 0 ? _customHeight.toStringAsFixed(0) : '');
    final thickCtl = TextEditingController(text: _customThickness > 0 ? _customThickness.toStringAsFixed(0) : '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('カスタム合板'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtl, decoration: const InputDecoration(labelText: '名前', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: widthCtl, keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: '幅 (mm)', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: heightCtl, keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: '高さ (mm)', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: thickCtl, keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  decoration: const InputDecoration(labelText: '厚み (mm)', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          FilledButton(
            onPressed: () {
              final w = double.tryParse(widthCtl.text);
              final h = double.tryParse(heightCtl.text);
              final t = double.tryParse(thickCtl.text);
              if (w != null && w > 0 && h != null && h > 0 && t != null && t > 0) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('決定'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _isCustom = true;
        _selectedSheet = null;
        _customName = nameCtl.text.isNotEmpty ? nameCtl.text : 'カスタム';
        _customWidth = double.tryParse(widthCtl.text) ?? 0;
        _customHeight = double.tryParse(heightCtl.text) ?? 0;
        _customThickness = double.tryParse(thickCtl.text) ?? 0;
      });
    }

    nameCtl.dispose();
    widthCtl.dispose();
    heightCtl.dispose();
    thickCtl.dispose();
  }

  void _onNext() {
    final sheet = _currentSheet;
    if (sheet == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SheetInputScreen(sheetStock: sheet)),
    );
  }
}
