class Campaign {
  int? campaignId;
  String title;
  String description;
  int? institutionId;
  String? base64Image;
  String? institutionName;
  String? photo;
  int? totalUses;

  Campaign({
    this.campaignId,
    required this.title,
    required this.description,
    required this.institutionId,
    required this.base64Image,
    this.institutionName,
    this.photo,
    this.totalUses,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      campaignId: json['campaign_id'],
      title: json['title'],
      description: json['description'],
      institutionId: json['institution_id'],
      base64Image: json['image_url'],
      institutionName: json['institution_name'],
      photo: json['photo'],
      totalUses: json['total_uses'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'campaign_id': campaignId,
      'institution_id': institutionId,
      'title': title,
      'description': description,
      'image_url': base64Image,
    };
  }
}
