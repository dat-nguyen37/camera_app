import 'package:camera_app/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _token;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  // Set thông tin user
  void setUser(Map<String, dynamic> user) {
    _user = user;
    notifyListeners(); // Báo cho các widget lắng nghe về sự thay đổi
  }

  void setToken(String token) {
    _token = token;
    notifyListeners(); // Báo cho các widget lắng nghe về sự thay đổi
  }

  String getToken() {
    return _token ?? '';
  }

  Future<void> saveTokenLocal(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  // Xóa thông tin user
  void clearUser() async {
    _user = null;
    SharedPreferences prefs =
        await SharedPreferences.getInstance();
    final token = prefs.getString('fcm_token');
    if (token != null) {
      await AuthService().removeToken(
        _token!,
        token,
      ); // gọi API remove ở backend
      await prefs.remove('fcm_token');
    }
    notifyListeners();
  }
}
