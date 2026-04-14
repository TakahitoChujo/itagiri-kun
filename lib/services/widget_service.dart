import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import 'storage_service.dart';

/// ホーム画面ウィジェットへのデータ提供サービス
///
/// iOS WidgetKit / Android AppWidget にデータを共有する。
class WidgetService {
  WidgetService._();

  static const String _appGroupId = 'group.com.itagirikun.widget';
  static const String _androidWidgetName = 'ItagiriWidgetProvider';
  static const String _iOSWidgetName = 'ItagiriWidget';

  /// ウィジェットの初期設定
  static Future<void> init() async {
    HomeWidget.setAppGroupId(_appGroupId);
  }

  /// ウィジェットに表示するデータを更新する
  ///
  /// プロジェクト一覧の変更時に呼び出す。
  static Future<void> updateWidgetData() async {
    try {
      final projects = StorageService.loadProjects();
      final sheetProjects = StorageService.loadSheetProjects();
      final offcuts = StorageService.loadOffcuts();

      // 最近のプロジェクト（最大3件）
      final allItems = <Map<String, dynamic>>[];
      for (final p in projects.take(3)) {
        allItems.add({
          'name': p.name,
          'type': '1D',
          'updatedAt': p.updatedAt.toIso8601String(),
          'stockCount': p.result?.totalStock,
          'utilization': p.result?.utilizationRate,
        });
      }
      for (final p in sheetProjects.take(3)) {
        allItems.add({
          'name': p.name,
          'type': '2D',
          'updatedAt': p.updatedAt.toIso8601String(),
          'sheetCount': p.result?.totalSheets,
          'utilization': p.result?.utilizationRate,
        });
      }
      allItems.sort((a, b) =>
          (b['updatedAt'] as String).compareTo(a['updatedAt'] as String));

      await HomeWidget.saveWidgetData<String>(
        'recentProjects',
        jsonEncode(allItems.take(3).toList()),
      );
      await HomeWidget.saveWidgetData<int>(
        'totalProjects',
        projects.length + sheetProjects.length,
      );
      await HomeWidget.saveWidgetData<int>(
        'offcutCount',
        offcuts.length,
      );

      // ウィジェットの更新を要求
      await HomeWidget.updateWidget(
        iOSName: _iOSWidgetName,
        androidName: _androidWidgetName,
      );
    } catch (_) {
      // ウィジェット更新失敗は無視
    }
  }
}
