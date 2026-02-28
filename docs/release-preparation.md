# 板取りくん - リリース準備チェックリスト

> 作成日: 2026-02-28
> 対象バージョン: v1.0 (MVP) → ストア初回リリース

---

## 1. 法務・商標

### 1.1 商標調査
- [x] 調査ガイド作成 → [trademark-search-guide.md](legal/trademark-search-guide.md)
- [ ] J-PlatPat で「イタドリクン」を称呼検索（第9類・第42類）
- [ ] J-PlatPat で「板取りくん」を商標名検索
- [ ] 結果を記録し、問題なければ使用決定
- [ ] 英語名「Itagiri-kun」の商標チェック
- [ ] ドメイン取得の検討（itagiri-kun.com 等）

### 1.2 プライバシーポリシー
- [x] プライバシーポリシー作成 → [privacy-policy.md](legal/privacy-policy.md)
- [ ] メールアドレスのプレースホルダーを実際のアドレスに差し替え
- [ ] GitHub Pages または静的サイトで公開
- [ ] 公開URLをストア掲載情報に設定

### 1.3 利用規約
- [x] 利用規約作成 → [terms-of-service.md](legal/terms-of-service.md)
- [ ] GitHub Pages で公開
- [ ] 管轄裁判所の確認（現在: 東京地方裁判所）

### 1.4 オープンソースライセンス表示
- [x] ライセンス一覧・互換性確認 → [oss-licenses.md](legal/oss-licenses.md)
- [ ] 全パッケージが商用利用可能な寛容ライセンスであることを確認済み
- [ ] アプリ内に `showLicensePage` を実装（設定画面に追加）

---

## 2. ストアアカウント

### 2.1 Apple Developer Program
- [ ] Apple Developer アカウント登録（年額 $99 / ¥12,980）
  - Apple ID の準備
  - D-U-N-S ナンバー（法人の場合）
- [ ] App Store Connect でアプリ登録
- [ ] Bundle ID 決定（例: `com.yourname.itagirikun`）
- [ ] 証明書・Provisioning Profile の設定
  - Development Certificate
  - Distribution Certificate
  - App Store Provisioning Profile

### 2.2 Google Play Console
- [ ] Google Play デベロッパーアカウント登録（$25 一回）
- [ ] アプリ登録
- [ ] パッケージ名決定（例: `com.yourname.itagirikun`）
- [ ] アップロード鍵の生成・設定
- [ ] Google Play App Signing の有効化

---

## 3. アプリアイコン・ビジュアル素材

### 3.1 アプリアイコン
- [ ] アイコンデザイン作成（1024×1024px）
  - コンセプト: 木材 + カット線 + 温かみのある色合い
  - メインカラー: #8B6914（アプリのプライマリカラー）
  - 背景: 木目テクスチャ or ウッド調グラデーション
- [ ] iOS 用アイコン生成
  - 角丸は自動適用（正方形で作成）
  - サイズ一覧: 20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024
- [ ] Android 用アダプティブアイコン生成
  - フォアグラウンド: 108×108dp（アイコン部分は 72×72dp 内に収める）
  - バックグラウンド: 単色 or グラデーション
  - レガシーアイコン: 48, 72, 96, 144, 192, 512
- [ ] `flutter_launcher_icons` パッケージで自動生成設定

### 3.2 スプラッシュスクリーン
- [ ] スプラッシュ画面デザイン
- [ ] `flutter_native_splash` パッケージで設定
- [ ] Android 12+ のスプラッシュスクリーンAPI対応

### 3.3 ストア用スクリーンショット

**App Store（iOS）**: 最低3枚、推奨5〜10枚
- [ ] iPhone 6.7" (1290×2796) - iPhone 15 Pro Max 相当
- [ ] iPhone 6.5" (1284×2778) - iPhone 14 Plus 相当
- [ ] iPad 12.9" (2048×2732) - iPad Pro 相当（任意）

**Google Play（Android）**: 最低2枚、推奨4〜8枚
- [ ] スマートフォン: 1080×1920 以上

**スクリーンショット構成案**:
1. ホーム画面 - 「かんたん木材カット最適化」
2. 木材選択 - 「ホームセンターの木材をプリセットから選択」
3. 部材入力 - 「必要な部材をサクサク入力」
4. 計算結果 - 「最適なカット配置を自動計算」
5. カット図 - 「見やすいカット図で無駄なく木取り」

- [ ] スクリーンショットにキャプション・フレーム追加
  - Fastlane Frameit or Figma でデバイスフレーム付き画像作成

### 3.4 フィーチャーグラフィック（Google Play）
- [ ] 1024×500 のフィーチャーグラフィック作成
  - アプリ名 + キャッチコピー + ビジュアル

---

## 4. ストア掲載情報

### 4.1 App Store

```
アプリ名: 板取りくん - 木材カット最適化
サブタイトル: DIYの木取り計算を簡単に（30文字以内）
カテゴリ: ユーティリティ / 仕事効率化
対象年齢: 4+
価格: 無料
```

**説明文（4000文字以内）**:
```
板取りくんは、DIYで木材をカットするときの「木取り計算」を
自動で最適化するアプリです。

◆ こんな悩みを解決します
・何本の木材を買えばいいかわからない
・端材（余り）をできるだけ減らしたい
・ホームセンターのカットサービスに渡す指示書がほしい

◆ 主な機能
・ワンタップで最適なカット配置を自動計算
・SPF材（1×4、2×4 等）のプリセット搭載
・見やすいカット図でムダなく木取り
・のこぎり刃の厚み（カーフ）も考慮
・プロジェクト保存で繰り返し使える

◆ 使い方はかんたん3ステップ
1. 木材を選ぶ（プリセットまたはカスタム）
2. 必要な部材の長さと本数を入力
3. 計算ボタンを押すだけ！

◆ こんな方におすすめ
・DIY初心者〜中級者
・家具や棚を自作する方
・ホームセンターでカットサービスを利用する方
・木材の無駄を減らしてコストを抑えたい方

※計算結果は参考値です。実際のカットでは誤差が生じる
場合があります。
```

**キーワード（100文字以内）**:
```
木取り,板取り,カット,最適化,DIY,木材,木工,端材,SPF,のこぎり,ホームセンター,ウッド
```

### 4.2 Google Play

```
アプリ名: 板取りくん - 木材カット最適化
短い説明（80文字以内）: DIYの木材カットを最適化！必要な木材の本数と最適な切り方を自動計算
カテゴリ: ツール
コンテンツレーティング: 全ユーザー対象
価格: 無料
```

**詳細な説明（4000文字以内）**: App Store と同内容（マークダウン不可、テキストのみ）

---

## 5. ビルド・署名設定

### 5.1 iOS ビルド設定
- [ ] `ios/Runner/Info.plist` の設定確認
  - CFBundleDisplayName: 板取りくん
  - CFBundleVersion / CFBundleShortVersionString: 1.0.0
  - NSAppTransportSecurity（必要に応じて）
- [ ] Xcode での署名設定
  - Team ID
  - Provisioning Profile
- [ ] `flutter build ipa` でリリースビルド
- [ ] TestFlight でベータテスト

### 5.2 Android ビルド設定
- [ ] `android/app/build.gradle` の設定
  - applicationId: com.yourname.itagirikun
  - versionCode: 1
  - versionName: "1.0.0"
  - minSdkVersion: 26 (Android 8.0)
  - targetSdkVersion: 34 (Android 14)
- [ ] keystore ファイル生成
  ```
  keytool -genkey -v -keystore itagirikun-release.keystore \
    -alias itagirikun -keyalg RSA -keysize 2048 -validity 10000
  ```
- [ ] `android/key.properties` 設定（.gitignore に追加済みか確認）
- [ ] `flutter build appbundle` で AAB ビルド
- [ ] ProGuard / R8 の難読化設定確認
- [ ] 内部テストトラックでテスト

---

## 6. 品質チェック（リリース前最終確認）

### 6.1 機能テスト
- [ ] 全画面遷移の正常動作確認
- [ ] プリセット木材8種すべてでの計算テスト
- [ ] カスタム木材での計算テスト
- [ ] プロジェクト保存・読み込み・削除の動作確認
- [ ] カーフ幅設定の反映確認
- [ ] 手計算との結果照合（最低3パターン）

### 6.2 デバイステスト
- [ ] iOS 実機テスト（最低1台）
- [ ] Android 実機テスト（最低1台）
- [ ] 異なる画面サイズでのレイアウト確認

### 6.3 パフォーマンス
- [ ] アプリ起動時間: 2秒以内
- [ ] 計算レスポンス: 即時〜1秒以内
- [ ] メモリリークなし（DevTools で確認）

### 6.4 クラッシュテスト
- [ ] 異常入力でのクラッシュなし確認
- [ ] ネットワーク切断時の挙動（v1.0はオフライン完結のため問題なし）
- [ ] ストレージ不足時のエラーハンドリング

---

## 7. ストア申請

### 7.1 App Store 申請
- [ ] App Store Connect でビルドアップロード
- [ ] アプリ情報入力（説明文、スクリーンショット、キーワード）
- [ ] プライバシーポリシーURL設定
- [ ] App Review ガイドラインの確認
  - 4.2 最小機能要件: クリア（実用的なユーティリティ）
  - 5.1.1 データ収集: 収集データなし（v1.0）
- [ ] 審査提出
- [ ] 審査フィードバック対応（リジェクト時の修正計画）

### 7.2 Google Play 申請
- [ ] AAB アップロード（内部テスト → クローズドテスト → 本番）
- [ ] ストア掲載情報入力
- [ ] コンテンツレーティング質問票回答
- [ ] データセーフティセクション入力
  - データ収集: なし
  - データ共有: なし
  - データ暗号化: 該当なし
- [ ] ターゲットオーディエンス設定
- [ ] 審査提出

---

## 8. リリース後

### 8.1 モニタリング
- [ ] クラッシュレポート確認（Firebase Crashlytics 導入後）
- [ ] ストアレビュー監視・返信体制
- [ ] ダウンロード数・アクティブユーザー数追跡

### 8.2 初期マーケティング
- [ ] SNS 告知（X/Twitter）
- [ ] DIY系コミュニティへの投稿
- [ ] ASO（App Store Optimization）の効果測定
- [ ] ユーザーフィードバック収集 → v1.1 への反映

### 8.3 v1.1 開発開始
- [x] マネタイズ Phase 0 基盤実装（PremiumService, AnalyticsService, AdBanner, PremiumBanner）
- [ ] ユーザーフィードバックの集約・優先度付け
- [ ] [v1.1-plan.md](v1.1-plan.md) に基づく開発着手

---

## タイムライン目安

| フェーズ | 内容 |
|---------|------|
| **準備** | アカウント登録、法務書類作成、アイコン作成 |
| **ビルド** | 署名設定、リリースビルド、実機テスト |
| **申請** | ストア情報入力、スクリーンショット登録、審査提出 |
| **リリース** | 公開、SNS告知、モニタリング開始 |

---

## 参考リンク

- [Apple App Store Review ガイドライン](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play ポリシーセンター](https://play.google.com/console/about/guides/policy/)
- [J-PlatPat 商標検索](https://www.j-platpat.inpit.go.jp/)
- [v1.1-plan.md](v1.1-plan.md): v1.1 開発計画
- [next-tasks.md](next-tasks.md): テスト計画・バグ修正履歴
