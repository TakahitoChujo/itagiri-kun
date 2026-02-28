# 板取りくん - Mac ビルド・iOS リリース手順

> 作成日: 2026-02-28
> 対象: Mac で初めてビルドする場合

---

## 1. 環境セットアップ

### 1.1 Xcode インストール
```bash
# App Store から Xcode をインストール（約10GB）
# インストール後、コマンドラインツールを有効化
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### 1.2 Flutter SDK インストール
```bash
# Homebrew でインストール（推奨）
brew install --cask flutter

# または git で取得
git clone https://github.com/flutter/flutter.git -b stable ~/src/flutter
echo 'export PATH="$HOME/src/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### 1.3 環境確認
```bash
flutter doctor
```

以下がすべて ✅ になればOK：
- Flutter
- Xcode
- iOS Simulator
- Connected device

---

## 2. リポジトリのセットアップ

```bash
# リポジトリをクローン
git clone https://github.com/[your-repo]/itagiri-kun.git
cd itagiri-kun

# パッケージ取得
flutter pub get

# 静的解析（0 issues を確認）
flutter analyze

# テスト実行（全通過を確認）
flutter test
```

---

## 3. Xcode で署名設定

```bash
# iOS フォルダを Xcode で開く
open ios/Runner.xcworkspace
```

Xcode が開いたら：

1. 左のツリーで「**Runner**」をクリック
2. 「**Signing & Capabilities**」タブ
3. 「**Automatically manage signing**」にチェック
4. **Team** に Apple Developer アカウントを選択
   - Team ID: `G2LHH59798`（Apple Developer ページで確認済み）
5. **Bundle Identifier** が `com.chujo.itagirikun` になっていることを確認

---

## 4. 実機テスト（任意）

iPhone を Mac に接続して：

```bash
flutter run
```

---

## 5. リリースビルド（IPA 作成）

```bash
flutter build ipa
```

生成場所：
```
build/ios/ipa/板取りくん.ipa
# または
build/ios/archive/Runner.xcarchive
```

---

## 6. App Store Connect へアップロード

### 方法A: Xcode から（推奨）

```bash
open ios/Runner.xcworkspace
```

1. メニュー →「**Product**」→「**Archive**」
2. Organizer が開いたら「**Distribute App**」
3. 「**App Store Connect**」→「**Upload**」
4. オプションはデフォルトでOK → アップロード

### 方法B: Transporter アプリ

1. App Store から「**Transporter**」をインストール
2. IPA ファイルをドラッグ＆ドロップ → アップロード

---

## 7. TestFlight でテスト

1. App Store Connect → 「TestFlight」タブ
2. アップロードされたビルドを選択
3. 「内部テスト」→ 自分のApple IDを追加
4. TestFlight アプリからインストール・動作確認

---

## 8. 審査提出

App Store Connect で：

1. 「App Store」タブ → 「1.0 準備中」
2. ビルドを選択（TestFlight でテスト済みのもの）
3. スクリーンショット・説明文を入力（→ `docs/release-preparation.md` 参照）
4. 「**審査へ提出**」

---

## トラブルシューティング

### `flutter doctor` で Xcode が ✗ の場合
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### CocoaPods が必要な場合
```bash
sudo gem install cocoapods
cd ios && pod install
```

### 署名エラーが出る場合
- Apple Developer アカウントにログイン済みか確認
- Xcode → Settings → Accounts → Apple ID を追加
