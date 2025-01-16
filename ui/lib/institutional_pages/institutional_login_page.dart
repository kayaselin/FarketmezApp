import 'package:flutter/material.dart';
import '../helper/login_logout.dart';


class InstitutionalLoginPage extends StatefulWidget {
  const InstitutionalLoginPage({super.key});

  @override
  _InstitutionalLoginPageState createState() => _InstitutionalLoginPageState();
}

class _InstitutionalLoginPageState extends State<InstitutionalLoginPage> {
  
  final TextEditingController _emailController = TextEditingController(text: 'pizzav@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: '1234567890');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login - Institutional'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Institutional Login',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Image.asset('assets/logo.png',
              height: 250,
              width: 250,),
            const Text(
              'Farketmez',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Login'),
              onPressed: () {
                final String email = _emailController.text;
                final String password = _passwordController.text;
                login(context, email, password, false); // Kurum girişi için false
              },
            ),
            TextButton(
              child: const Text(
                'Create Account',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/institutionalRegister');
              },
            ),
          ],
        ),
      ),
    );
  }
}
