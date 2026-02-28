import 'package:flutter/foundation.dart';

/// Analytics サービス（Phase 0: スタブ実装）
///
/// Firebase Analytics のインターフェースに合わせた API を提供する。
/// Phase 0 では debugPrint でイベントをログ出力するのみ。
/// Phase 1 で Firebase Analytics を導入する際は、このファイルの
/// 内部実装を差し替えるだけで済む設計。
///
/// 使い方:
/// ```dart
/// AnalyticsService.logWoodSelected(woodType: 'SPF 2x4', stockLength: 1820);
/// ```
class AnalyticsService {
  // -------------------------------------------------------
  // 初期化
  // -------------------------------------------------------

  /// Analytics の初期化を行う。
  ///
  /// アプリの main() で呼び出す。
  /// Phase 0 では何もしない。Phase 1 で Firebase.initializeApp() 後に
  /// FirebaseAnalytics のインスタンスを保持する処理を追加する。
  static Future<void> init() async {
    _log('AnalyticsService initialized (stub)');
  }

  // -------------------------------------------------------
  // 汎用イベント
  // -------------------------------------------------------

  /// 汎用のイベントログを送信する。
  ///
  /// 定義済みメソッドでカバーされないカスタムイベントに使用する。
  /// [name] にイベント名、[parameters] に任意のパラメータを渡す。
  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    _log(name, parameters);
  }

  // -------------------------------------------------------
  // 定義済みイベント
  // -------------------------------------------------------

  /// 初回起動イベントを記録する。
  static Future<void> logAppFirstOpen() async {
    _log('app_first_open');
  }

  /// 木材選択完了イベントを記録する。
  ///
  /// [woodType] 選択された木材の種類（例: 'SPF 2x4'）
  /// [stockLength] 原板の長さ（mm）
  static Future<void> logWoodSelected({
    required String woodType,
    required int stockLength,
  }) async {
    _log('wood_selected', {
      'wood_type': woodType,
      'stock_length': stockLength,
    });
  }

  /// 部材入力完了イベントを記録する。
  ///
  /// [pieceCount] 入力された部材の数
  static Future<void> logPiecesEntered({
    required int pieceCount,
  }) async {
    _log('pieces_entered', {
      'piece_count': pieceCount,
    });
  }

  /// 計算実行イベントを記録する。
  ///
  /// [binCount] 使用する原板の本数
  /// [utilizationRate] 歩留まり率（0.0〜1.0 または百分率）
  static Future<void> logCalculationDone({
    required int binCount,
    required double utilizationRate,
  }) async {
    _log('calculation_done', {
      'bin_count': binCount,
      'utilization_rate': utilizationRate,
    });
  }

  /// プロジェクト保存イベントを記録する。
  ///
  /// [projectCount] 保存後の総プロジェクト数
  static Future<void> logProjectSaved({
    required int projectCount,
  }) async {
    _log('project_saved', {
      'project_count': projectCount,
    });
  }

  /// 保存制限に遭遇したイベントを記録する。
  ///
  /// [limitType] 制限の種類（例: 'free_project_limit'）
  static Future<void> logLimitReached({
    required String limitType,
  }) async {
    _log('limit_reached', {
      'limit_type': limitType,
    });
  }

  /// プレミアム画面表示イベントを記録する。
  ///
  /// [entryPoint] どこからプレミアム画面に遷移したか（例: 'limit_dialog', 'settings'）
  static Future<void> logPremiumViewed({
    required String entryPoint,
  }) async {
    _log('premium_viewed', {
      'entry_point': entryPoint,
    });
  }

  /// 課金完了イベントを記録する。
  ///
  /// [price] 購入価格（例: '980'）
  /// [campaign] キャンペーン名（該当なしの場合は 'none'）
  static Future<void> logPremiumPurchased({
    required String price,
    String campaign = 'none',
  }) async {
    _log('premium_purchased', {
      'price': price,
      'campaign': campaign,
    });
  }

  /// PDF 出力イベントを記録する。
  ///
  /// [isPremium] プレミアムユーザーかどうか
  static Future<void> logPdfExported({
    required bool isPremium,
  }) async {
    _log('pdf_exported', {
      'is_premium': isPremium,
    });
  }

  /// 2D プレビュー表示イベントを記録する。
  static Future<void> log2dPreviewShown() async {
    _log('2d_preview_shown');
  }

  /// 広告クリックイベントを記録する。
  ///
  /// [adUnit] 広告ユニット ID
  /// [screen] 広告が表示されていた画面名
  static Future<void> logAdClicked({
    required String adUnit,
    required String screen,
  }) async {
    _log('ad_clicked', {
      'ad_unit': adUnit,
      'screen': screen,
    });
  }

  // -------------------------------------------------------
  // ユーザープロパティ（将来用）
  // -------------------------------------------------------

  /// ユーザープロパティを設定する。
  ///
  /// Phase 1 で Firebase Analytics の setUserProperty に差し替える。
  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    _log('set_user_property', {'name': name, 'value': value});
  }

  // -------------------------------------------------------
  // 内部ヘルパー
  // -------------------------------------------------------

  /// デバッグモード時のみイベントをログ出力する。
  ///
  /// Phase 1 では FirebaseAnalytics.logEvent() に差し替える。
  static void _log(String eventName, [Map<String, Object>? parameters]) {
    if (kDebugMode) {
      final params = parameters != null ? ', params: $parameters' : '';
      debugPrint('[Analytics] $eventName$params');
    }
  }
}
