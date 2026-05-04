import 'package:camera_app/services/alert_service.dart';
import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String cameraId;
  final String? image;
  final bool isRead;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.cameraId,
    this.image,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['_id'] ?? '',
      title: map['title'] ?? 'Cảnh báo Camera',
      body: map['body'] ?? '',
      cameraId: map['cameraId'] ?? '',
      image: map['image'],
      isRead: map['isRead'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  // Copy with isRead = true
  NotificationItem markRead() {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      cameraId: cameraId,
      image: image,
      isRead: true,
      createdAt: createdAt,
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  final AlertService _service = AlertService();

  List<NotificationItem> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  /// Fetch alerts từ API mới
  Future<void> fetchNotifications(String email) async {
    _isLoading = true;
    notifyListeners();

    final result = await _service.getAlerts();

    if (result.containsKey('success')) {
      final list = result['success'] as List;
      _notifications = list
          .map((e) => NotificationItem.fromMap(e as Map<String, dynamic>))
          .toList();
      _unreadCount = result['unreadCount'] as int;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Đánh dấu tất cả đã đọc (Giữ nguyên cấu trúc nhưng alerts có thể không cần)
  Future<void> markAllRead(String email) async {
    // Với alerts mới, tạm thời không gọi mark-read vì backend Alert chưa hỗ trợ isRead
    _notifications = _notifications.map((n) => n.markRead()).toList();
    _unreadCount = 0;
    notifyListeners();
  }

  /// Thêm thông báo ngay khi FCM tới (không cần reload API)
  void addLocalNotification({
    required String title,
    required String body,
    required String cameraId,
    String? image,
  }) {
    _notifications.insert(
      0,
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        cameraId: cameraId,
        image: image,
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );
    _unreadCount += 1;
    notifyListeners();
  }
}
