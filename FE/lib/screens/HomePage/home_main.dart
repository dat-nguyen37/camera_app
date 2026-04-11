import 'package:camera_app/providers/tab_provider.dart';
import 'package:camera_app/providers/user_provider.dart';
import 'package:camera_app/providers/detection_provider.dart';
import 'package:camera_app/screens/HomePage/full_screen.dart';
import 'package:camera_app/services/device_service.dart';
import 'package:ezviz_flutter/ezviz_flutter.dart' hide DeviceService;
import 'package:ezviz_flutter/widgets/ezviz_simple_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class _AppColors {
  static const Color bg = Color(0xFF0A0E1A);
  static const Color card = Color(0xFF111827);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color onlineGreen = Color(0xFF22C55E);
  static const Color offlineRed = Color(0xFFEF4444);
  static const Color border = Color(0xFF1E293B);
  static const Color inputBg = Color(0xFF0F172A);
}

// ─── Homepage Widget ──────────────────────────────────────────────────────────
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<Homepage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final DeviceService _deviceService = DeviceService();
  final _formKey = GlobalKey<FormState>();
  final List<dynamic> listCamera = [];

  Map<String, bool> _cameraOnlineStatus = {};
  Map<String, String> _cameraErrors = {};
  Map<String, int> _cameraKeyId = {};
  bool _isLoading = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    getDevice();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    _urlController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ─── API Calls ──────────────────────────────────────────────────────────────
  void getDevice() async {
    setState(() => _isLoading = true);
    final result = await _deviceService.getDevice();
    if (!mounted) return;
    if (result.containsKey('error')) {
      setState(() => _isLoading = false);
      _showSnack(result['error'], isError: true);
    } else {
      final data = result['success'] as List;
      setState(() {
        listCamera
          ..clear()
          ..addAll(data);
        for (var cam in data) {
          _cameraOnlineStatus[cam['_id']] = false;
        }
        _isLoading = false;
      });
      _fadeController.forward(from: 0);
    }
  }

  void addDevice() async {
    final result = await _deviceService.create(
      _nameController.text.trim(),
      _urlController.text.trim(),
    );
    if (!mounted) return;
    if (result.containsKey('error')) {
      _showSnack(result['error'], isError: true);
    } else {
      getDevice();
      _showSnack(result['success']);
      _nameController.clear();
      _urlController.clear();
    }
  }

  void deleteDevice(String id) async {
    final result = await _deviceService.delete(id);
    if (!mounted) return;
    if (result.containsKey('error')) {
      _showSnack(result['error'], isError: true);
    } else {
      setState(() {
        _cameraOnlineStatus.remove(id);
        _cameraErrors.remove(id);
      });
      getDevice();
      _showSnack(result['success']);
    }
  }

  void _reloadCamera(String id) {
    setState(() {
      _cameraKeyId[id] = (_cameraKeyId[id] ?? 0) + 1;
      _cameraOnlineStatus[id] = false;
      _cameraErrors.remove(id);
    });
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? _AppColors.offlineRed : _AppColors.onlineGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _openFullscreen(
      String cameraId, String cameraSerial, String cameraName) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final accessToken = user?['accessToken'] ?? '';
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => FullscreenCameraPage(
          cameraId: cameraId,
          cameraSerial: cameraSerial,
          cameraName: cameraName,
          accessToken: accessToken,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final accessToken = Provider.of<UserProvider>(context).token ?? '';
    final userName =
        Provider.of<UserProvider>(context).user?['username'] ?? 'Admin';
    final onlineCount =
        _cameraOnlineStatus.values.where((v) => v == true).length;

    return Scaffold(
      backgroundColor: _AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, userName),
            _buildStatsBar(onlineCount),
            Expanded(
              child: _isLoading
                  ? _buildShimmerList()
                  : listCamera.isEmpty
                      ? _buildEmptyState()
                      : _buildCameraList(accessToken),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, String userName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          // App logo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_AppColors.accentBlue, _AppColors.accentCyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: _AppColors.accentBlue.withOpacity(0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.videocam_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Camera Monitor',
                  style: TextStyle(
                    color: _AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'Xin chào, $userName',
                  style: const TextStyle(
                      color: _AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          // Notification
          _IconBtn(
            icon: Icons.notifications_none_rounded,
            badge: true,
            onTap: () =>
                Provider.of<TabProvider>(context, listen: false).setIndex(1),
          ),
          const SizedBox(width: 8),
          // Add device
          _IconBtn(
            icon: Icons.add_rounded,
            isPrimary: true,
            onTap: _showAddDeviceDialog,
          ),
        ],
      ),
    );
  }

  // ─── Stats Bar ───────────────────────────────────────────────────────────────
  Widget _buildStatsBar(int onlineCount) {
    final total = listCamera.length;
    final offline = total - onlineCount;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _AppColors.border,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _StatItem(
              label: 'Tổng',
              value: '$total',
              color: _AppColors.accentBlue,
              icon: Icons.devices_rounded),
          _Separator(),
          _StatItem(
              label: 'Online',
              value: '$onlineCount',
              color: _AppColors.onlineGreen,
              icon: Icons.wifi_rounded),
          _Separator(),
          _StatItem(
              label: 'Offline',
              value: '$offline',
              color: _AppColors.offlineRed,
              icon: Icons.wifi_off_rounded),
        ],
      ),
    );
  }

  // ─── Camera List ─────────────────────────────────────────────────────────────
  Widget _buildCameraList(String accessToken) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: () async => getDevice(),
        color: _AppColors.accentBlue,
        backgroundColor: _AppColors.card,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: listCamera.length,
          itemBuilder: (_, i) =>
              _buildCameraCard(listCamera[i], accessToken, i),
        ),
      ),
    );
  }

  // ─── Camera Card ─────────────────────────────────────────────────────────────
  Widget _buildCameraCard(dynamic item, String accessToken, int index) {
    final cameraId = item['_id'] as String? ?? '';
    final cameraName = item['name'] as String? ?? 'Camera ${index + 1}';
    final cameraSerial = item['url'] as String? ?? '';
    final isOnline = _cameraOnlineStatus[cameraId] == true;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: _AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOnline
              ? _AppColors.onlineGreen.withOpacity(0.35)
              : _AppColors.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
          if (isOnline)
            BoxShadow(
              color: _AppColors.onlineGreen.withOpacity(0.07),
              blurRadius: 22,
              spreadRadius: 3,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 8),
            child: Row(
              children: [
                // Index badge
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _AppColors.accentBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                        color: _AppColors.accentBlue.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: _AppColors.accentCyan,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cameraName,
                        style: const TextStyle(
                          color: _AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? _AppColors.onlineGreen
                                  : _AppColors.offlineRed,
                              shape: BoxShape.circle,
                              boxShadow: isOnline
                                  ? [
                                      BoxShadow(
                                          color: _AppColors.onlineGreen
                                              .withOpacity(0.6),
                                          blurRadius: 6,
                                          spreadRadius: 1)
                                    ]
                                  : [],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOnline ? 'Trực tuyến' : 'Ngoại tuyến',
                            style: TextStyle(
                              color: isOnline
                                  ? _AppColors.onlineGreen
                                  : _AppColors.offlineRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _reloadCamera(cameraId),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _AppColors.border.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.refresh_rounded, color: _AppColors.textSecondary, size: 12),
                                  SizedBox(width: 4),
                                  Text('Tải lại', style: TextStyle(color: _AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Context menu
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'fullscreen')
                      _openFullscreen(cameraId, cameraSerial, cameraName);
                    if (v == 'reload') _reloadCamera(cameraId);
                    if (v == 'delete') _confirmDelete(cameraId);
                  },
                  color: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  icon: const Icon(Icons.more_vert_rounded,
                      color: _AppColors.textSecondary, size: 22),
                  itemBuilder: (_) => [
                    _popupItem(
                        'fullscreen',
                        Icons.fullscreen_rounded,
                        'Xem toàn màn hình',
                        _AppColors.accentBlue),
                    _popupItem('reload', Icons.refresh_rounded, 'Khởi động lại',
                        _AppColors.onlineGreen),
                    const PopupMenuDivider(),
                    _popupItem('delete', Icons.delete_outline_rounded,
                        'Xóa thiết bị', _AppColors.offlineRed),
                  ],
                ),
              ],
            ),
          ),

          // ── Video Preview ────────────────────────────────────────────
          GestureDetector(
            onTap: () => _openFullscreen(cameraId, cameraSerial, cameraName),
            child: SizedBox(
              height: 210,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Stack(
                  children: [
                    // 1. Lớp Video (Cố định, không rebuild)
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: _buildPlayer(cameraId, cameraSerial, accessToken),
                      ),
                    ),

                    // 2. Lớp Overlay vẽ khung (Chỉ lớp này rebuild)
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack( // Thêm Stack ở đây để Positioned hoạt động đúng
                            children: [
                              Consumer<DetectionProvider>(
                                builder: (context, provider, child) {
                                  final detection = provider.getDetection(cameraId);
                                  if (detection == null) return const SizedBox.shrink();

                                  final left = detection.x * constraints.maxWidth;
                                  final top = detection.y * constraints.maxHeight;
                                  final width = detection.width * constraints.maxWidth;
                                  final height = detection.height * constraints.maxHeight;

                                  return Positioned(
                                    left: left,
                                    top: top,
                                    width: width,
                                    height: height,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _AppColors.accentCyan,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _AppColors.accentCyan.withOpacity(0.3),
                                            blurRadius: 4,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned(
                                            top: -18,
                                            left: -1,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: _AppColors.accentCyan,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.person_outline_rounded, color: Colors.black, size: 8),
                                                  SizedBox(width: 3),
                                                  Text(
                                                    'HUMAN',
                                                    style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // 3. Gợi ý chạm (Tap hint)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.open_in_full_rounded, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text('Tap để phóng to', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _popupItem(
      String value, IconData icon, String label, Color color) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(children: [
        Icon(icon, color: color, size: 19),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
                color: value == 'delete'
                    ? _AppColors.offlineRed
                    : _AppColors.textPrimary,
                fontSize: 14)),
      ]),
    );
  }

  // ─── Player ──────────────────────────────────────────────────────────────────
  Widget _buildPlayer(
      String cameraId, String cameraSerial, String accessToken) {
    if (cameraSerial.isEmpty) {
      return _errorBox('Chưa có serial camera', Icons.link_off_rounded);
    }
    if (accessToken.isEmpty) {
      return _errorBox('Chưa đăng nhập', Icons.lock_outline_rounded);
    }
    return EzvizSimplePlayer(
      key: ValueKey('${cameraId}_${_cameraKeyId[cameraId] ?? 0}'),
      deviceSerial: cameraSerial,
      channelNo: 1,
      config: EzvizPlayerConfig(
        appKey: 'ca870ed081f24c6d944051ec95c2c361',
        accessToken: accessToken,
        region: EzvizRegion.singapore,
        autoPlay: true,
        showControls: true,
        compactControls: true,
        enableAudio: false,
        enableEncryptionDialog: false,
      ),
      onStateChanged: (state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _cameraOnlineStatus[cameraId] =
                  state == EzvizSimplePlayerState.playing;
              if (state == EzvizSimplePlayerState.playing) {
                _cameraErrors[cameraId] = '';
              }
            });
          }
        });
      },
      onError: (error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _cameraOnlineStatus[cameraId] = false;
              _cameraErrors[cameraId] = error;
            });
          }
        });
      },
    );
  }

  Widget _errorBox(String msg, IconData icon) => Container(
        color: const Color(0xFF0D1117),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: _AppColors.offlineRed.withOpacity(0.7), size: 36),
              const SizedBox(height: 8),
              Text(msg,
                  style: const TextStyle(
                      color: _AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      );

  // ─── Loading / Empty ─────────────────────────────────────────────────────────
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: 3,
      itemBuilder: (_, __) => const _ShimmerCard(),
    );
  }

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _AppColors.border,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: _AppColors.accentBlue.withOpacity(0.12),
                      blurRadius: 30,
                      spreadRadius: 6)
                ],
              ),
              child: const Icon(Icons.videocam_off_rounded,
                  size: 48, color: _AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            const Text('Chưa có camera nào',
                style: TextStyle(
                    color: _AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
              'Thêm camera đầu tiên để bắt đầu\ngiám sát hệ thống của bạn',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _AppColors.textSecondary, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _showAddDeviceDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_AppColors.accentBlue, _AppColors.accentCyan]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: _AppColors.accentBlue.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Thêm camera ngay',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  // ─── Dialogs ─────────────────────────────────────────────────────────────────
  void _showAddDeviceDialog() {
    _nameController.clear();
    _urlController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _AppColors.border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10))
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: _AppColors.accentBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.add_to_queue_rounded,
                        color: _AppColors.accentBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text('Thêm thiết bị mới',
                      style: TextStyle(
                          color: _AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 22),
                _inputField(
                  controller: _nameController,
                  label: 'Tên thiết bị',
                  hint: 'VD: Camera cổng chính',
                  icon: Icons.label_outline_rounded,
                  validator: (v) =>
                      (v?.trim().isEmpty ?? true) ? 'Nhập tên thiết bị' : null,
                ),
                const SizedBox(height: 14),
                _inputField(
                  controller: _urlController,
                  label: 'Serial camera',
                  hint: 'VD: BG4803044',
                  icon: Icons.qr_code_2_rounded,
                  helper: 'Serial EZVIZ (9–10 ký tự)',
                  validator: (v) =>
                      (v?.trim().isEmpty ?? true) ? 'Nhập serial camera' : null,
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side:
                                const BorderSide(color: _AppColors.border)),
                      ),
                      child: const Text('Hủy',
                          style: TextStyle(color: _AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          addDevice();
                          Navigator.of(dialogContext).pop();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            _AppColors.accentBlue,
                            _AppColors.accentCyan
                          ]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: _AppColors.accentBlue.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: const Center(
                          child: Text('Thêm thiết bị',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? helper,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: _AppColors.textPrimary, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        labelStyle:
            const TextStyle(color: _AppColors.textSecondary, fontSize: 13),
        hintStyle: TextStyle(
            color: _AppColors.textSecondary.withOpacity(0.45), fontSize: 13),
        helperStyle:
            const TextStyle(color: _AppColors.textSecondary, fontSize: 11),
        prefixIcon:
            Icon(icon, color: _AppColors.accentBlue, size: 20),
        filled: true,
        fillColor: _AppColors.inputBg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: _AppColors.accentBlue, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _AppColors.offlineRed)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: _AppColors.offlineRed, width: 1.5)),
      ),
    );
  }

  void _confirmDelete(String cameraId) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: _AppColors.offlineRed.withOpacity(0.3), width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: _AppColors.offlineRed.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.delete_forever_rounded,
                    color: _AppColors.offlineRed, size: 36),
              ),
              const SizedBox(height: 16),
              const Text('Xóa thiết bị',
                  style: TextStyle(
                      color: _AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Bạn có chắc muốn xóa thiết bị này?\nHành động này không thể hoàn tác.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                              const BorderSide(color: _AppColors.border)),
                    ),
                    child: const Text('Hủy',
                        style:
                            TextStyle(color: _AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      deleteDevice(cameraId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _AppColors.offlineRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Xóa',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;
  final bool isPrimary;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.badge = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: isPrimary
                  ? const LinearGradient(
                      colors: [_AppColors.accentBlue, _AppColors.accentCyan],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight)
                  : null,
              color: isPrimary ? null : _AppColors.border,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                          color: _AppColors.accentBlue.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ]
                  : null,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          if (badge)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                    color: Color(0xFFF97316), shape: BoxShape.circle),
                child: const Center(
                  child: Text('3',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1)),
                Text(label,
                    style: const TextStyle(
                        color: _AppColors.textSecondary, fontSize: 10)),
              ],
            ),
          ],
        ),
      );
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: _AppColors.border.withOpacity(0.6));
}

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.65).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          margin: const EdgeInsets.only(bottom: 18),
          height: 270,
          decoration: BoxDecoration(
            color: _AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _AppColors.border),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                          color: _AppColors.border,
                          borderRadius: BorderRadius.circular(9))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 13,
                              width: 130,
                              color: _AppColors.border),
                          const SizedBox(height: 6),
                          Container(
                              height: 10, width: 70, color: _AppColors.border),
                        ]),
                  ),
                ]),
              ),
              Expanded(
                child: Container(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                        color: _AppColors.border.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
