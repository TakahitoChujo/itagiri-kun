# オープンソースライセンス一覧

> 板取りくん v1.0 で使用しているオープンソースパッケージ

---

## 使用パッケージ

| パッケージ | バージョン | ライセンス | 用途 |
|-----------|-----------|-----------|------|
| flutter | SDK | BSD-3-Clause | UIフレームワーク |
| flutter_riverpod | ^2.5.1 | MIT | 状態管理 |
| hive | ^2.2.3 | Apache-2.0 | ローカルDB（Key-Value） |
| hive_flutter | ^1.1.0 | Apache-2.0 | Hive の Flutter バインディング |
| uuid | ^4.4.0 | MIT | 一意ID生成 |
| intl | ^0.19.0 | BSD-3-Clause | 国際化・日付フォーマット |

### 開発時のみ使用（アプリには含まれない）

| パッケージ | バージョン | ライセンス | 用途 |
|-----------|-----------|-----------|------|
| flutter_test | SDK | BSD-3-Clause | テストフレームワーク |
| flutter_lints | ^4.0.0 | BSD-3-Clause | 静的解析ルール |

---

## ライセンス互換性

| ライセンス | 商用利用 | 改変 | 再配布 | コピーレフト | 判定 |
|-----------|---------|------|--------|-------------|------|
| MIT | OK | OK | OK | なし | 問題なし |
| BSD-3-Clause | OK | OK | OK | なし | 問題なし |
| Apache-2.0 | OK | OK | OK | なし | 問題なし |

**結論**: すべてのパッケージは商用利用可能な寛容ライセンス（permissive license）であり、コピーレフト（GPL等）のパッケージは含まれていません。ライセンス上の問題はありません。

---

## ライセンス表示義務

| ライセンス | 表示義務 |
|-----------|---------|
| MIT | 著作権表示 + ライセンス文の保持 |
| BSD-3-Clause | 著作権表示 + ライセンス文の保持 |
| Apache-2.0 | 著作権表示 + ライセンス文の保持 + NOTICE ファイル（ある場合） |

### Flutter アプリでの対応方法

Flutter では `LicensePage` ウィジェットを使うことで、すべての依存パッケージのライセンス情報を自動表示できます。

```dart
// 設定画面やAbout画面に追加
ListTile(
  title: const Text('オープンソースライセンス'),
  leading: const Icon(Icons.description),
  onTap: () {
    showLicensePage(
      context: context,
      applicationName: '板取りくん',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Takahito Chujo',
    );
  },
),
```

この `showLicensePage` は Flutter が依存パッケージの LICENSE ファイルを自動収集して表示するため、個別にライセンス文を管理する必要はありません。

---

## 実装チェックリスト

- [ ] 設定画面に「オープンソースライセンス」項目を追加
- [ ] `showLicensePage` を実装
- [ ] 表示内容の確認（全パッケージが表示されるか）
