import 'dart:convert';
import 'package:http/http.dart' as http;

class AlertService {
  final String _base = "http://192.168.2.12:5000/api/alert";

  Future<Map<String, dynamic>> getAlerts() async {
    try {
      final response = await http.get(Uri.parse(_base));
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': data['data'] as List,
          'unreadCount': data['unreadCount'] as int,
        };
      }
      return {
        'error': data['error'] ?? 'Lỗi không xác định',
      };
    } catch (e) {
      return {'error': 'Lỗi kết nối server'};
    }
  }
}
