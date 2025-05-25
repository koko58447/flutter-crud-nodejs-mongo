import '/category/formcategory.dart';
import 'package:flutter/material.dart';
import '../utils.dart';
import '../constants.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;

class ShowCategory extends StatefulWidget {
  const ShowCategory({Key? key}) : super(key: key);

  @override
  State<ShowCategory> createState() => _ShowCategoryState();
}

class _ShowCategoryState extends State<ShowCategory> {
  List categorys = [];
  List filterCategory = [];
  bool isLoading = true;
  final searchController = TextEditingController();

  Future<void> fetchAllData() async {
    await fetchData(
      apiPath: '$apiBaseUrl/api/categorys',
      onSuccess: (data) {
        setState(() {
          categorys = data;
          filterCategory = categorys;
        });
      },
      onError: (message) {
        showSnackBar(context, message);
      },
      onLoadingStart: () {
        setState(() {
          isLoading = true;
        });
      },
      onLoadingEnd: () {
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  void filterSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        filterCategory = categorys;
      });
      return;
    }

    setState(() {
      filterCategory = categorys.where((user) {
        String name = user['name'].toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAllData();
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
      appBar: AppBar(title: const Text('Category Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by name",
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
                : filterCategory.isEmpty
                ? const Center(child: Text("No users found."))
                : screenWidth < 600
                ? MobileView(
                    filteredSuppliers: filterCategory
                        .cast<Map<String, dynamic>>(),
                    onEdit: (Map<dynamic, dynamic> user) => handleEdit(
                      context: context,
                      list: user,
                      fetchAllData:
                          fetchAllData, // Replace with your fetch function
                      listFormBuilder: (user) =>
                          CategoryForm(user: user), // Pass UserForm here
                    ),
                    onDelete: (Map<dynamic, dynamic> user) => handleDelete(
                      context: context,
                      list: user,
                      deleteCallback: (id) async {
                        final response = await http.delete(
                          Uri.parse('$apiBaseUrl/api/categorys/$id'),
                        );
                        if (response.statusCode != 200) {
                          throw Exception("Failed to delete user");
                        }
                      },
                      updateState: (user) {
                        setState(() {
                          categorys.remove(user);
                          filterCategory = categorys;
                        });
                      },
                    ),
                    columns: const [
                      {'label': 'Name', 'key': 'name'},
                    ],
                  )
                : TableView(
                    filteredSuppliers: filterCategory
                        .cast<Map<String, dynamic>>(),
                    onEdit: (Map<dynamic, dynamic> user) => handleEdit(
                      context: context,
                      list: user,
                      fetchAllData:
                          fetchAllData, // Replace with your fetch function
                      listFormBuilder: (user) =>
                          CategoryForm(user: user), // Pass UserForm here
                    ),
                    onDelete: (Map<dynamic, dynamic> user) => handleDelete(
                      context: context,
                      list: user,
                      deleteCallback: (id) async {
                        final response = await http.delete(
                          Uri.parse('$apiBaseUrl/api/categorys/$id'),
                        );
                        if (response.statusCode != 200) {
                          throw Exception("Failed to delete user");
                        }
                      },
                      updateState: (user) {
                        setState(() {
                          categorys.remove(user);
                          filterCategory = categorys;
                        });
                      },
                    ),
                    columns: const [
                      {'label': 'Name', 'key': 'name'},
                    ],
                    title: 'Category Lists',
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
            onTap: () => createAndShareExcel(headers: ["Name"], rows: filterCategory.map((user) => [user['name']]).toList(),
              fileName: 'categorys.csv'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.table_chart),
            label: 'Export Excel',
            backgroundColor: Colors.orange,
            onTap: () => createAndShareExcel(headers: ["Name"], rows: filterCategory.map((user) => [user['name']]).toList(),
              fileName: 'categorys.xlsx'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Add Category',
            backgroundColor: Colors.blue,
            onTap: () async {
              await navigateAndRefresh(
                context: context,
                formBuilder: () => const CategoryForm(), // Pass the form widget
                fetchAllData: fetchAllData, // Pass the data refresh function
              );
            },
          ),
        ],
      ),
    );
  }
}
