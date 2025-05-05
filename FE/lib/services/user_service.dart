import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final apiUrl = "http://192.168.100.248:5000/api";

  Future<Map<String, dynamic>> signin(
    String email,
    String password,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      return {
        'error': 'Email hoặc mật khẩu không được để trống',
      };
    }
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': responseData};
      } else {
        return {
          'error':
              responseData['message'] ??
              'Lỗi không xác định',
        };
      }
    } catch (error) {
      return {'error': 'Lỗi server. Thử lại sau!'};
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      return {
        'error': 'Email hoặc mật khẩu không được để trống',
      };
    }
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success':
              responseData['message'] ??
              'Đăng kí thành công',
        };
      } else {
        return {
          'error':
              responseData['message'] ??
              'Lỗi không xác định',
        };
      }
    } catch (error) {
      return {'error': 'Lỗi server!. Vui lòng thử lại'};
    }
  }
}
