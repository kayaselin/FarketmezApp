import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../classes/campaign.dart';

class DealsRepository {
  final String baseUrl = 'http://localhost:3000'; // API'nizin URL'si

  Future<List<Campaign>> getCampaigns(int institutionId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/institutions/campaigns/$institutionId'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      // Boş bir liste döndüğünde, boş bir liste döndürmek için kontrol
      if (jsonList.isEmpty) {
        return [];
      }
      return jsonList.map((json) => Campaign.fromJson(json)).toList();
    } else {
      // API'den 200 dışında bir yanıt geldiğinde, boş bir liste döndürebilir veya
      // hata mesajınızı özelleştirebilirsiniz.
      // Bu örnekte, boş bir liste dönüyoruz.
      // throw Exception('Veri alınamadı');
      return [];
    }
  }

  Future<List<Campaign>> getCampaignStatistics(int institutionId) async {
  // POST isteği için URL
  final url = Uri.parse('$baseUrl/api/institutions/stats');

  // Headerlar, içerik tipini JSON olarak belirtir
  final headers = {'Content-Type': 'application/json; charset=UTF-8'};

  // Body, institutionId'yi JSON formatında içerir
  final body = json.encode({'institutionId': institutionId});

  // HTTP POST isteği
  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    // Başarılı yanıtı işle
    List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((json) => Campaign.fromJson(json)).toList();
  } else {
    // Hata durumunda exception fırlat
    throw Exception('Veri alınamadı');
  }
}

  Future<List<Campaign>> getRandomCampaigns() async {
    final response = await http.get(Uri.parse('$baseUrl/api/users/random-campaigns'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Campaign.fromJson(json)).toList();
    } else {
      throw Exception('Veri alınamadı');
    }
  }

  Future<String?> getCampaignCode(int campaignId, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/campaigns/generateCodeForUser/$campaignId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['code']; // Kodu döndür
      } else {
        print('Sunucudan kod alınamadı: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Bir hata oluştu: $e');
      return null;
    }
  }


  Future<String> validateCampaignCode(String code, int institutionId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/institutions/campaigns/approveCodes'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'code': code,
        'institutionId': institutionId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      // Kampanya bilgilerini başarıyla aldık, JSON string olarak dön
      return response.body;

    } else {
      // API'den gelen yanıt başarısız ise bir Exception fırlat
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String errorMessage = responseData['message'] ?? 'Kampanya doğrulanamadı veya bulunamadı.';
      return(errorMessage);
    }
  } catch (e) {
    // HTTP isteği sırasında bir hata oluştuğunda veya API'den başarısız bir yanıt geldiğinde burası çalışır
    // Beklenmedik hataları veya işlenmiş hata mesajlarını Exception olarak fırlat
    throw Exception('Kampanya kodu doğrulama sırasında bir hata oluştu: ${e.toString()}');
  }
}

  // Yeni eklenen metodlar

  Future<http.Response> createCampaign(Campaign campaign,int institutionId) async {
  // İstek URL'si
  final String url = '$baseUrl/api/institutions/create-campaign';
  
  // İstek body'si
  final String requestBody = jsonEncode(campaign.toJson());

  // URL ve gönderilecek verileri loglama
  print('Request URL: $url');
  print('Request Body: $requestBody');

  final response = await http.post(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: requestBody,
  );

  // Yanıtı loglama
  print('Response Status: ${response.statusCode}');
  print('Response Body: ${response.body}');

  return response;
}

  Future<http.Response> updateCampaign(int id, Campaign campaign) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/campaigns/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(campaign.toJson()),
    );
    return response;
  }

  Future<http.Response> deleteCampaign(int campaignId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/institutions/delete-campaign/$campaignId'),
    );
    return response;
  }
}