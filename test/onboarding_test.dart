import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itagiri_kun/gen_l10n/app_localizations.dart';
import 'package:itagiri_kun/screens/onboarding_screen.dart';

Widget _buildTestApp({Locale locale = const Locale('ja')}) {
  return ProviderScope(
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const OnboardingScreen(),
    ),
  );
}

void main() {
  group('OnboardingScreen', () {
    testWidgets('最初のページが表示される（大工アイコン）', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.carpenter), findsOneWidget);
    });

    testWidgets('スキップボタンが表示される', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('スキップ'), findsOneWidget);
    });

    testWidgets('最初のページで「次へ」ボタンが表示され「はじめる」は非表示', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('次へ'), findsOneWidget);
      expect(find.text('はじめる'), findsNothing);
    });

    testWidgets('PageView が表示される', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('SafeArea が使用されている', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsAtLeastNWidgets(1));
    });

    testWidgets('FilledButton が1つある（次へ / はじめる）', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(FilledButton), findsOneWidget);
    });
  });
}
