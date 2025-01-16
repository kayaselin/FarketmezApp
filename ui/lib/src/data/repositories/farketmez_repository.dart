import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:farketmez/classes/institution.dart';

class FarketmezRepository {
  final String baseUrl = 'http://localhost:3000';

  Future<int?> createRoom(int userId, int maxParticipants, int locationTagId, bool bool) async {
  var url = Uri.parse('$baseUrl/api/users/create');
  var response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json', // İçerik tipini belirtin
    },
    body: json.encode({
      'userId': userId,
      'maxParticipants': maxParticipants,
      'locationTagId': locationTagId,
    }),
  );

  if (response.statusCode == 201) {
    var data = json.decode(response.body);
    return data['roomId'];
  } else {
    print('Room creation failed: ${response.body}');
    return null;
  }
}


  Future<Map<String, dynamic>> joinRoom(int roomId, int userId) async {
  var url = Uri.parse('$baseUrl/api/users/join');
  var response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'roomId': roomId,
      'userId': userId,
    }),
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    // Servis yanıtından 'districtName' ve diğer bilgileri çekin
    return {
      'success': true,
      'districtName': data['districtName'], // Yanıtınıza göre ayarlayın
    };
  } else {
    // Hata durumu veya başarısız katılım
    return {'success': false};
  }
}

Future<bool> submitTags(int userId, int roomId, int tagId) async {
    final url = Uri.parse('$baseUrl/api/rooms/select-tag'); // POST isteğinizin URL'si
    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      'userId': userId,
      'roomId': roomId,
      'tagId': tagId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // İşlem başarılı
        return true;
      } else {
        // İşlem başarısız, hata mesajı log'layabilirsiniz
        print('Submit tag failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Submit tag exception: $e');
      return false;
    }
  }

  Future<bool> checkIfVotingFinished(int roomId) async {
    final url = Uri.parse('$baseUrl/api/rooms/is-finished/$roomId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['isFinished'];
      } else {
        print('Error checking voting status: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception when checking voting status: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> checkAndListInstitutions(int roomId) async {
  final url = Uri.parse('$baseUrl/api/rooms/institutions/$roomId');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // API'den gelen JSON verisinden `Institution` nesnelerinin listesini oluştur
      List<Institution> institutions = (data['institutions'] as List<dynamic>).map((institutionJson) => Institution.fromJson(institutionJson)).toList();
      
      return {
        'tagName': data['tagName'],
        'institutions': institutions, // Düzgün bir şekilde dönüştürülmüş liste
      };
    } else {
      print('Error fetching institutions: ${response.body}');
      return {'tagName': '', 'institutions': []};
    }
  } catch (e) {
    print('Exception when fetching institutions: $e');
    return {'tagName': '', 'institutions': []};
  }
}

  // Diğer fonksiyonlar burada tanımlanabilir. Örneğin, tag ekleme, oda bilgilerini güncelleme vb.
}
