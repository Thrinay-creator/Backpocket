import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static const String staffPasscode = 'STAFF2026';
  bool _isStaff = false;

  bool get isStaff => _isStaff;

  AuthProvider() {
    _loadAuthStatus();
  }

  Future<void> _loadAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isStaff = prefs.getBool('is_staff') ?? false;
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> login(String code) async {
    if (code.trim().toUpperCase() == staffPasscode) {
      _isStaff = true;
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_staff', true);
      } catch (_) {}
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isStaff = false;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_staff', false);
    } catch (_) {}
  }
}
