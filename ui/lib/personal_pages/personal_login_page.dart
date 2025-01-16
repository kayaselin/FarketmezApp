import 'package:flutter/material.dart';
import '../helper/login_logout.dart';
import 'package:farketmez/classes/colors.dart';

class PersonalLoginPage extends StatefulWidget {
  const PersonalLoginPage({super.key});

  @override
  _PersonalLoginPageState createState() => _PersonalLoginPageState();
}

class _PersonalLoginPageState extends State<PersonalLoginPage> {
  final TextEditingController _emailorUsernameController = TextEditingController(text: 'userkayit1@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: '1234567890');

  @override
  void dispose() {
    _emailorUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Login - Personal'),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Farketmez Personal Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                color: AppColors.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Image.asset('assets/logo.png',
              height: 250,
              width: 250,), // logo
              
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailorUsernameController,
                decoration: const InputDecoration(labelText: 'Email or Username'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor,),
                onPressed: () async {
                  final String emailOrUsername = _emailorUsernameController.text;
                  final String password = _passwordController.text;
                  try {
                    await login(context, emailOrUsername, password, true);
                    // Başarılı girişten sonra yapılacak işlemler burada
                  } catch (error) {
                    // Giriş başarısız olduğunda yapılacak işlemler burada
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Giriş başarısız: $error'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: AppColors.buttonTextColor),
                ),
              ),
              TextButton(
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: AppColors.buttonTextColor),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/personalRegister');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}