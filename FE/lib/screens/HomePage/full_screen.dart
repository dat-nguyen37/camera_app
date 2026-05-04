import 'package:camera_app/providers/user_provider.dart';
import 'package:camera_app/services/device_service.dart';
import 'package:camera_app/services/history_service.dart';
import 'package:ezviz_flutter/ezviz_flutter.dart' hide DeviceService;
import 'package:ezviz_flutter/widgets/ezviz_simple_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class FullscreenCameraPage extends StatefulWidget {
  final String cameraId;
  final String cameraSerial;
  final String cameraName;
  final String accessToken;
  final Map<String, dynamic> initialRoi;
  final bool isDetectionEnabled;

  const FullscreenCameraPage({
    super.key,
    required this.cameraId,
    required this.cameraSerial,
    required this.cameraName,
    required this.accessToken,
    required this.initialRoi,
    required this.isDetectionEnabled,
  });

  @override
  State<FullscreenCameraPage> createState() => _FullscreenCameraPageState();
}

class _FullscreenCameraPageState extends State<FullscreenCameraPage> {
  final HistoryService _historyService = HistoryService();
  List<dynamic> _notifications = [];
  bool _isLoadingNotif = false;
  DateTime _selectedDate = DateTime.now();

  // ROI State
  late double _roiX;
  late double _roiY;
  late double _roiWidth;
  late double _roiHeight;
  late bool _isDetectionEnabled;
  bool _isEditingRoi = false;
  final DeviceService _deviceService = DeviceService();

  @override
  void initState() {
    super.initState();
    // Cho phép cả dọc và ngang, nhưng mặc định khi vào là dọc
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _fetchHistory();
    // Initialize ROI from props
    _roiX = (widget.initialRoi['x'] ?? 0).toDouble();
    _roiY = (widget.initialRoi['y'] ?? 0).toDouble();
    _roiWidth = (widget.initialRoi['width'] ?? 100).toDouble();
    _roiHeight = (widget.initialRoi['height'] ?? 100).toDouble();
    _isDetectionEnabled = widget.isDetectionEnabled;
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoadingNotif = true);
    final email =
        Provider.of<UserProvider>(context, listen: false).user?['email'] ?? '';
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final result = await _historyService.getCameraHistory(
      email,
      widget.cameraId,
      date: dateStr,
    );

    if (mounted) {
      setState(() {
        if (result.containsKey('success')) {
          _notifications = result['success'];
        }
        _isLoadingNotif = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              surface: Color(0xFF111827),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _fetchHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: isLandscape
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF111827),
              elevation: 0,
              title: Text(
                widget.cameraName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: SafeArea(
        child: Column(
          children: [
            // Camera Player
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  EzvizSimplePlayer(
                    deviceSerial: widget.cameraSerial,
                    channelNo: 1,
                    config: EzvizPlayerConfig(
                      appKey: 'ca870ed081f24c6d944051ec95c2c361',
                      accessToken: widget.accessToken,
                      region: EzvizRegion.singapore,
                      autoPlay: true,
                      showControls: true,
                      compactControls: true,
                      enableAudio: true,
                      enableEncryptionDialog: false,
                    ),
                  ),
                  if (isLandscape)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  
                  // ROI Overlay
                  _buildRoiOverlay(),
                ],
              ),
            ),
            if (!isLandscape) ...[
              if (!_isEditingRoi) ...[
                _buildOptionTabs(),
                _buildFilterBar(),
              ],

              // Content based on selection
              Expanded(
                child: _isEditingRoi
                    ? _buildRoiControls()
                    : (_isLoadingNotif
                        ? const Center(child: CircularProgressIndicator())
                        : _notifications.isEmpty
                            ? _buildEmptyState()
                            : _buildNotificationList()),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoiOverlay() {
    if (!_isDetectionEnabled && !_isEditingRoi) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final pxX = (_roiX / 100) * constraints.maxWidth;
        final pxY = (_roiY / 100) * constraints.maxHeight;
        final pxW = (_roiWidth / 100) * constraints.maxWidth;
        final pxH = (_roiHeight / 100) * constraints.maxHeight;

        return Stack(
          children: [
            Positioned(
              left: pxX,
              top: pxY,
              child: GestureDetector(
                onPanUpdate: _isEditingRoi
                    ? (details) {
                        setState(() {
                          _roiX += (details.delta.dx / constraints.maxWidth) * 100;
                          _roiY += (details.delta.dy / constraints.maxHeight) * 100;
                          _roiX = _roiX.clamp(0.0, 100.0 - _roiWidth);
                          _roiY = _roiY.clamp(0.0, 100.0 - _roiHeight);
                        });
                      }
                    : null,
                child: Container(
                  width: pxW,
                  height: pxH,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isEditingRoi ? Colors.yellow : Colors.blue.withOpacity(0.5),
                      width: 2,
                    ),
                    color: (_isEditingRoi ? Colors.yellow : Colors.blue).withOpacity(0.2),
                  ),
                  child: _isEditingRoi
                      ? Stack(
                          children: [
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    _roiWidth += (details.delta.dx / constraints.maxWidth) * 100;
                                    _roiHeight += (details.delta.dy / constraints.maxHeight) * 100;
                                    _roiWidth = _roiWidth.clamp(10.0, 100.0 - _roiX);
                                    _roiHeight = _roiHeight.clamp(10.0, 100.0 - _roiY);
                                  });
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.yellow,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.open_in_full_rounded, size: 14, color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionTabs() {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              icon: Icons.notifications_active_rounded,
              label: "Cảnh báo",
              isActive: true,
            ),
          ),
          VerticalDivider(color: Colors.white.withOpacity(0.1), width: 1, indent: 15, endIndent: 15),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isEditingRoi = true),
              child: _buildTabItem(
                icon: Icons.crop_free_rounded,
                label: "Vùng nhận diện",
                isActive: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({required IconData icon, required String label, required bool isActive}) {
    return Container(
      decoration: BoxDecoration(
        border: isActive ? const Border(bottom: BorderSide(color: Color(0xFF3B82F6), width: 2)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: isActive ? const Color(0xFF3B82F6) : Colors.white54),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white54,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoiControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF0A0E1A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Cài đặt vùng nhận diện",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Kéo khung trên video để di chuyển, dùng nút góc dưới bên phải để thay đổi kích thước.",
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person_search_rounded, color: Colors.blue, size: 20),
                    SizedBox(width: 12),
                    Text(
                      "Bật nhận diện người",
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Switch(
                  value: _isDetectionEnabled,
                  onChanged: (val) => setState(() => _isDetectionEnabled = val),
                  activeColor: const Color(0xFF3B82F6),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditingRoi = false;
                      _roiX = (widget.initialRoi['x'] ?? 0).toDouble();
                      _roiY = (widget.initialRoi['y'] ?? 0).toDouble();
                      _roiWidth = (widget.initialRoi['width'] ?? 100).toDouble();
                      _roiHeight = (widget.initialRoi['height'] ?? 100).toDouble();
                      _isDetectionEnabled = widget.isDetectionEnabled;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text("Hủy", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveRoi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text("Lưu thay đổi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveRoi() async {
    final result = await _deviceService.updateROI(
      widget.cameraId,
      x: _roiX,
      y: _roiY,
      width: _roiWidth,
      height: _roiHeight,
      isDetectionEnabled: _isDetectionEnabled,
    );

    if (mounted) {
      if (result.containsKey('success')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['success']), backgroundColor: Colors.green),
        );
        setState(() => _isEditingRoi = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error']), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded,
                  color: Color(0xFF3B82F6), size: 18),
              const SizedBox(width: 8),
              const Text(
                'Lịch sử thông báo',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: Colors.white70, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final item = _notifications[index];
        final time = (DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now()).toLocal();
        final timeStr = DateFormat('HH:mm:ss').format(time);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFEF4444), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] ?? 'Cảnh báo',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['body'] ?? 'Phát hiện có người!',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                timeStr,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 48, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text(
            'Không có thông báo nào trong ngày này',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
