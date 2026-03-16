import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/responsive.dart';
import '../data/wood_presets.dart';
import '../gen_l10n/app_localizations.dart';
import '../models/offcut.dart';
import '../models/wood_stock.dart';
import '../services/storage_service.dart';
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
  Set<int> _selectedLengths = {};
  bool _isCustom = false;
  String? _selectedCategory;

  String _customName = 'カスタム';
  double _customWidth = 0;
  double _customHeight = 0;
  int _customLength = 1820;

  /// 選択された端材リスト（長さを整数で保持）
  List<Offcut> _availableOffcuts = [];
  Set<String> _selectedOffcutIds = {};

  @override
  void initState() {
    super.initState();
    if (woodPresets.isNotEmpty) {
      _selectedWood = woodPresets[0];
      _selectedLengths = {woodPresets[0].lengths.first};
      _loadOffcuts();
    }
  }

  void _loadOffcuts() {
    final wood = _currentWood;
    if (wood == null) return;
    setState(() {
      _availableOffcuts = StorageService.loadOffcutsForWood(wood.name);
      _selectedOffcutIds = {};
    });
  }

  List<WoodStock> get _filteredPresets => woodPresetsForCategory(_selectedCategory);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newProject)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.selectMaterial,
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
                      label: Text(l10n.allCategories),
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: context.gridColumnCount,
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
                      // 木材変更時は選択長さをリセット（最初の長さを選択）
                      _selectedLengths = {wood.lengths.first};
                      _selectedOffcutIds = {};
                    });
                    _loadOffcuts();
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Text(l10n.length,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                if (!_isCustom && _selectedWood != null && _selectedWood!.lengths.length > 1)
                  Expanded(
                    child: Text(
                      l10n.multipleStockLengths,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (!_isCustom && _selectedWood != null)
              _buildLengthMultiSelect(context)
            else if (_isCustom)
              _buildCustomLengthInput(context),

            if (!_isCustom && _availableOffcuts.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildOffcutSection(context),
            ],

            const SizedBox(height: 32),

            if (_currentWood != null && _selectedLengths.isNotEmpty) _buildSelectionSummary(context),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _canProceed ? _onNext : null,
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.onboardingNext),
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

  bool get _canProceed {
    if (_isCustom) return _customWidth > 0 && _customHeight > 0 && _customLength > 0;
    return _selectedWood != null && _selectedLengths.isNotEmpty;
  }

  /// マルチセレクト対応の長さ選択UI
  Widget _buildLengthMultiSelect(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _selectedWood!.lengths.map((length) {
        final isSelected = _selectedLengths.contains(length);
        final price = _selectedWood!.priceForLength(length);
        return FilterChip(
          label: Text(price != null ? '$length (¥$price)' : '$length mm'),
          selected: isSelected,
          checkmarkColor: colorScheme.onPrimary,
          selectedColor: colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedLengths.add(length);
              } else {
                // 最低1つは選択を維持
                if (_selectedLengths.length > 1) {
                  _selectedLengths.remove(length);
                }
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildOffcutSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.recycling, size: 16, color: colorScheme.tertiary),
            const SizedBox(width: 6),
            Text(
              l10n.savedOffcuts,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.tertiary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _availableOffcuts.map((offcut) {
            final isSelected = _selectedOffcutIds.contains(offcut.id);
            return FilterChip(
              avatar: Icon(Icons.recycling,
                  size: 14,
                  color: isSelected ? colorScheme.onTertiary : colorScheme.tertiary),
              label: Text(l10n.offcutLength(offcut.length.toStringAsFixed(0))),
              selected: isSelected,
              checkmarkColor: colorScheme.onTertiary,
              selectedColor: colorScheme.tertiary,
              labelStyle: TextStyle(
                color: isSelected ? colorScheme.onTertiary : colorScheme.onSurface,
                fontSize: 12,
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedOffcutIds.add(offcut.id);
                  } else {
                    _selectedOffcutIds.remove(offcut.id);
                  }
                });
              },
              onDeleted: () async {
                await StorageService.deleteOffcut(offcut.id);
                _loadOffcuts();
              },
              deleteIcon: const Icon(Icons.close, size: 14),
              deleteIconColor: colorScheme.onSurfaceVariant,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
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
              Text(l10n.custom,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: _isCustom ? colorScheme.primary : colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomLengthInput(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      initialValue: _customLength > 0 ? _customLength.toString() : '',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: l10n.length, border: const OutlineInputBorder(), suffixText: 'mm',
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      onChanged: (value) => setState(() => _customLength = int.tryParse(value) ?? 0),
    );
  }

  Widget _buildSelectionSummary(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final wood = _currentWood!;
    final sortedLengths = _selectedLengths.toList()..sort();

    String lengthText;
    if (_isCustom) {
      lengthText = l10n.selectionSummaryLength(_customLength);
    } else if (sortedLengths.length == 1) {
      final price = wood.priceForLength(sortedLengths.first);
      lengthText = price != null
          ? l10n.selectionSummaryWithPrice(sortedLengths.first, price)
          : l10n.selectionSummaryLength(sortedLengths.first);
    } else {
      lengthText = l10n.stockLengthSummary(sortedLengths.length) +
          ': ' +
          sortedLengths.map((l) => '${l}mm').join(' + ');
    }

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
                Text(lengthText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomInputDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: _isCustom ? _customName : l10n.custom);
    final widthController = TextEditingController(text: _isCustom && _customWidth > 0 ? _customWidth.toStringAsFixed(0) : '');
    final heightController = TextEditingController(text: _isCustom && _customHeight > 0 ? _customHeight.toStringAsFixed(0) : '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.customSettings),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.materialName, border: const OutlineInputBorder(), hintText: 'e.g. カスタム材')),
                const SizedBox(height: 16),
                TextField(controller: widthController, keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(labelText: '${l10n.thickness} (mm)', border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: heightController, keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(labelText: '${l10n.width} (mm)', border: const OutlineInputBorder(), hintText: '例: 89')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () {
                final w = double.tryParse(widthController.text);
                final h = double.tryParse(heightController.text);
                if (w != null && w > 0 && h != null && h > 0) Navigator.pop(context, true);
              },
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(() {
        _isCustom = true;
        _selectedWood = null;
        _selectedLengths = {_customLength};
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
    if (wood == null || _selectedLengths.isEmpty) return;
    final sortedLengths = _selectedLengths.toList()..sort();

    // 選択された端材の長さを追加（整数化）
    final offcutLengths = _availableOffcuts
        .where((o) => _selectedOffcutIds.contains(o.id))
        .map((o) => o.length.round())
        .toList();

    final allLengths = [...sortedLengths, ...offcutLengths]..sort();
    final uniqueLengths = allLengths.toSet().toList()..sort();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PiecesInputScreen(
          woodStock: wood,
          stockLength: uniqueLengths.first,
          stockLengths: uniqueLengths.length > 1 ? uniqueLengths : null,
        ),
      ),
    );
  }
}
