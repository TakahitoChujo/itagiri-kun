/// 板取りくん アプリ全体の寸法定数
///
/// パディング、角丸、フォントサイズなどの統一値を定義。
/// マジックナンバーを排除し、一貫性のあるUIを実現する。
class AppDimensions {
  AppDimensions._(); // インスタンス化防止

  // ──────────────────────────────────────────
  // パディング / マージン
  // ──────────────────────────────────────────
  static const paddingXS = 4.0;
  static const paddingS = 8.0;
  static const paddingM = 16.0;
  static const paddingL = 24.0;
  static const paddingXL = 32.0;

  // ──────────────────────────────────────────
  // 角丸 (Border Radius)
  // ──────────────────────────────────────────
  static const cardRadius = 12.0; // カード
  static const buttonRadius = 8.0; // ボタン
  static const chipRadius = 20.0; // チップ / バッジ
  static const inputRadius = 8.0; // 入力フィールド

  // ──────────────────────────────────────────
  // カット図 (Cut Diagram)
  // ──────────────────────────────────────────
  static const cutDiagramHeight = 60.0; // 1本の板材の表示高さ
  static const cutDiagramPadding = 2.0; // 部材間のスペース

  // ──────────────────────────────────────────
  // 木材プリセットカード
  // ──────────────────────────────────────────
  static const presetCardSize = 100.0; // プリセット選択カードのサイズ

  // ──────────────────────────────────────────
  // 入力フィールド
  // ──────────────────────────────────────────
  static const inputFieldHeight = 56.0; // テキスト入力の高さ

  // ──────────────────────────────────────────
  // アイコンサイズ
  // ──────────────────────────────────────────
  static const iconS = 16.0;
  static const iconM = 24.0;
  static const iconL = 32.0;

  // ──────────────────────────────────────────
  // テキストサイズ
  // ──────────────────────────────────────────
  static const textXS = 10.0; // キャプション
  static const textS = 12.0; // 補助テキスト
  static const textM = 14.0; // 本文
  static const textL = 16.0; // サブタイトル
  static const textXL = 20.0; // タイトル
  static const textXXL = 24.0; // 大見出し

  // ──────────────────────────────────────────
  // エレベーション
  // ──────────────────────────────────────────
  static const elevationNone = 0.0;
  static const elevationLow = 1.0;
  static const elevationMedium = 4.0;
  static const elevationHigh = 8.0;
}
