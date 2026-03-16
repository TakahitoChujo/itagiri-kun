import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../gen_l10n/app_localizations.dart';
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
  String _version = '';

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _kerfController =
        TextEditingController(text: settings.kerfWidth.toStringAsFixed(1));
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = info.version;
      });
    }
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
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
                        l10n.kerfWidthSetting,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.kerfWidthDescription,
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
                        l10n.unitSystem,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      RadioListTile<MeasurementUnit>(
                        value: MeasurementUnit.mm,
                        groupValue: settings.unit,
                        onChanged: (value) {
                          if (value != null) notifier.setUnit(value);
                        },
                        title: Text(l10n.unitMm),
                        subtitle: Text(l10n.recommended),
                        dense: true,
                      ),
                      RadioListTile<MeasurementUnit>(
                        value: MeasurementUnit.cm,
                        groupValue: settings.unit,
                        onChanged: (value) {
                          if (value != null) notifier.setUnit(value);
                        },
                        title: Text(l10n.unitCm),
                        dense: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 言語セクション
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.language, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        l10n.language,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      RadioListTile<AppLanguage>(
                        value: AppLanguage.system,
                        groupValue: settings.language,
                        onChanged: (value) {
                          if (value != null) notifier.setLanguage(value);
                        },
                        title: Text(l10n.languageSystem),
                        dense: true,
                      ),
                      RadioListTile<AppLanguage>(
                        value: AppLanguage.ja,
                        groupValue: settings.language,
                        onChanged: (value) {
                          if (value != null) notifier.setLanguage(value);
                        },
                        title: Text(l10n.languageJa),
                        dense: true,
                      ),
                      RadioListTile<AppLanguage>(
                        value: AppLanguage.en,
                        groupValue: settings.language,
                        onChanged: (value) {
                          if (value != null) notifier.setLanguage(value);
                        },
                        title: Text(l10n.languageEn),
                        dense: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // テーマセクション
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dark_mode_outlined, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        l10n.themeSetting,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      RadioListTile<AppTheme>(
                        value: AppTheme.system,
                        groupValue: settings.theme,
                        onChanged: (value) {
                          if (value != null) notifier.setTheme(value);
                        },
                        title: Text(l10n.themeSystem),
                        dense: true,
                      ),
                      RadioListTile<AppTheme>(
                        value: AppTheme.light,
                        groupValue: settings.theme,
                        onChanged: (value) {
                          if (value != null) notifier.setTheme(value);
                        },
                        title: Text(l10n.themeLight),
                        dense: true,
                      ),
                      RadioListTile<AppTheme>(
                        value: AppTheme.dark,
                        groupValue: settings.theme,
                        onChanged: (value) {
                          if (value != null) notifier.setTheme(value);
                        },
                        title: Text(l10n.themeDark),
                        dense: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // プレミアム導線バナー
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
                        l10n.appInfo,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(context, l10n.appInfoName, l10n.appName),
                  const SizedBox(height: 8),
                  _buildInfoRow(context, l10n.appInfoVersion, _version),
                  const SizedBox(height: 8),
                  _buildInfoRow(context, l10n.appInfoDescription, l10n.appInfoDescriptionValue),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 法的情報セクション
          Card(
            child: Column(
              children: [
                ListTile(
                  leading:
                      Icon(Icons.privacy_tip_outlined, color: colorScheme.primary),
                  title: Text(l10n.privacyPolicy),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () => _launchUrl(
                    'https://jyojorian.github.io/itagiri-kun/privacy-policy',
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.description_outlined,
                      color: colorScheme.primary),
                  title: Text(l10n.termsOfService),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () => _launchUrl(
                    'https://jyojorian.github.io/itagiri-kun/terms-of-service',
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading:
                      Icon(Icons.source_outlined, color: colorScheme.primary),
                  title: Text(l10n.openSourceLicenses),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: l10n.appName,
                    applicationVersion: _version,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.urlOpenFailed)),
        );
      }
    }
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
