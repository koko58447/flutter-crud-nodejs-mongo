import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'form.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'constants.dart';
import 'utils.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List users = [];
  List filteredUsers = [];
  final searchController = TextEditingController();
  bool isLoading = false;

  Future<void> fetchAllData() async {
    await fetchData(
      apiPath: '$apiBaseUrl/api/users',
      onSuccess: (data) {
        setState(() {
          users = data;
          filteredUsers = users;
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
        title: const Text('User Management'),
        actions: [
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh),
            onPressed: fetchAllData,
          ),
          PopupMenuButton(
            tooltip: "Export Data",
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.file_download, color: Colors.blue),
                    Text('Export Excel'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.file_download, color: Colors.blue),
                    Text('Export CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf_outlined, color: Colors.blue),
                    Text('Export PDF'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'excel') {
                createAndShareExcel(
                  headers: ["Name", "Email"],
                  rows: filteredUsers
                      .map((user) => [user['name'], user['email']])
                      .toList(),
                  fileName: 'users.xlsx',
                );
              } else if (value == 'csv') {
                createAndShareExportCSV(
                  headers: ["Name", "Email"],
                  rows: filteredUsers
                      .map((user) => [user['name'], user['email']])
                      .toList(),
                  fileName: 'users.csv',
                );
              } else if (value == 'pdf') {
                createAndSharePrintPDF(
                  headers: ["Name", "Email"],
                  rows: filteredUsers
                      .map((user) => [user['name'], user['email']])
                      .toList(),
                  fileName: 'users.pdf',
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
            hintText: "Search By name or email",
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                ? const Center(child: Text("No users found."))
                : screenWidth < 600
                ? MobileView(
                    filteredSuppliers: filteredUsers
                        .cast<Map<String, dynamic>>(),
                    onEdit: (Map<dynamic, dynamic> user) => handleEdit(
                      context: context,
                      list: user,
                      fetchAllData:
                          fetchAllData, // Replace with your fetch function
                      listFormBuilder: (user) =>
                          UserForm(user: user), // Pass UserForm here
                    ),
                    onDelete: (Map<dynamic, dynamic> user) => handleDelete(
                      context: context,
                      list: user,
                      deleteCallback: (id) async {
                        final response = await http.delete(
                          Uri.parse('$apiBaseUrl/api/users/$id'),
                        );
                        if (response.statusCode != 200) {
                          throw Exception("Failed to delete user");
                        }
                      },
                      updateState: (user) {
                        setState(() {
                          users.remove(user);
                          filteredUsers = users;
                        });
                      },
                    ),
                    columns: const [
                      {'label': 'Name', 'key': 'name'},
                      {'label': 'Email', 'key': 'email'},
                    ],
                  )
                : TableView(
                    filteredSuppliers: filteredUsers
                        .cast<Map<String, dynamic>>(),
                    onEdit: (Map<dynamic, dynamic> user) => handleEdit(
                      context: context,
                      list: user,
                      fetchAllData:
                          fetchAllData, // Replace with your fetch function
                      listFormBuilder: (user) =>
                          UserForm(user: user), // Pass UserForm here
                    ),
                    onDelete: (Map<dynamic, dynamic> user) => handleDelete(
                      context: context,
                      list: user,
                      deleteCallback: (id) async {
                        final response = await http.delete(
                          Uri.parse('$apiBaseUrl/api/users/$id'),
                        );
                        if (response.statusCode != 200) {
                          throw Exception("Failed to delete user");
                        }
                      },
                      updateState: (user) {
                        setState(() {
                          users.remove(user);
                          filteredUsers = users;
                        });
                      },
                    ),
                    columns: const [
                      {'label': 'Name', 'key': 'name'},
                      {'label': 'Email', 'key': 'email'},
                    ],
                    title: 'User Lists',
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add User",
        onPressed: () async {
          await navigateAndRefresh(
            context: context,
            formBuilder: () => const UserForm(),
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
