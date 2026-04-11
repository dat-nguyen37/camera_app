import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  final apiUrl = "http://192.168.2.8:5000/api/user";
  static const String appKey =
      'ca870ed081f24c6d944051ec95c2c361';
  static const String appSecret =
      'f610ddfb63ee4cdaba6e89851e34a202'; // Lấy từ EZVIZ Open Platform

  // Gọi API EZVIZ để lấy token
  Future<String?> loginWithEzviz(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://open.ezvizlife.com/api/lapp/token/get',
        ),
        headers: {
          'Content-Type':
              'application/x-www-form-urlencoded',
        },
        body: {
          'appKey': appKey,
          'appSecret': appSecret,
          'username': username,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == '200') {
          await register(username, password);
          return data['data']['accessToken'];
        }
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$apiUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "email": email,
        "password": password,
        "name": email,
      }),
    );
    print("fdfdbfdd ${response.body}");
    final data = json.decode(response.body);
    if (data['status'] == 'success') {
      return {
        'success': data['message'] ?? 'Đăng kí thành công',
      };
    } else {
      return {
        'error': data['message'] ?? 'Lỗi không xác định',
      };
    }
  }

  Future<Map<String, dynamic>> saveToken(
    String email,
    String fcmToken,
  ) async {
    final response = await http.post(
      Uri.parse('$apiUrl/save-token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "token": fcmToken,
        "email": email,
      }),
    );
    print("fdfdbfdd ${response.body}");
    final data = json.decode(response.body);
    print("fdfdbfdd $data");
    if (data['status'] == 'success') {
      return {
        'success':
            data['message'] ?? 'Lưu token thành công',
      };
    } else {
      return {
        'error': data['message'] ?? 'Lỗi không xác định',
      };
    }
  }

  Future<Map<String, dynamic>> removeToken(
    String email,
    String fcmToken,
  ) async {
    final response = await http.post(
      Uri.parse('$apiUrl/remove-token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "token": fcmToken,
        "email": email,
      }),
    );
    print("fdfdbfdd ${response.body}");
    final data = json.decode(response.body);
    if (data['status'] == 'success') {
      return {
        'success':
            data['message'] ?? 'Xóa token thành công',
      };
    } else {
      return {
        'error': data['message'] ?? 'Lỗi không xác định',
      };
    }
  }
}
