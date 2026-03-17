import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itagiri_kun/gen_l10n/app_localizations.dart';
import 'package:itagiri_kun/models/cut_piece.dart';
import 'package:itagiri_kun/models/cut_result.dart';
import 'package:itagiri_kun/models/project.dart';
import 'package:itagiri_kun/models/wood_stock.dart';
import 'package:itagiri_kun/providers/project_provider.dart';
import 'package:itagiri_kun/screens/result_screen.dart';
import 'package:itagiri_kun/services/premium_service.dart';

// テスト用ダミーデータ
final _wood = WoodStock(name: '2x4', width: 38, height: 89, lengths: [1820]);
const _result = CutResult(
  bins: [
    CutBin(
      pieces: [
        CutPieceResult(length: 500),
        CutPieceResult(length: 500),
      ],
      waste: 817,
      stockLength: 1820,
    ),
  ],
  totalStock: 1,
  totalWaste: 817,
  utilizationRate: 0.55,
);
const _pieces = [CutPiece(length: 500, quantity: 2)];

Widget _buildTestApp({Widget? home}) {
  return ProviderScope(
    overrides: [
      // Hive 不要にするため projectsProvider をオーバーライド
      projectsProvider.overrideWith((_) async => <Project>[]),
      // プレミアム状態をシンプルに false に固定
      isPremiumProvider.overrideWith((_) => false),
    ],
    child: MaterialApp(
      locale: const Locale('ja'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home ??
          ResultScreen(
            result: _result,
            woodStock: _wood,
            stockLength: 1820,
            pieces: _pieces,
            kerfWidth: 3.0,
          ),
    ),
  );
}

void main() {
  // 十分な高さを確保して全コンテンツを表示
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('ResultScreen', () {
    testWidgets('画面が正常に表示される', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('保存ボタンが表示される', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('プロジェクトを保存'), findsWidgets);
    });

    testWidgets('切断レイアウトに素材番号が表示される', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // 1本目の素材ラベル（l10n.stockNumber(1) = '1本目'）
      expect(find.text('1本目'), findsOneWidget);
    });

    testWidgets('保存ボタンタップでプロジェクト名ダイアログが表示される', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // FilledButton（最後のもの = 保存ボタン）をタップ
      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle();

      // AlertDialog が表示される（プロジェクト名入力ダイアログ）
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('既存プロジェクト更新時に保存ボタンが表示される', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final existingProject = Project(
        id: 'existing-id',
        name: '既存プロジェクト',
        woodStock: _wood,
        stockLength: 1820,
        pieces: _pieces,
        kerfWidth: 3.0,
        result: _result,
      );

      await tester.pumpWidget(_buildTestApp(
        home: ResultScreen(
          result: _result,
          woodStock: _wood,
          stockLength: 1820,
          pieces: _pieces,
          kerfWidth: 3.0,
          existingProject: existingProject,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(FilledButton), findsAtLeastNWidgets(1));
    });

    testWidgets('稼働率が表示される', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // 55.0% の稼働率が表示される
      expect(find.text('55.0%'), findsOneWidget);
    });

    testWidgets('端材が 50mm 以上のとき端材保存ボタンが表示される', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // waste=817mm なので端材保存ボタンが表示される
      expect(find.byIcon(Icons.save_alt), findsOneWidget);
    });
  });
}
