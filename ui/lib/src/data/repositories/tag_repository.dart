import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../classes/tag.dart';

class TagRepository {
  final String baseUrl = 'http://localhost:3000'; // API'nizin URL'si

  Future<List<Tag>> getTags() async {
    final response = await http.get(Uri.parse('$baseUrl/api/tags'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Tag.fromJson(json)).toList();
    } else {
      throw Exception('Veri alınamadı');
    }
  }

  // Yeni eklenen metodlar

  Future<http.Response> createTag(Tag tag) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/tags'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(tag.toJson()),
    );
    return response;
  }

  Future<http.Response> updateTag(int id, Tag tag) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/tags/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(tag.toJson()),
    );
    return response;
  }

  Future<http.Response> deleteTag(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/tags/$id'),
    );
    return response;
  }
}
