import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/wood_stock.dart';
import '../models/cut_piece.dart';
import '../models/cut_result.dart';
import '../models/project.dart';
import '../models/sheet_models.dart';

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
