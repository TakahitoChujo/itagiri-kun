import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';

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
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('板取りくん'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: 'プロジェクトを読み込み',
            onPressed: () => _onImportJson(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '設定',
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
                    Text('エラーが発生しました', style: TextStyle(color: colorScheme.error)),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(projectsProvider),
                      child: const Text('再読み込み'),
                    ),
                  ],
                ),
              ),
              data: (projects) {
                if (projects.isEmpty) return _buildEmptyState(context);
                return _buildProjectList(context, ref, projects);
              },
            ),
          ),
          const AdBanner(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewProjectDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('新規プロジェクト'),
      ),
    );
  }

  void _showNewProjectDialog(BuildContext context, WidgetRef ref) {
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
                'プロジェクトの種類を選択',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.straighten),
                title: const Text('1D カット（角材・板材）'),
                subtitle: const Text('長さ方向のカット最適化'),
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
                title: const Text('2D カット（合板）'),
                subtitle: const Text('板材の面積最適化'),
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
            const SnackBar(content: Text('ファイルの読み込みに失敗しました')),
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
          SnackBar(content: Text('「${imported.name}」を読み込みました')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ファイルの読み込みに失敗しました')),
        );
      }
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.carpenter_outlined, size: 80,
                color: colorScheme.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 24),
            Text(
              '新しいプロジェクトを作成しましょう',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '右下の「新規プロジェクト」ボタンから\n木材のカット計算を始められます',
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
                  existingProject: project,
                ),
              ),
            ).then((_) => ref.invalidate(projectsProvider));
          },
          onDuplicate: () async {
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
                SnackBar(content: Text('「${duplicate.name}」を作成しました')),
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
                    Text('${project.woodStock.name} (${project.stockLength}mm) - ${project.pieces.length}種類',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
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

  Future<void> _showActionsDialog(BuildContext context) async {
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
                title: const Text('プロジェクトを複製'),
                onTap: () => Navigator.pop(context, 'duplicate'),
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                title: Text('削除', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
        builder: (context) => AlertDialog(
          title: const Text('プロジェクトの削除'),
          content: Text('「${project.name}」を削除しますか？\nこの操作は取り消せません。'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('削除'),
            ),
          ],
        ),
      );
      if (confirmed == true) onDeleteConfirmed();
    }
  }
}
