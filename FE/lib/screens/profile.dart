import 'package:camera_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<StatefulWidget> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  bool _isSwitched = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        shape: CircleBorder(),
                        foregroundColor: Colors.blue,
                        backgroundColor:
                            const Color.fromARGB(
                              255,
                              228,
                              220,
                              220,
                            ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 30,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            shape: CircleBorder(),
                            foregroundColor: Colors.blue,
                            backgroundColor:
                                const Color.fromARGB(
                                  255,
                                  228,
                                  220,
                                  220,
                                ),
                          ),
                          child: Icon(Icons.add, size: 30),
                        ),
                        Stack(
                          children: [
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                shape: CircleBorder(),
                                foregroundColor:
                                    Colors.blue,
                                backgroundColor:
                                    const Color.fromARGB(
                                      255,
                                      228,
                                      220,
                                      220,
                                    ),
                              ),
                              child: Icon(
                                Icons.notifications_none,
                                size: 30,
                              ),
                            ),
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color:
                                      Colors.orangeAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          48,
                        ),
                        child: Image.asset(
                          'assets/images/download.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${user?['name'] ?? 'Chưa có tên'}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${user?['email'] ?? 'Chưa có email'}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.edit),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color.fromARGB(
                        255,
                        209,
                        203,
                        203,
                      ), // Màu viền
                      width: 1, // Độ dày viền
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          48,
                        ),
                        child: Icon(
                          Icons.change_circle_sharp,
                          size: 40,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                          child: Text(
                            'Change camera',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_forward_ios),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color.fromARGB(
                        255,
                        209,
                        203,
                        203,
                      ), // Màu viền
                      width: 1, // Độ dày viền
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          48,
                        ),
                        child: Icon(
                          Icons.notifications_sharp,
                          size: 40,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                          child: Text(
                            'Notifications',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Switch(
                        value: _isSwitched,
                        onChanged: (bool value) {
                          setState(() {
                            _isSwitched = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color.fromARGB(
                        255,
                        209,
                        203,
                        203,
                      ), // Màu viền
                      width: 1, // Độ dày viền
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          48,
                        ),
                        child: Icon(
                          Icons.shopping_cart,
                          size: 40,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                          child: Text(
                            'By pro version',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_forward_ios),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color.fromARGB(
                        255,
                        209,
                        203,
                        203,
                      ), // Màu viền
                      width: 1, // Độ dày viền
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          48,
                        ),
                        child: Icon(
                          Icons.contact_support,
                          size: 40,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                          child: Text(
                            'Support',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_forward_ios),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color.fromARGB(
                        255,
                        209,
                        203,
                        203,
                      ), // Màu viền
                      width: 1, // Độ dày viền
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          48,
                        ),
                        child: Icon(Icons.error, size: 40),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                          child: Text(
                            'About us',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_forward_ios),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
