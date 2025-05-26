import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../utils.dart';
import 'form_product.dart';

// Main ShowProduct Widget
class ShowProduct extends StatefulWidget {
  const ShowProduct({super.key});

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
      apiPath: '$apiBaseUrl/api/products/',
      onSuccess: (data) {
        // Process the data to include product and supplier name
        final List<Map<String, dynamic>> processedData = data.map((item) {
          return {
            '_id': item['_id'],
            'name': item['name'],
            'price': item['price'],
            'qty': item['qty'],
            'supplierid': item['supplierid']?['_id'] ?? 'Unknown',
            'suppliername': item['supplierid']?['name'] ?? 'Unknown',
            'categoryid': item['categoryid']?['_id'] ?? 'Unknown',
            'categoryname': item['categoryid']?['name'] ?? 'Unknown',
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
            .where(
              (product) =>
                  product['name'].toLowerCase().contains(query.toLowerCase()) ||
                  product['categoryname'].toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  product['suppliername'].toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products with Suppliers'),
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
                value: "pdf",
                child: Row(
                  children: const [
                    Icon(Icons.picture_as_pdf, color: Colors.blue),
                    SizedBox(width: 8.0),
                    Text('Export PDF'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "csv",
                child: Row(
                  children: const [
                    Icon(Icons.file_download, color: Colors.blue),
                    SizedBox(width: 8.0),
                    Text('Export CSV'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "excel",
                child: Row(
                  children: const [
                    Icon(Icons.table_chart, color: Colors.blue),
                    SizedBox(width: 8.0),
                    Text('Export Excel'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'pdf') {
                createAndSharePrintPDF(
                  headers: ["Name", "Price", "Qty", "Supplier", "Category"],
                  rows: _filteredProducts
                      .map(
                        (user) => [
                          user['name'],
                          user['price'],
                          user['qty'],
                          user['suppliername'],
                          user['categoryname'],
                        ],
                      )
                      .toList(),
                  fileName: 'products.pdf',
                );
              } else if (value == 'csv') {
                createAndShareExportCSV(
                  headers: ["Name", "Price", "Qty", "Supplier", "Category"],
                  rows: _filteredProducts
                      .map(
                        (user) => [
                          user['name'],
                          user['price'],
                          user['qty'],
                          user['suppliername'],
                          user['categoryname'],
                        ],
                      )
                      .toList(),
                  fileName: 'products.csv',
                );
              } else if (value == 'excel') {
                createAndShareExcel(
                  headers: ["Name", "Price", "Qty", "Supplier", "Category"],
                  rows: _filteredProducts
                      .map(
                        (user) => [
                          user['name'],
                          user['price'],
                          user['qty'],
                          user['suppliername'],
                          user['categoryname'],
                        ],
                      )
                      .toList(),
                  fileName: 'products.xlsx',
                );
              }
            },
          ),
        ],
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
                                  final response = await http.delete(
                                    Uri.parse('$apiBaseUrl/api/products/$id'),
                                  );
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
                          columns: const [
                            {'label': 'Name', 'key': 'name'},
                            {'label': 'Price', 'key': 'price'},
                            {'label': 'Quantity', 'key': 'qty'},
                            {'label': 'Supplier', 'key': 'suppliername'},
                            {'label': 'Category', 'key': 'categoryname'},
                          ],
                          onEdit: (Map<dynamic, dynamic> user) => handleEdit(
                            context: context,
                            list: user,
                            fetchAllData:
                                fetchAllData, // Replace with your fetch function
                            listFormBuilder: (user) => ProductForm(
                              product: user,
                            ), // Pass UserForm here
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
                                  final response = await http.delete(
                                    Uri.parse('$apiBaseUrl/api/products/$id'),
                                  );
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
                          columns: const [
                            {'label': 'Name', 'key': 'name'},
                            {'label': 'Price', 'key': 'price'},
                            {'label': 'Quantity', 'key': 'qty'},
                            {'label': 'Supplier', 'key': 'suppliername'},
                            {'label': 'Category', 'key': 'categoryname'},
                          ],
                          onEdit: (Map<dynamic, dynamic> user) => handleEdit(
                            context: context,
                            list: user,
                            fetchAllData:
                                fetchAllData, // Replace with your fetch function
                            listFormBuilder: (user) => ProductForm(
                              product: user,
                            ), // Pass UserForm here
                          ),
                          title: 'Products With Supplier',
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Product",
        onPressed: () async {
          await navigateAndRefresh(
            context: context,
            formBuilder: () => const ProductForm(),
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
