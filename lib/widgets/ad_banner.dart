import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/premium_service.dart'; // isPremiumProvider

// ---------------------------------------------------------------------------
// AdBanner — AdMob バナー広告ウィジェット
// ---------------------------------------------------------------------------

/// AdMob バナー広告（320x50）を表示するウィジェット。
///
/// - プレミアムユーザー（[isPremiumProvider] が true）の場合は非表示。
/// - Phase 0 では google_mobile_ads を使わず、プレースホルダーを表示する。
/// - Phase 1 で [Container] 内の child を [AdWidget] に差し替える。
///
/// 使用例:
/// ```dart
/// // ホーム画面や結果画面の下部に配置
/// Column(
///   children: [
///     Expanded(child: mainContent),
///     const AdBanner(),
///   ],
/// )
/// ```
class AdBanner extends ConsumerWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    // プレミアムユーザーには広告を表示しない
    if (isPremium) return const SizedBox.shrink();

    // Phase 0: プレースホルダー表示
    // Phase 1 で google_mobile_ads の AdWidget に差し替える
    // TODO: Phase 1 — BannerAd を読み込み、AdWidget(ad: _bannerAd) に置き換え
    return Container(
      height: 50, // AdMob バナー標準サイズ（320x50）の高さ
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: const Text(
        '広告 (テスト)',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }
}
