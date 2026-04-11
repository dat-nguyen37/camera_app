import 'package:flutter/material.dart';
import 'dart:async';

class DetectionBox {
  final double x;
  final double y;
  final double width;
  final double height;
  final String cameraId;
  final DateTime timestamp;

  DetectionBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.cameraId,
    required this.timestamp,
  });
}

class DetectionProvider with ChangeNotifier {
  Map<String, DetectionBox?> _detections = {};
  Map<String, Timer?> _timers = {};

  DetectionBox? getDetection(String cameraId) => _detections[cameraId];

  void updateDetection(String cameraId, double x, double y, double w, double h) {
    // Cancel old timer if exists
    _timers[cameraId]?.cancel();

    _detections[cameraId] = DetectionBox(
      x: x,
      y: y,
      width: w,
      height: h,
      cameraId: cameraId,
      timestamp: DateTime.now(),
    );
    notifyListeners();

    // Clear detection after 3 seconds
    _timers[cameraId] = Timer(const Duration(seconds: 3), () {
      _detections[cameraId] = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    for (var timer in _timers.values) {
      timer?.cancel();
    }
    super.dispose();
  }
}
