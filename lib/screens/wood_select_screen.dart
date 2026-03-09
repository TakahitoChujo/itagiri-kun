import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/wood_presets.dart';
import '../models/wood_stock.dart';
import '../widgets/wood_preset_card.dart';
import 'pieces_input_screen.dart';

/// 木材選択画面
class WoodSelectScreen extends StatefulWidget {
  const WoodSelectScreen({super.key});

  @override
  State<WoodSelectScreen> createState() => _WoodSelectScreenState();
}

class _WoodSelectScreenState extends State<WoodSelectScreen> {
  WoodStock? _selectedWood;
  int? _selectedLength;
  bool _isCustom = false;
  String? _selectedCategory;

  String _customName = 'カスタム';
  double _customWidth = 0;
  double _customHeight = 0;
  int _customLength = 1820;

  @override
  void initState() {
    super.initState();
    if (woodPresets.isNotEmpty) {
      _selectedWood = woodPresets[0];
      _selectedLength = woodPresets[0].lengths.first;
    }
  }

  List<WoodStock> get _filteredPresets => woodPresetsForCategory(_selectedCategory);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('新規プロジェクト')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('素材を選択',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            // カテゴリフィルター
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('すべて'),
                      selected: _selectedCategory == null,
                      onSelected: (_) => setState(() => _selectedCategory = null),
                    ),
                  ),
                  ...woodCategories.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: _selectedCategory == cat,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 木材プリセットグリッド
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),
              itemCount: _filteredPresets.length + 1,
              itemBuilder: (context, index) {
                if (index == _filteredPresets.length) {
                  return _buildCustomCard(context);
                }
                final wood = _filteredPresets[index];
                final isSelected = !_isCustom && _selectedWood == wood;
                return WoodPresetCard(
                  woodStock: wood,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _isCustom = false;
                      _selectedWood = wood;
                      if (_selectedLength == null || !wood.lengths.contains(_selectedLength)) {
                        _selectedLength = wood.lengths.first;
                      }
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            Text('素材の長さ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            if (!_isCustom && _selectedWood != null) _buildLengthDropdown(context) else if (_isCustom) _buildCustomLengthInput(context),

            const SizedBox(height: 12),

            if (!_isCustom && _selectedWood != null) ...[
              Text('よく使う長さ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedWood!.lengths.map((length) {
                  final isSelected = _selectedLength == length;
                  final price = _selectedWood!.priceForLength(length);
                  return ChoiceChip(
                    label: Text(price != null ? '$length (¥$price)' : '$length'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedLength = length);
                    },
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 32),

            if (_currentWood != null && _currentLength != null) _buildSelectionSummary(context),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _canProceed ? _onNext : null,
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

  WoodStock? get _currentWood {
    if (_isCustom) {
      if (_customWidth > 0 && _customHeight > 0) {
        return WoodStock(name: _customName.isNotEmpty ? _customName : 'カスタム', width: _customWidth, height: _customHeight, lengths: [_customLength]);
      }
      return null;
    }
    return _selectedWood;
  }

  int? get _currentLength {
    if (_isCustom) return _customLength > 0 ? _customLength : null;
    return _selectedLength;
  }

  bool get _canProceed => _currentWood != null && _currentLength != null;

  Widget _buildCustomCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: _isCustom ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _isCustom ? colorScheme.primary : colorScheme.outlineVariant, width: _isCustom ? 2.5 : 1),
      ),
      color: _isCustom ? colorScheme.primaryContainer.withValues(alpha: 0.3) : colorScheme.surface,
      child: InkWell(
        onTap: () => _showCustomInputDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 28, color: _isCustom ? colorScheme.primary : colorScheme.onSurfaceVariant),
              const SizedBox(height: 4),
              Text('カスタム',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: _isCustom ? colorScheme.primary : colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLengthDropdown(BuildContext context) {
    return DropdownButtonFormField<int>(
      key: ValueKey(_selectedWood),
      value: _selectedLength,
      decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), suffixText: 'mm'),
      items: _selectedWood!.lengths.map((length) {
        final price = _selectedWood!.priceForLength(length);
        return DropdownMenuItem<int>(
          value: length,
          child: Text(price != null ? '$length mm (¥$price)' : '$length mm'),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) setState(() => _selectedLength = value);
      },
    );
  }

  Widget _buildCustomLengthInput(BuildContext context) {
    return TextFormField(
      initialValue: _customLength > 0 ? _customLength.toString() : '',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(labelText: '長さ', border: OutlineInputBorder(), suffixText: 'mm',
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      onChanged: (value) => setState(() => _customLength = int.tryParse(value) ?? 0),
    );
  }

  Widget _buildSelectionSummary(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final wood = _currentWood!;
    final length = _currentLength!;
    final price = wood.priceForLength(length);

    return Container(
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
                Text('${wood.name} (${wood.sectionLabel})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                Text(price != null ? '長さ: $length mm / 参考価格: ¥$price' : '長さ: $length mm',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomInputDialog(BuildContext context) async {
    final nameController = TextEditingController(text: _isCustom ? _customName : 'カスタム');
    final widthController = TextEditingController(text: _isCustom && _customWidth > 0 ? _customWidth.toStringAsFixed(0) : '');
    final heightController = TextEditingController(text: _isCustom && _customHeight > 0 ? _customHeight.toStringAsFixed(0) : '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('カスタム素材'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: '名前', border: OutlineInputBorder(), hintText: '例: カスタム材')),
              const SizedBox(height: 16),
              TextField(controller: widthController, keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: '厚み (mm)', border: OutlineInputBorder(), hintText: '例: 38')),
              const SizedBox(height: 16),
              TextField(controller: heightController, keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: '幅 (mm)', border: OutlineInputBorder(), hintText: '例: 89')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          FilledButton(
            onPressed: () {
              final w = double.tryParse(widthController.text);
              final h = double.tryParse(heightController.text);
              if (w != null && w > 0 && h != null && h > 0) Navigator.pop(context, true);
            },
            child: const Text('決定'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _isCustom = true;
        _selectedWood = null;
        _customName = nameController.text.isNotEmpty ? nameController.text : 'カスタム';
        _customWidth = double.tryParse(widthController.text) ?? 0;
        _customHeight = double.tryParse(heightController.text) ?? 0;
      });
    }

    nameController.dispose();
    widthController.dispose();
    heightController.dispose();
  }

  void _onNext() {
    final wood = _currentWood;
    final length = _currentLength;
    if (wood == null || length == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => PiecesInputScreen(woodStock: wood, stockLength: length)));
  }
}
