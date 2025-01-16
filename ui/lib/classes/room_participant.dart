class RoomParticipant {
  int participantId;
  int roomId;
  int userId;
  DateTime joinTime;

  RoomParticipant({
    required this.participantId,
    required this.roomId,
    required this.userId,
    required this.joinTime,
  });

  factory RoomParticipant.fromJson(Map<String, dynamic> json) {
    return RoomParticipant(
      participantId: json['participant_id'],
      roomId: json['room_id'],
      userId: json['user_id'],
      joinTime: DateTime.parse(json['join_time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participant_id': participantId,
      'room_id': roomId,
      'user_id': userId,
      'join_time': joinTime.toIso8601String(),
    };
  }
}
