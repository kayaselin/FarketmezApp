import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../classes/user.dart';

class UserRepository {
  final String baseUrl = 'http://localhost:3000'; // API'nizin URL'si

  Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/users'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Veri alınamadı');
    }
  }


  // UserRepository içindeki getUserProfile metodunu örnek olarak düzenleme
Future<User> getUserProfile(int userId) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/users/profile'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, int>{
      'userId': userId,
    }),
  );

  if (response.statusCode == 200) {
    // Response body'yi decode et ve bir User nesnesine dönüştür
    final Map<String, dynamic> userMap = json.decode(response.body);
    return User.fromJson(userMap); // User.fromJson, Map'i User nesnesine dönüştüren bir factory constructor olmalı
  } else {
    throw Exception('Kullanıcı profil bilgisi alınamadı');
  }
}


  // Yeni eklenen metodlar

  Future<http.Response> createUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );
    return response;
  }

  Future<http.Response> updateUser(int id, User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );
    return response;
  }

  Future<http.Response> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/users/$id'),
    );
    return response;
  }
}
