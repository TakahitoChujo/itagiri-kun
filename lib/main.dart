import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants/colors.dart';
import 'constants/dimensions.dart';
import 'gen_l10n/app_localizations.dart';
import 'providers/settings_provider.dart';
import 'services/storage_service.dart';
import 'services/analytics_service.dart';
import 'services/widget_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive ストレージの初期化（全 Box を AES-256 暗号化して開く）
  await StorageService.initStorage();

  // Analytics の初期化（Phase 0: スタブ）
  await AnalyticsService.init();

  // ウィジェットサービスの初期化
  await WidgetService.init();

  runApp(
    const ProviderScope(
      child: ItagiriKunApp(),
    ),
  );
}

/// 板取りくん アプリのルートウィジェット
class ItagiriKunApp extends ConsumerWidget {
  const ItagiriKunApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final locale = settings.language.toLocale();
    final showOnboarding = StorageService.isFirstLaunch;

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: settings.theme.toThemeMode(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: AppDimensions.elevationNone,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
        ),
        cardTheme: CardThemeData(
          elevation: AppDimensions.elevationLow,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS + AppDimensions.paddingXS,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primaryLight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.surfaceVariant,
          thickness: 1,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: AppDimensions.elevationNone,
        ),
      ),
      home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}
