import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _token; // _token null olabilir
  bool get isLoggedIn => _token != null;

  String? get token => _token;

  void setToken(String? token) { // token null olabilir
    _token = token;
    notifyListeners(); // Durum değişikliğini bildir
  }

  void logOut() {
    _token = null;
    notifyListeners(); // Durum değişikliğini bildir
  }
}



