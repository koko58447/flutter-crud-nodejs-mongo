import 'dart:html' as html;
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

void exportListToExcel({
  required List data,
  required String sheetName,
  required List<String> headers,
  required List<String> fields,
  required String fileName,
}) {
  var excel = Excel.createExcel();
  Sheet sheetObject = excel[sheetName];
  sheetObject.appendRow(headers);

  for (var item in data) {
    sheetObject.appendRow([
      for (var field in fields) item[field]
    ]);
  }

  final excelBytes = excel.encode();
  final blob = html.Blob([excelBytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..target = 'blank'
    ..download = fileName
    ..click();
  html.Url.revokeObjectUrl(url);
}

void exportListToCSV({
  required List data,
  required List<String> headers,
  required List<String> fields,
  String fileName = 'export.csv',
}) {
  List<List<dynamic>> rows = [headers];
  for (var item in data) {
    rows.add([
      for (var field in fields) item[field]
    ]);
  }
  String csvData = const ListToCsvConverter().convert(rows);
  final bytes = html.Blob([csvData]);
  final url = html.Url.createObjectUrlFromBlob(bytes);
  final anchor = html.AnchorElement(href: url)
    ..target = 'blank'
    ..download = fileName
    ..click();
  html.Url.revokeObjectUrl(url);
}