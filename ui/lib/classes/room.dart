class Room {
  int roomId;
  int userId;
  int locTagId;
  int maxNumOfUsers;
  DateTime creationTime;
  DateTime expirationTime;
  //bool isAdmin;

  Room({
    required this.roomId,
    required this.userId,
    required this.locTagId,
    required this.maxNumOfUsers,
    required this.creationTime,
    required this.expirationTime,
    //required this.isAdmin,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['room_id'],
      userId: json['creator_user_id'],
      locTagId: json['loc_tag_id'],
      maxNumOfUsers: json['max_num_of_users'],
      creationTime: DateTime.parse(json['creation_time']),
      expirationTime: DateTime.parse(json['expiration_time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'creator_user_id': userId,
      'loc_tag_id': locTagId,
      'max_num_of_users': maxNumOfUsers,
      'creation_time': creationTime.toIso8601String(),
      'expiration_time': expirationTime.toIso8601String(),
    };
  }
}
