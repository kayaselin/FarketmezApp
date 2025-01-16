import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:farketmez/classes/user.dart';
import 'package:farketmez/src/data/repositories/user_repository.dart';
import 'personal_login_page.dart';

class PersonalRegisterPage extends StatefulWidget {
  const PersonalRegisterPage({super.key});

  @override
  State<PersonalRegisterPage> createState() =>
      _PersonalRegisterPageState();
}

class _PersonalRegisterPageState
    extends State<PersonalRegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _registerUser() async {
    final user = User(
      username: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    try {
      final response = await UserRepository().createUser(user);
      if (response.statusCode == 200 || response.statusCode == 201) {
ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(response.body)));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const PersonalLoginPage()), 
        );
      } else {
        print('Durum Kodu: ${response.statusCode}');
        print(jsonEncode(user.toJson()));

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Kayıt sırasında bir hata oluştu: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Bir hata oluştu: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal User Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            
            ElevatedButton(
              onPressed: _registerUser,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
