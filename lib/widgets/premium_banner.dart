import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/premium_service.dart'; // isPremiumProvider

/// 設定画面に表示するプレミアムアップグレード導線バナー。
///
/// プレミアムユーザーの場合は何も表示しない（[SizedBox.shrink]）。
/// 無料ユーザーの場合はプレミアムの訴求バナーを表示し、
/// タップで将来のプレミアム購入画面に遷移する。
///
/// Phase 0 では購入画面の代わりに [SnackBar] でメッセージを表示する。
///
/// デザイン:
/// ```
/// ┌──────────────────────────────────┐
/// │  ⭐ 板取りくん プレミアム         │
/// │                                  │
/// │  広告なし・PDF出力・2D合板対応    │
/// │  木材1本分の価格で永久に使える    │
/// │                                  │
/// │  [詳しく見る →]                  │
/// └──────────────────────────────────┘
/// ```
class PremiumBanner extends ConsumerWidget {
  const PremiumBanner({super.key});

  /// プレミアムバッジのゴールデンロッド色（monetization-plan.md より）
  static const _goldenrod = Color(0xFFDAA520);

  /// バナーの背景グラデーション開始色（クリームベージュ系）
  static const _backgroundStart = Color(0xFFFFF8E7);

  /// バナーの背景グラデーション終了色（ゴールド薄め）
  static const _backgroundEnd = Color(0xFFFFF0C8);

  /// バナーのボーダー色
  static const _borderColor = Color(0xFFE8D5A0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    // プレミアムユーザーなら非表示
    if (isPremium) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onBannerTapped(context),
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_backgroundStart, _backgroundEnd],
              ),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: _borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _goldenrod.withValues(alpha: 0.15),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // タイトル行: スターアイコン + 「板取りくん プレミアム」
                _buildTitle(context),
                const SizedBox(height: 12.0),

                // 訴求テキスト: 機能紹介
                _buildDescription(context),
                const SizedBox(height: 4.0),

                // 訴求テキスト: 価格訴求
                _buildPriceAppeal(context),
                const SizedBox(height: 16.0),

                // CTA: 「詳しく見る →」
                _buildCta(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// タイトル行を構築する
  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        // ゴールデンロッドのスターアイコン
        const Icon(
          Icons.star_rounded,
          color: _goldenrod,
          size: 24.0,
        ),
        const SizedBox(width: 8.0),
        Text(
          '板取りくん プレミアム',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5A4200), // ディープウッド
              ),
        ),
      ],
    );
  }

  /// 機能紹介テキストを構築する
  Widget _buildDescription(BuildContext context) {
    return Text(
      '広告なし・PDF出力・2D合板対応',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF5A4200), // ディープウッド
            height: 1.4,
          ),
    );
  }

  /// 価格訴求テキストを構築する
  Widget _buildPriceAppeal(BuildContext context) {
    return Text(
      '木材1本分の価格で永久に使える',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF757575), // グレー（控えめに）
            height: 1.4,
          ),
    );
  }

  /// CTA（「詳しく見る →」）を構築する
  Widget _buildCta(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32), // フォレストグリーン
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Text(
          '詳しく見る →',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// バナータップ時の処理。
  ///
  /// Phase 0 では SnackBar でメッセージを表示する。
  /// Phase 1 以降ではプレミアム購入画面に遷移する。
  void _onBannerTapped(BuildContext context) {
    // Phase 0: SnackBar でメッセージを表示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('プレミアム購入画面は今後のアップデートで追加されます'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    // TODO: Phase 1 でプレミアム購入画面に遷移する
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (_) => const PremiumScreen()),
    // );
  }
}
