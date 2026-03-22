import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:itagiri_kun/models/sheet_models.dart';
import 'package:itagiri_kun/models/sheet_project.dart';
import 'package:itagiri_kun/services/export_service.dart';

/// テストヘルパー: 基本的な SheetProject を作成する
SheetProject _createTestSheetProject({
  String id = 'sheet-test-id',
  String name = 'テスト合板プロジェクト',
  double unitPrice = 1280,
  bool withResult = true,
}) {
  final sheetStock = SheetStock(
    name: 'ラワン合板',
    width: 910,
    height: 1820,
    thickness: 12,
    price: 1280,
  );

  final pieces = [
    SheetPiece(width: 400, height: 300, quantity: 2, label: '棚板'),
    SheetPiece(width: 200, height: 500, quantity: 1, label: '側板'),
    SheetPiece(width: 600, height: 400, quantity: 1, canRotate: false),
  ];

  SheetCutResult? result;
  if (withResult) {
    result = const SheetCutResult(
      bins: [
        SheetCutBin(
          pieces: [
            SheetPlacedPiece(x: 0, y: 0, width: 400, height: 300, label: '棚板'),
            SheetPlacedPiece(x: 403, y: 0, width: 400, height: 300, label: '棚板'),
            SheetPlacedPiece(x: 0, y: 303, width: 200, height: 500, label: '側板'),
            SheetPlacedPiece(x: 203, y: 303, width: 600, height: 400, rotated: false),
          ],
          wasteArea: 1015800,
          sheetWidth: 910,
          sheetHeight: 1820,
        ),
      ],
      totalSheets: 1,
      totalWasteArea: 1015800,
      utilizationRate: 0.387,
    );
  }

  return SheetProject(
    id: id,
    name: name,
    sheetStock: sheetStock,
    pieces: pieces,
    kerfWidth: 3.0,
    result: result,
    unitPrice: unitPrice,
  );
}

void main() {
  group('SheetProject モデル', () {
    test('totalPieceCount は全ピースの合計数を返す', () {
      final project = _createTestSheetProject();
      // 2 + 1 + 1 = 4
      expect(project.totalPieceCount, equals(4));
    });

    test('totalPieceArea は全ピースの合計面積を返す', () {
      final project = _createTestSheetProject();
      // 400*300*2 + 200*500*1 + 600*400*1 = 240000 + 100000 + 240000 = 580000
      expect(project.totalPieceArea, equals(580000));
    });

    test('totalCost は unitPrice * totalSheets を返す', () {
      final project = _createTestSheetProject(unitPrice: 1280);
      // 1280 * 1 = 1280
      expect(project.totalCost, equals(1280.0));
    });

    test('totalCost は unitPrice が null の場合 null を返す', () {
      final project = _createTestSheetProject();
      final noPrice = project.copyWith(unitPrice: 0); // override
      // copyWith doesn't support setting to null easily, test directly
      final p2 = SheetProject(
        id: 'x',
        name: 'x',
        sheetStock: project.sheetStock,
        pieces: project.pieces,
        result: project.result,
      );
      expect(p2.totalCost, isNull);
    });

    test('totalCost は result が null の場合 null を返す', () {
      final project = _createTestSheetProject(withResult: false);
      expect(project.totalCost, isNull);
    });

    test('copyWith は正しくコピーされる', () {
      final project = _createTestSheetProject();
      final copied = project.copyWith(name: '変更済み');
      expect(copied.name, equals('変更済み'));
      expect(copied.id, equals(project.id));
      expect(copied.sheetStock.name, equals(project.sheetStock.name));
      expect(copied.pieces.length, equals(project.pieces.length));
      expect(copied.kerfWidth, equals(project.kerfWidth));
      expect(copied.unitPrice, equals(project.unitPrice));
    });

    test('toString はプロジェクト情報を含む', () {
      final project = _createTestSheetProject();
      final str = project.toString();
      expect(str, contains('SheetProject'));
      expect(str, contains(project.id));
      expect(str, contains(project.name));
    });
  });

  group('SheetPiece モデル', () {
    test('area は幅 x 高さを返す', () {
      final piece = SheetPiece(width: 400, height: 300, quantity: 1);
      expect(piece.area, equals(120000));
    });

    test('copyWith は正しくコピーされる', () {
      final piece = SheetPiece(
        width: 400,
        height: 300,
        quantity: 2,
        label: 'テスト',
        canRotate: true,
      );
      final copied = piece.copyWith(quantity: 5);
      expect(copied.width, equals(400));
      expect(copied.height, equals(300));
      expect(copied.quantity, equals(5));
      expect(copied.label, equals('テスト'));
      expect(copied.canRotate, isTrue);
    });

    test('equality は width, height, quantity, label で判定される', () {
      final a = SheetPiece(width: 400, height: 300, quantity: 2, label: 'A');
      final b = SheetPiece(width: 400, height: 300, quantity: 2, label: 'A');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('SheetStock モデル', () {
    test('sizeLabel は W x H mm を返す', () {
      final stock = SheetStock(name: 'テスト', width: 910, height: 1820, thickness: 12);
      expect(stock.sizeLabel, equals('910 x 1820 mm'));
    });

    test('copyWith は正しくコピーされる', () {
      final stock = SheetStock(name: 'A', width: 910, height: 1820, thickness: 12, price: 1280);
      final copied = stock.copyWith(name: 'B');
      expect(copied.name, equals('B'));
      expect(copied.width, equals(910));
      expect(copied.price, equals(1280));
    });
  });

  group('SheetCutBin', () {
    test('sheetArea, usedArea, utilizationRate の計算が正しい', () {
      const bin = SheetCutBin(
        pieces: [SheetPlacedPiece(x: 0, y: 0, width: 500, height: 500)],
        wasteArea: 750000,
        sheetWidth: 1000,
        sheetHeight: 1000,
      );
      expect(bin.sheetArea, equals(1000000));
      expect(bin.usedArea, equals(250000));
      expect(bin.utilizationRate, closeTo(0.25, 0.001));
    });
  });

  group('ExportService 2D JSON roundtrip', () {
    test('エクスポートしてインポートするとデータが保持される', () async {
      final project = _createTestSheetProject();

      final tempDir = Directory.systemTemp.createTempSync('sheet_export_test');
      try {
        // Build the same map that ExportService._sheetProjectToMap would
        final map = {
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
          'result': {
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
          },
          'createdAt': project.createdAt.toIso8601String(),
          'updatedAt': project.updatedAt.toIso8601String(),
        };

        final jsonString = const JsonEncoder.withIndent('  ').convert(map);
        final filePath = '${tempDir.path}/test_sheet_export.json';
        await File(filePath).writeAsString(jsonString, encoding: utf8);

        // インポート
        final imported = await ExportService.importSheetFromJson(filePath);

        expect(imported, isNotNull);
        expect(imported!.name, equals('テスト合板プロジェクト'));
        expect(imported.sheetStock.name, equals('ラワン合板'));
        expect(imported.sheetStock.width, equals(910));
        expect(imported.sheetStock.height, equals(1820));
        expect(imported.sheetStock.thickness, equals(12));
        expect(imported.sheetStock.price, equals(1280));
        expect(imported.pieces.length, equals(3));
        expect(imported.pieces[0].label, equals('棚板'));
        expect(imported.pieces[0].width, equals(400));
        expect(imported.pieces[0].height, equals(300));
        expect(imported.pieces[0].quantity, equals(2));
        expect(imported.pieces[1].label, equals('側板'));
        expect(imported.pieces[2].canRotate, isFalse);
        expect(imported.kerfWidth, equals(3.0));
        expect(imported.unitPrice, equals(1280));
        expect(imported.result, isNotNull);
        expect(imported.result!.totalSheets, equals(1));
        expect(imported.result!.bins.length, equals(1));
        expect(imported.result!.bins[0].pieces.length, equals(4));
        expect(imported.result!.bins[0].pieces[0].label, equals('棚板'));
        expect(imported.result!.bins[0].pieces[0].x, equals(0));
        expect(imported.result!.bins[0].pieces[0].y, equals(0));
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('result なしのプロジェクトもインポートできる', () async {
      final tempDir = Directory.systemTemp.createTempSync('sheet_export_test2');
      try {
        final map = {
          'type': 'sheet',
          'id': 'no-result',
          'name': '結果なし',
          'sheetStock': {
            'name': 'テスト',
            'width': 910.0,
            'height': 1820.0,
            'thickness': 12.0,
          },
          'pieces': [
            {'width': 400.0, 'height': 300.0, 'quantity': 1},
          ],
          'kerfWidth': 3.0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final filePath = '${tempDir.path}/no_result.json';
        await File(filePath).writeAsString(jsonEncode(map), encoding: utf8);

        final imported = await ExportService.importSheetFromJson(filePath);

        expect(imported, isNotNull);
        expect(imported!.name, equals('結果なし'));
        expect(imported.result, isNull);
        expect(imported.unitPrice, isNull);
        expect(imported.pieces.length, equals(1));
        expect(imported.pieces[0].canRotate, isTrue); // default
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('不正なJSONはnullを返す', () async {
      final tempDir = Directory.systemTemp.createTempSync('sheet_export_test3');
      try {
        final filePath = '${tempDir.path}/bad.json';
        await File(filePath).writeAsString('not valid json');

        final result = await ExportService.importSheetFromJson(filePath);
        expect(result, isNull);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('必須フィールドが欠けているJSONはnullを返す', () async {
      final tempDir = Directory.systemTemp.createTempSync('sheet_export_test4');
      try {
        final filePath = '${tempDir.path}/missing_fields.json';
        await File(filePath).writeAsString(jsonEncode({'id': 'x'}));

        final result = await ExportService.importSheetFromJson(filePath);
        expect(result, isNull);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('存在しないファイルはnullを返す', () async {
      final result = await ExportService.importSheetFromJson('/nonexistent/path.json');
      expect(result, isNull);
    });
  });

  group('SheetPlacedPiece', () {
    test('area は幅 x 高さを返す', () {
      const piece = SheetPlacedPiece(x: 10, y: 20, width: 300, height: 400);
      expect(piece.area, equals(120000));
    });

    test('equality は x, y, width, height で判定される', () {
      const a = SheetPlacedPiece(x: 10, y: 20, width: 300, height: 400, label: 'A');
      const b = SheetPlacedPiece(x: 10, y: 20, width: 300, height: 400, label: 'B');
      expect(a, equals(b)); // label は equality に含まれない
    });

    test('toString は位置とサイズを含む', () {
      const piece = SheetPlacedPiece(x: 10, y: 20, width: 300, height: 400, rotated: true);
      final str = piece.toString();
      expect(str, contains('10'));
      expect(str, contains('20'));
      expect(str, contains('300'));
      expect(str, contains('400'));
      expect(str, contains('true'));
    });
  });
}
