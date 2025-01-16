import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:farketmez/classes/token.dart';
import 'package:farketmez/classes/photo.dart';

class PhotoRepository {
  final String baseUrl = 'http://localhost:3000'; // veya Android emülatör için 'http://10.0.2.2:3000'
  final String stringToken = Token.token; // Token değerinizi buraya ekleyin

  Future<List<Photo>> getPhotos(int institutionId) async {
  final uri = Uri.parse('$baseUrl/api/institutions/photos/$institutionId');
  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $stringToken',
    },
  );

  if (response.statusCode == 200 && response.body.isNotEmpty) {
    List<dynamic> photoListJson = json.decode(response.body);
    List<Photo> photos = photoListJson.map((photo) => Photo(
      id: photo['photo_id'], // API'den gelen yanıtta bu anahtarın adına göre değiştirin
      data: base64Decode(photo['photo_byte']),
    )).toList();
    return photos;
  } else {
    throw Exception('Failed to load photos. Status code: ${response.statusCode}');
  }
}


  Future<void> addPhoto(String base64Image, institutionId) async {
  var url = Uri.parse('$baseUrl/api/institutions/photos/upload/$institutionId');
  var response = await http.post(url, body: {
    'photo_byte': base64Image,

  });

  if (response.statusCode == 200) {
    // İşlem başarılı
    print('Image successfully uploaded');
  } else {
    // İşlemde bir hata oluştu
    print('Failed to upload image');
  }
}

  Future<void> deletePhoto(int photoId) async {
    final uri = Uri.parse('$baseUrl/api/institutions/photos/$photoId');
    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $stringToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Fotoğraf silinirken bir hata oluştu. Status code: ${response.statusCode}');
    }
  }
}
