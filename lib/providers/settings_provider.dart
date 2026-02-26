import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// 単位系
enum MeasurementUnit {
  mm,
  cm,
}

/// アプリ設定
class Settings {
  /// 鋸刃の幅 (mm)
  final double kerfWidth;

  /// 単位系
  final MeasurementUnit unit;

  const Settings({
    this.kerfWidth = 3.0,
    this.unit = MeasurementUnit.mm,
  });

  Settings copyWith({
    double? kerfWidth,
    MeasurementUnit? unit,
  }) {
    return Settings(
      kerfWidth: kerfWidth ?? this.kerfWidth,
      unit: unit ?? this.unit,
    );
  }
}

/// 設定の StateNotifier（Hive で永続化）
class SettingsNotifier extends StateNotifier<Settings> {
  static const String _boxName = 'settings';
  static const String _kerfKey = 'kerfWidth';
  static const String _unitKey = 'unit';

  SettingsNotifier() : super(const Settings()) {
    _loadFromStorage();
  }

  /// Hive から設定を読み込む
  void _loadFromStorage() {
    try {
      final box = Hive.box(_boxName);
      final kerf = box.get(_kerfKey, defaultValue: 3.0) as double;
      final unitIndex = box.get(_unitKey, defaultValue: 0) as int;
      state = Settings(
        kerfWidth: kerf,
        unit: MeasurementUnit
            .values[unitIndex.clamp(0, MeasurementUnit.values.length - 1)],
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

  /// Hive に設定を保存する
  void _saveToStorage() {
    try {
      final box = Hive.box(_boxName);
      box.put(_kerfKey, state.kerfWidth);
      box.put(_unitKey, state.unit.index);
    } catch (_) {
      // 保存失敗時は無視（次回起動時にデフォルトに戻る）
    }
  }

  /// Hive Box の初期化（main で呼ぶ）
  static Future<void> initSettingsBox() async {
    await Hive.openBox(_boxName);
  }
}

/// 設定プロバイダー
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier();
});
