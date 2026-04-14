import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/wood_stock.dart';
import '../models/cut_piece.dart';
import '../models/cut_result.dart';
import '../models/project.dart';
import '../models/sheet_models.dart';
import '../models/sheet_project.dart';
import '../models/offcut.dart';
import '../models/custom_preset.dart';

/// Hive を使ったローカルストレージサービス
///
/// - 全データを AES-256 で暗号化して保存する。
/// - 暗号化キーは OS のセキュアストレージ（Android Keystore / iOS Keychain）に保存する。
/// - プロジェクトの CRUD 操作を提供する。
/// - アプリ起動時に [initStorage] を呼び出してから使用すること。
class StorageService {
  static const String _projectBoxName = 'projects';
  static const String _settingsBoxName = 'settings';
  static const String _premiumBoxName = 'premium';
  static const String _offcutBoxName = 'offcuts';
  static const String _sheetProjectBoxName = 'sheet_projects';
  static const String _checklistBoxName = 'checklists';
  static const String _customWoodPresetBoxName = 'custom_wood_presets';
  static const String _customSheetPresetBoxName = 'custom_sheet_presets';
  static const String _onboardingKey = 'onboarding_done';

  /// 初回起動フラグ（initStorage 後に参照可能）
  static bool _isFirstLaunch = false;
  static bool get isFirstLaunch => _isFirstLaunch;

  /// flutter_secure_storage に保存する暗号化キーのエイリアス
  static const String _encryptionKeyAlias = 'hive_enc_key_v1';

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ---------------------------------------------------------------------------
  // 暗号化キー管理
  // ---------------------------------------------------------------------------

  /// セキュアストレージから暗号化キーを取得する。
  ///
  /// 初回起動時は 32 バイトのランダムキーを生成して保存する。
  /// 以降の起動では保存済みのキーを読み込む。
  static Future<HiveAesCipher> _getOrCreateCipher() async {
    String? keyBase64 = await _secureStorage.read(key: _encryptionKeyAlias);

    if (keyBase64 == null) {
      final key =
          List<int>.generate(32, (_) => Random.secure().nextInt(256));
      keyBase64 = base64Url.encode(key);
      await _secureStorage.write(
        key: _encryptionKeyAlias,
        value: keyBase64,
      );
    }

    final keyBytes = base64Url.decode(keyBase64);
    return HiveAesCipher(keyBytes);
  }

  // ---------------------------------------------------------------------------
  // 初期化
  // ---------------------------------------------------------------------------

  /// Hive の初期化・TypeAdapter 登録・全 Box のオープンを行う。
  ///
  /// アプリの main() で最初に呼び出す必要がある。
  /// 全 Box は AES-256 で暗号化される。
  static Future<void> initStorage() async {
    await Hive.initFlutter();

    final cipher = await _getOrCreateCipher();

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
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(SheetStockAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(SheetPlacedPieceAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(SheetCutBinAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(SheetCutResultAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(SheetPieceAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(SheetProjectAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(CustomWoodPresetAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(CustomSheetPresetAdapter());
    }

    // 全 Box を暗号化して開く
    await Hive.openBox<Project>(
      _projectBoxName,
      encryptionCipher: cipher,
    );
    await Hive.openBox(
      _settingsBoxName,
      encryptionCipher: cipher,
    );
    await Hive.openBox(
      _premiumBoxName,
      encryptionCipher: cipher,
    );
    await Hive.openBox<String>(
      _offcutBoxName,
      encryptionCipher: cipher,
    );
    await Hive.openBox<SheetProject>(
      _sheetProjectBoxName,
      encryptionCipher: cipher,
    );
    await Hive.openBox<String>(
      _checklistBoxName,
      encryptionCipher: cipher,
    );
    await Hive.openBox<CustomWoodPreset>(
      _customWoodPresetBoxName,
      encryptionCipher: cipher,
    );
    await Hive.openBox<CustomSheetPreset>(
      _customSheetPresetBoxName,
      encryptionCipher: cipher,
    );

    // 初回起動フラグを確認
    final settingsBox = Hive.box(_settingsBoxName);
    _isFirstLaunch = !(settingsBox.get(_onboardingKey, defaultValue: false) as bool);
  }

  /// オンボーディング完了を記録する
  static Future<void> markOnboardingDone() async {
    final box = Hive.box(_settingsBoxName);
    await box.put(_onboardingKey, true);
    _isFirstLaunch = false;
  }

  // ---------------------------------------------------------------------------
  // プロジェクト CRUD
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // 2D 合板プロジェクト CRUD
  // ---------------------------------------------------------------------------

  /// 合板プロジェクト用の Hive Box を取得する。
  static Box<SheetProject> get _sheetProjectBox =>
      Hive.box<SheetProject>(_sheetProjectBoxName);

  /// 合板プロジェクトを保存する。
  static Future<void> saveSheetProject(SheetProject project) async {
    project.updatedAt = DateTime.now();
    await _sheetProjectBox.put(project.id, project);
  }

  /// 全合板プロジェクトを取得する（更新日時降順）。
  static List<SheetProject> loadSheetProjects() {
    final projects = _sheetProjectBox.values.toList();
    projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return projects;
  }

  /// 指定した ID の合板プロジェクトを取得する。
  static SheetProject? loadSheetProject(String id) {
    return _sheetProjectBox.get(id);
  }

  /// 指定した ID の合板プロジェクトを削除する。
  static Future<void> deleteSheetProject(String id) async {
    await _sheetProjectBox.delete(id);
  }

  /// 全合板プロジェクト数を返す。
  static int get sheetProjectCount => _sheetProjectBox.length;

  /// ストレージをクリーンアップする（全データ削除）。
  ///
  /// 主にデバッグ・テスト用。
  static Future<void> clearAll() async {
    await _projectBox.clear();
    await _sheetProjectBox.clear();
  }

  /// Hive を閉じる。アプリ終了時に呼ぶ。
  static Future<void> close() async {
    await Hive.close();
  }

  // ---------------------------------------------------------------------------
  // 端材 CRUD
  // ---------------------------------------------------------------------------

  static Box<String> get _offcutBox => Hive.box<String>(_offcutBoxName);

  /// 端材を保存する
  static Future<Offcut> saveOffcut({
    required String woodStockName,
    required double length,
    String? sourceProjectId,
  }) async {
    final offcut = Offcut(
      id: const Uuid().v4(),
      woodStockName: woodStockName,
      length: length,
      sourceProjectId: sourceProjectId,
      savedAt: DateTime.now(),
    );
    await _offcutBox.put(offcut.id, offcut.toJsonString());
    return offcut;
  }

  /// 全端材を取得する（新しい順）
  static List<Offcut> loadOffcuts() {
    final offcuts = _offcutBox.values
        .map((s) {
          try {
            return Offcut.fromJsonString(s);
          } catch (_) {
            return null;
          }
        })
        .whereType<Offcut>()
        .toList();
    offcuts.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return offcuts;
  }

  /// 特定の木材名の端材のみ取得する
  static List<Offcut> loadOffcutsForWood(String woodStockName) {
    return loadOffcuts()
        .where((o) => o.woodStockName == woodStockName)
        .toList();
  }

  /// 端材を削除する
  static Future<void> deleteOffcut(String id) async {
    await _offcutBox.delete(id);
  }

  /// 端材をインポートする（既存IDを保持）
  static Future<void> importOffcut(Offcut offcut) async {
    await _offcutBox.put(offcut.id, offcut.toJsonString());
  }

  // ---------------------------------------------------------------------------
  // チェックリスト CRUD
  // ---------------------------------------------------------------------------

  static Box<String> get _checklistBox =>
      Hive.box<String>(_checklistBoxName);

  /// チェックリストの状態を保存する
  static Future<void> saveChecklist(
    String projectId,
    Map<String, bool> checks,
    int resultHash,
  ) async {
    final data = jsonEncode({
      'resultHash': resultHash,
      'checks': checks,
    });
    await _checklistBox.put(projectId, data);
  }

  /// チェックリストの状態を読み込む
  ///
  /// resultHash が一致しない場合（再計算された場合）は null を返す。
  static Map<String, bool>? loadChecklist(
    String projectId,
    int resultHash,
  ) {
    final raw = _checklistBox.get(projectId);
    if (raw == null) return null;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (data['resultHash'] != resultHash) return null;

      final checks = (data['checks'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v as bool));
      return checks;
    } catch (_) {
      return null;
    }
  }

  /// チェックリストの進捗を取得する (done, total)
  ///
  /// 保存されていない場合は null を返す。
  static (int done, int total)? getChecklistProgress(String projectId) {
    final raw = _checklistBox.get(projectId);
    if (raw == null) return null;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final checks = data['checks'] as Map<String, dynamic>;
      final total = checks.length;
      if (total == 0) return null;
      final done = checks.values.where((v) => v == true).length;
      return (done, total);
    } catch (_) {
      return null;
    }
  }

  /// チェックリストを削除する
  static Future<void> deleteChecklist(String projectId) async {
    await _checklistBox.delete(projectId);
  }

  // ---------------------------------------------------------------------------
  // カスタム木材プリセット CRUD
  // ---------------------------------------------------------------------------

  static Box<CustomWoodPreset> get _customWoodPresetBox =>
      Hive.box<CustomWoodPreset>(_customWoodPresetBoxName);

  /// カスタム木材プリセットを保存する
  static Future<void> saveCustomWoodPreset(CustomWoodPreset preset) async {
    await _customWoodPresetBox.put(preset.id, preset);
  }

  /// 全カスタム木材プリセットを取得する（作成日時降順）
  static List<CustomWoodPreset> loadCustomWoodPresets() {
    final presets = _customWoodPresetBox.values.toList();
    presets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return presets;
  }

  /// カスタム木材プリセットを削除する
  static Future<void> deleteCustomWoodPreset(String id) async {
    await _customWoodPresetBox.delete(id);
  }

  // ---------------------------------------------------------------------------
  // カスタム合板プリセット CRUD
  // ---------------------------------------------------------------------------

  static Box<CustomSheetPreset> get _customSheetPresetBox =>
      Hive.box<CustomSheetPreset>(_customSheetPresetBoxName);

  /// カスタム合板プリセットを保存する
  static Future<void> saveCustomSheetPreset(CustomSheetPreset preset) async {
    await _customSheetPresetBox.put(preset.id, preset);
  }

  /// 全カスタム合板プリセットを取得する（作成日時降順）
  static List<CustomSheetPreset> loadCustomSheetPresets() {
    final presets = _customSheetPresetBox.values.toList();
    presets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return presets;
  }

  /// カスタム合板プリセットを削除する
  static Future<void> deleteCustomSheetPreset(String id) async {
    await _customSheetPresetBox.delete(id);
  }
}
