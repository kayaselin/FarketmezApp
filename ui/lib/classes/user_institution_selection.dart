class UserInstitutionSelection {
  int iselectionId;
  int roomId;
  int userId;
  int institutionId;
  DateTime selectionTime;

  UserInstitutionSelection({
    required this.iselectionId,
    required this.roomId,
    required this.userId,
    required this.institutionId,
    required this.selectionTime,
  });

  factory UserInstitutionSelection.fromJson(Map<String, dynamic> json) {
    return UserInstitutionSelection(
      iselectionId: json['iselection_id'],
      roomId: json['room_id'],
      userId: json['user_id'],
      institutionId: json['institution_id'],
      selectionTime: DateTime.parse(json['selection_time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iselection_id': iselectionId,
      'room_id': roomId,
      'user_id': userId,
      'institution_id': institutionId,
      'selection_time': selectionTime.toIso8601String(),
    };
  }
}
