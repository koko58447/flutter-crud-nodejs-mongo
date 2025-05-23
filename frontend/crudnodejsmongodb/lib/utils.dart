import 'dart:html' as html;
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
    sheetObject.appendRow([for (var field in fields) item[field]]);
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
    rows.add([for (var field in fields) item[field]]);
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
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () => onDelete(supplier),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: SizedBox(
            width: constraints.maxWidth, // Full width
            child: PaginatedDataTable(
              header: Text(title),
              columns:
                  columns
                      .map(
                        (column) => DataColumn(label: Text(column['label']!)),
                      )
                      .toList()
                    ..add(
                      const DataColumn(label: Text('Actions')),
                    ), // Add actions column
              source: _UserDataSource(
                filteredSuppliers: filteredSuppliers,
                onEdit: onEdit,
                onDelete: onDelete,
                columns: columns,
              ),
              columnSpacing: 20, // Adjust spacing between columns
              horizontalMargin: 10, // Adjust horizontal margin
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

  @override
  DataRow? getRow(int index) {
    if (index >= filteredSuppliers.length) return null;

    final supplier = filteredSuppliers[index];
    return DataRow(
      cells: [
        ...columns.map((column) {
          final key = column['key']!;
          return DataCell(Text(supplier[key]?.toString() ?? 'N/A'));
        }).toList(),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => onEdit(supplier),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(supplier),
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
        fileName = pickedFile.path.split('/').last;
      }

      return {'filePath': fileName, 'fileBytes': fileBytes};
    }
  } catch (e) {
    print("Failed to pick image: $e");
  }

  return null; // ဘာမှမရွေးရင် null ပြန်ပါမယ်
}
