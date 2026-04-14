import 'dart:io';

import '../models/cut_piece.dart';
import '../models/sheet_models.dart';

/// CSV/テキストファイルから部品リストをインポートするサービス
class CsvImportService {
  /// CSV ファイルサイズ上限 (1 MB)
  static const int _maxFileSize = 1 * 1024 * 1024;

  /// 最大行数
  static const int _maxRows = 1000;

  /// 1D 部品リストを CSV からインポート
  ///
  /// CSV フォーマット: ラベル,長さ(mm),数量
  /// ヘッダー行は自動検出してスキップ。
  static Future<List<CutPiece>> import1DFromCsv(String filePath) async {
    final lines = await _readLines(filePath);
    final pieces = <CutPiece>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final fields = _parseCsvLine(line);
      if (fields.length < 2) continue;

      // ヘッダー行をスキップ
      if (_isHeaderRow(fields)) continue;

      try {
        final piece = _parse1DRow(fields);
        if (piece != null) pieces.add(piece);
      } catch (_) {
        continue;
      }
    }

    return pieces;
  }

  /// 2D 部品リストを CSV からインポート
  ///
  /// CSV フォーマット: ラベル,幅(mm),高さ(mm),数量
  /// ヘッダー行は自動検出してスキップ。
  static Future<List<SheetPiece>> import2DFromCsv(String filePath) async {
    final lines = await _readLines(filePath);
    final pieces = <SheetPiece>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final fields = _parseCsvLine(line);
      if (fields.length < 3) continue;

      // ヘッダー行をスキップ
      if (_isHeaderRow(fields)) continue;

      try {
        final piece = _parse2DRow(fields);
        if (piece != null) pieces.add(piece);
      } catch (_) {
        continue;
      }
    }

    return pieces;
  }

  /// ファイルを読み込んで行リストを返す
  static Future<List<String>> _readLines(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw const FormatException('File not found');
    }

    final fileSize = await file.length();
    if (fileSize > _maxFileSize) {
      throw const FormatException('File too large');
    }

    final content = await file.readAsString();
    final lines = content.split(RegExp(r'\r?\n'));
    if (lines.length > _maxRows) {
      throw const FormatException('Too many rows');
    }

    return lines;
  }

  /// CSV 行をフィールドに分割（引用符対応）
  static List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (inQuotes) {
        if (ch == '"' && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++;
        } else if (ch == '"') {
          inQuotes = false;
        } else {
          current.write(ch);
        }
      } else {
        if (ch == '"') {
          inQuotes = true;
        } else if (ch == ',' || ch == '\t') {
          fields.add(current.toString().trim());
          current = StringBuffer();
        } else {
          current.write(ch);
        }
      }
    }
    fields.add(current.toString().trim());
    return fields;
  }

  /// ヘッダー行かどうかを判定
  static bool _isHeaderRow(List<String> fields) {
    final headerKeywords = {
      // 日本語
      'ラベル', '長さ', '幅', '高さ', '数量', 'サイズ', '名前',
      // 英語
      'label', 'length', 'width', 'height', 'qty', 'quantity',
      'name', 'size', 'piece', 'part',
    };
    final lowerFields = fields.map((f) => f.toLowerCase()).toList();
    return lowerFields.any((f) => headerKeywords.contains(f));
  }

  /// 1D行のパース: [ラベル, 長さ, 数量] or [長さ, 数量] or [長さ, 数量, ラベル]
  static CutPiece? _parse1DRow(List<String> fields) {
    // パターン1: 数値,数値 → 長さ,数量
    // パターン2: 文字列,数値,数値 → ラベル,長さ,数量
    // パターン3: 数値,数値,文字列 → 長さ,数量,ラベル

    if (fields.length == 2) {
      final length = _parseNumber(fields[0]);
      final quantity = _parseInt(fields[1]);
      if (length != null && length > 0 && quantity != null && quantity > 0) {
        return CutPiece(length: length, quantity: quantity);
      }
      return null;
    }

    // 3+ fields
    final first = _parseNumber(fields[0]);
    final second = _parseNumber(fields[1]);
    final third = fields.length > 2 ? _parseInt(fields[2]) : null;

    if (first == null && second != null && third != null && third > 0) {
      // ラベル, 長さ, 数量
      return CutPiece(
        length: second,
        quantity: third,
        label: fields[0].isNotEmpty ? fields[0] : null,
      );
    }

    if (first != null && first > 0) {
      final qty = _parseInt(fields[1]) ?? 1;
      final label = fields.length > 2 && _parseNumber(fields[2]) == null
          ? fields[2]
          : null;
      return CutPiece(
        length: first,
        quantity: qty > 0 ? qty : 1,
        label: label?.isNotEmpty == true ? label : null,
      );
    }

    return null;
  }

  /// 2D行のパース: [ラベル, 幅, 高さ, 数量] or [幅, 高さ, 数量] etc.
  static SheetPiece? _parse2DRow(List<String> fields) {
    if (fields.length == 3) {
      final w = _parseNumber(fields[0]);
      final h = _parseNumber(fields[1]);
      final q = _parseInt(fields[2]);
      if (w != null && w > 0 && h != null && h > 0) {
        return SheetPiece(
          width: w,
          height: h,
          quantity: (q != null && q > 0) ? q : 1,
        );
      }
      return null;
    }

    // 4+ fields
    final first = _parseNumber(fields[0]);

    if (first == null) {
      // ラベル, 幅, 高さ, 数量
      final w = _parseNumber(fields[1]);
      final h = _parseNumber(fields[2]);
      final q = fields.length > 3 ? _parseInt(fields[3]) : null;
      if (w != null && w > 0 && h != null && h > 0) {
        return SheetPiece(
          width: w,
          height: h,
          quantity: (q != null && q > 0) ? q : 1,
          label: fields[0].isNotEmpty ? fields[0] : null,
        );
      }
    } else {
      // 幅, 高さ, 数量[, ラベル]
      final h = _parseNumber(fields[1]);
      final q = _parseInt(fields[2]);
      final label = fields.length > 3 && _parseNumber(fields[3]) == null
          ? fields[3]
          : null;
      if (first > 0 && h != null && h > 0) {
        return SheetPiece(
          width: first,
          height: h,
          quantity: (q != null && q > 0) ? q : 1,
          label: label?.isNotEmpty == true ? label : null,
        );
      }
    }

    return null;
  }

  static double? _parseNumber(String s) {
    final cleaned = s.replaceAll(RegExp(r'[^\d.\-]'), '');
    return double.tryParse(cleaned);
  }

  static int? _parseInt(String s) {
    final cleaned = s.replaceAll(RegExp(r'[^\d\-]'), '');
    return int.tryParse(cleaned);
  }
}
