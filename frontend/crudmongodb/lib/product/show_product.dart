import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
    _fetchProductsWithSuppliers();
  }

  Future<void> _fetchProductsWithSuppliers() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/products/productsupplier'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _products = data;
          _filteredProducts = data;
          _isLoading = false;
        });
      } else {
        _showErrorDialog(
            "Failed to fetch products. Status code: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorDialog("An error occurred while fetching products: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
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
                product['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

 
  Future<void> _deleteProduct(Map product) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product"),
        content: Text("Are you sure you want to delete ${product['name']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.delete(
          Uri.parse('$apiBaseUrl/api/products/${product['_id']}'),
        );

        if (response.statusCode == 200) {
          setState(() {
            _products.remove(product);
            _filteredProducts.remove(product);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to delete product: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products with Suppliers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
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
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredProducts.isEmpty
              ? const Center(child: Text('No products found.'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 700) {
                      return MobileProductListView(
                        products: _filteredProducts,
                        onEdit: (Map product) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductForm(
                                product: product,
                              ),
                            ),
                          ).then((result) {
                            if (result == true) _fetchProductsWithSuppliers();
                          });
                        },
                        onDelete: _deleteProduct,
                      );
                    } else {
                      return DesktopProductTableView(
                        products: _filteredProducts,
                        onEdit: (Map product) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductForm(
                                product: product,
                              ),
                            ),
                          ).then((result) {
                            if (result == true) _fetchProductsWithSuppliers();
                          });
                        },
                        onDelete: _deleteProduct,
                      );
                    }
                  },
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
    fields: ['name', 'price', 'supplierid', 'qty'],
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
  fields: ['name', 'price', 'supplierid', 'qty'],
  fileName: 'products.xlsx',
), // Call the exportToExcel function
          ),
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Add Product',
            backgroundColor: Colors.blue,
            onTap: () async {
               final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductForm()),
          );
          if (result == true) _fetchProductsWithSuppliers();
            },
          ),
        ],
      ),
    );
  }
}

class MobileProductListView extends StatelessWidget {
  final List products;
  final Function(Map) onEdit;
  final Function(Map) onDelete;

  const MobileProductListView({
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                product['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                  'Price: \$${product['price']} | Quantity: ${product['qty']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => onEdit(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onDelete(product),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DesktopProductTableView extends StatefulWidget {
  final List products;
  final Function(Map) onEdit;
  final Function(Map) onDelete;

  const DesktopProductTableView({
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<DesktopProductTableView> createState() => _DesktopProductTableViewState();
}

class _DesktopProductTableViewState extends State<DesktopProductTableView> {
  int _rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                ),
                child: PaginatedDataTable(
                  header: const Text('Products with Suppliers'),
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Quantity')),
                DataColumn(label: Text('Supplier')),
                DataColumn(label: Text('Actions')),
              ],
              source: _ProductDataSource(
                products: widget.products,
                onEdit: widget.onEdit,
                onDelete: widget.onDelete,
              ),
                  rowsPerPage: 10, // Number of rows per page
                  columnSpacing: 20,
                  horizontalMargin: 10,
                  showCheckboxColumn: false, // Hide checkbox column
                ),
              ),
              const SizedBox(height: 60), // Add spacing below the table
            ],
          ),
        );
      },
    );
  }
}


class _ProductDataSource extends DataTableSource {
  final List products;
  final Function(Map) onEdit;
  final Function(Map) onDelete;

  _ProductDataSource({
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= products.length) return null;
    final product = products[index];
    final supplierDetails = product['supplierDetails'];
    return DataRow(
      cells: [
        DataCell(Text(product['name'] ?? '')),
        DataCell(Text(product['price'].toString())),
        DataCell(Text(product['qty'].toString())),
        DataCell(Text(
          supplierDetails != null && supplierDetails.isNotEmpty
              ? supplierDetails['name'] ?? ''
              : 'N/A',
        )),
        DataCell(Row(
           mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(product),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(product),
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => products.length;

  @override
  int get selectedRowCount => 0;
}