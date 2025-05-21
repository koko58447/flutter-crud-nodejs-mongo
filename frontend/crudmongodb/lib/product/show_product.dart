import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../utils.dart';
import 'form_product.dart';

// Main ShowProduct Widget
class ShowProduct extends StatefulWidget {
  @override
  _ShowProductState createState() => _ShowProductState();
}

class _ShowProductState extends State<ShowProduct> {
  List _products = [];
  List _filteredProducts = [];
  bool _isLoading = true;
  String _searchText = "";
  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    await fetchData(
      apiPath: '$apiBaseUrl/api/products/productsupplier',
      onSuccess: (data) {
        // Process the data to include product and supplier name
        final List<Map<String, dynamic>> processedData = data.map((item) {
          return {
            '_id': item['_id'],
            'name': item['name'],
            'price': item['price'],
            'qty': item['qty'],
            'supplierid': item['supplierid'],
            'suppliername': item['supplierDetails']?['name'] ?? 'Unknown',
          };
        }).toList();
        setState(() {
          _products = processedData;
          _filteredProducts = processedData;
          _isLoading = false;
        });
      },
      onError: (message) {
        showSnackBar(context, message);
      },
      onLoadingStart: () {
        setState(() {
          _isLoading = true;
        });
      },
      onLoadingEnd: () {
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  void _filterProducts(String query) {
    setState(() {
      _searchText = query;
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products
            .where((product) =>
                product['name'].toLowerCase().contains(query.toLowerCase()) ||
                product['suppliername']
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products with Suppliers'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterProducts,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? const Center(child: Text('No products found.'))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 700) {
                            return MobileView(
                              filteredSuppliers: _filteredProducts
                                  .cast<Map<String, dynamic>>(),
                              onDelete: (Map<dynamic, dynamic> user) =>
                                  handleDelete(
                                context: context,
                                list: user,
                                deleteCallback: (id) async {
                                  final response = await http.delete(Uri.parse(
                                      '$apiBaseUrl/api/products/$id'));
                                  if (response.statusCode != 200) {
                                    throw Exception("Failed to delete user");
                                  }
                                },
                                updateState: (user) {
                                  setState(() {
                                    _products.remove(user);
                                    _filteredProducts = _products;
                                  });
                                },
                              ),
                              columns: [
                                {'label': 'Name', 'key': 'name'},
                                {'label': 'Price', 'key': 'price'},
                                {'label': 'Quantity', 'key': 'qty'},
                                {'label': 'Supplier', 'key': 'suppliername'},
                              ],
                              onEdit: (Map<dynamic, dynamic> user) =>
                                  handleEdit(
                                context: context,
                                list: user,
                                fetchAllData:
                                    fetchAllData, // Replace with your fetch function
                                listFormBuilder: (user) => ProductForm(
                                    product: user), // Pass UserForm here
                              ),
                            );
                          } else {
                            return TableView(
                              filteredSuppliers: _filteredProducts
                                  .cast<Map<String, dynamic>>(),
                              onDelete: (Map<dynamic, dynamic> user) =>
                                  handleDelete(
                                context: context,
                                list: user,
                                deleteCallback: (id) async {
                                  final response = await http.delete(Uri.parse(
                                      '$apiBaseUrl/api/products/$id'));
                                  if (response.statusCode != 200) {
                                    throw Exception("Failed to delete user");
                                  }
                                },
                                updateState: (user) {
                                  setState(() {
                                    _products.remove(user);
                                    _filteredProducts = _products;
                                  });
                                },
                              ),
                              columns: [
                                {'label': 'Name', 'key': 'name'},
                                {'label': 'Price', 'key': 'price'},
                                {'label': 'Quantity', 'key': 'qty'},
                                {'label': 'Supplier', 'key': 'suppliername'},
                              ],
                              onEdit: (Map<dynamic, dynamic> user) =>
                                  handleEdit(
                                context: context,
                                list: user,
                                fetchAllData:
                                    fetchAllData, // Replace with your fetch function
                                listFormBuilder: (user) => ProductForm(
                                    product: user), // Pass UserForm here
                              ),
                              title: 'Products With Supplier',
                            );
                          }
                        },
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
            onTap: () => exportListToCSV(
              data: _filteredProducts,
              headers: ["Name", "Price", "Supplier", "Qty"],
              fields: ['name', 'price', 'suppliername', 'qty'],
              fileName: 'product.csv',
            ), // Call the exportToCSV function
          ),
          SpeedDialChild(
            child: const Icon(Icons.table_chart),
            label: 'Export Excel',
            backgroundColor: Colors.orange,
            onTap: () => exportListToExcel(
              data: _filteredProducts,
              sheetName: 'Product',
              headers: ["Name", "Price", "Supplier", "Qty"],
              fields: ['name', 'price', 'suppliername', 'qty'],
              fileName: 'products.xlsx',
            ), // Call the exportToExcel function
          ),
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Add Product',
            backgroundColor: Colors.blue,
            onTap: () async {
              await navigateAndRefresh(
                  context: context,
                  formBuilder: () => ProductForm(), // Pass the form widget
                  fetchAllData: fetchAllData);
            },
          ),
        ],
      ),
    );
  }
}
