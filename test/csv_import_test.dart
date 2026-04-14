import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:itagiri_kun/services/csv_import_service.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('csv_import_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Future<String> _writeCsv(String content) async {
    final file = File('${tempDir.path}/test.csv');
    await file.writeAsString(content);
    return file.path;
  }

  group('CsvImportService - 1D Import', () {
    test('parses simple length,quantity CSV', () async {
      final path = await _writeCsv('500,2\n300,4\n1000,1\n');
      final pieces = await CsvImportService.import1DFromCsv(path);
      expect(pieces.length, 3);
      expect(pieces[0].length, 500);
      expect(pieces[0].quantity, 2);
      expect(pieces[1].length, 300);
      expect(pieces[1].quantity, 4);
      expect(pieces[2].length, 1000);
      expect(pieces[2].quantity, 1);
    });

    test('parses label,length,quantity CSV', () async {
      final path = await _writeCsv('棚板,500,2\n脚,800,4\n');
      final pieces = await CsvImportService.import1DFromCsv(path);
      expect(pieces.length, 2);
      expect(pieces[0].label, '棚板');
      expect(pieces[0].length, 500);
      expect(pieces[0].quantity, 2);
      expect(pieces[1].label, '脚');
    });

    test('skips header row', () async {
      final path = await _writeCsv('Label,Length,Qty\n棚板,500,2\n脚,800,4\n');
      final pieces = await CsvImportService.import1DFromCsv(path);
      expect(pieces.length, 2);
      expect(pieces[0].label, '棚板');
    });

    test('skips Japanese header row', () async {
      final path = await _writeCsv('ラベル,長さ,数量\n棚板,500,2\n');
      final pieces = await CsvImportService.import1DFromCsv(path);
      expect(pieces.length, 1);
    });

    test('handles empty lines', () async {
      final path = await _writeCsv('500,2\n\n300,4\n\n');
      final pieces = await CsvImportService.import1DFromCsv(path);
      expect(pieces.length, 2);
    });

    test('handles quoted fields', () async {
      final path = await _writeCsv('"棚板, 大",500,2\n');
      final pieces = await CsvImportService.import1DFromCsv(path);
      expect(pieces.length, 1);
      expect(pieces[0].label, '棚板, 大');
    });

    test('returns empty for invalid file', () async {
      final path = await _writeCsv('invalid\ndata\n');
      final pieces = await CsvImportService.import1DFromCsv(path);
      expect(pieces, isEmpty);
    });

    test('throws for non-existent file', () async {
      expect(
        () => CsvImportService.import1DFromCsv('${tempDir.path}/nonexist.csv'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('CsvImportService - 2D Import', () {
    test('parses width,height,quantity CSV', () async {
      final path = await _writeCsv('400,300,2\n200,150,4\n');
      final pieces = await CsvImportService.import2DFromCsv(path);
      expect(pieces.length, 2);
      expect(pieces[0].width, 400);
      expect(pieces[0].height, 300);
      expect(pieces[0].quantity, 2);
    });

    test('parses label,width,height,quantity CSV', () async {
      final path = await _writeCsv('天板,400,300,2\n側板,200,500,2\n');
      final pieces = await CsvImportService.import2DFromCsv(path);
      expect(pieces.length, 2);
      expect(pieces[0].label, '天板');
      expect(pieces[0].width, 400);
      expect(pieces[0].height, 300);
      expect(pieces[0].quantity, 2);
    });

    test('skips header row', () async {
      final path = await _writeCsv('Label,Width,Height,Qty\n天板,400,300,2\n');
      final pieces = await CsvImportService.import2DFromCsv(path);
      expect(pieces.length, 1);
      expect(pieces[0].label, '天板');
    });

    test('handles tab-separated values', () async {
      final path = await _writeCsv('400\t300\t2\n200\t150\t4\n');
      final pieces = await CsvImportService.import2DFromCsv(path);
      expect(pieces.length, 2);
    });

    test('returns empty for invalid data', () async {
      final path = await _writeCsv('abc\ndef\n');
      final pieces = await CsvImportService.import2DFromCsv(path);
      expect(pieces, isEmpty);
    });
  });

  group('CsvImportService - CSV Parsing', () {
    test('handles escaped quotes', () async {
      final path = await _writeCsv('"棚板""A""",500,2\n');
      final pieces = await CsvImportService.import1DFromCsv(path);
      expect(pieces.length, 1);
      expect(pieces[0].label, '棚板"A"');
    });

    test('handles Windows-style line endings', () async {
      final path = await _writeCsv('500,2\r\n300,4\r\n');
      final pieces = await CsvImportService.import1DFromCsv(path);
      expect(pieces.length, 2);
    });
  });
}
