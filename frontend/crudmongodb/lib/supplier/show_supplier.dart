import 'package:crudmongodb/supplier/form_supplier.dart';
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

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/api/suppliers'));
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> handleEdit(Map supplier) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupplierForm(
            supplier: supplier), // Ensure UserForm is implemented correctly
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
              "Failed to delete ${supplier['name']} from the database.");
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Supplier Management")),
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
                            )),
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
            onTap: () => exportListToCSV(
              data: filteredSuppliers,
              headers: ["Name", "Email", "Phone", "Address", "Gmail", "FBacc"],
              fields: ['name', 'email', 'phone', 'address', 'gmail', 'fbacc'],
              fileName: 'suppliers.csv',
            ), // Call the exportToCSV function
          ),
          SpeedDialChild(
            child: const Icon(Icons.table_chart),
            label: 'Export Excel',
            backgroundColor: Colors.orange,
            onTap: () => exportListToExcel(
              data: filteredSuppliers,
              sheetName: 'Supplier',
              headers: ["Name", "Email", "Phone", "Address", "Gmail", "FBacc"],
              fields: ['name', 'email', 'phone', 'address', 'gmail', 'fbacc'],
              fileName: 'suppliers.xlsx',
            ), // Call the exportToExcel function
          ),
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Add Supplier',
            backgroundColor: Colors.blue,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SupplierForm()),
              );
              if (result == true) fetchUsers();
            },
          ),
        ],
      ),
    );
  }
}
