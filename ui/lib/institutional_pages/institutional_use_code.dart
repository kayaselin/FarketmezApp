import 'dart:convert';

import 'package:flutter/material.dart';
import '../src/data/repositories/campaign_repository.dart'; // Doğru yolu kullanın
import 'package:farketmez/classes/token.dart'; // Doğru yolu kullanın

class ValidateCampaignPage extends StatefulWidget {
  const ValidateCampaignPage({super.key});

  @override
  _ValidateCampaignPageState createState() => _ValidateCampaignPageState();
}

class _ValidateCampaignPageState extends State<ValidateCampaignPage> {
  final TextEditingController _controller = TextEditingController();
  final DealsRepository _repository = DealsRepository();

  void validateCampaignCode() async {
  try {
    final String code = _controller.text.trim();
    final String? responseString = await _repository.validateCampaignCode(code, Token.institutionId);

    if (responseString != null) {
      // String'i JSON objesine dönüştür
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response.containsKey('campaign')) {
        final Map<String, dynamic> campaign = response['campaign'];
        // `message` bilgisini al
        final String message = response['message'];

        // Kullanıcıya gösterilecek mesajı hazırla
        final String displayMessage = '$message\nCampaign Title: ${campaign['title']}\nDescription: ${campaign['description']}';

        // Başarılı işlem sonucunu kullanıcıya göster
        _showDialog('KOD ALMA', displayMessage);
      } else {
        _showDialog('Hata', 'Kod gecersiz ya da 24 saat icerisinde birden fazla kod kullandiniz.');
      }
    } else {
      // responseString null ise geçersiz bir yanıt alındı demektir
      _showDialog('Hata', 'Geçersiz yanıt alındı');
    }
  } catch (e) {
    String errorMessage = 'Bir hata oluştu.';
    if (e is FormatException) {
      // FormatException hatası için özel mesaj
      errorMessage = e.message;
    } else if (e is Exception) {
      // Diğer hatalar için genel bir yaklaşım
      errorMessage = e.toString();
    }

    // Hata mesajını kullanıcıya göster
    _showDialog('Hata', errorMessage);
  }
}





  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kampanya Kodunu Doğrula'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Kampanya Kodunu Girin',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: validateCampaignCode,
              child: const Text('Kodu Doğrula'),
            ),
          ],
        ),
      ),
    );
  }
}
