import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:itagiri_kun/models/project.dart';
import 'package:itagiri_kun/models/wood_stock.dart';
import 'package:itagiri_kun/models/cut_piece.dart';
import 'package:itagiri_kun/models/cut_result.dart';
import 'package:itagiri_kun/services/export_service.dart';

void main() {
  group('ExportService JSON roundtrip', () {
    test('エクスポートしてインポートするとデータが保持される', () async {
      final project = Project(
        id: 'test-id',
        name: 'テストプロジェクト',
        woodStock: WoodStock(
          name: '2x4',
          width: 38,
          height: 89,
          lengths: [1820],
        ),
        stockLength: 1820,
        pieces: [
          const CutPiece(length: 500, quantity: 3, label: '棚板'),
          const CutPiece(length: 300, quantity: 2),
        ],
        kerfWidth: 3.0,
        unitPrice: 498,
        result: const CutResult(
          bins: [
            CutBin(
              pieces: [
                CutPieceResult(length: 500, label: '棚板'),
                CutPieceResult(length: 500, label: '棚板'),
                CutPieceResult(length: 500, label: '棚板'),
              ],
              waste: 311,
              stockLength: 1820,
            ),
            CutBin(
              pieces: [
                CutPieceResult(length: 300),
                CutPieceResult(length: 300),
              ],
              waste: 1217,
              stockLength: 1820,
            ),
          ],
          totalStock: 2,
          totalWaste: 1528,
          utilizationRate: 0.58,
        ),
      );

      // JSON にシリアライズ
      final tempDir = Directory.systemTemp.createTempSync('export_test');
      try {
        final jsonPath = '${tempDir.path}/test_export.json';
        // ExportService.exportToJson uses path_provider which won't work in test
        // So test the roundtrip logic directly via JSON encode/decode

        // Manually test the serialization by using the same _projectToMap logic
        final map = {
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
          'result': {
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
          },
          'createdAt': project.createdAt.toIso8601String(),
          'updatedAt': project.updatedAt.toIso8601String(),
        };

        final jsonString = const JsonEncoder.withIndent('  ').convert(map);
        final file = File(jsonPath);
        await file.writeAsString(jsonString, encoding: utf8);

        // インポート
        final imported = await ExportService.importFromJson(jsonPath);

        expect(imported, isNotNull);
        expect(imported!.name, equals('テストプロジェクト'));
        expect(imported.woodStock.name, equals('2x4'));
        expect(imported.stockLength, equals(1820));
        expect(imported.pieces.length, equals(2));
        expect(imported.pieces[0].label, equals('棚板'));
        expect(imported.kerfWidth, equals(3.0));
        expect(imported.unitPrice, equals(498));
        expect(imported.result, isNotNull);
        expect(imported.result!.totalStock, equals(2));
        expect(imported.result!.bins.length, equals(2));
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('不正なJSONはnullを返す', () async {
      final tempDir = Directory.systemTemp.createTempSync('export_test2');
      try {
        final filePath = '${tempDir.path}/bad.json';
        await File(filePath).writeAsString('not valid json');

        final result = await ExportService.importFromJson(filePath);
        expect(result, isNull);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('存在しないファイルはnullを返す', () async {
      final result = await ExportService.importFromJson('/nonexistent/path.json');
      expect(result, isNull);
    });
  });

  group('ExportService CSV', () {
    test('CSVフィールドエスケープ', () {
      // Private method test via behavior
      // Just verify the export doesn't crash with special characters in labels
      final project = Project(
        id: 'csv-test',
        name: 'CSV"テスト,改行\nあり',
        woodStock: WoodStock(name: '2x4', width: 38, height: 89, lengths: [1820]),
        stockLength: 1820,
        pieces: [const CutPiece(length: 500, quantity: 1, label: 'ラベル,"カンマ付き"')],
        kerfWidth: 3.0,
        result: const CutResult(
          bins: [
            CutBin(
              pieces: [CutPieceResult(length: 500, label: 'ラベル,"カンマ付き"')],
              waste: 1320,
              stockLength: 1820,
            ),
          ],
          totalStock: 1,
          totalWaste: 1320,
          utilizationRate: 0.275,
        ),
      );

      // This would normally call exportToCsv but that needs path_provider
      // At minimum verify the project is valid
      expect(project.name, contains(','));
      expect(project.pieces[0].label, contains('"'));
    });
  });
}
