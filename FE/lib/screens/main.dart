import 'dart:io';

import 'package:camera_app/providers/notification_provider.dart';
import 'package:camera_app/providers/tab_provider.dart';
import 'package:camera_app/providers/user_provider.dart';
import 'package:camera_app/screens/HomePage/home_wrapper.dart';
import 'package:camera_app/screens/notifications.dart';
import 'package:camera_app/services/notification_service.dart';
import 'package:camera_app/services/user_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPageView extends StatefulWidget {
  const MainPageView({super.key});

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {
  late PageController _pageController;

  Future<void> _saveToken() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (Platform.isAndroid ||
        (Platform.isIOS && Firebase.apps.isNotEmpty)) {
      final fcmToken = await NotificationService.getToken();
      if (fcmToken != null) {
        await AuthService().saveToken(userProvider.getToken(), fcmToken);
        userProvider.saveTokenLocal(fcmToken);
      }
      NotificationService.listenTokenRefresh((newToken) async {
        if (userProvider.user != null) {
          await AuthService().saveToken(newToken, userProvider.user!['email']);
          userProvider.saveTokenLocal(newToken);
        }
      });
    }
  }

  void _onTabChanged() {
    final idx = Provider.of<TabProvider>(context, listen: false).currentIndex;
    if (_pageController.hasClients && (_pageController.page?.round() ?? 0) != idx) {
      _pageController.jumpToPage(idx);
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _saveToken();
    // Sync PageController whenever TabProvider index changes from outside
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TabProvider>(context, listen: false).addListener(_onTabChanged);
      final email = Provider.of<UserProvider>(context, listen: false).user?['email'];
      if (email != null) {
        Provider.of<NotificationProvider>(context, listen: false)
            .fetchNotifications(email);
      }
    });
  }

  final List<Widget> _pages = [
    HomeWrapper(),
    NotificationsPage(),
  ];

  @override
  void dispose() {
    Provider.of<TabProvider>(context, listen: false).removeListener(_onTabChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabProvider = Provider.of<TabProvider>(context);
    final unreadCount = context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          tabProvider.setIndex(index);
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabProvider.currentIndex,
        onTap: (int index) {
          tabProvider.setIndex(index);
          _pageController.jumpToPage(index);
        },
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications),
                if (unreadCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Thông báo',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
      ),
    );
  }
}
