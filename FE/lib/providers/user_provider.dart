import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  // Set thông tin user
  void setUser(Map<String, dynamic> user) {
    _user = user;
    notifyListeners(); // Báo cho các widget lắng nghe về sự thay đổi
  }

  // Xóa thông tin user
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
