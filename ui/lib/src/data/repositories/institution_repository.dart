import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../classes/institution.dart';
import '../../../classes/rating.dart';


class InstitutionRepository {
  final String baseUrl = 'http://localhost:3000';

  Future<List<Institution>> getInstitutions() async {
    final response = await http.get(Uri.parse('$baseUrl/api/institutions'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Institution.fromJson(json)).toList();
    } else {
      throw Exception('Veri alınamadı');
    }
  }

  Future<Institution> getInstitutionProfile(int institutionId) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/institutions/profile'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, int>{
      'institutionId': institutionId,
    }),
  );

  if (response.statusCode == 200) {
    // Response body'yi decode et ve bir User nesnesine dönüştür
    final Map<String, dynamic> institutionMap = json.decode(response.body);
    return Institution.fromJson(institutionMap); // User.fromJson, Map'i User nesnesine dönüştüren bir factory constructor olmalı
  } else {
    throw Exception('Kullanıcı profil bilgisi alınamadı');
  }
}


  Future<List<UserRating>> getRatingsForInstitution(int institutionId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/ratings/$institutionId'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => UserRating.fromJson(json)).toList();
    } else {
      throw Exception('Veri alınamadı');
    }
  }

  // Yeni eklenen metodlar

  Future<http.Response> createInstitution(Institution institution) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/institutions/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(institution.toJson()),
    );
    return response;
  }

  Future<http.Response> updateInstitution(int institutionId, Institution institution) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/institutions/$institutionId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(institution.toJson()),
    );
    return response;
  }

  Future<http.Response> deleteInstitution(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/institutions/$id'),
    );
    return response;
  }
}
