import '/category/formcategory.dart';
import 'package:flutter/material.dart';
import '../utils.dart';
import '../constants.dart';
import 'package:http/http.dart' as http;

class ShowCategory extends StatefulWidget {
  const ShowCategory({Key? key}) : super(key: key);

  @override
  State<ShowCategory> createState() => _ShowCategoryState();
}

class _ShowCategoryState extends State<ShowCategory> {
  List<Map<String, dynamic>> categorys = [];
  List<Map<String, dynamic>> filterCategory = [];
  bool isLoading = true;
  final searchController = TextEditingController();

  Future<void> fetchAllData() async {
    await fetchData(
      apiPath: '$apiBaseUrl/api/categorys',
      onSuccess: (data) {
        print(data);
        setState(() {
          categorys = data.cast<Map<String, dynamic>>();
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
      appBar: AppBar(
        title: const Text('Category Management'),
        actions: [
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh),
            onPressed: fetchAllData,
          ),
          PopupMenuButton(
            tooltip: "Export Data",
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.blue),
                    const Text("Export PDF"),
                  ],
                ),
                onTap: () => createAndSharePrintPDF(
                  headers: ["Name"],
                  rows: filterCategory.map((user) => [user['name']]).toList(),
                  fileName: 'categorys.pdf',
                ),
              ),
              PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    const Icon(Icons.file_download, color: Colors.blue),
                    const Text("Export CSV"),
                  ],
                ),
                onTap: () => createAndShareExportCSV(
                  headers: ["Name"],
                  rows: filterCategory.map((user) => [user['name']]).toList(),
                  fileName: 'categorys.csv',
                ),
              ),
              PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    const Icon(Icons.table_chart, color: Colors.blue),
                    const Text("Export Excel"),
                  ],
                ),
                onTap: () => createAndShareExcel(
                  headers: ["Name"],
                  rows: filterCategory.map((user) => [user['name']]).toList(),
                  fileName: 'categorys.xlsx',
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'excel') {
                createAndShareExcel(
                  headers: ["Name"],
                  rows: filterCategory.map((user) => [user['name']]).toList(),
                  fileName: 'categorys.xlsx',
                );
              } else if (value == 'csv') {
                createAndShareExportCSV(
                  headers: ["Name"],
                  rows: filterCategory.map((user) => [user['name']]).toList(),
                  fileName: 'categorys.csv',
                );
              } else if (value == 'pdf') {
                createAndSharePrintPDF(
                  headers: ["Name"],
                  rows: filterCategory.map((user) => [user['name']]).toList(),
                  fileName: 'categorys.pdf',
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
            hintText: "Search by name",
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await navigateAndRefresh(
            context: context,
            formBuilder: () => const CategoryForm(),
            fetchAllData: fetchAllData,
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
