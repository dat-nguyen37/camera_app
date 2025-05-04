import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class FullscreenCameraPage extends StatefulWidget {
  final String streamUrl;

  const FullscreenCameraPage({
    super.key,
    required this.streamUrl,
  });

  @override
  State<FullscreenCameraPage> createState() =>
      _FullscreenCameraPageState();
}

class _FullscreenCameraPageState
    extends State<FullscreenCameraPage> {
  @override
  void initState() {
    super.initState();
    // Ép xoay ngang
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    // Ẩn status bar và navigation bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  @override
  void dispose() {
    // Trả lại chế độ dọc khi thoát
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Mjpeg(
              stream: widget.streamUrl,
              isLive: true,
              fit: BoxFit.contain,
              error: (context, error, stack) {
                return Container(
                  color: Colors.black12,
                  height: 200,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    'Không thể kết nối tới thiết bị',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 32,
            left: 16,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
