import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../gen_l10n/app_localizations.dart';
import '../services/unit_converter.dart';

/// 単位換算画面
class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  final TextEditingController _valueController =
      TextEditingController(text: '1000');
  LengthUnit _fromUnit = LengthUnit.mm;
  LengthUnit _toUnit = LengthUnit.cm;

  double get _inputValue => double.tryParse(_valueController.text) ?? 0;

  double get _convertedValue =>
      UnitConverter.convert(_inputValue, _fromUnit, _toUnit);

  Map<LengthUnit, double> get _allConversions =>
      UnitConverter.convertAll(_inputValue, _fromUnit);

  String _unitLabel(LengthUnit unit) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ja' ? unit.labelJa : unit.labelEn;
  }

  void _swapUnits() {
    setState(() {
      final tmp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = tmp;
    });
  }

  String _formatValue(double value) {
    if (value == 0) return '0';
    final s = value.toStringAsFixed(6);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.unitConverter)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _valueController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: InputDecoration(
                      labelText: l10n.length,
                      border: const OutlineInputBorder(),
                      suffixText: _fromUnit.symbol,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildUnitDropdown(
                          label: l10n.convertFrom,
                          value: _fromUnit,
                          onChanged: (unit) {
                            if (unit != null) setState(() => _fromUnit = unit);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: IconButton.filledTonal(
                          onPressed: _swapUnits,
                          icon: const Icon(Icons.swap_horiz),
                        ),
                      ),
                      Expanded(
                        child: _buildUnitDropdown(
                          label: l10n.convertTo,
                          value: _toUnit,
                          onChanged: (unit) {
                            if (unit != null) setState(() => _toUnit = unit);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(l10n.conversionResult,
                      style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer)),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${_formatValue(_convertedValue)} ${_toUnit.symbol}',
                      style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatValue(_inputValue)} ${_fromUnit.symbol}',
                    style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer
                            .withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.straighten, color: colorScheme.primary),
              const SizedBox(width: 12),
              Text(l10n.allUnits,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          ...LengthUnit.values.map((unit) {
            final value = _allConversions[unit] ?? 0;
            final isSource = unit == _fromUnit;
            return Card(
              elevation: isSource ? 0 : 1,
              color: isSource ? colorScheme.surfaceContainerHighest : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSource
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  foregroundColor: isSource
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                  child: Text(unit.symbol,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                title: Text(_formatValue(value),
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text(_unitLabel(unit)),
                trailing: isSource
                    ? Icon(Icons.arrow_back,
                        size: 16, color: colorScheme.primary)
                    : null,
              ),
            );
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildUnitDropdown({
    required String label,
    required LengthUnit value,
    required ValueChanged<LengthUnit?> onChanged,
  }) {
    return DropdownButtonFormField<LengthUnit>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      isExpanded: true,
      items: LengthUnit.values.map((unit) {
        return DropdownMenuItem<LengthUnit>(
          value: unit,
          child: Text('${_unitLabel(unit)} (${unit.symbol})',
              overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
