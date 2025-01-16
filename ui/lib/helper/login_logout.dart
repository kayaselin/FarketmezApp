import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:farketmez/classes/platform.dart';
import '../institutional_pages/institutional_home_page.dart';
import '../personal_pages/personal_home_page.dart'; // Diğer gerekli importlarınız
import 'package:farketmez/classes/token.dart';

Future<void> login(BuildContext context, String emailOrUsername, String password, bool isUser) async {
  
  String platformurl = Provider.of<PlatformProvider>(context, listen: false).platformurl;
  String emailString = 'email';
  if(isUser){
    emailString = 'emailOrUsername';
  }
  var url = isUser
      ? 'http://$platformurl:3000/api/users/login'
      : 'http://$platformurl:3000/api/institutions/login';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        emailString: emailOrUsername,
        'password': password
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['token'] != null && responseData['token']['token'] is String) {
        String token = responseData['token']['token'];
        Token.token = token;
        if(!isUser) {
          Token.institutionId = responseData['token']['institutionId'];
        }
        else{
          Token.userId = responseData['token']['userId'];
        }
        

        // Kullanıcı tipine göre anasayfaya yönlendirme
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                isUser ? const PersonalHomePage() : const InstitutionalHomePage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token bilgisi alınamadı veya hatalı.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş başarısız: ${response.statusCode}')),
      );
    }
  } catch (error) {
    print(error.toString());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Bir hata oluştu'),
    ));
  }
}
