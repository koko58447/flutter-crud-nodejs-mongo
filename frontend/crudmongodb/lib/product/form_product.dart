import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductForm extends StatefulWidget {
  final Map? product;

  ProductForm({this.product});
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
      _qtyController.text = widget.product!['qty']?.toString() ?? '';
    }

    // Fetch suppliers from MongoDB
    _fetchSuppliers();
  }

  Future<void> _fetchSuppliers() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.70.64:5000/api/suppliers'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _suppliers = data
              .map((supplier) => {
                    'id': supplier['_id'].toString(),
                    'name': supplier['name'].toString(),
                  })
              .toList();
        });
      } else {
        _showErrorDialog(
            "Failed to fetch suppliers. Status code: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorDialog("An error occurred while fetching suppliers: $e");
    }
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
            ? 'http://192.168.70.64:5000/api/products/${widget.product!['_id']}'
            : 'http://192.168.70.64:5000/api/products';

        final body = {
          'name': _nameController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'supplierid': _selectedSupplierId ?? '',
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
              "Failed to save product. Status code: ${response.statusCode}");
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
                  decoration: InputDecoration(labelText: 'Product Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the product name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
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
                  decoration: InputDecoration(labelText: 'Supplier'),
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
                TextFormField(
                  controller: _qtyController,
                  decoration: InputDecoration(labelText: 'Qty'),
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
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
