class Photos {
  int photoId;
  int institutionId;
  String photoUrl;
  String photoType;

  Photos({
    required this.photoId,
    required this.institutionId,
    required this.photoUrl,
    required this.photoType,
  });

  factory Photos.fromJson(Map<String, dynamic> json) {
    return Photos(
      photoId: json['photo_id'],
      institutionId: json['institution_id'],
      photoUrl: json['photo_url'],
      photoType: json['photo_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photo_id': photoId,
      'institution_id': institutionId,
      'photo_url': photoUrl,
      'photo_type': photoType,
    };
  }
}
