import 'dart:convert';
import 'package:http/http.dart' as http;

class DeviceService {
  final apiUrl = "http://192.168.1.6:5000/api/device";

  Future<Map<String, dynamic>> create(
    String device_name,
    String url,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/add_device'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'device_name': device_name,
          'url': url,
        }),
      );
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success':
              responseData['message'] ??
              "Thêm thiết bị thành công",
        };
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

  Future getDevice() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/getDevice'),
      );
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': responseData['data']};
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

  Future<Map<String, dynamic>> delete(id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/delete/$id'),
      );
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success':
              responseData['message'] ?? 'Xóa thành công',
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
