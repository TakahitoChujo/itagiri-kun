import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../gen_l10n/app_localizations.dart';
import '../models/offcut.dart';
import '../providers/project_provider.dart';
import '../services/storage_service.dart';

/// 端材在庫管理画面
class OffcutInventoryScreen extends ConsumerStatefulWidget {
  const OffcutInventoryScreen({super.key});

  @override
  ConsumerState<OffcutInventoryScreen> createState() =>
      _OffcutInventoryScreenState();
}

class _OffcutInventoryScreenState extends ConsumerState<OffcutInventoryScreen> {
  @override
  Widget build(BuildContext context) {
    final offcutsAsync = ref.watch(offcutsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.offcutInventory)),
      body: offcutsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48,
                  color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(l10n.errorOccurred),
              TextButton(
                onPressed: () => ref.invalidate(offcutsProvider),
                child: Text(l10n.reload),
              ),
            ],
          ),
        ),
        data: (offcuts) {
          if (offcuts.isEmpty) return _buildEmptyState(context);
          return _buildGroupedList(context, offcuts);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOffcutDialog(context),
        tooltip: l10n.addOffcutManually,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80,
                color: colorScheme.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 24),
            Text(l10n.offcutInventoryEmpty,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6)),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(l10n.offcutInventorySubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.4)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedList(BuildContext context, List<Offcut> offcuts) {
    final grouped = <String, List<Offcut>>{};
    for (final offcut in offcuts) {
      grouped.putIfAbsent(offcut.woodStockName, () => []).add(offcut);
    }
    final groupKeys = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
      itemCount: groupKeys.length,
      itemBuilder: (context, index) {
        final woodName = groupKeys[index];
        final items = grouped[woodName]!;
        return _buildGroup(context, woodName, items);
      },
    );
  }

  Widget _buildGroup(BuildContext context, String woodName, List<Offcut> offcuts) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.straighten, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(woodName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600, color: colorScheme.primary)),
              const Spacer(),
              Text(l10n.offcutCount(offcuts.length),
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        ...offcuts.map((offcut) => _buildOffcutTile(context, offcut)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildOffcutTile(BuildContext context, Offcut offcut) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

    return Dismissible(
      key: ValueKey(offcut.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      confirmDismiss: (_) async {
        final l10n = AppLocalizations.of(context);
        return showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.delete),
            content: Text('${offcut.woodStockName} - ${offcut.length.toStringAsFixed(0)}mm'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                child: Text(l10n.delete),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        await StorageService.deleteOffcut(offcut.id);
        ref.invalidate(offcutsProvider);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.recycling, size: 20,
                    color: colorScheme.onTertiaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${offcut.length.toStringAsFixed(0)} mm',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(dateFormat.format(offcut.savedAt),
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddOffcutDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final lengthController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.addOffcutManually),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(100),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.offcutWoodName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.offcutWoodName : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: lengthController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    LengthLimitingTextInputFormatter(7),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.length,
                    border: const OutlineInputBorder(),
                    suffixText: 'mm',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.length;
                    final parsed = double.tryParse(v);
                    if (parsed == null || parsed <= 0 || parsed > 100000) return l10n.length;
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(context, true);
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final length = double.parse(lengthController.text);
      await StorageService.saveOffcut(
        woodStockName: nameController.text.trim(),
        length: length,
      );
      ref.invalidate(offcutsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.offcutSaved(length.toStringAsFixed(0)))),
        );
      }
    }
    nameController.dispose();
    lengthController.dispose();
  }
}
