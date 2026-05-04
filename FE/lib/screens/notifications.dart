import 'dart:convert';
import 'dart:typed_data';
import 'package:camera_app/providers/notification_provider.dart';
import 'package:camera_app/providers/tab_provider.dart';
import 'package:camera_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState
    extends State<NotificationsPage> {
  TabProvider? _tabProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadAndMarkRead(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Gỡ listener cũ nếu đã gắn
    _tabProvider?.removeListener(_onTabChanged);
    // Gắn listener mới
    _tabProvider = Provider.of<TabProvider>(
      context,
      listen: false,
    );
    _tabProvider!.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabProvider?.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    // Chỉ gọi khi tab thông báo (index 1) được chọn
    if (_tabProvider?.currentIndex == 1) {
      _loadAndMarkRead();
    }
  }

  Future<void> _loadAndMarkRead() async {
    final email = _getEmail();
    if (email == null) return;
    final provider = context.read<NotificationProvider>();
    await provider.fetchNotifications(email);
    await provider.markAllRead(email);
  }

  String? _getEmail() {
    final user = context.read<UserProvider>().user;
    return user?['email'] as String?;
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.isNegative) {
      if (diff.abs().inSeconds < 60) return 'Vừa xong';
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60)
      return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24)
      return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        title: const Text(
          'Thông báo',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3B82F6),
              ),
            );
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 72,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có thông báo nào',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF3B82F6),
            onRefresh: _loadAndMarkRead,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final n = provider.notifications[index];
                return _NotifCard(
                  title: n.title,
                  body: n.body,
                  time: _formatTime(n.createdAt),
                  isRead: n.isRead,
                  image: n.image,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final String? image;

  const _NotifCard({
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color:
            isRead
                ? const Color(0xFF111827)
                : const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isRead
                  ? const Color(0xFF1E293B)
                  : const Color(
                    0xFF3B82F6,
                  ).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color:
                isRead
                    ? const Color(0xFF1E293B)
                    : const Color(
                      0xFF3B82F6,
                    ).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.videocam_rounded,
            color:
                isRead
                    ? Colors.white38
                    : const Color(0xFF3B82F6),
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isRead ? Colors.white60 : Colors.white,
            fontWeight:
                isRead ? FontWeight.w400 : FontWeight.w700,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              body,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              time,
              style: const TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing:
            image != null
                ? const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white38,
                )
                : (isRead
                    ? null
                    : Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                      ),
                    )),
        children: [
          if (image != null && image!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      Uint8List.fromList(
                        base64Decode(image!),
                      ),
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        print('Lỗi: $error');
                        return const Icon(
                          Icons.broken_image,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
