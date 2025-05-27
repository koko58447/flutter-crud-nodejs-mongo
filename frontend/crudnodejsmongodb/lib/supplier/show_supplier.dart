import '/supplier/form_supplier.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../constants.dart';
import '../utils.dart';

class Supplier extends StatefulWidget {
  const Supplier({Key? key}) : super(key: key);

  @override
  State<Supplier> createState() => _SupplierState();
}

class _SupplierState extends State<Supplier> {
  List suppliers = [];
  List filteredSuppliers = [];
  final searchController = TextEditingController();
  bool isLoading = false;
  DateTimeRange? selectedDateRange;

  Future<void> fetchUsers({DateTimeRange? dateRange}) async {
    setState(() {
      isLoading = true;
    });

    try {
      String url = '$apiBaseUrl/api/suppliers/searchdate';
      if (dateRange != null) {
        String startDate = dateRange.start.toIso8601String();
        String endDate = dateRange.end.toIso8601String();
        url += '?startDate=$startDate&endDate=$endDate';
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          suppliers = json.decode(response.body);
          filteredSuppliers = suppliers;
        });
      } else {
        showSnackBar("Failed to fetch supplier. Please try again.");
      }
    } catch (e) {
      showSnackBar("An error occurred while fetching supplier.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredSuppliers = suppliers;
      });
      return;
    }

    setState(() {
      filteredSuppliers = suppliers.where((supplier) {
        String name = supplier['name'].toLowerCase();
        String email = supplier['email'].toLowerCase();
        String phone = supplier['phone'].toLowerCase();
        String address = supplier['address'].toLowerCase();
        String gmail = supplier['gmail'].toLowerCase();
        String fbacc = supplier['fbacc'].toLowerCase();
        return name.contains(query.toLowerCase()) ||
            email.contains(query.toLowerCase()) ||
            phone.contains(query.toLowerCase()) ||
            address.contains(query.toLowerCase()) ||
            gmail.contains(query.toLowerCase()) ||
            fbacc.contains(query.toLowerCase());
      }).toList();
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> handleEdit(Map supplier) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupplierForm(
          supplier: supplier,
        ), // Ensure UserForm is implemented correctly
      ),
    );
    if (result == true) {
      // Fetch users again to reflect changes
      await fetchUsers();
      showSnackBar("${supplier['name']} has been updated.");
    }
  }

  Future<void> handleDelete(Map supplier) async {
    final bool isDeleted = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete ${supplier['name']}?"),
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

    if (isDeleted == true) {
      try {
        // Example: API call to delete supplier from DB
        final response = await http.delete(
          Uri.parse('$apiBaseUrl/api/suppliers/${supplier['_id']}'),
        );

        if (response.statusCode == 200) {
          setState(() {
            suppliers.remove(supplier); // Remove from local list
            filteredSuppliers = suppliers; // Update filtered list
          });
          showSnackBar("${supplier['name']} has been deleted.");
        } else {
          showSnackBar(
            "Failed to delete ${supplier['name']} from the database.",
          );
        }
      } catch (e) {
        showSnackBar("An error occurred: $e");
      }
    }
  }

  void openDateRangePicker(BuildContext context) async {
    await selectDateRange(
      context: context,
      initialDateRange: selectedDateRange,
      onDateRangeSelected: (DateTimeRange picked) async {
        setState(() {
          selectedDateRange = picked;
        });
        await fetchUsers(dateRange: picked);
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Supplier Management"),
        actions: [
          IconButton(
            tooltip: "Select Date Range",
            icon: const Icon(Icons.date_range),
            onPressed: () => openDateRangePicker(context),
          ),
          IconButton(
            tooltip: "Refresh Supplier List",
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await fetchUsers(dateRange: selectedDateRange);
              showSnackBar("Supplier list refreshed.");
            },
          ),
          PopupMenuButton(
            tooltip: "Exports Data",
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export_pdf',
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: Colors.blue,
                    ),
                    const Text('Export PDF'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export_csv',
                child: Row(
                  children: [
                    const Icon(Icons.file_download, color: Colors.blue),
                    const Text('Export CSV'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export_excel',
                child: Row(
                  children: [
                    const Icon(Icons.table_chart, color: Colors.blue),
                    const Text('Export Excel'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'export_pdf') {
                createAndSharePrintPDF(
                  headers: [
                    "Name",
                    "Email",
                    "Phone",
                    "Address",
                    "Gmail",
                    "Fbacc",
                  ],
                  rows: filteredSuppliers
                      .map(
                        (user) => [
                          user['name'],
                          user['email'],
                          user['phone'],
                          user['address'],
                          user['gmail'],
                          user['fbacc'],
                        ],
                      )
                      .toList(),
                  fileName: 'supplier.pdf',
                );
              } else if (value == 'export_csv') {
                createAndShareExportCSV(
                  headers: [
                    "Name",
                    "Email",
                    "Phone",
                    "Address",
                    "Gmail",
                    "Fbacc",
                  ],
                  rows: filteredSuppliers
                      .map(
                        (user) => [
                          user['name'],
                          user['email'],
                          user['phone'],
                          user['address'],
                          user['gmail'],
                          user['fbacc'],
                        ],
                      )
                      .toList(),
                  fileName: 'supplier.csv',
                );
              } else if (value == 'export_excel') {
                createAndShareExcel(
                  headers: [
                    "Name",
                    "Email",
                    "Phone",
                    "Address",
                    "Gmail",
                    "Fbacc",
                  ],
                  rows: filteredSuppliers
                      .map(
                        (user) => [
                          user['name'],
                          user['email'],
                          user['phone'],
                          user['address'],
                          user['gmail'],
                          user['fbacc'],
                        ],
                      )
                      .toList(),
                  fileName: 'supplier.xlsx',
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          customSearchField(
            controller: searchController,
            hintText: "Search by name or email",
          ),
          if (selectedDateRange != null) // Show date range only if selected
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Selected Date Range: ${formatDate(selectedDateRange!.start.toLocal())} - ${formatDate(selectedDateRange!.end.toLocal())}",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredSuppliers.isEmpty
                ? const Center(child: Text("No supplier found."))
                : screenWidth < 600
                ? MobileView(
                    filteredSuppliers: filteredSuppliers
                        .cast<Map<String, dynamic>>(),
                    onEdit: handleEdit,
                    onDelete: handleDelete,
                    columns: const [
                      {'label': 'Name', 'key': 'name'},
                      {'label': 'Email', 'key': 'email'},
                      {'label': 'Phone', 'key': 'phone'},
                      {'label': 'Address', 'key': 'address'},
                    ],
                  )
                : TableView(
                    filteredSuppliers: filteredSuppliers
                        .cast<Map<String, dynamic>>(),
                    onEdit: handleEdit,
                    onDelete: handleDelete,
                    columns: const [
                      {'label': 'Name', 'key': 'name'},
                      {'label': 'Email', 'key': 'email'},
                      {'label': 'Phone', 'key': 'phone'},
                      {'label': 'Address', 'key': 'address'},
                      {'label': 'Gmail', 'key': 'gmail'},
                      {'label': 'FB Account', 'key': 'fbacc'},
                    ],
                    title: 'Supplier List',
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add New Supplier",
        onPressed: () async {
          await navigateAndRefresh(
            context: context,
            formBuilder: () => const SupplierForm(),
            fetchAllData: fetchUsers,
          );
        },
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // အဝိုင်းပုံစံ
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
