import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../classes/rating.dart';

class RatingsRepository {
  final String baseUrl = 'http://10.0.2.2:3000';

  Future<List<UserRating>> getRatingsForInstitution(int institutionId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/ratings?institutionId=$institutionId'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => UserRating.fromJson(json)).toList();
    } else {
      throw Exception('Veri alınamadı');
    }
  }

  // Yeni eklenen metodlar

  Future<http.Response> createRating(UserRating rating) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ratings'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(rating.toJson()),
    );
    return response;
  }

  Future<http.Response> updateRating(int id, UserRating rating) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/ratings/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(rating.toJson()),
    );
    return response;
  }

  Future<http.Response> deleteRating(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/ratings/$id'),
    );
    return response;
  }
}
