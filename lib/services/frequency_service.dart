import 'storage_service.dart';

/// よく使うカットサイズの分析サービス
///
/// 過去のプロジェクトから頻出するカットサイズを集計し、提案に使用する。
class FrequencyService {
  FrequencyService._();

  /// 1D: よく使うカット長さの上位 N 件を返す
  ///
  /// 各長さの出現回数（quantity考慮）をカウントし、頻度の高い順に返す。
  /// [woodStockName] を指定すると、同じ素材のプロジェクトのみ集計する。
  static List<FrequentSize> getFrequentLengths({
    int limit = 5,
    String? woodStockName,
  }) {
    final projects = StorageService.loadProjects();
    final counter = <double, int>{};

    for (final project in projects) {
      if (woodStockName != null && project.woodStock.name != woodStockName) {
        continue;
      }
      for (final piece in project.pieces) {
        if (piece.length > 0) {
          counter[piece.length] = (counter[piece.length] ?? 0) + piece.quantity;
        }
      }
    }

    final sorted = counter.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(limit)
        .map((e) => FrequentSize(length: e.key, count: e.value))
        .toList();
  }

  /// 2D: よく使うカットサイズの上位 N 件を返す
  static List<FrequentSheetSize> getFrequentSheetSizes({
    int limit = 5,
    String? sheetStockName,
  }) {
    final projects = StorageService.loadSheetProjects();
    final counter = <String, _SheetSizeEntry>{};

    for (final project in projects) {
      if (sheetStockName != null && project.sheetStock.name != sheetStockName) {
        continue;
      }
      for (final piece in project.pieces) {
        if (piece.width > 0 && piece.height > 0) {
          final key = '${piece.width}x${piece.height}';
          if (counter.containsKey(key)) {
            counter[key]!.count += piece.quantity;
          } else {
            counter[key] = _SheetSizeEntry(
              width: piece.width,
              height: piece.height,
              count: piece.quantity,
            );
          }
        }
      }
    }

    final sorted = counter.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return sorted
        .take(limit)
        .map((e) => FrequentSheetSize(
              width: e.width,
              height: e.height,
              count: e.count,
            ))
        .toList();
  }

  /// 1D: よく使うラベルの上位 N 件を返す
  static List<String> getFrequentLabels({int limit = 8}) {
    final projects = StorageService.loadProjects();
    final counter = <String, int>{};

    for (final project in projects) {
      for (final piece in project.pieces) {
        final label = piece.label;
        if (label != null && label.isNotEmpty) {
          counter[label] = (counter[label] ?? 0) + 1;
        }
      }
    }

    final sorted = counter.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).map((e) => e.key).toList();
  }
}

/// 頻出する1Dカットサイズ
class FrequentSize {
  final double length;
  final int count;

  const FrequentSize({required this.length, required this.count});

  @override
  String toString() => 'FrequentSize(length: $length, count: $count)';
}

/// 頻出する2Dカットサイズ
class FrequentSheetSize {
  final double width;
  final double height;
  final int count;

  const FrequentSheetSize({
    required this.width,
    required this.height,
    required this.count,
  });

  @override
  String toString() => 'FrequentSheetSize(${width}x$height, count: $count)';
}

class _SheetSizeEntry {
  final double width;
  final double height;
  int count;

  _SheetSizeEntry({
    required this.width,
    required this.height,
    required this.count,
  });
}
