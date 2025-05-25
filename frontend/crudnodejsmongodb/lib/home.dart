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
                            filteredSuppliers:
                                filteredUsers.cast<Map<String, dynamic>>(),
                            onEdit: (Map<dynamic, dynamic> user) => handleEdit(
                              context: context,
                              list: user,
                              fetchAllData:
                                  fetchAllData, // Replace with your fetch function
                              listFormBuilder: (user) =>
                                  UserForm(user: user), // Pass UserForm here
                            ),
                            onDelete: (Map<dynamic, dynamic> user) =>
                                handleDelete(
                              context: context,
                              list: user,
                              deleteCallback: (id) async {
                                final response = await http.delete(
                                    Uri.parse('$apiBaseUrl/api/users/$id'));
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
                            filteredSuppliers:
                                filteredUsers.cast<Map<String, dynamic>>(),
                            onEdit: (Map<dynamic, dynamic> user) => handleEdit(
                              context: context,
                              list: user,
                              fetchAllData:
                                  fetchAllData, // Replace with your fetch function
                              listFormBuilder: (user) =>
                                  UserForm(user: user), // Pass UserForm here
                            ),
                            onDelete: (Map<dynamic, dynamic> user) =>
                                handleDelete(
                              context: context,
                              list: user,
                              deleteCallback: (id) async {
                                final response = await http.delete(
                                    Uri.parse('$apiBaseUrl/api/users/$id'));
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
            onTap: () => createAndShareExcel(headers: ["Name", "Email"], rows: filteredUsers.map((user) => [user['name'], user['email']]).toList(),
              fileName: 'users.csv'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.table_chart),
            label: 'Export Excel',
            backgroundColor: Colors.orange,
            onTap: () => createAndShareExcel(headers: ["Name", "Email"], rows: filteredUsers.map((user) => [user['name'], user['email']]).toList(),
              fileName: 'users.xlsx'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Add User',
            backgroundColor: Colors.blue,
            onTap: () async {
              await navigateAndRefresh(
                context: context,
                formBuilder: () => const UserForm(), // Pass the form widget
                fetchAllData: fetchAllData, // Pass the data refresh function
              );
            },
          ),
        ],
      ),
    );
  }
}
