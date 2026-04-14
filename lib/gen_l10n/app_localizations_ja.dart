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
  String get onboardingTitle4 => 'プロジェクトの\n始め方';

  @override
  String get onboardingBody4 =>
      '「新規プロジェクト」から素材を選び、切り出したいサイズを入力して「計算する」をタップ。最適なカット配置が自動で表示されます。';

  @override
  String get onboardingTitle5 => '保存＆エクスポート';

  @override
  String get onboardingBody5 =>
      '計算結果をプロジェクトとして保存し、いつでも確認できます。PDF・CSVでのエクスポートやバックアップ・復元にも対応しています。';

  @override
  String get onboardingTitle6 => '便利ツール';

  @override
  String get onboardingBody6 =>
      '端材を在庫として管理し、次のプロジェクトで再利用できます。単位換算ツールも搭載し、mm・cm・インチの変換もかんたんです。';

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

  @override
  String get undo => '元に戻す';

  @override
  String get redo => 'やり直す';

  @override
  String get fromOffcut => '端材から';

  @override
  String get useAsTemplate => 'テンプレとして使用';

  @override
  String get shareAsImage => '画像として共有';

  @override
  String get dataManagement => 'データ管理';

  @override
  String get dataManagementDescription =>
      '全プロジェクトと端材データをバックアップ・復元できます。\niCloud Drive経由でデバイス間の移行にも使えます。';

  @override
  String get exportBackup => 'バックアップ';

  @override
  String get importBackup => '復元';

  @override
  String backupImportSuccess(int projects, int offcuts) {
    return '復元完了: プロジェクト$projects件、端材$offcuts件';
  }

  @override
  String get backupImportFailed => 'バックアップの読み込みに失敗しました';

  @override
  String get backupNoData => 'バックアップするデータがありません';

  @override
  String defaultSheetProjectName(String sheetName) {
    return '$sheetName カットプラン';
  }

  @override
  String get unitPriceLabelSheet => '合板1枚あたりの単価:';

  @override
  String costFormulaSheet(int count, String price, String total) {
    return '$count枚 x ¥$price = ¥$total';
  }

  @override
  String sheetsCount(int count) {
    return '$count枚';
  }

  @override
  String get customPresets => 'カスタムプリセット';

  @override
  String get addCustomPreset => 'カスタムプリセットを追加';

  @override
  String get editCustomPreset => 'プリセットを編集';

  @override
  String get deletePreset => 'プリセットを削除';

  @override
  String deletePresetConfirm(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String presetSaved(String name) {
    return 'プリセット「$name」を保存しました';
  }

  @override
  String get presetNameHint => '例: ツーバイフォー SPF';

  @override
  String get price => '価格';

  @override
  String get frequentSizes => 'よく使うサイズ';

  @override
  String get frequentLabels => 'よく使うラベル';

  @override
  String usedNTimes(int count) {
    return '$count回使用';
  }

  @override
  String get projectNotes => 'メモ';

  @override
  String get projectNotesHint => 'メモを入力...';

  @override
  String get attachPhoto => '写真を添付';

  @override
  String get removePhoto => '写真を削除';

  @override
  String get takePhoto => 'カメラで撮影';

  @override
  String get chooseFromGallery => 'ギャラリーから選択';

  @override
  String get offcutInventory => '端材在庫';

  @override
  String get offcutInventoryEmpty => '端材在庫はありません';

  @override
  String get offcutInventorySubtitle => 'プロジェクトの計算結果から端材を保存できます';

  @override
  String get addOffcutManually => '端材を手動追加';

  @override
  String get offcutWoodName => '木材名';

  @override
  String offcutCount(int count) {
    return '端材: $count件';
  }

  @override
  String get compareLayouts => 'レイアウト比較';

  @override
  String get comparisonResults => '比較結果';

  @override
  String get strategyFFD => '最大ピース優先 (FFD)';

  @override
  String get strategyBFD => '最適充填優先 (BFD)';

  @override
  String get strategyFF => '先着順 (FF)';

  @override
  String get bestResult => '最良';

  @override
  String get stocksUsed => '素材使用数';

  @override
  String get wasteAmount => '端材量';

  @override
  String get useThisLayout => 'このレイアウトを使用';

  @override
  String get costDashboard => 'コスト分析';

  @override
  String get totalSpent => '総材料費';

  @override
  String get averageUtilization => '平均利用率';

  @override
  String get totalProjects => 'プロジェクト数';

  @override
  String get costByProject => 'プロジェクト別コスト';

  @override
  String get utilizationTrend => '利用率推移';

  @override
  String get wasteByMaterial => '素材別端材量';

  @override
  String get noDataForChart => 'グラフを表示するデータがありません';

  @override
  String get unitConverter => '単位換算';

  @override
  String get convertFrom => '変換元';

  @override
  String get convertTo => '変換先';

  @override
  String get conversionResult => '変換結果';

  @override
  String get allUnits => '全単位一覧';

  @override
  String get batchExport => '一括エクスポート';

  @override
  String get batchExportTitle => '一括エクスポート';

  @override
  String get selectProjects => 'プロジェクトを選択';

  @override
  String get selectAll => 'すべて選択';

  @override
  String get deselectAll => 'すべて解除';

  @override
  String get exportFormat => 'エクスポート形式';

  @override
  String get exportAsPdf => 'PDF';

  @override
  String get exportAsCsv => 'CSV';

  @override
  String exportSelectedCount(int count) {
    return '$count件を選択中';
  }

  @override
  String get exportStarted => 'エクスポートを開始しました';

  @override
  String get noProjectsSelected => 'プロジェクトを選択してください';

  @override
  String get tools => 'ツール';

  @override
  String get grainDirection => '木目';

  @override
  String get grainNone => 'なし';

  @override
  String get grainHorizontal => '横目';

  @override
  String get grainVertical => '縦目';

  @override
  String get csvImport => 'CSVインポート';

  @override
  String get csvImportEmpty => 'インポートできる部品が見つかりませんでした';

  @override
  String csvImportSuccess(int count) {
    return '$count件の部品をインポートしました';
  }

  @override
  String get csvImportFailed => 'CSVファイルの読み込みに失敗しました';

  @override
  String get fractionModeOn => '分数入力モードを有効にする';

  @override
  String get fractionModeOff => '通常入力モードに戻す';

  @override
  String get fractionHint => '例: 1/2, 3 1/4';
}
