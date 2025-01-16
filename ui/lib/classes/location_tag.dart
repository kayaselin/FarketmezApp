class LocTag {
  final int locTagId;
  final String districtName;

  LocTag({
    required this.locTagId,
    required this.districtName,
  });

  factory LocTag.fromJson(Map<String, dynamic> json) {
    return LocTag(
      locTagId: json['loc_tag_id'],
      districtName: json['district_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loc_tag_id': locTagId,
      'district_name': districtName,
    };
  }
}
