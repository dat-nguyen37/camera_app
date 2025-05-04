import 'package:camera_app/screens/HomePage/home_main.dart';
import 'package:camera_app/screens/HomePage/home_wrapper.dart';
import 'package:camera_app/screens/profile.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

class MainPageView extends StatefulWidget {
  MainPageView({super.key});

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  final List<Widget> _pages = [
    HomeWrapper(),
    Homepage(),
    ProfilePage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: ConvexAppBar(
        key: ValueKey(_currentIndex),
        items: [
          TabItem(icon: Icons.home),
          TabItem(icon: Icons.badge_rounded),
          TabItem(icon: Icons.person),
        ],
        color: Colors.white,
        initialActiveIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(index);
          });
        },
      ),
    );
  }
}
