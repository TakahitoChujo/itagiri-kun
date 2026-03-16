import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';

import '../constants/responsive.dart';
import '../gen_l10n/app_localizations.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../services/storage_service.dart';
import '../services/export_service.dart';
import '../widgets/ad_banner.dart';
import 'settings_screen.dart';
import 'wood_select_screen.dart';
import 'pieces_input_screen.dart';
import 'sheet_select_screen.dart';

/// ホーム画面（プロジェクト一覧）
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: l10n.importProject,
            onPressed: () => _onImportJson(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: projectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text(l10n.errorOccurred, style: TextStyle(color: colorScheme.error)),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(projectsProvider),
                      child: Text(l10n.reload),
                    ),
                  ],
                ),
              ),
              data: (projects) {
                if (projects.isEmpty) return _buildEmptyState(context);
                return _buildProjectListWithSearch(context, ref, projects);
              },
            ),
          ),
          const AdBanner(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewProjectDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.newProject),
      ),
    );
  }

  Widget _buildProjectListWithSearch(BuildContext context, WidgetRef ref, List<Project> projects) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final filtered = _searchQuery.isEmpty
        ? projects
        : projects
            .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchProjects,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: context.emptyIconSize,
                            color: colorScheme.primary.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text(
                          l10n.searchNoResults(_searchQuery),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : _buildProjectList(context, ref, filtered),
        ),
      ],
    );
  }

  void _showNewProjectDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.selectProjectType,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.straighten),
                title: Text(l10n.cut1DTitle),
                subtitle: Text(l10n.cut1DSubtitle),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WoodSelectScreen()),
                  ).then((_) => ref.invalidate(projectsProvider));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.crop_square),
                title: Text(l10n.cut2DTitle),
                subtitle: Text(l10n.cut2DSubtitle),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SheetSelectScreen()),
                  ).then((_) => ref.invalidate(projectsProvider));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onImportJson(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) return;
      final filePath = result.files.single.path;
      if (filePath == null) return;

      final project = await ExportService.importFromJson(filePath);
      if (project == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.importFailed)),
          );
        }
        return;
      }

      final imported = project.copyWith(
        id: const Uuid().v4(),
        name: '${project.name} (インポート)',
      );
      await StorageService.saveProject(imported);
      ref.invalidate(projectsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.importSuccess(imported.name))),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.importFailed)),
        );
      }
    }
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
            Icon(Icons.carpenter_outlined, size: context.emptyIconSize,
                color: colorScheme.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 24),
            Text(
              l10n.emptyProjectTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.emptyProjectSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectList(BuildContext context, WidgetRef ref, List<Project> projects) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _ProjectCard(
          project: project,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PiecesInputScreen(
                  woodStock: project.woodStock,
                  stockLength: project.stockLength,
                  stockLengths: project.stockLengths,
                  existingProject: project,
                ),
              ),
            ).then((_) => ref.invalidate(projectsProvider));
          },
          onDuplicate: () async {
            final l10n = AppLocalizations.of(context);
            final duplicate = project.copyWith(
              id: const Uuid().v4(),
              name: '${project.name} (コピー)',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            await StorageService.saveProject(duplicate);
            ref.invalidate(projectsProvider);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.duplicateCreated(duplicate.name))),
              );
            }
          },
          onDeleteConfirmed: () async {
            await StorageService.deleteProject(project.id);
            ref.invalidate(projectsProvider);
          },
        );
      },
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onDuplicate;
  final VoidCallback onDeleteConfirmed;

  const _ProjectCard({
    required this.project,
    required this.onTap,
    required this.onDuplicate,
    required this.onDeleteConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showActionsDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.content_cut, color: colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      _buildSubtitle(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(dateFormat.format(project.updatedAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11)),
                  ],
                ),
              ),
              if (project.result != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${project.result!.totalStock}本',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onTertiaryContainer)),
                ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: colorScheme.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final lengths = project.effectiveStockLengths;
    final lengthStr = lengths.length == 1
        ? '${lengths.first}mm'
        : lengths.map((l) => '${l}mm').join('+');
    return '${project.woodStock.name} ($lengthStr) - ${project.pieces.length}種類';
  }

  Future<void> _showActionsDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: Text(l10n.duplicateProject),
                onTap: () => Navigator.pop(context, 'duplicate'),
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                title: Text(l10n.delete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
            ],
          ),
        ),
      ),
    );

    if (action == 'duplicate') {
      onDuplicate();
    } else if (action == 'delete') {
      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(l10n.deleteProject),
            content: Text(l10n.deleteProjectConfirm(project.name)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                child: Text(l10n.delete),
              ),
            ],
          );
        },
      );
      if (confirmed == true) onDeleteConfirmed();
    }
  }
}
