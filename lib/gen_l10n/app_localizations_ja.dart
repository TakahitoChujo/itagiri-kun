// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => '板取りくん';

  @override
  String get settings => '設定';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get reload => '再読み込み';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get ok => 'OK';

  @override
  String get duplicate => '複製';

  @override
  String get close => '閉じる';

  @override
  String get importProject => 'プロジェクトを読み込み';

  @override
  String get newProject => '新規プロジェクト';

  @override
  String get emptyProjectTitle => '新しいプロジェクトを作成しましょう';

  @override
  String get emptyProjectSubtitle => '右下の「新規プロジェクト」ボタンから\n木材のカット計算を始められます';

  @override
  String get selectProjectType => 'プロジェクトの種類を選択';

  @override
  String get cut1DTitle => '1D カット（角材・板材）';

  @override
  String get cut1DSubtitle => '長さ方向のカット最適化';

  @override
  String get cut2DTitle => '2D カット（合板）';

  @override
  String get cut2DSubtitle => '板材の面積最適化';

  @override
  String get duplicateProject => 'プロジェクトを複製';

  @override
  String get deleteProject => 'プロジェクトの削除';

  @override
  String deleteProjectConfirm(String name) {
    return '「$name」を削除しますか？\nこの操作は取り消せません。';
  }

  @override
  String get importFailed => 'ファイルの読み込みに失敗しました';

  @override
  String importSuccess(String name) {
    return '「$name」を読み込みました';
  }

  @override
  String duplicateCreated(String name) {
    return '「$name」を作成しました';
  }

  @override
  String get selectMaterial => '素材を選択';

  @override
  String get allCategories => 'すべて';

  @override
  String get custom => 'カスタム';

  @override
  String get customSettings => 'カスタム設定';

  @override
  String get materialName => '素材名';

  @override
  String get width => '幅';

  @override
  String get height => '高さ';

  @override
  String get length => '長さ';

  @override
  String get startCutting => 'カットを開始';

  @override
  String get pleaseSelectMaterial => '素材を選択してください';

  @override
  String get pleaseEnterLength => '長さを入力してください';

  @override
  String get enterPieces => '部材を入力';

  @override
  String get sizesToCut => '切り出したいサイズ';

  @override
  String get sizesToCut2D => '切り出したいサイズ (2D)';

  @override
  String kerfWidthLabel(String width) {
    return '鋸刃の幅: $width mm';
  }

  @override
  String get columnLength => '長さ(mm)';

  @override
  String get columnQuantity => '数量';

  @override
  String get columnWidth => '幅(mm)';

  @override
  String get columnHeight => '高さ(mm)';

  @override
  String get columnLabel => 'ラベル';

  @override
  String get addSize => 'サイズを追加';

  @override
  String get calculate => '計算する';

  @override
  String get inputError => '入力エラー';

  @override
  String errorLengthRequired(int row) {
    return '$row行目: 長さを入力してください';
  }

  @override
  String errorQuantityRequired(int row) {
    return '$row行目: 数量を1以上にしてください';
  }

  @override
  String errorLengthExceeds(int row, String length, String stockLength) {
    return '$row行目: 長さ(${length}mm)が素材長(${stockLength}mm)を超えています';
  }

  @override
  String get errorNoPieces => '部材を1つ以上入力してください';

  @override
  String get resultTitle => '計算結果';

  @override
  String get resultTitle2D => '計算結果 (2D)';

  @override
  String get checklistTooltip => 'カットチェックリスト';

  @override
  String get exportTooltip => 'エクスポート';

  @override
  String get cutLayout => 'カット配置';

  @override
  String stockNumber(int n) {
    return '$n本目';
  }

  @override
  String sheetNumber(int n) {
    return '$n枚目';
  }

  @override
  String piecesWaste1D(int pieces, String waste) {
    return '$piecesピース / 端材: ${waste}mm';
  }

  @override
  String piecesWaste2D(int pieces, String waste) {
    return '$piecesピース / 端材: ${waste}mm²';
  }

  @override
  String get purchase => '購入';

  @override
  String get totalWaste => '端材合計';

  @override
  String get utilizationRate => '利用率';

  @override
  String get costEstimate => '材料費の見積もり';

  @override
  String get unitPriceLabel => '素材1本あたりの単価:';

  @override
  String get totalCostLabel => '合計金額';

  @override
  String costFormula(int count, String price, String total) {
    return '$count本 x ¥$price = ¥$total';
  }

  @override
  String get saveProject => 'プロジェクトを保存';

  @override
  String get projectUpdated => 'プロジェクトを更新しました';

  @override
  String projectSaved(String name) {
    return '「$name」を保存しました';
  }

  @override
  String exportFailed(String error) {
    return 'エクスポートに失敗しました: $error';
  }

  @override
  String get projectNameDialogTitle => 'プロジェクト名';

  @override
  String get projectNameHint => '例: 本棚用カット';

  @override
  String defaultProjectName(String woodName) {
    return '$woodName カットプラン';
  }

  @override
  String get checklistTitle => 'カットチェックリスト';

  @override
  String get checklistComplete => 'カット完了です！';

  @override
  String get checklistReset => 'リセット';

  @override
  String checklistProgress(int done, int total) {
    return '$done/$total 完了';
  }

  @override
  String get selectSheet => '合板を選択';

  @override
  String get customSheet => 'カスタム合板';

  @override
  String get customSheetSettings => 'カスタム合板設定';

  @override
  String get thickness => '厚さ';

  @override
  String thicknessLabel(String thickness) {
    return '厚さ ${thickness}mm';
  }

  @override
  String get enterPieces2D => '部材を入力 (2D)';

  @override
  String get kerfWidthSetting => '鋸刃の幅（カーフ）';

  @override
  String get kerfWidthDescription => 'カットごとに失われる木材の幅です。\n一般的な鋸刃は約3mmです。';

  @override
  String get unitSystem => '単位系';

  @override
  String get unitMm => 'ミリメートル (mm)';

  @override
  String get unitCm => 'センチメートル (cm)';

  @override
  String get recommended => '推奨';

  @override
  String get language => '言語';

  @override
  String get languageJa => '日本語';

  @override
  String get languageEn => 'English';

  @override
  String get languageSystem => '端末に合わせる';

  @override
  String get appInfo => 'アプリ情報';

  @override
  String get appInfoName => 'アプリ名';

  @override
  String get appInfoVersion => 'バージョン';

  @override
  String get appInfoDescription => '説明';

  @override
  String get appInfoDescriptionValue =>
      'DIY木材カット計算アプリ\n端材を最小にする最適カット配置を自動計算します';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfService => '利用規約';

  @override
  String get openSourceLicenses => 'オープンソースライセンス';

  @override
  String get urlOpenFailed => 'URLを開けませんでした';

  @override
  String get premiumTitle => '板取りくん プレミアム';

  @override
  String get premiumDescription => '広告なし・PDF出力・2D合板対応';

  @override
  String get premiumPriceAppeal => '木材1本分の価格で永久に使える';

  @override
  String get premiumCta => '詳しく見る →';

  @override
  String get premiumComingSoon => 'プレミアム購入画面は今後のアップデートで追加されます';

  @override
  String get onboardingTitle1 => '木材カットを\n賢く最適化';

  @override
  String get onboardingBody1 =>
      '角材・合板の必要なサイズを入力するだけで、端材を最小にする最適なカット配置を自動計算します。';

  @override
  String get onboardingTitle2 => '1D・2D どちらも対応';

  @override
  String get onboardingBody2 =>
      '角材・板材の長さカット（1D）と、合板の面カット（2D）の両方に対応。DIYのあらゆるシーンで活躍します。';

  @override
  String get onboardingTitle3 => 'カットチェックリストで\n作業をサポート';

  @override
  String get onboardingBody3 =>
      '計算結果からカットチェックリストを生成。1本ずつチェックしながら作業できるので、切り間違いを防げます。';

  @override
  String get onboardingSkip => 'スキップ';

  @override
  String get onboardingNext => '次へ';

  @override
  String get onboardingStart => 'はじめる';

  @override
  String get commonLengths => 'よく使う長さ';

  @override
  String selectionSummaryLength(int length) {
    return '長さ: $length mm';
  }

  @override
  String selectionSummaryWithPrice(int length, int price) {
    return '長さ: $length mm / 参考価格: ¥$price';
  }

  @override
  String get themeSetting => 'テーマ';

  @override
  String get themeSystem => '端末に合わせる';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get searchProjects => 'プロジェクトを検索';

  @override
  String searchNoResults(String query) {
    return '「$query」に一致するプロジェクトはありません';
  }

  @override
  String get multipleStockLengths => '複数の長さを選択（最適化で混在）';

  @override
  String stockLengthSummary(int count) {
    return '$count種類の長さ';
  }

  @override
  String offcutSaved(String length) {
    return '端材を保存しました (${length}mm)';
  }

  @override
  String get saveOffcut => '端材を保存';

  @override
  String get savedOffcuts => '保存済みの端材';

  @override
  String get useOffcut => '端材を使用';

  @override
  String offcutLength(String length) {
    return '${length}mm の端材';
  }

  @override
  String get noOffcuts => '保存された端材はありません';

  @override
  String offcutAdded(String length) {
    return '${length}mm の端材を追加しました';
  }
}
