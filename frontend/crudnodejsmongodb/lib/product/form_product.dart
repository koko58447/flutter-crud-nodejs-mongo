import '/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';

class ProductForm extends StatefulWidget {
  final Map? product;

  const ProductForm({super.key, this.product});
  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _qtyController;

  String? _selectedSupplierId;
  List<Map<String, String>> _suppliers = [];

  String? _selectedCategoryId;
  List<Map<String, String>> _categorys = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _qtyController = TextEditingController();

    // If editing an existing product, pre-fill the form fields
    if (widget.product != null) {
      _nameController.text = widget.product!['name'] ?? '';
      _priceController.text = widget.product!['price']?.toString() ?? '';
      _selectedSupplierId = widget.product!['supplierid'];
      _selectedCategoryId = widget.product!['categoryid'] ?? 1;
      _qtyController.text = widget.product!['qty']?.toString() ?? '';
    }

    // Fetch suppliers from MongoDB
    _fetchSuppliers();
    _fetchCategorys();
  }

  Future<void> _fetchSuppliers() async {
    await loadData(
      apiBaseUrl: '$apiBaseUrl/api/suppliers',
      updateSuppliers: (suppliers) {
        setState(() {
          _suppliers = suppliers;
        });
      },
      showErrorDialog: (message) {
        _showErrorDialog(message);
      },
    );
  }

  Future<void> _fetchCategorys() async {
    await loadData(
      apiBaseUrl: '$apiBaseUrl/api/categorys',
      updateSuppliers: (a) {
        setState(() {
          _categorys = a;
        });
      },
      showErrorDialog: (message) {
        _showErrorDialog(message);
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final url = widget.product != null && widget.product!['_id'] != null
            ? '$apiBaseUrl/api/products/${widget.product!['_id']}'
            : '$apiBaseUrl/api/products';

        final body = {
          'name': _nameController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'supplierid': _selectedSupplierId ?? '',
          'categoryid': _selectedCategoryId ?? 1,
          'qty': int.tryParse(_qtyController.text) ?? 0,
        };

        final method = widget.product != null ? http.put : http.post;

        final response = await method(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body),
        );

        print(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.pop(context, true);
        } else {
          _showErrorDialog(
            "Failed to save product. Status code: ${response.statusCode}",
          );
        }
      } catch (e) {
        _showErrorDialog("An error occurred: $e");
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the product name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedSupplierId,
                  decoration: const InputDecoration(labelText: 'Supplier'),
                  items: _suppliers.map((supplier) {
                    return DropdownMenuItem(
                      value: supplier['id'],
                      child: Text(supplier['name']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSupplierId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a supplier';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categorys.map((supplier) {
                    return DropdownMenuItem(
                      value: supplier['id'],
                      child: Text(supplier['name']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _qtyController,
                  decoration: const InputDecoration(labelText: 'Qty'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the Qty quantity';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
