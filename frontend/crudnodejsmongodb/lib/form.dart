import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
import 'utils.dart';

class UserForm extends StatefulWidget {
  final Map? user;

  const UserForm({super.key, this.user});

  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user?['name']);
    emailController = TextEditingController(text: widget.user?['email']);
    passwordController = TextEditingController(text: widget.user?['password']);
  }

  Future<void> saveUser() async {
    final url = widget.user == null
        ? '$apiBaseUrl/api/users'
        : '$apiBaseUrl/api/users/${widget.user!['_id']}';

    final method = widget.user == null ? http.post : http.put;

    final body = {
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text,
    };

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
        title: Text(widget.user == null ? 'Add User' : 'Edit User'),
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
            CustomTextField(
              labelText: "Email",
              hintText: "Enter Email",
              controller: emailController,
            ),
            CustomTextField(
              labelText: "Password",
              hintText: "Enter Password",
              controller: passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 20),
            CustomElevatedButton(
              onPressed: saveUser,
              text: 'Save User',
              icon: Icons.save,
            ),
          ],
        ),
      ),
    );
  }
}
