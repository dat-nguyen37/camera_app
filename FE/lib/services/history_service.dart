import 'dart:convert';
import 'package:http/http.dart' as http;

class HistoryService {
  final String _base =
      "http://192.168.2.12:5000/api/notification";

  Future<Map<String, dynamic>> getHistory(
    String email,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_base/history?email=${Uri.encodeComponent(email)}',
        ),
      );
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

  Future<bool> markAllRead(String email) async {
    try {
      final response = await http.put(
        Uri.parse('$_base/mark-read'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getCameraHistory(
    String email,
    String cameraId, {
    String? date,
  }) async {
    try {
      String url =
          '$_base/camera?email=${Uri.encodeComponent(email)}&cameraId=${Uri.encodeComponent(cameraId)}';
      if (date != null) {
        url += '&date=${Uri.encodeComponent(date)}';
      }
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': data['data'] as List};
      }
      return {
        'error': data['error'] ?? 'Lỗi không xác định',
      };
    } catch (e) {
      return {'error': 'Lỗi kết nối server'};
    }
  }
}
