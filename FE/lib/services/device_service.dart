import 'dart:convert';
import 'package:http/http.dart' as http;

class DeviceService {
  final apiUrl = "http://192.168.2.12:5000/api/device";

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

  Future<Map<String, int>> getDeviceStatus(
    String accessToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://open.ezvizlife.com/api/lapp/device/list',
        ),
        headers: {
          'Content-Type':
              'application/x-www-form-urlencoded',
        },
        body: {
          'accessToken': accessToken,
          'pageStart': '0',
          'pageSize': '50',
        },
      );
      final data = json.decode(response.body);
      print("EZVIZ API Response: $data");
      Map<String, int> statuses = {};
      if (data['code'] == '200' && data['data'] != null) {
        for (var dev in data['data']) {
          // status: 0-offline, 1-online
          statuses[dev['deviceSerial']
                  .toString()
                  .toUpperCase()] =
              dev['status'];
        }
      }
      return statuses;
    } catch (e) {
      print("Error fetching device status: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> updateROI(
    String id, {
    double? x,
    double? y,
    double? width,
    double? height,
    bool? isDetectionEnabled,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (x != null) body['x'] = x;
      if (y != null) body['y'] = y;
      if (width != null) body['width'] = width;
      if (height != null) body['height'] = height;
      if (isDetectionEnabled != null)
        body['is_detection_enabled'] = isDetectionEnabled;

      final response = await http.put(
        Uri.parse('$apiUrl/update_roi/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success':
              responseData['message'] ??
              'Cập nhật thành công',
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
