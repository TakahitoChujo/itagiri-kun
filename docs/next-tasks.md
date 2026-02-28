# 板取りくん - 次のタスク一覧

> 作成日: 2026-02-27
> 更新日: 2026-02-28
> 現在のステータス: MVP v1.0 完成、Phase 0 マネタイズ基盤実装済み

---

## 0. 環境セットアップ（最優先）

- [ ] Flutter SDK インストール (https://docs.flutter.dev/get-started/install/windows/mobile)
- [ ] `flutter create .` でプラットフォーム固有ファイル生成
- [ ] `flutter pub get` で依存パッケージ取得
- [ ] `flutter run` で動作確認
- [ ] `flutter test` でユニットテスト実行（20ケース）

---

## 1. セキュリティテスト

### 1.1 入力バリデーション
- [ ] 長さフィールドに極端な値を入力（0, -1, 999999, 小数点、文字列）
- [ ] 数量フィールドに極端な値を入力（0, -1, 99999）
- [ ] カーフ幅に異常値（負数、巨大な値）→ 上限10mmチェック済み、下限0もチェック済み
- [ ] カスタム木材の幅・厚みに0やマイナスを入力
- [ ] プロジェクト名に特殊文字（`<script>`, SQL文, 超長文字列）

### 1.2 データストレージ
- [ ] Hive Box のデータが改ざんされた場合のリカバリ確認
- [ ] ストレージ容量不足時の挙動（try-catch の動作確認）
- [ ] 大量プロジェクト保存時（100件+）のパフォーマンス

### 1.3 算出ロジックの堅牢性
- [ ] 浮動小数点の丸め誤差テスト（例: 0.1 + 0.2 問題）
- [ ] 部材数が非常に多い場合（100個+）のアルゴリズム性能
- [ ] 素材長 == 部材長 + カーフ幅 のギリギリケース

### 1.4 依存パッケージ
- [ ] `flutter pub audit` で既知の脆弱性チェック
- [ ] 各パッケージのライセンス確認（MIT/BSD/Apache）

---

## 2. アクセシビリティテスト

- [ ] TalkBack (Android) / VoiceOver (iOS) でのスクリーンリーダー動作確認
- [ ] CutDiagram の Semantics ラベルが適切に読み上げられるか
- [ ] フォントサイズ拡大時のレイアウト崩れチェック
- [ ] コントラスト比の確認（WCAG 2.1 AA準拠: 4.5:1以上）
  - AppColors.primary (#8B6914) on white → 要確認
  - AppColors.textSecondary (#757575) on white → 4.6:1 ギリギリ
- [ ] タッチターゲットサイズ（最低48x48dp）の確認

---

## 3. パフォーマンステスト

- [ ] 大量ピース入力時（50行以上）のUI応答性
- [ ] FFDアルゴリズムの計算時間測定（100ピース、1000ピース）
- [ ] ListView の大量プロジェクト表示時のスクロール性能
- [ ] メモリ使用量プロファイリング（Flutter DevTools）
- [ ] CustomPainter の再描画頻度確認

---

## 4. UI/UXテスト

- [ ] 複数端末サイズでのレスポンシブ確認（SE, 標準, Pro Max, タブレット）
- [ ] ダークモード対応確認（現状は未対応 → v1.1で検討）
- [ ] 横画面回転時のレイアウト
- [ ] キーボード表示時のスクロール・入力フィールドの可視性
- [ ] 戻るボタン（Android）の挙動確認
- [ ] 入力中にアプリがバックグラウンドに移った場合のデータ保持

---

## 5. 結合テスト（画面遷移フロー）

- [ ] ホーム → 木材選択 → 部材入力 → 計算結果 → 保存 → ホーム（正常フロー）
- [ ] 保存済みプロジェクト → 部材入力 → 再計算 → 上書き保存
- [ ] プロジェクト削除 → 一覧更新確認
- [ ] 設定変更 → カーフ幅が計算に反映されるか
- [ ] カスタム木材選択 → 計算 → 保存 → 再読み込み

---

## 6. v1.1 に向けた開発タスク

仕様書 Section 2.2 より:

| # | 機能 | 優先度 |
|---|------|--------|
| F9 | 合板対応（2Dカット最適化） | 高 |
| F10 | 金額計算（木材単価 → 合計金額） | 中 |
| F11 | カット指示書PDF出力 | 高 |
| F12 | ホームセンター木材DB | 低 |

### 追加技術タスク
- [ ] pdf パッケージ導入（F11用）
- [ ] 2Dビンパッキングアルゴリズム実装（F9用）
- [ ] ダークモード対応
- [ ] cm単位系の実装（設定画面で無効化中）
- [ ] Firebase Crashlytics 導入
- [x] ~~AdMob SDK 導入準備（Phase 2 収益化）~~ → Phase 0 基盤として実装済み（下記参照）

---

## 7. リリース準備

仕様書 Section 10 より:

- [ ] J-PlatPat でアプリ名「板取りくん」の商標チェック
- [ ] プライバシーポリシー作成（GitHub Pages で公開）
- [ ] 利用規約作成
- [ ] Apple Developer / Google Play デベロッパーアカウント作成
- [ ] アプリアイコン作成（1024x1024）
- [ ] スクリーンショット 5枚以上
- [ ] カット計算の精度テスト（手計算と照合）
- [ ] ストア掲載文の最終調整（仕様書 Section 8.2 参照）

---

---

## 8. Phase 0 マネタイズ基盤（実装済み 2026-02-28）

monetization-plan.md の Phase 0 に基づき、以下を実装完了。

### 新規ファイル
| ファイル | 内容 |
|---------|------|
| `lib/services/premium_service.dart` | PremiumNotifier + premiumProvider + isPremiumProvider。Hive キャッシュ対応。Phase 0 では isPremium=true ハードコード |
| `lib/services/analytics_service.dart` | 11種の型安全なイベントメソッド（スタブ実装、debugPrint 出力）。Phase 1 で Firebase Analytics に差し替え |
| `lib/widgets/ad_banner.dart` | AdMob バナー (320x50) プレースホルダー。プレミアム時は非表示 |
| `lib/widgets/premium_banner.dart` | 設定画面のプレミアム導線バナー（ゴールデンロッド配色） |

### 変更ファイル
| ファイル | 変更内容 |
|---------|---------|
| `lib/main.dart` | PremiumNotifier.initPremiumBox() + AnalyticsService.init() 追加 |
| `lib/screens/home_screen.dart` | 画面下部に AdBanner 配置 |
| `lib/screens/result_screen.dart` | スクロール末尾に AdBanner 配置 |
| `lib/screens/settings_screen.dart` | アプリ情報の上に PremiumBanner 配置 |

### Phase 0 の動作
- `_isPhase0 = true` → 広告バナー・プレミアムバナーともに非表示（全機能開放）
- Phase 1 で `_isPhase0 = false` に変更するだけで制限開始・広告表示

### QA結果
- 静的解析: エラー 0 / 警告 0（info 20件は全て既存コードの deprecated 系）
- Phase 0 動作検証: 全テスト項目 PASS

### Phase 1 で必要な作業
- [ ] `google_mobile_ads` パッケージ導入 + 実広告差し替え
- [ ] `in_app_purchase` or RevenueCat 導入
- [ ] プレミアム購入画面の実装
- [ ] `_isPhase0 = false` に切り替え
- [ ] Firebase Analytics 実導入（`firebase_core` + `firebase_analytics`）
- [ ] プロジェクト保存3件制限の実装
- [ ] 2Dカットのプレビュー/ブラー表示
- [ ] PDF出力の透かし制御

---

## QAテスト結果サマリー（実施済み）

| # | 重要度 | 問題 | 状態 |
|---|--------|------|------|
| BUG-1 | 高 | フォントアセット未存在 → ビルドエラー | **修正済** |
| BUG-2 | 高 | 未使用パッケージ5個 | **修正済** |
| BUG-3 | 中 | カット図にカーフ非表示 | **修正済** |
| BUG-4 | 中 | カーフ幅上限チェックなし | **修正済** |
| BUG-5 | 中 | 設定が永続化されない | **修正済** |
| BUG-6 | 低 | CutDiagram にSemantics未設定 | **修正済** |
