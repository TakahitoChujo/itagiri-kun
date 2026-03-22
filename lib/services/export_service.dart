import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/project.dart';
import '../models/cut_piece.dart';
import '../models/cut_result.dart';
import '../models/offcut.dart';
import '../models/wood_stock.dart';
import '../models/sheet_models.dart';
import '../models/sheet_project.dart';
import 'storage_service.dart';

/// エクスポートサービス
///
/// プロジェクトデータを PDF / CSV / JSON 形式でエクスポート・共有する。
class ExportService {
  // ---------------------------------------------------------------------------
  // PDF エクスポート
  // ---------------------------------------------------------------------------

  /// プロジェクトを PDF に出力し、保存先のファイルパスを返す。
  static Future<String> exportToPdf(
    Project project, {
    double? unitPrice,
  }) async {
    final pdf = pw.Document();
    final result = project.result;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          final children = <pw.Widget>[];

          children.add(pw.Header(level: 0, text: project.name));
          children.add(pw.SizedBox(height: 8));
          children.add(pw.Header(level: 1, text: 'Summary'));

          final summaryData = <List<String>>[
            ['Wood Type', project.woodStock.name],
            ['Section', project.woodStock.sectionLabel],
            ['Stock Length (mm)', project.stockLength.toString()],
            ['Kerf Width (mm)', project.kerfWidth.toStringAsFixed(1)],
            ['Total Pieces', project.totalPieceCount.toString()],
          ];

          if (result != null) {
            summaryData.addAll([
              ['Total Stock Required', result.totalStock.toString()],
              ['Total Waste (mm)', result.totalWaste.toStringAsFixed(1)],
              ['Utilization Rate', '${(result.utilizationRate * 100).toStringAsFixed(1)}%'],
            ]);

            final effectivePrice = unitPrice ?? project.unitPrice;
            if (effectivePrice != null) {
              summaryData.addAll([
                ['Unit Price', '${effectivePrice.toStringAsFixed(0)} yen'],
                ['Total Cost', '${(effectivePrice * result.totalStock).toStringAsFixed(0)} yen'],
              ]);
            }
          }

          children.add(pw.TableHelper.fromTextArray(
            headerCount: 0,
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            data: summaryData,
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(3),
            },
          ));

          children.add(pw.SizedBox(height: 16));
          children.add(pw.Header(level: 1, text: 'Pieces List'));

          final piecesRows = <List<String>>[];
          for (var i = 0; i < project.pieces.length; i++) {
            final piece = project.pieces[i];
            piecesRows.add([
              (i + 1).toString(),
              piece.label ?? '-',
              piece.length.toStringAsFixed(1),
              piece.quantity.toString(),
            ]);
          }

          children.add(pw.TableHelper.fromTextArray(
            headers: ['#', 'Label', 'Length (mm)', 'Qty'],
            data: piecesRows,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ));

          children.add(pw.SizedBox(height: 16));

          if (result != null && result.bins.isNotEmpty) {
            children.add(pw.Header(level: 1, text: 'Cut Layout'));

            for (var binIndex = 0; binIndex < result.bins.length; binIndex++) {
              final bin = result.bins[binIndex];
              children.add(pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Bin #${binIndex + 1}  '
                      '(Util: ${(bin.utilizationRate * 100).toStringAsFixed(1)}%, '
                      'Waste: ${bin.waste.toStringAsFixed(1)} mm)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                    ),
                    pw.SizedBox(height: 4),
                    pw.TableHelper.fromTextArray(
                      headers: ['#', 'Label', 'Length (mm)'],
                      data: List.generate(bin.pieces.length, (pi) {
                        final p = bin.pieces[pi];
                        return [
                          (pi + 1).toString(),
                          p.label ?? '-',
                          p.length.toStringAsFixed(1),
                        ];
                      }),
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      cellAlignment: pw.Alignment.centerLeft,
                      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    ),
                  ],
                ),
              ));
            }
          }

          return children;
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final safeName = _sanitizeFilename(project.name);
    final filePath = '${dir.path}/${safeName}_cut_plan.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  // ---------------------------------------------------------------------------
  // CSV エクスポート
  // ---------------------------------------------------------------------------

  static Future<String> exportToCsv(Project project) async {
    final buffer = StringBuffer();
    final result = project.result;

    buffer.write('\uFEFF'); // BOM
    buffer.writeln('ビン番号,ピース番号,ラベル,長さ(mm),端材(mm)');

    if (result != null) {
      for (var binIndex = 0; binIndex < result.bins.length; binIndex++) {
        final bin = result.bins[binIndex];
        for (var pieceIndex = 0; pieceIndex < bin.pieces.length; pieceIndex++) {
          final piece = bin.pieces[pieceIndex];
          final label = _escapeCsvField(piece.label ?? '');
          final wasteValue = pieceIndex == bin.pieces.length - 1
              ? bin.waste.toStringAsFixed(1)
              : '';
          buffer.writeln(
            '${binIndex + 1},${pieceIndex + 1},$label,${piece.length.toStringAsFixed(1)},$wasteValue',
          );
        }
      }
    }

    final dir = await getTemporaryDirectory();
    final safeName = _sanitizeFilename(project.name);
    final filePath = '${dir.path}/${safeName}_cut_plan.csv';
    final file = File(filePath);
    await file.writeAsString(buffer.toString(), encoding: utf8);

    return filePath;
  }

  // ---------------------------------------------------------------------------
  // JSON エクスポート / インポート
  // ---------------------------------------------------------------------------

  static Future<String> exportToJson(Project project) async {
    final map = _projectToMap(project);
    final jsonString = const JsonEncoder.withIndent('  ').convert(map);

    final dir = await getTemporaryDirectory();
    final safeName = _sanitizeFilename(project.name);
    final filePath = '${dir.path}/${safeName}_project.json';
    final file = File(filePath);
    await file.writeAsString(jsonString, encoding: utf8);

    return filePath;
  }

  /// JSON ファイルサイズ上限 (5 MB)
  static const int _maxJsonFileSize = 5 * 1024 * 1024;

  static Future<Project?> importFromJson(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return null;

      final fileSize = await file.length();
      if (fileSize > _maxJsonFileSize) return null;

      final jsonString = await file.readAsString(encoding: utf8);
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) return null;

      return _projectFromMap(decoded);
    } on FormatException {
      return null;
    } on FileSystemException {
      return null;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // 画像エクスポート
  // ---------------------------------------------------------------------------

  static Future<String> exportToImage(Uint8List pngBytes, String projectName) async {
    final dir = await getTemporaryDirectory();
    final safeName = _sanitizeFilename(projectName);
    final filePath = '${dir.path}/${safeName}_cut_plan.png';
    final file = File(filePath);
    await file.writeAsBytes(pngBytes);
    return filePath;
  }

  // ---------------------------------------------------------------------------
  // バックアップ エクスポート / インポート
  // ---------------------------------------------------------------------------

  /// 全データのバックアップ JSON を生成してファイルパスを返す。
  static Future<String> exportBackup() async {
    final projects = StorageService.loadProjects();
    final offcuts = StorageService.loadOffcuts();

    final backup = <String, dynamic>{
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'projects': projects.map((p) => _projectToMap(p)).toList(),
      'offcuts': offcuts.map((o) => jsonDecode(o.toJsonString())).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${dir.path}/itagiri_backup_$timestamp.json';
    final file = File(filePath);
    await file.writeAsString(jsonString, encoding: utf8);

    return filePath;
  }

  /// バックアップ JSON からデータをインポートする。
  ///
  /// 既存IDのプロジェクト/端材はスキップする（非破壊マージ）。
  /// Returns (projectsImported, offcutsImported).
  static Future<(int, int)> importBackup(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) throw const FormatException('File not found');

    final fileSize = await file.length();
    if (fileSize > 50 * 1024 * 1024) {
      throw const FormatException('File too large');
    }

    final jsonString = await file.readAsString(encoding: utf8);
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup format');
    }

    final version = decoded['version'];
    if (version != 1) throw const FormatException('Unsupported backup version');

    int projectsImported = 0;
    int offcutsImported = 0;

    // プロジェクトのインポート
    final projectsList = decoded['projects'];
    if (projectsList is List) {
      for (final pMap in projectsList) {
        if (pMap is! Map<String, dynamic>) continue;
        try {
          final project = _projectFromMap(pMap);
          if (StorageService.loadProject(project.id) != null) continue;
          await StorageService.saveProject(project);
          projectsImported++;
        } catch (_) {
          continue;
        }
      }
    }

    // 端材のインポート
    final offcutsList = decoded['offcuts'];
    if (offcutsList is List) {
      final existingIds =
          StorageService.loadOffcuts().map((o) => o.id).toSet();

      for (final oMap in offcutsList) {
        if (oMap is! Map<String, dynamic>) continue;
        try {
          final offcut = Offcut.fromJsonString(jsonEncode(oMap));
          if (existingIds.contains(offcut.id)) continue;
          await StorageService.importOffcut(offcut);
          offcutsImported++;
        } catch (_) {
          continue;
        }
      }
    }

    return (projectsImported, offcutsImported);
  }

  // ---------------------------------------------------------------------------
  // 2D 合板 PDF エクスポート
  // ---------------------------------------------------------------------------

  static Future<String> exportSheetToPdf(
    SheetProject project, {
    double? unitPrice,
  }) async {
    final pdf = pw.Document();
    final result = project.result;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          final children = <pw.Widget>[];

          children.add(pw.Header(level: 0, text: project.name));
          children.add(pw.SizedBox(height: 8));
          children.add(pw.Header(level: 1, text: 'Summary'));

          final summaryData = <List<String>>[
            ['Sheet Type', project.sheetStock.name],
            ['Sheet Size', project.sheetStock.sizeLabel],
            ['Kerf Width (mm)', project.kerfWidth.toStringAsFixed(1)],
            ['Total Pieces', project.totalPieceCount.toString()],
          ];

          if (result != null) {
            summaryData.addAll([
              ['Total Sheets Required', result.totalSheets.toString()],
              ['Total Waste (mm\u00B2)', result.totalWasteArea.toStringAsFixed(1)],
              ['Utilization Rate', '${(result.utilizationRate * 100).toStringAsFixed(1)}%'],
            ]);

            final effectivePrice = unitPrice ?? project.unitPrice;
            if (effectivePrice != null) {
              summaryData.addAll([
                ['Unit Price', '${effectivePrice.toStringAsFixed(0)} yen'],
                ['Total Cost', '${(effectivePrice * result.totalSheets).toStringAsFixed(0)} yen'],
              ]);
            }
          }

          children.add(pw.TableHelper.fromTextArray(
            headerCount: 0,
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            data: summaryData,
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(3),
            },
          ));

          children.add(pw.SizedBox(height: 16));
          children.add(pw.Header(level: 1, text: 'Pieces List'));

          final piecesRows = <List<String>>[];
          for (var i = 0; i < project.pieces.length; i++) {
            final piece = project.pieces[i];
            piecesRows.add([
              (i + 1).toString(),
              piece.label ?? '-',
              '${piece.width.toStringAsFixed(0)} x ${piece.height.toStringAsFixed(0)}',
              piece.quantity.toString(),
            ]);
          }

          children.add(pw.TableHelper.fromTextArray(
            headers: ['#', 'Label', 'Size (mm)', 'Qty'],
            data: piecesRows,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ));

          children.add(pw.SizedBox(height: 16));

          if (result != null && result.bins.isNotEmpty) {
            children.add(pw.Header(level: 1, text: 'Cut Layout'));

            for (var binIndex = 0; binIndex < result.bins.length; binIndex++) {
              final bin = result.bins[binIndex];
              children.add(pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Sheet #${binIndex + 1}  '
                      '(Util: ${(bin.utilizationRate * 100).toStringAsFixed(1)}%, '
                      'Waste: ${bin.wasteArea.toStringAsFixed(1)} mm\u00B2)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                    ),
                    pw.SizedBox(height: 4),
                    pw.TableHelper.fromTextArray(
                      headers: ['#', 'Label', 'Size (mm)', 'Position', 'Rotated'],
                      data: List.generate(bin.pieces.length, (pi) {
                        final p = bin.pieces[pi];
                        return [
                          (pi + 1).toString(),
                          p.label ?? '-',
                          '${p.width.toStringAsFixed(0)} x ${p.height.toStringAsFixed(0)}',
                          '(${p.x.toStringAsFixed(0)}, ${p.y.toStringAsFixed(0)})',
                          p.rotated ? 'Yes' : 'No',
                        ];
                      }),
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      cellAlignment: pw.Alignment.centerLeft,
                      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    ),
                  ],
                ),
              ));
            }
          }

          return children;
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final safeName = _sanitizeFilename(project.name);
    final filePath = '${dir.path}/${safeName}_sheet_cut_plan.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  // ---------------------------------------------------------------------------
  // 2D 合板 CSV エクスポート
  // ---------------------------------------------------------------------------

  static Future<String> exportSheetToCsv(SheetProject project) async {
    final buffer = StringBuffer();
    final result = project.result;

    buffer.write('\uFEFF'); // BOM
    buffer.writeln('シート番号,ピース番号,ラベル,幅(mm),高さ(mm),X座標,Y座標,回転,端材面積(mm²)');

    if (result != null) {
      for (var binIndex = 0; binIndex < result.bins.length; binIndex++) {
        final bin = result.bins[binIndex];
        for (var pieceIndex = 0; pieceIndex < bin.pieces.length; pieceIndex++) {
          final piece = bin.pieces[pieceIndex];
          final label = _escapeCsvField(piece.label ?? '');
          final wasteValue = pieceIndex == bin.pieces.length - 1
              ? bin.wasteArea.toStringAsFixed(1)
              : '';
          buffer.writeln(
            '${binIndex + 1},${pieceIndex + 1},$label,'
            '${piece.width.toStringAsFixed(0)},${piece.height.toStringAsFixed(0)},'
            '${piece.x.toStringAsFixed(0)},${piece.y.toStringAsFixed(0)},'
            '${piece.rotated ? "Yes" : "No"},$wasteValue',
          );
        }
      }
    }

    final dir = await getTemporaryDirectory();
    final safeName = _sanitizeFilename(project.name);
    final filePath = '${dir.path}/${safeName}_sheet_cut_plan.csv';
    final file = File(filePath);
    await file.writeAsString(buffer.toString(), encoding: utf8);

    return filePath;
  }

  // ---------------------------------------------------------------------------
  // 2D 合板 JSON エクスポート / インポート
  // ---------------------------------------------------------------------------

  static Future<String> exportSheetToJson(SheetProject project) async {
    final map = _sheetProjectToMap(project);
    final jsonString = const JsonEncoder.withIndent('  ').convert(map);

    final dir = await getTemporaryDirectory();
    final safeName = _sanitizeFilename(project.name);
    final filePath = '${dir.path}/${safeName}_sheet_project.json';
    final file = File(filePath);
    await file.writeAsString(jsonString, encoding: utf8);

    return filePath;
  }

  static Future<SheetProject?> importSheetFromJson(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return null;

      final fileSize = await file.length();
      if (fileSize > _maxJsonFileSize) return null;

      final jsonString = await file.readAsString(encoding: utf8);
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) return null;

      return _sheetProjectFromMap(decoded);
    } on FormatException {
      return null;
    } on FileSystemException {
      return null;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // ファイル共有
  // ---------------------------------------------------------------------------

  static Future<void> shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
    // 共有完了後に一時ファイルを削除
    _cleanupTempFile(filePath);
  }

  /// 一時ファイルを安全に削除する
  static void _cleanupTempFile(String filePath) {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {
      // 削除失敗は無視（OS が後で回収する）
    }
  }

  // ---------------------------------------------------------------------------
  // Private: シリアライズ / デシリアライズ
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _projectToMap(Project project) {
    return {
      'id': project.id,
      'name': project.name,
      'woodStock': {
        'name': project.woodStock.name,
        'width': project.woodStock.width,
        'height': project.woodStock.height,
        'lengths': project.woodStock.lengths,
      },
      'stockLength': project.stockLength,
      'pieces': project.pieces
          .map((p) => {'length': p.length, 'quantity': p.quantity, 'label': p.label})
          .toList(),
      'kerfWidth': project.kerfWidth,
      'unitPrice': project.unitPrice,
      'result': project.result != null
          ? {
              'bins': project.result!.bins
                  .map((b) => {
                        'pieces': b.pieces
                            .map((p) => {'length': p.length, 'label': p.label})
                            .toList(),
                        'waste': b.waste,
                        'stockLength': b.stockLength,
                      })
                  .toList(),
              'totalStock': project.result!.totalStock,
              'totalWaste': project.result!.totalWaste,
              'utilizationRate': project.result!.utilizationRate,
            }
          : null,
      'createdAt': project.createdAt.toIso8601String(),
      'updatedAt': project.updatedAt.toIso8601String(),
    };
  }

  /// 部材数の上限
  static const int _maxPieces = 10000;

  static double _positiveNum(dynamic value) {
    if (value is! num) throw const FormatException('not a number');
    final d = value.toDouble();
    if (d < 0 || d > 1e8) throw const FormatException('out of range');
    return d;
  }

  static int _positiveInt(dynamic value) {
    if (value is! int) throw const FormatException('not an int');
    if (value <= 0 || value > 1e7) throw const FormatException('out of range');
    return value;
  }

  static Project _projectFromMap(Map<String, dynamic> map) {
    // 必須フィールドの型チェック
    if (map['id'] is! String ||
        map['name'] is! String ||
        map['woodStock'] is! Map<String, dynamic> ||
        map['pieces'] is! List) {
      throw const FormatException('missing required fields');
    }

    final wsMap = map['woodStock'] as Map<String, dynamic>;
    CutResult? result;
    if (map['result'] != null) {
      if (map['result'] is! Map<String, dynamic>) {
        throw const FormatException('invalid result');
      }
      final rMap = map['result'] as Map<String, dynamic>;
      final bins = rMap['bins'];
      if (bins is! List) throw const FormatException('invalid bins');
      if (bins.length > _maxPieces) throw const FormatException('too many bins');

      result = CutResult(
        bins: bins.map((bMap) {
          if (bMap is! Map<String, dynamic>) throw const FormatException('invalid bin');
          final b = bMap;
          final pieces = b['pieces'];
          if (pieces is! List) throw const FormatException('invalid pieces');
          if (pieces.length > _maxPieces) throw const FormatException('too many pieces');
          return CutBin(
            pieces: pieces.map((pMap) {
              if (pMap is! Map<String, dynamic>) throw const FormatException('invalid piece');
              return CutPieceResult(
                length: _positiveNum(pMap['length']),
                label: pMap['label'] is String ? pMap['label'] as String : null,
              );
            }).toList(),
            waste: _positiveNum(b['waste']),
            stockLength: _positiveNum(b['stockLength']),
          );
        }).toList(),
        totalStock: _positiveInt(rMap['totalStock']),
        totalWaste: _positiveNum(rMap['totalWaste']),
        utilizationRate: _positiveNum(rMap['utilizationRate']),
      );
    }

    final piecesList = map['pieces'] as List;
    if (piecesList.length > _maxPieces) throw const FormatException('too many pieces');

    return Project(
      id: map['id'] as String,
      name: (map['name'] as String).substring(0, (map['name'] as String).length.clamp(0, 200)),
      woodStock: WoodStock(
        name: wsMap['name'] is String ? wsMap['name'] as String : 'unknown',
        width: _positiveNum(wsMap['width']),
        height: _positiveNum(wsMap['height']),
        lengths: (wsMap['lengths'] is List)
            ? (wsMap['lengths'] as List).whereType<int>().toList()
            : <int>[],
      ),
      stockLength: _positiveInt(map['stockLength']),
      pieces: piecesList.map((pMap) {
        if (pMap is! Map<String, dynamic>) throw const FormatException('invalid piece');
        return CutPiece(
          length: _positiveNum(pMap['length']),
          quantity: _positiveInt(pMap['quantity']),
          label: pMap['label'] is String ? pMap['label'] as String : null,
        );
      }).toList(),
      kerfWidth: _positiveNum(map['kerfWidth']),
      unitPrice: map['unitPrice'] != null && map['unitPrice'] is num
          ? _positiveNum(map['unitPrice'])
          : null,
      result: result,
      createdAt: map['createdAt'] is String ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
      updatedAt: map['updatedAt'] is String ? DateTime.parse(map['updatedAt'] as String) : DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // Private: 2D シリアライズ / デシリアライズ
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _sheetProjectToMap(SheetProject project) {
    return {
      'type': 'sheet',
      'id': project.id,
      'name': project.name,
      'sheetStock': {
        'name': project.sheetStock.name,
        'width': project.sheetStock.width,
        'height': project.sheetStock.height,
        'thickness': project.sheetStock.thickness,
        'price': project.sheetStock.price,
      },
      'pieces': project.pieces
          .map((p) => {
                'width': p.width,
                'height': p.height,
                'quantity': p.quantity,
                'label': p.label,
                'canRotate': p.canRotate,
              })
          .toList(),
      'kerfWidth': project.kerfWidth,
      'unitPrice': project.unitPrice,
      'result': project.result != null
          ? {
              'bins': project.result!.bins
                  .map((b) => {
                        'pieces': b.pieces
                            .map((p) => {
                                  'x': p.x,
                                  'y': p.y,
                                  'width': p.width,
                                  'height': p.height,
                                  'rotated': p.rotated,
                                  'label': p.label,
                                })
                            .toList(),
                        'wasteArea': b.wasteArea,
                        'sheetWidth': b.sheetWidth,
                        'sheetHeight': b.sheetHeight,
                      })
                  .toList(),
              'totalSheets': project.result!.totalSheets,
              'totalWasteArea': project.result!.totalWasteArea,
              'utilizationRate': project.result!.utilizationRate,
            }
          : null,
      'createdAt': project.createdAt.toIso8601String(),
      'updatedAt': project.updatedAt.toIso8601String(),
    };
  }

  static SheetProject _sheetProjectFromMap(Map<String, dynamic> map) {
    if (map['id'] is! String ||
        map['name'] is! String ||
        map['sheetStock'] is! Map<String, dynamic> ||
        map['pieces'] is! List) {
      throw const FormatException('missing required fields');
    }

    final ssMap = map['sheetStock'] as Map<String, dynamic>;
    SheetCutResult? result;
    if (map['result'] != null) {
      if (map['result'] is! Map<String, dynamic>) {
        throw const FormatException('invalid result');
      }
      final rMap = map['result'] as Map<String, dynamic>;
      final bins = rMap['bins'];
      if (bins is! List) throw const FormatException('invalid bins');
      if (bins.length > _maxPieces) throw const FormatException('too many bins');

      result = SheetCutResult(
        bins: bins.map((bMap) {
          if (bMap is! Map<String, dynamic>) throw const FormatException('invalid bin');
          final pieces = bMap['pieces'];
          if (pieces is! List) throw const FormatException('invalid pieces');
          if (pieces.length > _maxPieces) throw const FormatException('too many pieces');
          return SheetCutBin(
            pieces: pieces.map((pMap) {
              if (pMap is! Map<String, dynamic>) throw const FormatException('invalid piece');
              return SheetPlacedPiece(
                x: _positiveNum(pMap['x']),
                y: _positiveNum(pMap['y']),
                width: _positiveNum(pMap['width']),
                height: _positiveNum(pMap['height']),
                rotated: pMap['rotated'] == true,
                label: pMap['label'] is String ? pMap['label'] as String : null,
              );
            }).toList(),
            wasteArea: _positiveNum(bMap['wasteArea']),
            sheetWidth: _positiveNum(bMap['sheetWidth']),
            sheetHeight: _positiveNum(bMap['sheetHeight']),
          );
        }).toList(),
        totalSheets: _positiveInt(rMap['totalSheets']),
        totalWasteArea: _positiveNum(rMap['totalWasteArea']),
        utilizationRate: _positiveNum(rMap['utilizationRate']),
      );
    }

    final piecesList = map['pieces'] as List;
    if (piecesList.length > _maxPieces) throw const FormatException('too many pieces');

    return SheetProject(
      id: map['id'] as String,
      name: (map['name'] as String).substring(0, (map['name'] as String).length.clamp(0, 200)),
      sheetStock: SheetStock(
        name: ssMap['name'] is String ? ssMap['name'] as String : 'unknown',
        width: _positiveNum(ssMap['width']),
        height: _positiveNum(ssMap['height']),
        thickness: _positiveNum(ssMap['thickness']),
        price: ssMap['price'] is int ? ssMap['price'] as int : null,
      ),
      pieces: piecesList.map((pMap) {
        if (pMap is! Map<String, dynamic>) throw const FormatException('invalid piece');
        return SheetPiece(
          width: _positiveNum(pMap['width']),
          height: _positiveNum(pMap['height']),
          quantity: _positiveInt(pMap['quantity']),
          label: pMap['label'] is String ? pMap['label'] as String : null,
          canRotate: pMap['canRotate'] != false,
        );
      }).toList(),
      kerfWidth: _positiveNum(map['kerfWidth']),
      unitPrice: map['unitPrice'] != null && map['unitPrice'] is num
          ? _positiveNum(map['unitPrice'])
          : null,
      result: result,
      createdAt: map['createdAt'] is String ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
      updatedAt: map['updatedAt'] is String ? DateTime.parse(map['updatedAt'] as String) : DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // Private: ユーティリティ
  // ---------------------------------------------------------------------------

  static String _sanitizeFilename(String name) {
    final sanitized = name.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_');
    final trimmed = sanitized.trim().replaceAll(RegExp(r'^\.+|\.+$'), '');
    if (trimmed.isEmpty) return 'project';
    return trimmed.length > 100 ? trimmed.substring(0, 100) : trimmed;
  }

  static String _escapeCsvField(String field) {
    // CSV Injection 対策: 数式として解釈される先頭文字をエスケープ
    var safe = field;
    if (safe.isNotEmpty &&
        (safe.startsWith('=') ||
            safe.startsWith('+') ||
            safe.startsWith('-') ||
            safe.startsWith('@') ||
            safe.startsWith('\t') ||
            safe.startsWith('\r'))) {
      safe = "'$safe";
    }
    if (safe.contains(RegExp(r'[,"\n\r]'))) {
      return '"${safe.replaceAll('"', '""')}"';
    }
    return safe;
  }
}
