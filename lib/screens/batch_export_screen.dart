import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../gen_l10n/app_localizations.dart';
import '../providers/project_provider.dart';
import '../services/export_service.dart';

/// 一括エクスポート画面
class BatchExportScreen extends ConsumerStatefulWidget {
  const BatchExportScreen({super.key});

  @override
  ConsumerState<BatchExportScreen> createState() => _BatchExportScreenState();
}

class _BatchExportScreenState extends ConsumerState<BatchExportScreen> {
  final Set<String> _selectedIds = {};
  String _format = 'pdf';
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.batchExportTitle),
        actions: [
          TextButton(
            onPressed: _selectedIds.isEmpty ? null : () => _onExport(context),
            child: _exporting
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.exportTooltip),
          ),
        ],
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.errorOccurred)),
        data: (projects) {
          if (projects.isEmpty) {
            return Center(child: Text(l10n.noProjectsSelected));
          }
          return Column(
            children: [
              // Format selection
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(l10n.exportFormat,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: Text(l10n.exportAsPdf),
                      selected: _format == 'pdf',
                      onSelected: (_) => setState(() => _format = 'pdf'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(l10n.exportAsCsv),
                      selected: _format == 'csv',
                      onSelected: (_) => setState(() => _format = 'csv'),
                    ),
                  ],
                ),
              ),
              // Select all / deselect
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(l10n.exportSelectedCount(_selectedIds.length),
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (_selectedIds.length == projects.length) {
                            _selectedIds.clear();
                          } else {
                            _selectedIds.clear();
                            _selectedIds.addAll(projects.map((p) => p.id));
                          }
                        });
                      },
                      child: Text(_selectedIds.length == projects.length
                          ? l10n.deselectAll
                          : l10n.selectAll),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Project list
              Expanded(
                child: ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    final selected = _selectedIds.contains(project.id);
                    return CheckboxListTile(
                      value: selected,
                      title: Text(project.name, maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${project.woodStock.name} - ${project.pieces.length}種類'
                        '${project.result != null ? ' (${(project.result!.utilizationRate * 100).toStringAsFixed(0)}%)' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      secondary: Icon(
                        project.result != null
                            ? Icons.check_circle_outline
                            : Icons.pending_outlined,
                        color: project.result != null
                            ? Colors.green
                            : colorScheme.outline,
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedIds.add(project.id);
                          } else {
                            _selectedIds.remove(project.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onExport(BuildContext context) async {
    if (_exporting || _selectedIds.isEmpty) return;
    final l10n = AppLocalizations.of(context);

    setState(() => _exporting = true);

    try {
      final allProjects = ref.read(projectsProvider).valueOrNull ?? [];
      final selected = allProjects
          .where((p) => _selectedIds.contains(p.id) && p.result != null)
          .toList();

      if (selected.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.noProjectsSelected)),
          );
        }
        return;
      }

      String filePath;
      if (_format == 'pdf') {
        filePath = await ExportService.batchExportToPdf(selected);
      } else {
        filePath = await ExportService.batchExportToCsv(selected);
      }

      await ExportService.shareFile(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportStarted)),
        );
      }
    } catch (e) {
      debugPrint('Batch export failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(''))),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}
