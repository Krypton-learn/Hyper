import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  String? _accessToken;
  
  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  
  bool get isOwner => _currentUser?.owner ?? false;
  
  void setUser(Map<String, dynamic> userData) {
    _currentUser = User.fromMap(userData);
    notifyListeners();
  }

  void setToken(String token) {
    _accessToken = token;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    _accessToken = null;
    notifyListeners();
  }
}
