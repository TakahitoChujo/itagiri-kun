import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import '../widgets/premium_banner.dart';

/// 設定画面
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _kerfController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _kerfController =
        TextEditingController(text: settings.kerfWidth.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _kerfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 鋸刃の幅セクション
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.content_cut, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        '鋸刃の幅（カーフ）',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'カットごとに失われる木材の幅です。\n一般的な鋸刃は約3mmです。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _kerfController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')),
                          ],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            suffixText: 'mm',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null && parsed >= 0 && parsed <= 10) {
                              notifier.setKerfWidth(parsed);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // よく使う値のクイック選択
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [0.0, 2.0, 3.0, 4.0].map((value) {
                            final isSelected =
                                (settings.kerfWidth - value).abs() < 0.01;
                            return ChoiceChip(
                              label: Text('${value.toStringAsFixed(0)}mm'),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  notifier.setKerfWidth(value);
                                  _kerfController.text =
                                      value.toStringAsFixed(1);
                                }
                              },
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 単位系セクション
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.straighten, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        '単位系',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<MeasurementUnit>(
                    value: MeasurementUnit.mm,
                    groupValue: settings.unit,
                    onChanged: (value) {
                      if (value != null) {
                        notifier.setUnit(value);
                      }
                    },
                    title: const Text('ミリメートル (mm)'),
                    subtitle: const Text('推奨'),
                    dense: true,
                  ),
                  RadioListTile<MeasurementUnit>(
                    value: MeasurementUnit.cm,
                    groupValue: settings.unit,
                    onChanged: null, // v1.0ではmmのみ
                    title: Text(
                      'センチメートル (cm)',
                      style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.4)),
                    ),
                    subtitle: Text(
                      'v1.1で対応予定',
                      style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.3)),
                    ),
                    dense: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // プレミアム導線バナー（プレミアムユーザーには非表示）
          const PremiumBanner(),
          const SizedBox(height: 16),

          // アプリ情報セクション
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'アプリ情報',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(context, 'アプリ名', '板取りくん'),
                  const SizedBox(height: 8),
                  _buildInfoRow(context, 'バージョン', '1.0.0'),
                  const SizedBox(height: 8),
                  _buildInfoRow(context, '説明',
                      'DIY木材カット計算アプリ\n端材を最小にする最適カット配置を自動計算します'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
