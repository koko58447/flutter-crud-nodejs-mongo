import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class SupplierForm extends StatefulWidget {
  final Map? supplier;

  SupplierForm({this.supplier});
  @override
  _SupplierFormState createState() => _SupplierFormState();
}

class _SupplierFormState extends State<SupplierForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _gmailController;
  late TextEditingController _fbaccController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _gmailController = TextEditingController();
    _fbaccController = TextEditingController();

    // If editing an existing supplier, pre-fill the form fields
    if (widget.supplier != null) {
      _nameController.text = widget.supplier!['name'] ?? '';
      _emailController.text = widget.supplier!['email'] ?? '';
      _addressController.text = widget.supplier!['address'] ?? '';
      _phoneController.text = widget.supplier!['phone'] ?? '';
      _gmailController.text = widget.supplier!['gmail'] ?? '';
      _fbaccController.text = widget.supplier!['fbacc'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _gmailController.dispose();
    _fbaccController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final url = widget.supplier != null && widget.supplier!['_id'] != null
            ? 'http://192.168.70.64:5000/api/suppliers/${widget.supplier!['_id']}'
            : 'http://192.168.70.64:5000/api/suppliers';

        final body = {
          'name': _nameController.text,
          'email': _emailController.text,
          'address': _addressController.text,
          'phone': _phoneController.text,
          'gmail': _gmailController.text,
          'fbacc': _fbaccController.text,
        };

        final method = widget.supplier != null ? http.put : http.post;

        final response = await method(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.pop(context, true);
        } else {
          _showErrorDialog(
              "Failed to save supplier. Status code: ${response.statusCode}");
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
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
                TextFormField(
                  controller: _gmailController,
                  decoration: InputDecoration(labelText: 'Gmail'),
                ),
                TextFormField(
                  controller: _fbaccController,
                  decoration: InputDecoration(labelText: 'Facebook Account'),
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
