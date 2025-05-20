import 'package:crudmongodb/login.dart';
import 'package:crudmongodb/product/form_product.dart';
import 'package:crudmongodb/product/show_product.dart';
import 'package:crudmongodb/setting/setting.dart';
import 'package:crudmongodb/supplier/show_supplier.dart';
import 'package:crudmongodb/uploadimage/form_upload.dart';
import 'package:crudmongodb/uploadimage/show_upload.dart';
import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter CRUD',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ResponsiveLayout(),
    );
  }
}

class ResponsiveLayout extends StatefulWidget {
  @override
  _ResponsiveLayoutState createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  Widget _currentContent = Dashboard(); // Default content for the left panel
  String _selectedItem = 'Dashboard'; // Track the selected menu item

  @override
  Widget build(BuildContext context) {
    final drawer = Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text(
              'Dashboard',
              style: TextStyle(
                color:
                    _selectedItem == 'Dashboard' ? Colors.blue : Colors.black,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedItem = 'Dashboard'; // Update selected item
                _currentContent = Dashboard(); // Update content to Dashboard
              });
              if (MediaQuery.of(context).size.width < 1200) {
                Navigator.pop(context); // Close the drawer
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              'Users',
              style: TextStyle(
                color: _selectedItem == 'Users' ? Colors.blue : Colors.black,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedItem = 'Users'; // Update selected item
                _currentContent = Home(); // Update content to Home widget
              });
              if (MediaQuery.of(context).size.width < 1200) {
                Navigator.pop(context); // Close the drawer
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.support_outlined),
            title: Text(
              'Supplier',
              style: TextStyle(
                color:
                    _selectedItem == 'Suppliers' ? Colors.blue : Colors.black,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedItem = 'Suppliers'; // Update selected item
                _currentContent = Supplier(); // Update content to Home widget
              });
              if (MediaQuery.of(context).size.width < 1200) {
                Navigator.pop(context); // Close the drawer
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.image_aspect_ratio),
            title: Text(
              'Upload Image',
              style: TextStyle(
                color: _selectedItem == 'Upload Image'
                    ? Colors.blue
                    : Colors.black,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedItem = 'Upload Image'; // Update selected item
                _currentContent = ShowUpload(); // Update content to Home widget
              });
              if (MediaQuery.of(context).size.width < 1200) {
                Navigator.pop(context); // Close the drawer
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.production_quantity_limits),
            title: Text(
              'Product',
              style: TextStyle(
                color: _selectedItem == 'Product'
                    ? Colors.blue
                    : Colors.black,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedItem = 'Product'; // Update selected item
                _currentContent = ShowProduct(); // Update content to Home widget
              });
              if (MediaQuery.of(context).size.width < 1200) {
                Navigator.pop(context); // Close the drawer
              }
            },
          ),
        ],
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        return false; // Prevent default back button behavior
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1200) {
            // Desktop layout with persistent drawer
            return Scaffold(
              appBar: AppBar(
                title: const Text('Flutter CRUD'),
                actions: [
                  GestureDetector(
                    onTap: () {
                      // Navigate to the Settings page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SettingPage()), // Replace with your SettingPage
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: const [
                          Icon(Icons.settings),
                          SizedBox(width: 4),
                          Text('Settings'),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Show logout confirmation dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content:
                              const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(), // Close dialog
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close dialog
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Login()), // Navigate to LoginPage
                                );
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: const [
                          Icon(Icons.logout),
                          SizedBox(width: 4),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              body: Row(
                children: [
                  Container(
                    width: 250, // Fixed width for the drawer
                    child: drawer,
                  ),
                  Expanded(
                    child: _currentContent, // Display the selected content
                  ),
                ],
              ),
            );
          } else {
            // Mobile/Tablet layout with sliding drawer
            return Scaffold(
              appBar: AppBar(
                title: const Text('Flutter CRUD'),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'Logout') {
                        // Handle logout action
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(), // Close dialog
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close dialog
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Login()), // Navigate to LoginPage
                                  );
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                      } else if (value == 'Setting') {
                        // Handle setting action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SettingPage()), // Navigate to SettingPage
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Setting',
                        child: Text('Setting'),
                      ),
                      const PopupMenuItem(
                        value: 'Logout',
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                ],
              ),
              drawer: drawer,
              body: _currentContent, // Display the selected content
            );
          }
        },
      ),
    );
  }
}
