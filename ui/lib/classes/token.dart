class Token {
  static String _token = 'your_token_here';

  static int _institutionId = 0;

  static int _userId = 0;

  static String get token => _token;

  static set token(String value) {
    _token = value;
  }

  static int get institutionId => _institutionId;

  static set institutionId(int value) {
    _institutionId = value;
  }

  static int get userId => _userId;

  static set userId(int value) {
    _userId = value;
  }
}