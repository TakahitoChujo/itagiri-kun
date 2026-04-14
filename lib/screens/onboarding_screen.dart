import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../gen_l10n/app_localizations.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

/// 初回起動時に表示するオンボーディング画面
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    await StorageService.markOnboardingDone();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final pages = [
      _OnboardingPage(
        icon: Icons.carpenter,
        title: l10n.onboardingTitle1,
        body: l10n.onboardingBody1,
      ),
      _OnboardingPage(
        icon: Icons.straighten,
        title: l10n.onboardingTitle2,
        body: l10n.onboardingBody2,
      ),
      _OnboardingPage(
        icon: Icons.checklist_rtl,
        title: l10n.onboardingTitle3,
        body: l10n.onboardingBody3,
      ),
      _OnboardingPage(
        icon: Icons.route,
        title: l10n.onboardingTitle4,
        body: l10n.onboardingBody4,
      ),
      _OnboardingPage(
        icon: Icons.save_alt,
        title: l10n.onboardingTitle5,
        body: l10n.onboardingBody5,
      ),
      _OnboardingPage(
        icon: Icons.build_outlined,
        title: l10n.onboardingTitle6,
        body: l10n.onboardingBody6,
      ),
    ];

    final isLast = _currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // スキップボタン
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(l10n.onboardingSkip,
                    style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5))),
              ),
            ),

            // ページコンテンツ
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: pages.length,
                itemBuilder: (context, i) => pages[i],
              ),
            ),

            // インジケーター + ボタン
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // ドットインジケーター
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.primary.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // メインボタン
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLast ? _finish : _goToNextPage,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: Text(isLast ? l10n.onboardingStart : l10n.onboardingNext),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 60, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  height: 1.3,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
