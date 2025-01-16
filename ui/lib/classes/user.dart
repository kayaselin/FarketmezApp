class User {
  int? userId;
  String username;
  String email;
  String? password;
  String? profilePic;

  User({
    this.userId,
    required this.username,
    required this.email,
    this.password,
    this.profilePic,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
      email: json['mail'],
      password: json['password'],
      profilePic: json['profile_pic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      //'user_id': userId,
      'username': username,
      'email': email,
      'password': password,
      //'profile_pic': profilePic,
    };
  }
}
