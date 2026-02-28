import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// ---------------------------------------------------------------------------
// プレミアム（課金）状態モデル
// ---------------------------------------------------------------------------

/// プレミアム状態を表す不変データクラス。
///
/// [isPremium] が true のとき、広告非表示・全機能開放となる。
/// Phase 0 では常に true をハードコードし、全機能を開放する。
class PremiumState {
  /// プレミアム課金済みかどうか
  final bool isPremium;

  /// 購入日時（IAP 連携後に設定される）
  final DateTime? purchaseDate;

  /// 適用中のキャンペーンコード（ローンチ記念 ¥480 など）
  final String? campaignCode;

  const PremiumState({
    this.isPremium = false,
    this.purchaseDate,
    this.campaignCode,
  });

  /// 一部のフィールドだけ変更したコピーを返す
  PremiumState copyWith({
    bool? isPremium,
    DateTime? purchaseDate,
    String? campaignCode,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      campaignCode: campaignCode ?? this.campaignCode,
    );
  }
}

// ---------------------------------------------------------------------------
// PremiumNotifier — Riverpod StateNotifier
// ---------------------------------------------------------------------------

/// 課金状態を管理する StateNotifier。
///
/// - Hive でローカルキャッシュし、オフラインでも課金状態を参照できる。
/// - Phase 0 では [_isPhase0] = true とし、常に isPremium = true を返す。
/// - Phase 1 以降で IAP SDK（in_app_purchase / RevenueCat）と連携し、
///   実際の購入レシートを Source of Truth とする。
///
/// 使い方:
/// ```dart
/// // 画面から課金状態を参照
/// final isPremium = ref.watch(premiumProvider).isPremium;
///
/// // 購入処理の呼び出し
/// ref.read(premiumProvider.notifier).purchase();
/// ```
class PremiumNotifier extends StateNotifier<PremiumState> {
  // -----------------------------------------------------------------------
  // 定数
  // -----------------------------------------------------------------------

  /// Hive Box 名。storage_service.dart の initStorage() で開く必要がある。
  static const String boxName = 'premium';

  /// Hive キー: プレミアム状態
  static const String _isPremiumKey = 'isPremium';

  /// Hive キー: 購入日時（ISO 8601 文字列で保存）
  static const String _purchaseDateKey = 'purchaseDate';

  /// Hive キー: キャンペーンコード
  static const String _campaignCodeKey = 'campaignCode';

  /// Phase 0 フラグ。
  /// true の間は isPremium を常に true として扱い、全機能を開放する。
  /// Phase 1 で false に切り替えて、実際の IAP 状態を使用する。
  static const bool _isPhase0 = true;

  // -----------------------------------------------------------------------
  // コンストラクタ
  // -----------------------------------------------------------------------

  PremiumNotifier() : super(const PremiumState()) {
    _loadFromCache();
  }

  // -----------------------------------------------------------------------
  // キャッシュ読み書き（Hive）
  // -----------------------------------------------------------------------

  /// Hive キャッシュからプレミアム状態を復元する。
  ///
  /// Phase 0 では Hive の値に関係なく isPremium = true を設定する。
  void _loadFromCache() {
    try {
      final box = Hive.box(boxName);

      final cachedIsPremium =
          box.get(_isPremiumKey, defaultValue: false) as bool;
      final cachedDateStr = box.get(_purchaseDateKey) as String?;
      final cachedCampaign = box.get(_campaignCodeKey) as String?;

      final purchaseDate =
          cachedDateStr != null ? DateTime.tryParse(cachedDateStr) : null;

      state = PremiumState(
        // Phase 0: 常に true。Phase 1 以降は cachedIsPremium を使用。
        isPremium: _isPhase0 ? true : cachedIsPremium,
        purchaseDate: purchaseDate,
        campaignCode: cachedCampaign,
      );
    } catch (_) {
      // Box が未オープン、またはデータ破損時はデフォルト値を使用。
      // Phase 0 では isPremium = true をフォールバックとする。
      state = const PremiumState(isPremium: _isPhase0);
    }
  }

  /// 現在のプレミアム状態を Hive キャッシュに保存する。
  void _saveToCache() {
    try {
      final box = Hive.box(boxName);
      box.put(_isPremiumKey, state.isPremium);
      box.put(
        _purchaseDateKey,
        state.purchaseDate?.toIso8601String(),
      );
      box.put(_campaignCodeKey, state.campaignCode);
    } catch (_) {
      // 保存失敗時は無視。次回起動時に IAP から再取得される。
    }
  }

  // -----------------------------------------------------------------------
  // Hive Box の初期化（main で呼ぶ）
  // -----------------------------------------------------------------------

  /// Hive の premium Box を開く。
  ///
  /// アプリの main() で StorageService.initStorage() の後に呼び出す。
  /// ```dart
  /// await PremiumNotifier.initPremiumBox();
  /// ```
  static Future<void> initPremiumBox() async {
    await Hive.openBox(boxName);
  }

  // -----------------------------------------------------------------------
  // 公開メソッド
  // -----------------------------------------------------------------------

  /// 課金状態を確認・更新する。
  ///
  /// Phase 0: 何もしない（常に true）。
  /// Phase 1 以降: IAP SDK で App Store / Google Play の
  /// 購入レシートを検証し、state と Hive キャッシュを更新する。
  Future<void> checkStatus() async {
    if (_isPhase0) {
      // Phase 0: 全機能開放のため、明示的に true を設定
      state = state.copyWith(isPremium: true);
      return;
    }

    // --- Phase 1 以降の実装 ---
    // TODO: IAP SDK（in_app_purchase / RevenueCat）で購入状態を確認
    // 例:
    // final isPurchased = await IAPService.verifyPurchase();
    // final purchaseDate = await IAPService.getPurchaseDate();
    // state = state.copyWith(
    //   isPremium: isPurchased,
    //   purchaseDate: purchaseDate,
    // );
    // _saveToCache();
  }

  /// プレミアムを購入する。
  ///
  /// Phase 0: 即座に購入完了として扱う（テスト用）。
  /// Phase 1 以降: IAP SDK の購入フローを起動し、
  /// 完了後に state と Hive キャッシュを更新する。
  ///
  /// [campaignCode] が指定された場合、キャンペーン価格が適用される。
  /// 戻り値: 購入成功なら true、キャンセル・エラーなら false。
  Future<bool> purchase({String? campaignCode}) async {
    if (_isPhase0) {
      // Phase 0: 即座に購入成功として処理
      state = PremiumState(
        isPremium: true,
        purchaseDate: DateTime.now(),
        campaignCode: campaignCode,
      );
      _saveToCache();
      return true;
    }

    // --- Phase 1 以降の実装 ---
    // TODO: IAP SDK で購入フローを開始
    // 例:
    // try {
    //   final productId = campaignCode != null
    //       ? 'premium_campaign'
    //       : 'premium_standard';
    //   final result = await IAPService.purchase(productId);
    //   if (result.success) {
    //     state = PremiumState(
    //       isPremium: true,
    //       purchaseDate: result.purchaseDate,
    //       campaignCode: campaignCode,
    //     );
    //     _saveToCache();
    //     return true;
    //   }
    // } catch (e) {
    //   // 購入エラーのハンドリング
    // }
    return false;
  }

  /// 過去の購入を復元する。
  ///
  /// 端末の再インストールや機種変更時に使用する。
  /// Phase 0: 即座に復元成功として扱う。
  /// Phase 1 以降: IAP SDK の復元フローを実行し、
  /// 購入レシートが見つかれば state を更新する。
  ///
  /// 戻り値: 復元成功なら true、購入履歴なし・エラーなら false。
  Future<bool> restore() async {
    if (_isPhase0) {
      // Phase 0: 即座に復元成功として処理
      state = state.copyWith(isPremium: true);
      _saveToCache();
      return true;
    }

    // --- Phase 1 以降の実装 ---
    // TODO: IAP SDK で購入履歴を復元
    // 例:
    // try {
    //   final result = await IAPService.restorePurchases();
    //   if (result.hasPremium) {
    //     state = PremiumState(
    //       isPremium: true,
    //       purchaseDate: result.purchaseDate,
    //       campaignCode: result.campaignCode,
    //     );
    //     _saveToCache();
    //     return true;
    //   }
    // } catch (e) {
    //   // 復元エラーのハンドリング
    // }
    return false;
  }

  /// プレミアム状態をリセットする（デバッグ・テスト用）。
  ///
  /// 本番ビルドでは呼び出さないこと。
  void debugReset() {
    assert(() {
      state = const PremiumState();
      _saveToCache();
      return true;
    }());
  }
}

// ---------------------------------------------------------------------------
// Riverpod プロバイダー
// ---------------------------------------------------------------------------

/// プレミアム状態を提供するグローバルプロバイダー。
///
/// 使用例:
/// ```dart
/// // 課金状態の監視（画面の自動再描画）
/// final isPremium = ref.watch(premiumProvider).isPremium;
///
/// // 購入処理の呼び出し
/// await ref.read(premiumProvider.notifier).purchase();
///
/// // 購入復元の呼び出し
/// await ref.read(premiumProvider.notifier).restore();
/// ```
final premiumProvider =
    StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  return PremiumNotifier();
});

// ---------------------------------------------------------------------------
// 便利なセレクタープロバイダー
// ---------------------------------------------------------------------------

/// isPremium だけを監視する軽量プロバイダー。
///
/// 広告表示の切り替えなど、bool 値だけが必要な場面で使用する。
/// PremiumState の他のフィールド変更では再描画されないため効率的。
///
/// 使用例:
/// ```dart
/// final isPremium = ref.watch(isPremiumProvider);
/// if (!isPremium) {
///   return AdBanner(); // 無料ユーザーにのみ広告を表示
/// }
/// ```
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(premiumProvider).isPremium;
});
