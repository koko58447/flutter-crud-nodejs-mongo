import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

class Exportexcel extends StatefulWidget {
  const Exportexcel({super.key});

  @override
  State<Exportexcel> createState() => _ExportexcelState();
}

class _ExportexcelState extends State<Exportexcel> {
  Future<void> _createAndSaveExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // ဒေတာထည့်ပါ
    sheet.cell(CellIndex.indexByString("A1")).value = TextCellValue("Name");
    sheet.cell(CellIndex.indexByString("B1")).value = TextCellValue("Age");
    sheet.cell(CellIndex.indexByString("A2")).value = TextCellValue("Mg Mg");
    sheet.cell(CellIndex.indexByString("B2")).value = TextCellValue("25");
    final fileBytes = excel.encode()!;

    if (kIsWeb) {
      // Web မှာ ဖိုင်ကို download လုပ်ပါ
      // final blob = Blob([
      //   fileBytes,
      // ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      // final url = Url.createObjectUrlFromBlob(blob);
      // AnchorElement(href: url)
      //   ..setAttribute('download', 'sample.xlsx')
      //   ..click();
      // Url.revokeObjectUrl(url);
      // return;
    } else {
      // File Path ရယူပါ
      final directory = await getApplicationDocumentsDirectory();

      final file = File("${directory.path}/sample.xlsx")
        ..writeAsBytesSync(fileBytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Please check the attached Excel file.');
    }

    // Open file
    // OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Excel File')),
      body: const Center(child: Text('Press the button to create Excel')),
      floatingActionButton: FloatingActionButton(
        onPressed: _createAndSaveExcel,
        child: const Icon(Icons.save),
      ),
    );
  }
}
