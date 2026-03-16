import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// 単位系
enum MeasurementUnit {
  mm,
  cm,
}

/// アプリ言語
enum AppLanguage {
  system,
  ja,
  en;

  /// Locale に変換
  Locale? toLocale() {
    switch (this) {
      case AppLanguage.ja:
        return const Locale('ja');
      case AppLanguage.en:
        return const Locale('en');
      case AppLanguage.system:
        return null;
    }
  }
}

/// アプリテーマ
enum AppTheme {
  system,
  light,
  dark;

  /// ThemeMode に変換
  ThemeMode toThemeMode() {
    switch (this) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }
}

/// アプリ設定
class Settings {
  /// 鋸刃の幅 (mm)
  final double kerfWidth;

  /// 単位系
  final MeasurementUnit unit;

  /// 言語
  final AppLanguage language;

  /// テーマ
  final AppTheme theme;

  const Settings({
    this.kerfWidth = 3.0,
    this.unit = MeasurementUnit.mm,
    this.language = AppLanguage.system,
    this.theme = AppTheme.system,
  });

  Settings copyWith({
    double? kerfWidth,
    MeasurementUnit? unit,
    AppLanguage? language,
    AppTheme? theme,
  }) {
    return Settings(
      kerfWidth: kerfWidth ?? this.kerfWidth,
      unit: unit ?? this.unit,
      language: language ?? this.language,
      theme: theme ?? this.theme,
    );
  }
}

/// 設定の StateNotifier（Hive で永続化）
class SettingsNotifier extends StateNotifier<Settings> {
  static const String _boxName = 'settings';
  static const String _kerfKey = 'kerfWidth';
  static const String _unitKey = 'unit';
  static const String _languageKey = 'language';
  static const String _themeKey = 'theme';

  SettingsNotifier() : super(const Settings()) {
    _loadFromStorage();
  }

  /// Hive から設定を読み込む
  void _loadFromStorage() {
    try {
      final box = Hive.box(_boxName);
      final kerf = box.get(_kerfKey, defaultValue: 3.0) as double;
      final unitIndex = box.get(_unitKey, defaultValue: 0) as int;
      final langIndex = box.get(_languageKey, defaultValue: 0) as int;
      final themeIndex = box.get(_themeKey, defaultValue: 0) as int;
      state = Settings(
        kerfWidth: kerf,
        unit: MeasurementUnit
            .values[unitIndex.clamp(0, MeasurementUnit.values.length - 1)],
        language: AppLanguage
            .values[langIndex.clamp(0, AppLanguage.values.length - 1)],
        theme: AppTheme
            .values[themeIndex.clamp(0, AppTheme.values.length - 1)],
      );
    } catch (_) {
      // ボックスが未オープンの場合はデフォルト値を使用
    }
  }

  /// 鋸刃の幅を更新する
  void setKerfWidth(double width) {
    state = state.copyWith(kerfWidth: width);
    _saveToStorage();
  }

  /// 単位系を更新する
  void setUnit(MeasurementUnit unit) {
    state = state.copyWith(unit: unit);
    _saveToStorage();
  }

  /// 言語を更新する
  void setLanguage(AppLanguage language) {
    state = state.copyWith(language: language);
    _saveToStorage();
  }

  /// テーマを更新する
  void setTheme(AppTheme theme) {
    state = state.copyWith(theme: theme);
    _saveToStorage();
  }

  /// Hive に設定を保存する
  void _saveToStorage() {
    try {
      final box = Hive.box(_boxName);
      box.put(_kerfKey, state.kerfWidth);
      box.put(_unitKey, state.unit.index);
      box.put(_languageKey, state.language.index);
      box.put(_themeKey, state.theme.index);
    } catch (_) {
      // 保存失敗時は無視（次回起動時にデフォルトに戻る）
    }
  }
}

/// 設定プロバイダー
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier();
});
