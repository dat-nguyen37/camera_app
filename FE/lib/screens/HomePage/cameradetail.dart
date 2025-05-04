import 'package:camera_app/routes/app_routes.dart';
import 'package:camera_app/screens/HomePage/full_screen.dart';
import 'package:camera_app/screens/HomePage/home_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class CameraDetail extends StatefulWidget {
  final String streamUrl;
  const CameraDetail({super.key, required this.streamUrl});

  @override
  State<StatefulWidget> createState() => _CameraDetail();
}

class _CameraDetail extends State<CameraDetail> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
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
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (
                                    BuildContext context,
                                  ) {
                                    return AlertDialog(
                                      content: Text(
                                        "Tính năng đang phát triển",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(
                                              context,
                                            ).pop();
                                          },
                                          child: Text("Ok"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
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
              ),
              SizedBox(height: 32),
              Text(
                'Living room',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 32),
              Stack(
                children: [
                  Mjpeg(
                    stream: widget.streamUrl,
                    isLive: true,
                    fit: BoxFit.cover,
                    height: 300,
                    error: (context, error, stack) {
                      return Container(
                        color: Colors.black12,
                        height: 200,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          'Không thể kết nối tới thiết bị',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          HomeRoutes.fullscreen,
                          arguments: widget.streamUrl,
                        );
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey
                            .withOpacity(0.5),
                      ),
                      icon: Icon(
                        Icons.fullscreen_sharp,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey
                            .withOpacity(0.3),
                      ),
                      icon: Icon(Icons.videocam, size: 30),
                    ),
                    IconButton(
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey
                            .withOpacity(0.3),
                      ),
                      icon: Icon(Icons.mic, size: 30),
                    ),
                    IconButton(
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey
                            .withOpacity(0.3),
                      ),
                      icon: Icon(
                        Icons.location_searching,
                        size: 30,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey
                            .withOpacity(0.3),
                      ),
                      icon: Icon(
                        Icons.wifi_sharp,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey
                            .withOpacity(0.3),
                      ),
                      icon: Icon(
                        Icons.music_note,
                        size: 30,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey
                            .withOpacity(0.3),
                      ),
                      icon: Icon(
                        Icons.flashlight_on_sharp,
                        size: 30,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey
                            .withOpacity(0.3),
                      ),
                      icon: Icon(Icons.dark_mode, size: 30),
                    ),
                    IconButton(
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey
                            .withOpacity(0.3),
                      ),
                      icon: Icon(
                        Icons.volume_mute_outlined,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
