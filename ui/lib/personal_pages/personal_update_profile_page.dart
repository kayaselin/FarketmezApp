import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:farketmez/classes/token.dart';
import 'package:http/http.dart' as http;

class PersonalUpdateProfilePage extends StatefulWidget {
  const PersonalUpdateProfilePage({super.key});

  @override
  _PersonalUpdateProfilePageState createState() => _PersonalUpdateProfilePageState();
}

class _PersonalUpdateProfilePageState extends State<PersonalUpdateProfilePage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // `_updateUserInfo` fonksiyonunun güncellenmiş hali
void _updateUserInfo() async {
  final Map<String, dynamic> updateInfo = {};
  final userId = Token.userId;

  updateInfo['userId'] = userId;

  if (_userNameController.text.isNotEmpty) {
    updateInfo['username'] = _userNameController.text;
  }
  if (_emailController.text.isNotEmpty) {
    updateInfo['mail'] = _emailController.text;
  }
  if (_passwordController.text.isNotEmpty) {
    updateInfo['password'] = _passwordController.text;
  }

  // API'ye PUT isteği gönder
  final response = await http.put(
    Uri.parse('http://localhost:3000/api/users/update-user'), // Gerçek API URL'niz
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
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Image.asset('assets/logo.png', height: 50, width: 50,),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/personalProfilePage');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: 'UserName',
                border: OutlineInputBorder(),
                hintText: 'Enter new username',
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
            ElevatedButton(
              onPressed: _updateUserInfo,
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  // Handle settings action
                  Navigator.pop(context);
                },
              ),
            ),
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.home_filled),
                onPressed: () {
                  // Handle settings action
                  Navigator.pushNamed(context, '/personalHomePage');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}