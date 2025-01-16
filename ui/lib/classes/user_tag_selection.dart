class UserTagSelection {
  int roomId;
  int userId;
  int tagId;
  

  UserTagSelection({
    required this.roomId,
    required this.userId,
    required this.tagId,
    
  });

  factory UserTagSelection.fromJson(Map<String, dynamic> json) {
    return UserTagSelection(
      roomId: json['room_id'],
      userId: json['user_id'],
      tagId: json['tag_id'],
      
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'user_id': userId,
      'tag_id': tagId,
      
    };
  }
}
