import 'dart:io';

import 'package:camera_app/providers/tab_provider.dart';
import 'package:camera_app/providers/user_provider.dart';
import 'package:camera_app/screens/HomePage/home_wrapper.dart';
import 'package:camera_app/screens/notifications.dart';
import 'package:camera_app/screens/profile.dart';
import 'package:camera_app/services/notification_service.dart';
import 'package:camera_app/services/user_service.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:convex_bottom_bar/convex_bottom_bar.dart';
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
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    if (Platform.isAndroid ||
        (Platform.isIOS && Firebase.apps.isNotEmpty)) {
      final fcmToken = await NotificationService.getToken();
      if (fcmToken != null) {
        await AuthService().saveToken(
          userProvider.getToken(),
          fcmToken,
        );
        userProvider.saveTokenLocal(fcmToken);
      }
      NotificationService.listenTokenRefresh((
        newToken,
      ) async {
        if (userProvider.user != null) {
          await AuthService().saveToken(
            newToken,
            userProvider.user!['email'],
          );
          userProvider.saveTokenLocal(newToken);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _saveToken();
  }

  final List<Widget> _pages = [
    HomeWrapper(),
    NotificationsPage(),
    ProfilePage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabProvider = Provider.of<TabProvider>(context);
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
      ),
    );
  }
}
