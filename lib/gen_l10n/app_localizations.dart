import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja')
  ];

  /// Application name
  ///
  /// In ja, this message translates to:
  /// **'板取りくん'**
  String get appName;

  /// Settings screen title
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settings;

  /// Generic error message
  ///
  /// In ja, this message translates to:
  /// **'エラーが発生しました'**
  String get errorOccurred;

  /// Reload button
  ///
  /// In ja, this message translates to:
  /// **'再読み込み'**
  String get reload;

  /// Cancel button
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// Save button
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// Delete button
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get delete;

  /// OK button
  ///
  /// In ja, this message translates to:
  /// **'OK'**
  String get ok;

  /// Duplicate action
  ///
  /// In ja, this message translates to:
  /// **'複製'**
  String get duplicate;

  /// Close button
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get close;

  /// Import project tooltip
  ///
  /// In ja, this message translates to:
  /// **'プロジェクトを読み込み'**
  String get importProject;

  /// New project button
  ///
  /// In ja, this message translates to:
  /// **'新規プロジェクト'**
  String get newProject;

  /// Empty state title
  ///
  /// In ja, this message translates to:
  /// **'新しいプロジェクトを作成しましょう'**
  String get emptyProjectTitle;

  /// Empty state subtitle
  ///
  /// In ja, this message translates to:
  /// **'右下の「新規プロジェクト」ボタンから\n木材のカット計算を始められます'**
  String get emptyProjectSubtitle;

  /// Project type selection sheet title
  ///
  /// In ja, this message translates to:
  /// **'プロジェクトの種類を選択'**
  String get selectProjectType;

  /// 1D cut project type title
  ///
  /// In ja, this message translates to:
  /// **'1D カット（角材・板材）'**
  String get cut1DTitle;

  /// 1D cut project type subtitle
  ///
  /// In ja, this message translates to:
  /// **'長さ方向のカット最適化'**
  String get cut1DSubtitle;

  /// 2D cut project type title
  ///
  /// In ja, this message translates to:
  /// **'2D カット（合板）'**
  String get cut2DTitle;

  /// 2D cut project type subtitle
  ///
  /// In ja, this message translates to:
  /// **'板材の面積最適化'**
  String get cut2DSubtitle;

  /// Duplicate project action
  ///
  /// In ja, this message translates to:
  /// **'プロジェクトを複製'**
  String get duplicateProject;

  /// Delete project dialog title
  ///
  /// In ja, this message translates to:
  /// **'プロジェクトの削除'**
  String get deleteProject;

  /// Delete project confirmation message
  ///
  /// In ja, this message translates to:
  /// **'「{name}」を削除しますか？\nこの操作は取り消せません。'**
  String deleteProjectConfirm(String name);

  /// Import failed error message
  ///
  /// In ja, this message translates to:
  /// **'ファイルの読み込みに失敗しました'**
  String get importFailed;

  /// Import success message
  ///
  /// In ja, this message translates to:
  /// **'「{name}」を読み込みました'**
  String importSuccess(String name);

  /// Duplicate created message
  ///
  /// In ja, this message translates to:
  /// **'「{name}」を作成しました'**
  String duplicateCreated(String name);

  /// Material selection heading
  ///
  /// In ja, this message translates to:
  /// **'素材を選択'**
  String get selectMaterial;

  /// All categories filter chip
  ///
  /// In ja, this message translates to:
  /// **'すべて'**
  String get allCategories;

  /// Custom option
  ///
  /// In ja, this message translates to:
  /// **'カスタム'**
  String get custom;

  /// Custom settings heading
  ///
  /// In ja, this message translates to:
  /// **'カスタム設定'**
  String get customSettings;

  /// Material name field label
  ///
  /// In ja, this message translates to:
  /// **'素材名'**
  String get materialName;

  /// Width label
  ///
  /// In ja, this message translates to:
  /// **'幅'**
  String get width;

  /// Height label
  ///
  /// In ja, this message translates to:
  /// **'高さ'**
  String get height;

  /// Length label
  ///
  /// In ja, this message translates to:
  /// **'長さ'**
  String get length;

  /// Start cutting button
  ///
  /// In ja, this message translates to:
  /// **'カットを開始'**
  String get startCutting;

  /// Validation: no material selected
  ///
  /// In ja, this message translates to:
  /// **'素材を選択してください'**
  String get pleaseSelectMaterial;

  /// Validation: length not entered
  ///
  /// In ja, this message translates to:
  /// **'長さを入力してください'**
  String get pleaseEnterLength;

  /// Pieces input screen title (no existing project)
  ///
  /// In ja, this message translates to:
  /// **'部材を入力'**
  String get enterPieces;

  /// Pieces input header
  ///
  /// In ja, this message translates to:
  /// **'切り出したいサイズ'**
  String get sizesToCut;

  /// 2D pieces input header
  ///
  /// In ja, this message translates to:
  /// **'切り出したいサイズ (2D)'**
  String get sizesToCut2D;

  /// Kerf width info label
  ///
  /// In ja, this message translates to:
  /// **'鋸刃の幅: {width} mm'**
  String kerfWidthLabel(String width);

  /// Length column header
  ///
  /// In ja, this message translates to:
  /// **'長さ(mm)'**
  String get columnLength;

  /// Quantity column header
  ///
  /// In ja, this message translates to:
  /// **'数量'**
  String get columnQuantity;

  /// Width column header
  ///
  /// In ja, this message translates to:
  /// **'幅(mm)'**
  String get columnWidth;

  /// Height column header
  ///
  /// In ja, this message translates to:
  /// **'高さ(mm)'**
  String get columnHeight;

  /// Label column header
  ///
  /// In ja, this message translates to:
  /// **'ラベル'**
  String get columnLabel;

  /// Add size button
  ///
  /// In ja, this message translates to:
  /// **'サイズを追加'**
  String get addSize;

  /// Calculate button
  ///
  /// In ja, this message translates to:
  /// **'計算する'**
  String get calculate;

  /// Input error dialog title
  ///
  /// In ja, this message translates to:
  /// **'入力エラー'**
  String get inputError;

  /// Validation error: length required
  ///
  /// In ja, this message translates to:
  /// **'{row}行目: 長さを入力してください'**
  String errorLengthRequired(int row);

  /// Validation error: quantity required
  ///
  /// In ja, this message translates to:
  /// **'{row}行目: 数量を1以上にしてください'**
  String errorQuantityRequired(int row);

  /// Validation error: length exceeds stock
  ///
  /// In ja, this message translates to:
  /// **'{row}行目: 長さ({length}mm)が素材長({stockLength}mm)を超えています'**
  String errorLengthExceeds(int row, String length, String stockLength);

  /// Validation error: no pieces
  ///
  /// In ja, this message translates to:
  /// **'部材を1つ以上入力してください'**
  String get errorNoPieces;

  /// Result screen title
  ///
  /// In ja, this message translates to:
  /// **'計算結果'**
  String get resultTitle;

  /// 2D result screen title
  ///
  /// In ja, this message translates to:
  /// **'計算結果 (2D)'**
  String get resultTitle2D;

  /// Checklist icon tooltip
  ///
  /// In ja, this message translates to:
  /// **'カットチェックリスト'**
  String get checklistTooltip;

  /// Export icon tooltip
  ///
  /// In ja, this message translates to:
  /// **'エクスポート'**
  String get exportTooltip;

  /// Cut layout section header
  ///
  /// In ja, this message translates to:
  /// **'カット配置'**
  String get cutLayout;

  /// nth stock label (1D)
  ///
  /// In ja, this message translates to:
  /// **'{n}本目'**
  String stockNumber(int n);

  /// nth sheet label (2D)
  ///
  /// In ja, this message translates to:
  /// **'{n}枚目'**
  String sheetNumber(int n);

  /// Pieces and waste label for 1D bin
  ///
  /// In ja, this message translates to:
  /// **'{pieces}ピース / 端材: {waste}mm'**
  String piecesWaste1D(int pieces, String waste);

  /// Pieces and waste label for 2D bin
  ///
  /// In ja, this message translates to:
  /// **'{pieces}ピース / 端材: {waste}mm²'**
  String piecesWaste2D(int pieces, String waste);

  /// Purchase label in summary card
  ///
  /// In ja, this message translates to:
  /// **'購入'**
  String get purchase;

  /// Total waste label
  ///
  /// In ja, this message translates to:
  /// **'端材合計'**
  String get totalWaste;

  /// Utilization rate label
  ///
  /// In ja, this message translates to:
  /// **'利用率'**
  String get utilizationRate;

  /// Cost estimate card title
  ///
  /// In ja, this message translates to:
  /// **'材料費の見積もり'**
  String get costEstimate;

  /// Unit price label
  ///
  /// In ja, this message translates to:
  /// **'素材1本あたりの単価:'**
  String get unitPriceLabel;

  /// Total cost label
  ///
  /// In ja, this message translates to:
  /// **'合計金額'**
  String get totalCostLabel;

  /// Cost formula breakdown
  ///
  /// In ja, this message translates to:
  /// **'{count}本 x ¥{price} = ¥{total}'**
  String costFormula(int count, String price, String total);

  /// Save project button
  ///
  /// In ja, this message translates to:
  /// **'プロジェクトを保存'**
  String get saveProject;

  /// Project updated snackbar
  ///
  /// In ja, this message translates to:
  /// **'プロジェクトを更新しました'**
  String get projectUpdated;

  /// Project saved snackbar
  ///
  /// In ja, this message translates to:
  /// **'「{name}」を保存しました'**
  String projectSaved(String name);

  /// Export failed error message
  ///
  /// In ja, this message translates to:
  /// **'エクスポートに失敗しました: {error}'**
  String exportFailed(String error);

  /// Project name dialog title
  ///
  /// In ja, this message translates to:
  /// **'プロジェクト名'**
  String get projectNameDialogTitle;

  /// Project name hint text
  ///
  /// In ja, this message translates to:
  /// **'例: 本棚用カット'**
  String get projectNameHint;

  /// Default project name
  ///
  /// In ja, this message translates to:
  /// **'{woodName} カットプラン'**
  String defaultProjectName(String woodName);

  /// Checklist screen title
  ///
  /// In ja, this message translates to:
  /// **'カットチェックリスト'**
  String get checklistTitle;

  /// All cuts done message
  ///
  /// In ja, this message translates to:
  /// **'カット完了です！'**
  String get checklistComplete;

  /// Reset checklist button
  ///
  /// In ja, this message translates to:
  /// **'リセット'**
  String get checklistReset;

  /// Checklist progress label
  ///
  /// In ja, this message translates to:
  /// **'{done}/{total} 完了'**
  String checklistProgress(int done, int total);

  /// Sheet selection screen title and heading
  ///
  /// In ja, this message translates to:
  /// **'合板を選択'**
  String get selectSheet;

  /// Custom sheet option name
  ///
  /// In ja, this message translates to:
  /// **'カスタム合板'**
  String get customSheet;

  /// Custom sheet settings heading
  ///
  /// In ja, this message translates to:
  /// **'カスタム合板設定'**
  String get customSheetSettings;

  /// Thickness label
  ///
  /// In ja, this message translates to:
  /// **'厚さ'**
  String get thickness;

  /// Thickness label with value
  ///
  /// In ja, this message translates to:
  /// **'厚さ {thickness}mm'**
  String thicknessLabel(String thickness);

  /// 2D pieces input screen title
  ///
  /// In ja, this message translates to:
  /// **'部材を入力 (2D)'**
  String get enterPieces2D;

  /// Kerf width setting card title
  ///
  /// In ja, this message translates to:
  /// **'鋸刃の幅（カーフ）'**
  String get kerfWidthSetting;

  /// Kerf width description
  ///
  /// In ja, this message translates to:
  /// **'カットごとに失われる木材の幅です。\n一般的な鋸刃は約3mmです。'**
  String get kerfWidthDescription;

  /// Unit system setting card title
  ///
  /// In ja, this message translates to:
  /// **'単位系'**
  String get unitSystem;

  /// Millimeter unit option
  ///
  /// In ja, this message translates to:
  /// **'ミリメートル (mm)'**
  String get unitMm;

  /// Centimeter unit option
  ///
  /// In ja, this message translates to:
  /// **'センチメートル (cm)'**
  String get unitCm;

  /// Recommended badge
  ///
  /// In ja, this message translates to:
  /// **'推奨'**
  String get recommended;

  /// Language setting card title
  ///
  /// In ja, this message translates to:
  /// **'言語'**
  String get language;

  /// Japanese language option
  ///
  /// In ja, this message translates to:
  /// **'日本語'**
  String get languageJa;

  /// English language option
  ///
  /// In ja, this message translates to:
  /// **'English'**
  String get languageEn;

  /// System language option
  ///
  /// In ja, this message translates to:
  /// **'端末に合わせる'**
  String get languageSystem;

  /// App info section title
  ///
  /// In ja, this message translates to:
  /// **'アプリ情報'**
  String get appInfo;

  /// App name label
  ///
  /// In ja, this message translates to:
  /// **'アプリ名'**
  String get appInfoName;

  /// Version label
  ///
  /// In ja, this message translates to:
  /// **'バージョン'**
  String get appInfoVersion;

  /// Description label
  ///
  /// In ja, this message translates to:
  /// **'説明'**
  String get appInfoDescription;

  /// App description text
  ///
  /// In ja, this message translates to:
  /// **'DIY木材カット計算アプリ\n端材を最小にする最適カット配置を自動計算します'**
  String get appInfoDescriptionValue;

  /// Privacy policy link
  ///
  /// In ja, this message translates to:
  /// **'プライバシーポリシー'**
  String get privacyPolicy;

  /// Terms of service link
  ///
  /// In ja, this message translates to:
  /// **'利用規約'**
  String get termsOfService;

  /// Open source licenses link
  ///
  /// In ja, this message translates to:
  /// **'オープンソースライセンス'**
  String get openSourceLicenses;

  /// URL open failed snackbar
  ///
  /// In ja, this message translates to:
  /// **'URLを開けませんでした'**
  String get urlOpenFailed;

  /// Premium banner title
  ///
  /// In ja, this message translates to:
  /// **'板取りくん プレミアム'**
  String get premiumTitle;

  /// Premium features description
  ///
  /// In ja, this message translates to:
  /// **'広告なし・PDF出力・2D合板対応'**
  String get premiumDescription;

  /// Premium price appeal text
  ///
  /// In ja, this message translates to:
  /// **'木材1本分の価格で永久に使える'**
  String get premiumPriceAppeal;

  /// Premium CTA button
  ///
  /// In ja, this message translates to:
  /// **'詳しく見る →'**
  String get premiumCta;

  /// Premium coming soon message
  ///
  /// In ja, this message translates to:
  /// **'プレミアム購入画面は今後のアップデートで追加されます'**
  String get premiumComingSoon;

  /// Onboarding page 1 title
  ///
  /// In ja, this message translates to:
  /// **'木材カットを\n賢く最適化'**
  String get onboardingTitle1;

  /// Onboarding page 1 body
  ///
  /// In ja, this message translates to:
  /// **'角材・合板の必要なサイズを入力するだけで、端材を最小にする最適なカット配置を自動計算します。'**
  String get onboardingBody1;

  /// Onboarding page 2 title
  ///
  /// In ja, this message translates to:
  /// **'1D・2D どちらも対応'**
  String get onboardingTitle2;

  /// Onboarding page 2 body
  ///
  /// In ja, this message translates to:
  /// **'角材・板材の長さカット（1D）と、合板の面カット（2D）の両方に対応。DIYのあらゆるシーンで活躍します。'**
  String get onboardingBody2;

  /// Onboarding page 3 title
  ///
  /// In ja, this message translates to:
  /// **'カットチェックリストで\n作業をサポート'**
  String get onboardingTitle3;

  /// Onboarding page 3 body
  ///
  /// In ja, this message translates to:
  /// **'計算結果からカットチェックリストを生成。1本ずつチェックしながら作業できるので、切り間違いを防げます。'**
  String get onboardingBody3;

  /// Onboarding skip button
  ///
  /// In ja, this message translates to:
  /// **'スキップ'**
  String get onboardingSkip;

  /// Onboarding next button
  ///
  /// In ja, this message translates to:
  /// **'次へ'**
  String get onboardingNext;

  /// Onboarding start button
  ///
  /// In ja, this message translates to:
  /// **'はじめる'**
  String get onboardingStart;

  /// Common lengths quick-select label
  ///
  /// In ja, this message translates to:
  /// **'よく使う長さ'**
  String get commonLengths;

  /// Selection summary: length only
  ///
  /// In ja, this message translates to:
  /// **'長さ: {length} mm'**
  String selectionSummaryLength(int length);

  /// Selection summary: length + reference price
  ///
  /// In ja, this message translates to:
  /// **'長さ: {length} mm / 参考価格: ¥{price}'**
  String selectionSummaryWithPrice(int length, int price);

  /// Theme setting card title
  ///
  /// In ja, this message translates to:
  /// **'テーマ'**
  String get themeSetting;

  /// System theme option
  ///
  /// In ja, this message translates to:
  /// **'端末に合わせる'**
  String get themeSystem;

  /// Light theme option
  ///
  /// In ja, this message translates to:
  /// **'ライト'**
  String get themeLight;

  /// Dark theme option
  ///
  /// In ja, this message translates to:
  /// **'ダーク'**
  String get themeDark;

  /// Search projects hint text
  ///
  /// In ja, this message translates to:
  /// **'プロジェクトを検索'**
  String get searchProjects;

  /// No search results message
  ///
  /// In ja, this message translates to:
  /// **'「{query}」に一致するプロジェクトはありません'**
  String searchNoResults(String query);

  /// Multiple stock lengths hint
  ///
  /// In ja, this message translates to:
  /// **'複数の長さを選択（最適化で混在）'**
  String get multipleStockLengths;

  /// Summary when multiple stock lengths selected
  ///
  /// In ja, this message translates to:
  /// **'{count}種類の長さ'**
  String stockLengthSummary(int count);

  /// Offcut saved snackbar
  ///
  /// In ja, this message translates to:
  /// **'端材を保存しました ({length}mm)'**
  String offcutSaved(String length);

  /// Save offcut button
  ///
  /// In ja, this message translates to:
  /// **'端材を保存'**
  String get saveOffcut;

  /// Saved offcuts section title
  ///
  /// In ja, this message translates to:
  /// **'保存済みの端材'**
  String get savedOffcuts;

  /// Use offcut button
  ///
  /// In ja, this message translates to:
  /// **'端材を使用'**
  String get useOffcut;

  /// Offcut length label
  ///
  /// In ja, this message translates to:
  /// **'{length}mm の端材'**
  String offcutLength(String length);

  /// No offcuts available message
  ///
  /// In ja, this message translates to:
  /// **'保存された端材はありません'**
  String get noOffcuts;

  /// Offcut added to project message
  ///
  /// In ja, this message translates to:
  /// **'{length}mm の端材を追加しました'**
  String offcutAdded(String length);

  /// Undo action
  ///
  /// In ja, this message translates to:
  /// **'元に戻す'**
  String get undo;

  /// Redo action
  ///
  /// In ja, this message translates to:
  /// **'やり直す'**
  String get redo;

  /// Label for bins made from saved offcuts
  ///
  /// In ja, this message translates to:
  /// **'端材から'**
  String get fromOffcut;

  /// Use project as template action
  ///
  /// In ja, this message translates to:
  /// **'テンプレとして使用'**
  String get useAsTemplate;

  /// Share as image menu option
  ///
  /// In ja, this message translates to:
  /// **'画像として共有'**
  String get shareAsImage;

  /// Data management section title
  ///
  /// In ja, this message translates to:
  /// **'データ管理'**
  String get dataManagement;

  /// Data management description
  ///
  /// In ja, this message translates to:
  /// **'全プロジェクトと端材データをバックアップ・復元できます。\niCloud Drive経由でデバイス間の移行にも使えます。'**
  String get dataManagementDescription;

  /// Export backup button
  ///
  /// In ja, this message translates to:
  /// **'バックアップ'**
  String get exportBackup;

  /// Import backup button
  ///
  /// In ja, this message translates to:
  /// **'復元'**
  String get importBackup;

  /// Backup import success message
  ///
  /// In ja, this message translates to:
  /// **'復元完了: プロジェクト{projects}件、端材{offcuts}件'**
  String backupImportSuccess(int projects, int offcuts);

  /// Backup import failed message
  ///
  /// In ja, this message translates to:
  /// **'バックアップの読み込みに失敗しました'**
  String get backupImportFailed;

  /// No data to backup message
  ///
  /// In ja, this message translates to:
  /// **'バックアップするデータがありません'**
  String get backupNoData;

  /// Default sheet project name
  ///
  /// In ja, this message translates to:
  /// **'{sheetName} カットプラン'**
  String defaultSheetProjectName(String sheetName);

  /// Unit price label for sheet
  ///
  /// In ja, this message translates to:
  /// **'合板1枚あたりの単価:'**
  String get unitPriceLabelSheet;

  /// Cost formula for sheet
  ///
  /// In ja, this message translates to:
  /// **'{count}枚 x ¥{price} = ¥{total}'**
  String costFormulaSheet(int count, String price, String total);

  /// Sheet count badge
  ///
  /// In ja, this message translates to:
  /// **'{count}枚'**
  String sheetsCount(int count);

  /// Custom presets section
  ///
  /// In ja, this message translates to:
  /// **'カスタムプリセット'**
  String get customPresets;

  /// Add custom preset button
  ///
  /// In ja, this message translates to:
  /// **'カスタムプリセットを追加'**
  String get addCustomPreset;

  /// Edit custom preset dialog title
  ///
  /// In ja, this message translates to:
  /// **'プリセットを編集'**
  String get editCustomPreset;

  /// Delete preset action
  ///
  /// In ja, this message translates to:
  /// **'プリセットを削除'**
  String get deletePreset;

  /// Delete preset confirmation
  ///
  /// In ja, this message translates to:
  /// **'「{name}」を削除しますか？'**
  String deletePresetConfirm(String name);

  /// Preset saved message
  ///
  /// In ja, this message translates to:
  /// **'プリセット「{name}」を保存しました'**
  String presetSaved(String name);

  /// Custom preset name hint
  ///
  /// In ja, this message translates to:
  /// **'例: ツーバイフォー SPF'**
  String get presetNameHint;

  /// Price label
  ///
  /// In ja, this message translates to:
  /// **'価格'**
  String get price;

  /// Frequent sizes section
  ///
  /// In ja, this message translates to:
  /// **'よく使うサイズ'**
  String get frequentSizes;

  /// Frequent labels section
  ///
  /// In ja, this message translates to:
  /// **'よく使うラベル'**
  String get frequentLabels;

  /// Usage count label
  ///
  /// In ja, this message translates to:
  /// **'{count}回使用'**
  String usedNTimes(int count);

  /// Project notes field label
  ///
  /// In ja, this message translates to:
  /// **'メモ'**
  String get projectNotes;

  /// Project notes hint
  ///
  /// In ja, this message translates to:
  /// **'メモを入力...'**
  String get projectNotesHint;

  /// Attach photo button
  ///
  /// In ja, this message translates to:
  /// **'写真を添付'**
  String get attachPhoto;

  /// Remove photo button
  ///
  /// In ja, this message translates to:
  /// **'写真を削除'**
  String get removePhoto;

  /// Take photo option
  ///
  /// In ja, this message translates to:
  /// **'カメラで撮影'**
  String get takePhoto;

  /// Choose from gallery option
  ///
  /// In ja, this message translates to:
  /// **'ギャラリーから選択'**
  String get chooseFromGallery;

  /// Offcut inventory screen title
  ///
  /// In ja, this message translates to:
  /// **'端材在庫'**
  String get offcutInventory;

  /// Empty offcut inventory message
  ///
  /// In ja, this message translates to:
  /// **'端材在庫はありません'**
  String get offcutInventoryEmpty;

  /// Empty offcut inventory subtitle
  ///
  /// In ja, this message translates to:
  /// **'プロジェクトの計算結果から端材を保存できます'**
  String get offcutInventorySubtitle;

  /// Add offcut manually button
  ///
  /// In ja, this message translates to:
  /// **'端材を手動追加'**
  String get addOffcutManually;

  /// Offcut wood name label
  ///
  /// In ja, this message translates to:
  /// **'木材名'**
  String get offcutWoodName;

  /// Offcut count label
  ///
  /// In ja, this message translates to:
  /// **'端材: {count}件'**
  String offcutCount(int count);

  /// Compare layouts button
  ///
  /// In ja, this message translates to:
  /// **'レイアウト比較'**
  String get compareLayouts;

  /// Comparison results screen title
  ///
  /// In ja, this message translates to:
  /// **'比較結果'**
  String get comparisonResults;

  /// FFD strategy name
  ///
  /// In ja, this message translates to:
  /// **'最大ピース優先 (FFD)'**
  String get strategyFFD;

  /// BFD strategy name
  ///
  /// In ja, this message translates to:
  /// **'最適充填優先 (BFD)'**
  String get strategyBFD;

  /// First Fit strategy name
  ///
  /// In ja, this message translates to:
  /// **'先着順 (FF)'**
  String get strategyFF;

  /// Best result badge
  ///
  /// In ja, this message translates to:
  /// **'最良'**
  String get bestResult;

  /// Stocks used label
  ///
  /// In ja, this message translates to:
  /// **'素材使用数'**
  String get stocksUsed;

  /// Waste amount label
  ///
  /// In ja, this message translates to:
  /// **'端材量'**
  String get wasteAmount;

  /// Use this layout button
  ///
  /// In ja, this message translates to:
  /// **'このレイアウトを使用'**
  String get useThisLayout;

  /// Cost dashboard screen title
  ///
  /// In ja, this message translates to:
  /// **'コスト分析'**
  String get costDashboard;

  /// Total spent label
  ///
  /// In ja, this message translates to:
  /// **'総材料費'**
  String get totalSpent;

  /// Average utilization label
  ///
  /// In ja, this message translates to:
  /// **'平均利用率'**
  String get averageUtilization;

  /// Total projects label
  ///
  /// In ja, this message translates to:
  /// **'プロジェクト数'**
  String get totalProjects;

  /// Cost by project chart title
  ///
  /// In ja, this message translates to:
  /// **'プロジェクト別コスト'**
  String get costByProject;

  /// Utilization trend chart title
  ///
  /// In ja, this message translates to:
  /// **'利用率推移'**
  String get utilizationTrend;

  /// Waste by material chart title
  ///
  /// In ja, this message translates to:
  /// **'素材別端材量'**
  String get wasteByMaterial;

  /// No data for chart message
  ///
  /// In ja, this message translates to:
  /// **'グラフを表示するデータがありません'**
  String get noDataForChart;

  /// Unit converter screen title
  ///
  /// In ja, this message translates to:
  /// **'単位換算'**
  String get unitConverter;

  /// Convert from label
  ///
  /// In ja, this message translates to:
  /// **'変換元'**
  String get convertFrom;

  /// Convert to label
  ///
  /// In ja, this message translates to:
  /// **'変換先'**
  String get convertTo;

  /// Conversion result label
  ///
  /// In ja, this message translates to:
  /// **'変換結果'**
  String get conversionResult;

  /// All units list header
  ///
  /// In ja, this message translates to:
  /// **'全単位一覧'**
  String get allUnits;

  /// Batch export button
  ///
  /// In ja, this message translates to:
  /// **'一括エクスポート'**
  String get batchExport;

  /// Batch export screen title
  ///
  /// In ja, this message translates to:
  /// **'一括エクスポート'**
  String get batchExportTitle;

  /// Select projects header
  ///
  /// In ja, this message translates to:
  /// **'プロジェクトを選択'**
  String get selectProjects;

  /// Select all button
  ///
  /// In ja, this message translates to:
  /// **'すべて選択'**
  String get selectAll;

  /// Deselect all button
  ///
  /// In ja, this message translates to:
  /// **'すべて解除'**
  String get deselectAll;

  /// Export format label
  ///
  /// In ja, this message translates to:
  /// **'エクスポート形式'**
  String get exportFormat;

  /// Export as PDF option
  ///
  /// In ja, this message translates to:
  /// **'PDF'**
  String get exportAsPdf;

  /// Export as CSV option
  ///
  /// In ja, this message translates to:
  /// **'CSV'**
  String get exportAsCsv;

  /// Selected projects count
  ///
  /// In ja, this message translates to:
  /// **'{count}件を選択中'**
  String exportSelectedCount(int count);

  /// Export started message
  ///
  /// In ja, this message translates to:
  /// **'エクスポートを開始しました'**
  String get exportStarted;

  /// No projects selected warning
  ///
  /// In ja, this message translates to:
  /// **'プロジェクトを選択してください'**
  String get noProjectsSelected;

  /// Tools section title on home/settings
  ///
  /// In ja, this message translates to:
  /// **'ツール'**
  String get tools;

  /// Grain direction label
  ///
  /// In ja, this message translates to:
  /// **'木目'**
  String get grainDirection;

  /// No grain constraint
  ///
  /// In ja, this message translates to:
  /// **'なし'**
  String get grainNone;

  /// Horizontal grain direction
  ///
  /// In ja, this message translates to:
  /// **'横目'**
  String get grainHorizontal;

  /// Vertical grain direction
  ///
  /// In ja, this message translates to:
  /// **'縦目'**
  String get grainVertical;

  /// CSV import button tooltip
  ///
  /// In ja, this message translates to:
  /// **'CSVインポート'**
  String get csvImport;

  /// CSV import empty result
  ///
  /// In ja, this message translates to:
  /// **'インポートできる部品が見つかりませんでした'**
  String get csvImportEmpty;

  /// CSV import success message
  ///
  /// In ja, this message translates to:
  /// **'{count}件の部品をインポートしました'**
  String csvImportSuccess(int count);

  /// CSV import failed message
  ///
  /// In ja, this message translates to:
  /// **'CSVファイルの読み込みに失敗しました'**
  String get csvImportFailed;

  /// Enable fraction input mode tooltip
  ///
  /// In ja, this message translates to:
  /// **'分数入力モードを有効にする'**
  String get fractionModeOn;

  /// Disable fraction input mode tooltip
  ///
  /// In ja, this message translates to:
  /// **'通常入力モードに戻す'**
  String get fractionModeOff;

  /// Fraction input hint
  ///
  /// In ja, this message translates to:
  /// **'例: 1/2, 3 1/4'**
  String get fractionHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
