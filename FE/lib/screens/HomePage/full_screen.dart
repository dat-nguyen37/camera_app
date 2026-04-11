import 'package:ezviz_flutter/ezviz_flutter.dart';
import 'package:ezviz_flutter/widgets/ezviz_simple_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullscreenCameraPage extends StatefulWidget {
  final String cameraId;
  final String cameraSerial;
  final String cameraName;
  final String accessToken;

  const FullscreenCameraPage({
    super.key,
    required this.cameraId,
    required this.cameraSerial,
    required this.cameraName,
    required this.accessToken,
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
          // Camera chiếm toàn bộ màn hình
          Positioned.fill(
            child: EzvizSimplePlayer(
              deviceSerial: widget.cameraSerial,
              channelNo: 1,
              config: EzvizPlayerConfig(
                appKey: 'ca870ed081f24c6d944051ec95c2c361',
                accessToken: widget.accessToken,
                region: EzvizRegion.singapore,
                autoPlay: true,
                showControls: false, // Ẩn controls mặc định
                enableAudio: true,
                enableEncryptionDialog: false,
              ),
              onStateChanged: (state) {
                print('Fullscreen Camera state: $state');
              },
              onError: (error) {
                print('Fullscreen Camera error: $error');
              },
            ),
          ),

          // Nút back - nổi trên camera
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

          // Tên camera ở góc trên
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.cameraName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
