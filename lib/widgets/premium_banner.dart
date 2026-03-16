import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../gen_l10n/app_localizations.dart';
import '../services/premium_service.dart';

/// 設定画面に表示するプレミアムアップグレード導線バナー。
class PremiumBanner extends ConsumerWidget {
  const PremiumBanner({super.key});

  static const _goldenrod = Color(0xFFDAA520);
  static const _backgroundStart = Color(0xFFFFF8E7);
  static const _backgroundEnd = Color(0xFFFFF0C8);
  static const _borderColor = Color(0xFFE8D5A0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

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
                _buildTitle(context),
                const SizedBox(height: 12.0),
                _buildDescription(context),
                const SizedBox(height: 4.0),
                _buildPriceAppeal(context),
                const SizedBox(height: 16.0),
                _buildCta(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        const Icon(Icons.star_rounded, color: _goldenrod, size: 24.0),
        const SizedBox(width: 8.0),
        Text(
          l10n.premiumTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5A4200),
              ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Text(
      l10n.premiumDescription,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF5A4200),
            height: 1.4,
          ),
    );
  }

  Widget _buildPriceAppeal(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Text(
      l10n.premiumPriceAppeal,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF757575),
            height: 1.4,
          ),
    );
  }

  Widget _buildCta(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          l10n.premiumCta,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _onBannerTapped(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.premiumComingSoon),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
