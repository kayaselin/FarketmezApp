import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:farketmez/classes/token.dart';
import 'package:http/http.dart' as http;

class InstitutionalUpdateProfilePage extends StatefulWidget {
  const InstitutionalUpdateProfilePage({super.key});

  @override
  _InstitutionalUpdateProfilePageState createState() => _InstitutionalUpdateProfilePageState();
}

class _InstitutionalUpdateProfilePageState extends State<InstitutionalUpdateProfilePage> {
  final TextEditingController _institutionNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _institutionNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // `_updateUserInfo` fonksiyonunun güncellenmiş hali
void _updateUserInfo() async {
  final Map<String, dynamic> updateInfo = {};
  final institutionId = Token.institutionId;

  updateInfo['institutionId'] = institutionId;

  if (_institutionNameController.text.isNotEmpty) {
    updateInfo['institutionName'] = _institutionNameController.text;
  }
  if (_emailController.text.isNotEmpty) {
    updateInfo['email'] = _emailController.text;
  }
  if (_passwordController.text.isNotEmpty) {
    updateInfo['password'] = _passwordController.text;
  }
  if (_addressController.text.isNotEmpty) {
    updateInfo['addressText'] = _addressController.text;
  }
  if (_phoneNumberController.text.isNotEmpty) {
    updateInfo['phoneNumber'] = _phoneNumberController.text;
  }

  // API'ye PUT isteği gönder
  final response = await http.put(
    Uri.parse('http://localhost:3000/api/institutions/update-institution'), // Gerçek API URL'niz
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(updateInfo),
  );

  if (response.statusCode == 200) {
    // Başarıyla güncellendi
    print('Update Info: $updateInfo');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Information updated successfully')),
    );
  } else {
    // Hata oluştu
    print('Failed to update user info: ${response.body}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update information: ${response.body}')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Information'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _institutionNameController,
              decoration: const InputDecoration(
                labelText: 'Institution Name',
                border: OutlineInputBorder(),
                hintText: 'Enter new institution name',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                hintText: 'Enter new email',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                hintText: 'Enter new password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                hintText: 'Enter new address',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                hintText: 'Enter new phone number',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserInfo,
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
