class InstitutionTagLink {
  int institutionId;
  int tagId;

  InstitutionTagLink({
    required this.institutionId,
    required this.tagId,
  });

  factory InstitutionTagLink.fromJson(Map<String, dynamic> json) {
    return InstitutionTagLink(
      institutionId: json['institution_id'],
      tagId: json['tag_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'institution_id': institutionId,
      'tag_id': tagId,
    };
  }
}
