import 'rating.dart';

class Institution {
  int? institutionId;
  String institutionName;
  String? email;
  String? password;
  String addressText;
  String? profilePic;
  int? locTagId;
  String phoneNumber;
  List<UserRating> ratings; // Rating listesi ekleniyor
  List<String> tags; // Etiketler için bir liste
  double? latitude;
  double? longitude;

  Institution({
    this.institutionId,
    required this.institutionName,
    this.email,
    this.password,
    required this.addressText,
    this.profilePic,
    this.locTagId,
    required this.phoneNumber,
    this.ratings = const [], // Varsayılan olarak boş bir liste olarak başlatılıyor
    required this.tags, // Etiketler parametresi ekleniyor
    this.latitude,
    this.longitude,
  });

factory Institution.fromJson(Map<String, dynamic> json) {
  return Institution(
    institutionId: json['institution_id'],
    institutionName: json['institution_name'],
    email: json['email'],
    password: json['password'],
    addressText: json['adress_text'],
    profilePic: json['profile_pic'],
    locTagId: json['loc_tag_id'],
    phoneNumber: json['phone_number'],
    // API'den gelen JSON içindeki rating verilerini de dönüştürüp ekleyebilirsiniz
    // Örnek: ratings: (json['ratings'] as List).map((ratingJson) => Rating.fromJson(ratingJson)).toList(),
    tags: json['tag_names'] != null ? List<String>.from(json['tag_names'].split(', ')) : [],
    latitude:  json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
    longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null
  );
}


  Map<String, dynamic> toJson() {
  return {
    'institutionName': institutionName,
    'email': email,
    'password': password,
    'address': addressText,
    //'profile_pic': profilePic,
    'locTagId': locTagId.toString(),
    'phoneNumber': phoneNumber,
    //'ratings': ratings.map((rating) => rating.toJson()).toList(),
    'tags': tags.map((tag) => tag.toString()).toList(),
    'latitude': latitude,
    'longitude': longitude,
  };
}

}
