class UserRating {
  int ratingId;
  int userId;
  int institutionId;
  int score;
  DateTime ratingDate;

  UserRating({
    required this.ratingId,
    required this.userId,
    required this.institutionId,
    required this.score,
    required this.ratingDate,
  });

  factory UserRating.fromJson(Map<String, dynamic> json) {
    return UserRating(
      ratingId: json['rating_id'],
      userId: json['user_id'],
      institutionId: json['institution_id'],
      score: json['score'],
      ratingDate: DateTime.parse(json['rating_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating_id': ratingId,
      'user_id': userId,
      'institution_id': institutionId,
      'score': score,
      'rating_date': ratingDate.toIso8601String(),
    };
  }
}
