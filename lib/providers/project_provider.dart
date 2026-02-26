import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';
import '../services/storage_service.dart';

/// プロジェクト一覧プロバイダー
///
/// StorageService からプロジェクト一覧を読み込む。
/// ref.invalidate(projectsProvider) で再読み込み可能。
final projectsProvider = FutureProvider<List<Project>>((ref) async {
  return StorageService.loadProjects();
});

/// 現在選択中のプロジェクト
final currentProjectProvider = StateProvider<Project?>((ref) {
  return null;
});
