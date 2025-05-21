import 'dart:html' as html;
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    required this.filteredSuppliers,
    required this.onEdit,
    required this.onDelete,
    required this.columns, // Pass column definitions
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filteredSuppliers.length,
      itemBuilder: (context, index) {
        var supplier = filteredSuppliers[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...columns.map((column) {
                  final key = column['key']!;
                  final label = column['label']!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '$label: ${supplier[key] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
              columns: columns
                  .map((column) => DataColumn(label: Text(column['label']!)))
                  .toList()
                ..add(const DataColumn(
                    label: Text('Actions'))), // Add actions column
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
    return DataRow(cells: [
      ...columns.map((column) {
        final key = column['key']!;
        return DataCell(Text(supplier[key]?.toString() ?? 'N/A'));
      }).toList(),
      DataCell(Row(
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
      )),
    ]);
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
      content: Text("Are you sure you want to delete item?"),
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

//show snackbar
void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
