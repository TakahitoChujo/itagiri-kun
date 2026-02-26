import 'package:hive_flutter/hive_flutter.dart';

import '../models/wood_stock.dart';
import '../models/cut_piece.dart';
import '../models/cut_result.dart';
import '../models/project.dart';

/// Hive を使ったローカルストレージサービス
///
/// プロジェクトの CRUD 操作を提供する。
/// アプリ起動時に [initStorage] を呼び出してから使用すること。
class StorageService {
  static const String _projectBoxName = 'projects';

  /// Hive の初期化とすべての TypeAdapter の登録を行う。
  ///
  /// アプリの main() で最初に呼び出す必要がある。
  static Future<void> initStorage() async {
    await Hive.initFlutter();

    // TypeAdapter の登録（重複登録を避けるためチェック付き）
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(WoodStockAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CutPieceAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CutPieceResultAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(CutBinAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(CutResultAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(ProjectAdapter());
    }

    // プロジェクト用ボックスを開く
    await Hive.openBox<Project>(_projectBoxName);
  }

  /// プロジェクト用の Hive Box を取得する。
  static Box<Project> get _projectBox =>
      Hive.box<Project>(_projectBoxName);

  /// プロジェクトを保存する。
  ///
  /// 既存の場合は上書き、新規の場合は追加される。
  /// [project.id] をキーとして使用する。
  static Future<void> saveProject(Project project) async {
    project.updatedAt = DateTime.now();
    await _projectBox.put(project.id, project);
  }

  /// 全プロジェクトを取得する。
  ///
  /// 更新日時の降順（新しい順）でソートされて返される。
  static List<Project> loadProjects() {
    final projects = _projectBox.values.toList();
    projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return projects;
  }

  /// 指定した ID のプロジェクトを取得する。
  ///
  /// 見つからない場合は null を返す。
  static Project? loadProject(String id) {
    return _projectBox.get(id);
  }

  /// 指定した ID のプロジェクトを削除する。
  static Future<void> deleteProject(String id) async {
    await _projectBox.delete(id);
  }

  /// 全プロジェクト数を返す。
  static int get projectCount => _projectBox.length;

  /// ストレージをクリーンアップする（全データ削除）。
  ///
  /// 主にデバッグ・テスト用。
  static Future<void> clearAll() async {
    await _projectBox.clear();
  }

  /// Hive を閉じる。アプリ終了時に呼ぶ。
  static Future<void> close() async {
    await Hive.close();
  }
}
