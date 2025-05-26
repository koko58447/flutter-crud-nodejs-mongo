import 'package:crudnodejsmongodb/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants.dart';

class CategoryForm extends StatefulWidget {
  final Map? user;
  const CategoryForm({super.key, this.user});

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user?['name']);
  }

  Future<void> saveUser() async {
    final url = widget.user == null
        ? '$apiBaseUrl/api/categorys'
        : '$apiBaseUrl/api/categorys/${widget.user!['_id']}';

    final method = widget.user == null ? http.post : http.put;

    final body = {'name': nameController.text};

    final response = await method(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Add Category' : 'Edit Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              labelText: "Name",
              hintText: "Enter Name",
              controller: nameController,
            ),
            const SizedBox(height: 20),
            CustomElevatedButton(
              onPressed: saveUser,
              text: 'Save',
              icon: Icons.save,
            ),
          ],
        ),
      ),
    );
  }
}
