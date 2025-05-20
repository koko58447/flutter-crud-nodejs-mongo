import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'form.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'constants.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List users = [];
  List filteredUsers = [];
  final searchController = TextEditingController();
  bool isLoading = false;

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await http.get(Uri.parse('$apiBaseUrl/api/users'));
      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body);
          filteredUsers = users;
        });
      } else {
        showSnackBar("Failed to fetch users. Please try again.");
      }
    } catch (e) {
      showSnackBar("An error occurred while fetching users.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredUsers = users;
      });
      return;
    }

    setState(() {
      filteredUsers = users.where((user) {
        String name = user['name'].toLowerCase();
        String email = user['email'].toLowerCase();
        return name.contains(query.toLowerCase()) ||
            email.contains(query.toLowerCase());
      }).toList();
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> handleEdit(Map user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            UserForm(user: user), // Ensure UserForm is implemented correctly
      ),
    );
    if (result == true) {
      // Fetch users again to reflect changes
      await fetchUsers();
      showSnackBar("${user['name']} has been updated.");
    }
  }

  void handleDelete(Map user) async {
    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete ${user['name']}?"),
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
        // Example: API call to delete user from DB
        final response = await http.delete(
          Uri.parse('$apiBaseUrl/api/users/${user['_id']}'),
        );

        if (response.statusCode == 200) {
          setState(() {
            users.remove(user); // Remove user from local list
            filteredUsers = users; // Update filtered list
          });
          showSnackBar("${user['name']} has been deleted.");
        } else {
          showSnackBar("Failed to delete ${user['name']} from the database.");
        }
      } catch (e) {
        showSnackBar("An error occurred: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
    searchController.addListener(() {
      filterSearch(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void exportToExcel() {
    try {
      // Create a new Excel document
      var excel = Excel.createExcel();

      // Add a sheet and populate it with data
      Sheet sheetObject = excel['Users'];
      sheetObject.appendRow(["Name", "Email"]); // Header row

      // Add user data to the sheet
      for (var user in filteredUsers) {
        sheetObject.appendRow([user['name'], user['email']]);
      }

      // Save the Excel file as bytes
      final excelBytes = excel.encode();

      // Create a Blob and download the file
      final blob = html.Blob([excelBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = 'users.xlsx'
        ..click();
      html.Url.revokeObjectUrl(url);

      print("Excel file exported successfully.");
    } catch (e) {
      print("Error exporting Excel: $e");
    }
  }

  void exportToCSV() {
    try {
      // Define the headers for the CSV file
      List<List<dynamic>> rows = [
        ["Name", "Email"] // Header row
      ];

      // Add user data to the rows
      for (var user in filteredUsers) {
        rows.add([user['name'], user['email']]);
      }

      // Convert rows to CSV format
      String csvData = const ListToCsvConverter().convert(rows);

      // Create a Blob and download the file
      final bytes = html.Blob([csvData]);
      final url = html.Url.createObjectUrlFromBlob(bytes);
      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = 'users.csv'
        ..click();
      html.Url.revokeObjectUrl(url);

      print("CSV file exported successfully.");
    } catch (e) {
      print("Error exporting CSV: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by name or email",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? const Center(child: Text("No users found."))
                    : screenWidth < 600
                        ? MobileView(
                            filteredUsers: filteredUsers,
                            onEdit: handleEdit,
                            onDelete: handleDelete,
                          )
                        : TableView(
                            filteredUsers: filteredUsers,
                            onEdit: handleEdit,
                            onDelete: handleDelete,
                          ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add, // Main FAB icon
        activeIcon: Icons.close, // Icon when FAB is expanded
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.file_download),
            label: 'Export CSV',
            backgroundColor: Colors.green,
            onTap: exportToCSV, // Call the exportToCSV function
          ),
          SpeedDialChild(
            child: const Icon(Icons.table_chart),
            label: 'Export Excel',
            backgroundColor: Colors.orange,
            onTap: exportToExcel, // Call the exportToExcel function
          ),
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Add User',
            backgroundColor: Colors.blue,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserForm()),
              );
              if (result == true) fetchUsers();
            },
          ),
        ],
      ),
    );
  }
}

class MobileView extends StatelessWidget {
  final List filteredUsers;
  final Function(Map) onEdit;
  final Function(Map) onDelete;

  const MobileView({
    required this.filteredUsers,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        var user = filteredUsers[index];
        return ListTile(
          leading: const Icon(Icons.person, size: 50),
          title: Text(user['name']),
          subtitle: Text(user['email']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => onEdit(user),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(user),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TableView extends StatelessWidget {
  final List filteredUsers;
  final Function(Map) onEdit;
  final Function(Map) onDelete;

  const TableView({
    required this.filteredUsers,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                ),
                child: PaginatedDataTable(
                  header: const Text("User List"),
                  columns: const [
                    DataColumn(label: Text("Name")),
                    DataColumn(label: Text("Email")),
                    DataColumn(label: Text("Actions")),
                  ],
                  source: _UserDataSource(
                    filteredUsers: filteredUsers,
                    onEdit: onEdit,
                    onDelete: onDelete,
                  ),
                  rowsPerPage: 10, // Number of rows per page
                  columnSpacing: 20,
                  horizontalMargin: 10,
                  showCheckboxColumn: false, // Hide checkbox column
                ),
              ),
              const SizedBox(height: 60), // Add spacing below the table
            ],
          ),
        );
      },
    );
  }
}

class _UserDataSource extends DataTableSource {
  final List filteredUsers;
  final Function(Map) onEdit;
  final Function(Map) onDelete;

  _UserDataSource({
    required this.filteredUsers,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= filteredUsers.length) return null;

    final user = filteredUsers[index];
    return DataRow(cells: [
      DataCell(Text(user['name'])),
      DataCell(Text(user['email'])),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => onEdit(user),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(user),
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => filteredUsers.length;

  @override
  int get selectedRowCount => 0;
}
