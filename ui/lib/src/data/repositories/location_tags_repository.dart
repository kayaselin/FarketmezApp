import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../classes/location_tag.dart';

class LocationTagsRepository {
  final String baseUrl = 'http://localhost:3000'; // API'nizin URL'si

  Future<List<LocTag>> getLocationTags() async {
  final response = await http.get(Uri.parse('$baseUrl/api/locationtags'));

  if (response.statusCode == 200) {
    List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((json) => LocTag.fromJson(json)).toList();
  } else {
    throw Exception('Veri alınamadı');
  }
}

// Yeni eklenen metodlar

  Future<http.Response> createLocationTag(LocTag locTag) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/locationtags'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(locTag.toJson()),
    );
    return response;
  }

  Future<http.Response> updateLocationTag(int id, LocTag locTag) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/locationtags/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(locTag.toJson()),
    );
    return response;
  }

  Future<http.Response> deleteLocationTag(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/locationtags/$id'),
    );
    return response;
  }
}

