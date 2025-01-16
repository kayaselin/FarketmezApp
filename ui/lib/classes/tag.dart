class Tag {
  final int tagId;
  final String tagName;

  Tag({
    required this.tagId,
    required this.tagName,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      tagId: json['tag_id'],
      tagName: json['tag_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag_id': tagId,
      'tag_name': tagName,
    };
  }
}
