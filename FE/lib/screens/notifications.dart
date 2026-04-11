import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState
    extends State<NotificationsPage> {
  // Mock data for notifications
  final List<Map<String, String>> _notifications = [
    {
      'title': 'Cảnh báo chuyển động',
      'message':
          'Phát hiện chuyển động bất thường tại cửa chính vào lúc 10:30 AM.',
      'time': '2 giờ trước',
    },
    {
      'title': 'Thiết bị ngoại tuyến',
      'message': 'Camera phòng khách đã bị ngắt kết nối.',
      'time': 'Hôm qua',
    },
    {
      'title': 'Cập nhật hệ thống',
      'message':
          'Hệ thống đã được cập nhật lên phiên bản mới nhất.',
      'time': '3 ngày trước',
    },
    {
      'title': 'Pin yếu',
      'message':
          'Pin của cảm biến cửa sổ đang yếu. Vui lòng kiểm tra.',
      'time': '1 tuần trước',
    },
    {
      'title': 'Cảnh báo nhiệt độ',
      'message':
          'Nhiệt độ trong nhà vượt quá ngưỡng an toàn.',
      'time': '2 tuần trước',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body:
          _notifications.isEmpty
              ? const Center(
                child: Text('Chưa có thông báo nào'),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification =
                      _notifications[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                    ),
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.notifications_active,
                        color: Colors.blue,
                      ),
                      title: Text(
                        notification['title']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4.0),
                          Text(
                            notification['message']!,
                            style: const TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            notification['time']!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Handle notification tap, e.g., navigate to detail page
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã chạm vào thông báo: ${notification['title']}',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
