import 'barcodescanner/barcodescanner.dart';
import 'barcodescanner/invoicceprinter.dart';
import 'category/showcategory.dart';
import 'exportexcel.dart';
import 'login.dart';
import 'product/form_product.dart';
import 'product/show_product.dart';
import 'setting/setting.dart';
import 'supplier/show_supplier.dart';
import 'uploadimage/form_upload.dart';
import 'uploadimage/show_upload.dart';
import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'home.dart';
import 'videos/showvideos.dart';

import 'package:easy_localization/easy_localization.dart';
import 'utils.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
 
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('my')],
      path: 'assets/translations', // json files path
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'Flutter CRUD Project',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ResponsiveLayout(),
    );
  }
}

class ResponsiveLayout extends StatefulWidget {
  const ResponsiveLayout({super.key});

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
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: Text(
              'Dashboard',
              style: TextStyle(
                color: _selectedItem == 'Dashboard'
                    ? Colors.blue
                    : Colors.black,
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
            leading: const Icon(Icons.person),
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
            leading: const Icon(Icons.support_outlined),
            title: Text(
              'Supplier',
              style: TextStyle(
                color: _selectedItem == 'Suppliers'
                    ? Colors.blue
                    : Colors.black,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedItem = 'Suppliers'; // Update selected item
                _currentContent =
                    const Supplier(); // Update content to Home widget
              });
              if (MediaQuery.of(context).size.width < 1200) {
                Navigator.pop(context); // Close the drawer
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.image_aspect_ratio),
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
            leading: const Icon(Icons.production_quantity_limits),
            title: Text(
              'Product',
              style: TextStyle(
                color: _selectedItem == 'Product' ? Colors.blue : Colors.black,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedItem = 'Product'; // Update selected item
                _currentContent =
                    ShowProduct(); // Update content to Home widget
              });
              if (MediaQuery.of(context).size.width < 1200) {
                Navigator.pop(context); // Close the drawer
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(
              'Category',
              style: TextStyle(
                color: _selectedItem == 'Category' ? Colors.blue : Colors.black,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedItem = 'Category'; // Update selected item
                _currentContent =
                    const ShowCategory(); // Update content to Home widget
              });
              if (MediaQuery.of(context).size.width < 1200) {
                Navigator.pop(context); // Close the drawer
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.barcode_reader),
            title: Text(
              'Barcode Scanner',
              style: TextStyle(
                color: _selectedItem == 'Barcode Scanner'
                    ? Colors.blue
                    : Colors.black,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedItem = 'Barcode Scanner'; // Update selected item
                _currentContent =
                    const Barcodescanner(); // Update content to Home widget
              });
              if (MediaQuery.of(context).size.width < 1200) {
                Navigator.pop(context); // Close the drawer
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.print),
            title: Text(
              'Invoice',
              style: TextStyle(
                color: _selectedItem == 'Invoice' ? Colors.blue : Colors.black,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedItem = 'Invoice'; // Update selected item
                _currentContent =
                    const InvoicePrinter(); // Update content to Home widget
              });
              if (MediaQuery.of(context).size.width < 1200) {
                Navigator.pop(context); // Close the drawer
              }
            },
          ),
           ListTile(
            leading: const Icon(Icons.print),
            title: Text(
              'Excel',
              style: TextStyle(
                color: _selectedItem == 'Excel' ? Colors.blue : Colors.black,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedItem = 'Excel'; // Update selected item
                _currentContent =
                    const Exportexcel(); // Update content to Home widget
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
                title: Text(tr('title')), // Use translation key
                actions: [
                  GestureDetector(
                    onTap:(){
                      showLanguageDialog(context);
                    },
                    child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.language),
                            SizedBox(width: 4),
                            Text('Language'),
                            Text(
                                '(' + getCurrentLanguageLabel(context) + ')',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to the Settings page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingPage(),
                        ), // Replace with your SettingPage
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
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
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
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
                                    builder: (context) => Login(),
                                  ), // Navigate to LoginPage
                                );
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
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
                  SizedBox(
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
                title:  Text(tr('title')),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'Logout') {
                        // Handle logout action
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
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
                                      builder: (context) => Login(),
                                    ), // Navigate to LoginPage
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
                            builder: (context) => SettingPage(),
                          ), // Navigate to SettingPage
                        );
                      }
                      else if (value == 'Language') {
      // Show language selection dialog
                        showLanguageDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'Language',
                        child: Row(
        children: [
          const Text("Language"), // "Language"
          const SizedBox(width: 8),
          Text(
            '(' + getCurrentLanguageLabel(context) + ')',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
                      ),
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
