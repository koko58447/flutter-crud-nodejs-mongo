import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as mylib;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> createAndSharePrintPDF({
  required List<String> headers,
  required List<List<dynamic>> rows,
  String fileName = 'export.pdf',
}) async {
  final pdf = pw.Document();

  // PDF တွင် Table ထည့်ပါ
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Table.fromTextArray(
          headers: headers,
          data: rows
              .map((row) => row.map((cell) => cell.toString()).toList())
              .toList(),
        );
      },
    ),
  );

  if (kIsWeb) {
    // 🌐 Web မှာ PDF ကို browser မှာ preview/download လုပ်ပါ
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  } else {
    // 📱 Mobile မှာ PDF ကို save သို့မဟုတ် print လုပ်ပါ
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    // Share လုပ်ပါ
    await Share.shareXFiles([XFile(file.path)], text: 'PDF Report Attached');
  }
}

Future<void> createAndShareExportCSV({
  required List<String> headers,
  required List<List<dynamic>> rows,
  String fileName = 'export.csv',
}) async {
  // Header ထည့်ပါ
  final csv = StringBuffer();
  csv.writeln(headers.join(','));

  // Rows ထည့်ပါ
  for (var row in rows) {
    csv.writeln(row.map((cell) => '"$cell"').join(','));
  }

  if (kIsWeb) {
    // 🔁 Web အတွက် – Browser မှာ download လုပ်ပါ
    final blob = mylib.Blob([csv.toString()], 'text/csv');
    final url = mylib.Url.createObjectUrlFromBlob(blob);
    final anchor = mylib.AnchorElement()
      ..href = url
      ..download = "$fileName"
      ..click();
    mylib.Url.revokeObjectUrl(url);
  } else {
    // 📱 Mobile အတွက် – File သိမ်းပြီး Share လုပ်ပါ
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath)..writeAsStringSync(csv.toString());

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Please check the attached CSV file.');
  }
}

Future<void> createAndShareExcel({
  required List<String> headers,
  required List<List<dynamic>> rows,
  String fileName = 'export.xlsx',
}) async {
  // Excel ဖန်တီးပါ
  final excel = Excel.createExcel();
  final sheet = excel['Sheet1'];

  // Headers ထည့်ပါ (A1, B1, C1 ...)
  for (int i = 0; i < headers.length; i++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value =
        TextCellValue(headers[i]);
  }

  // Rows ထည့်ပါ (A2, B2, A3, B3 ...)
  for (int rowIdx = 0; rowIdx < rows.length; rowIdx++) {
    final rowData = rows[rowIdx];
    for (int colIdx = 0; colIdx < rowData.length; colIdx++) {
      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: colIdx,
              rowIndex: rowIdx + 1,
            ),
          )
          .value = TextCellValue(
        rowData[colIdx].toString(),
      );
    }
  }

  if (kIsWeb) {
    // 🔁 Web အတွက် – Browser မှာ download လုပ်ပါ
    final bytes = excel.encode()!;
    final blob = mylib.Blob([
      bytes,
    ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    final url = mylib.Url.createObjectUrlFromBlob(blob);
    final anchor = mylib.AnchorElement()
      ..href = url
      ..download = "$fileName"
      ..click();
    mylib.Url.revokeObjectUrl(url);
  } else {
    // File Path ရယူပါ
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath)..writeAsBytesSync(excel.encode()!);

    // Share ပြုလုပ်ပါ
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Please check the attached Excel file.');
  }
}

//mobile view and table view
class MobileView extends StatelessWidget {
  final List<Map<String, dynamic>> filteredSuppliers;
  final Function(Map) onEdit;
  final Function(Map) onDelete;
  final List<Map<String, String>> columns; // List of column definitions

  const MobileView({
    super.key,
    required this.filteredSuppliers,
    required this.onEdit,
    required this.onDelete,
    required this.columns, // Pass column definitions
  });

  @override
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filteredSuppliers.length,
      itemBuilder: (context, index) {
        var supplier = filteredSuppliers[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...columns.map((column) {
                  final key = column['key']!;
                  final label = column['label']!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          supplier[key]?.toString() ?? 'N/A',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(thickness: 1, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      label: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () => onEdit(supplier),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            20,
                          ), // အဝိုင်းပုံစံ
                          side: BorderSide(color: Colors.blue.withOpacity(0.6)),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        elevation: 2,
                        shadowColor: Colors.blue.withOpacity(0.3),
                        minimumSize: const Size(100, 40),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () => onDelete(supplier),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            20,
                          ), // အဝိုင်းပုံစံ
                          side: BorderSide(color: Colors.blue.withOpacity(0.6)),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        elevation: 2,
                        shadowColor: Colors.blue.withOpacity(0.3),
                        minimumSize: const Size(100, 40),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TableView extends StatelessWidget {
  final List<Map<String, dynamic>> filteredSuppliers;
  final Function(Map) onEdit;
  final Function(Map) onDelete;
  final List<Map<String, String>> columns; // List of column definitions
  final String title;

  const TableView({
    super.key,
    required this.filteredSuppliers,
    required this.onEdit,
    required this.onDelete,
    required this.columns,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> columnsWithIndex = List.from(columns);
    columnsWithIndex.insert(0, {'key': 'index', 'label': '#'});

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: SizedBox(
            width: constraints.maxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text('Total: ${filteredSuppliers.length} records'),
                ),
                SizedBox(
                  // 👈 ဒီနေရာမှာ full width သေချာစေဖို့
                  width: double.infinity,
                  child: PaginatedDataTable(
                    header: Text(title),
                    columns: [
                      const DataColumn(label: Text('#')),
                      ...columns.map(
                        (col) => DataColumn(label: Text(col['label']!)),
                      ),
                      const DataColumn(label: Text('Actions')),
                    ],
                    source: _UserDataSource(
                      filteredSuppliers: filteredSuppliers,
                      onEdit: onEdit,
                      onDelete: onDelete,
                      columns: columns,
                    ),
                    columnSpacing: 20,
                    horizontalMargin: 10,
                    // optional: dataRowHeight, headingRowHeight တွေပြင်လို့ရပါတယ်
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UserDataSource extends DataTableSource {
  final List<Map<String, dynamic>> filteredSuppliers;
  final Function(Map) onEdit;
  final Function(Map) onDelete;
  final List<Map<String, String>> columns;

  _UserDataSource({
    required this.filteredSuppliers,
    required this.onEdit,
    required this.onDelete,
    required this.columns,
  });

  DataRow? getRow(int index) {
    if (index >= filteredSuppliers.length) return null;

    final supplier = filteredSuppliers[index];
    return DataRow(
      cells: [
        DataCell(Text('${index + 1}')), // Row number
        ...columns.map((column) {
          final key = column['key']!;
          return DataCell(Text(supplier[key]?.toString() ?? 'N/A'));
        }),
        DataCell(
          Row(
            children: [
              IconButton(
                tooltip: tr("button.edit"), // Use translation
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => onEdit(supplier),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.blue.withOpacity(0.6)),
                  ),
                  elevation: 2,
                  shadowColor: Colors.blue.withOpacity(0.3),
                ),
              ),
              IconButton(
                tooltip: tr("button.delete"),
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(supplier),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  backgroundColor: Colors.red.withOpacity(0.1),
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.red.withOpacity(0.6)),
                  ),
                  elevation: 2,
                  shadowColor: Colors.red.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => filteredSuppliers.length;

  @override
  int get selectedRowCount => 0;
}

//show all data
Future<void> fetchData({
  required String apiPath,
  required Function(List<dynamic>) onSuccess,
  required Function(String) onError,
  required VoidCallback onLoadingStart,
  required VoidCallback onLoadingEnd,
}) async {
  onLoadingStart();
  try {
    final response = await http.get(Uri.parse(apiPath));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      onSuccess(data);
    } else {
      onError("Failed to fetch data. Please try again.");
    }
  } catch (e) {
    onError("An error occurred while fetching data.");
  } finally {
    onLoadingEnd();
  }
}

// handle edit and update
Future<void> handleEdit({
  required BuildContext context,
  required Map list,
  required Future<void> Function() fetchAllData,
  required Widget Function(Map list)
  listFormBuilder, // Pass UserForm as a builder
}) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => listFormBuilder(list), // Use the passed UserForm builder
    ),
  );
  if (result == true) {
    // Fetch data again to reflect changes
    await fetchAllData();
    showSnackBar(context, "update successful");
  }
}

//handel delete and delete
Future<void> handleDelete({
  required BuildContext context,
  required Map list,
  required Future<void> Function(String id)
  deleteCallback, // API delete callback
  required Function(Map list) updateState, // Function to update local state
}) async {
  final bool? isConfirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Delete"),
      content: const Text("Are you sure you want to delete item?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Delete", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (isConfirmed == true) {
    try {
      // Call the delete callback function
      await deleteCallback(list['_id']);

      // Update local state
      updateState(list);

      // Show success snackbar
      showSnackBar(context, "delete successful.");
    } catch (e) {
      // Show error snackbar
      showSnackBar(context, "An error occurred: $e");
    }
  }
}

//navigatert and refresh
Future<void> navigateAndRefresh({
  required BuildContext context,
  required Widget Function()
  formBuilder, // Form widget builder (e.g., UserForm)
  required Future<void> Function() fetchAllData, // Callback to refresh data
}) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => formBuilder()),
  );

  if (result == true) {
    await fetchAllData(); // Refresh data if the form returns true
  }
}

//load data with combo box
Future<void> loadData({
  required String apiBaseUrl,
  required Function(List<Map<String, String>>)
  updateSuppliers, // Callback to update suppliers
  required Function(String) showErrorDialog, // Callback to show error dialog
}) async {
  try {
    final response = await http.get(Uri.parse(apiBaseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final suppliers = data
          .map(
            (supplier) => {
              'id': supplier['_id'].toString(),
              'name': supplier['name'].toString(),
            },
          )
          .toList();

      // Update suppliers using the callback
      updateSuppliers(suppliers);
    } else {
      showErrorDialog(
        "Failed to fetch suppliers. Status code: ${response.statusCode}",
      );
    }
  } catch (e) {
    showErrorDialog("An error occurred while fetching suppliers: $e");
  }
}

//show snackbar
void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Error"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

void showSuccessDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Success"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

//show date range picker
Future<void> selectDateRange({
  required BuildContext context,
  required DateTimeRange? initialDateRange,
  required Future<void> Function(DateTimeRange dateRange) onDateRangeSelected,
}) async {
  print("Opening date range picker...");
  DateTimeRange? picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
    initialDateRange: initialDateRange,
  );

  if (picked != null) {
    print("Date range selected: ${picked.start} - ${picked.end}");
    await onDateRangeSelected(picked);
  } else {
    print("Date range picker canceled.");
  }
}

//show date format (dd-MM-yyyy)
String formatDate(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date);
}

//get image and file path
Future<Map<String, dynamic>?> pickImageAndGetResult(
  ImagePicker picker, {
  bool fromCamera = true,
}) async {
  try {
    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedFile != null) {
      Uint8List? fileBytes;
      String? fileName;

      if (kIsWeb) {
        // Web အတွက် file ကို bytes အဖြစ်ဖတ်
        fileBytes = await pickedFile.readAsBytes();
        fileName = pickedFile.name;
      } else {
        // Mobile အတွက် file path ကိုသာ သိမ်း
        fileBytes = await pickedFile.readAsBytes();
        fileName = pickedFile.path.split('/').last;
      }

      return {'filePath': fileName, 'fileBytes': fileBytes};
    }
  } catch (e) {
    print("Failed to pick image: $e");
  }

  return null; // ဘာမှမရွေးရင် null ပြန်ပါမယ်
}

//set language
String getCurrentLanguageLabel(BuildContext context) {
  final locale = Localizations.localeOf(context);
  if (locale.languageCode == 'en') {
    return 'English';
  } else if (locale.languageCode == 'my') {
    return 'မြန်မာ';
  }
  return 'Unknown';
}

void showLanguageDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'language.select'.tr(),
      ), // သို့မဟုတ် သင့်ဘာသာပြန်ချက် key အတိုင်း
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('language.english'.tr()),
            onTap: () {
              context.setLocale(const Locale('en'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('language.myanmar'.tr()),
            onTap: () {
              context.setLocale(const Locale('my'));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}

// Custom TextField widget

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final bool isPassword; // Optional
  final TextInputType keyboardType; // Optional

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade700),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          prefixIcon: Icon(
            isPassword ? Icons.lock : Icons.person,
            color: Colors.blue,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }
}

// customElevatedButton

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final double fontSize;
  final IconData? icon; // Optional icon

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor = Colors.blueAccent,
    this.foregroundColor = Colors.white,
    this.fontSize = 16,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        elevation: 4,
        shadowColor: backgroundColor.withOpacity(0.5),
        minimumSize: const Size(200, 50),
      ),
      child: icon == null
          ? Text(text)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(icon), const SizedBox(width: 8), Text(text)],
            ),
    );
  }
}

//custom dropdown button

class CustomDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String labelText;
  final String hintText;
  final String? Function(T?)? validator;

  const CustomDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.labelText,
    required this.hintText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        onChanged: onChanged,
        items: items,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade700),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
      ),
    );
  }
}
