import 'package:camera_app/main.dart' show navigatorKey;
import 'package:camera_app/providers/notification_provider.dart';
import 'package:camera_app/providers/tab_provider.dart';
import 'package:camera_app/providers/user_provider.dart';
import 'package:camera_app/providers/detection_provider.dart';
import 'package:camera_app/routes/app_routes.dart';
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
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
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

  void getDevice() async {
    setState(() => _isLoading = true);
    final result = await _deviceService.getDevice();
    if (!mounted) return;
    if (result.containsKey('error')) {
      setState(() => _isLoading = false);
      _showSnack(result['error'], isError: true);
    } else {
      final data = result['success'] as List;
      final accessToken = Provider.of<UserProvider>(context, listen: false).token ?? '';

      Map<String, int> statuses = {};
      if (accessToken.isNotEmpty) {
        statuses = await _deviceService.getDeviceStatus(accessToken);
      }

      setState(() {
        listCamera..clear()..addAll(data);
        for (var cam in data) {
          final serial = (cam['url'] ?? '').toString().trim().toUpperCase();
          _cameraOnlineStatus[cam['_id']] = statuses[serial] == 1;
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
      });
      getDevice();
      _showSnack(result['success']);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _AppColors.offlineRed : _AppColors.onlineGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accessToken = Provider.of<UserProvider>(context).token ?? '';
    final userName = Provider.of<UserProvider>(context).user?['username'] ?? 'Admin';
    final onlineCount = _cameraOnlineStatus.values.where((v) => v == true).length;

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

  Widget _buildHeader(BuildContext context, String userName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
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
            child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 24),
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
                  ),
                ),
                Text(
                  'Xin chào, $userName',
                  style: const TextStyle(color: _AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          Consumer<NotificationProvider>(
            builder: (context, notifProvider, _) => _IconBtn(
              icon: Icons.notifications_none_rounded,
              badgeCount: notifProvider.unreadCount,
              onTap: () => Provider.of<TabProvider>(context, listen: false).setIndex(1),
            ),
          ),
          const SizedBox(width: 8),
          _IconBtn(icon: Icons.add_rounded, isPrimary: true, onTap: _showAddDeviceDialog),
          const SizedBox(width: 8),
          _IconBtn(
            icon: Icons.logout_rounded,
            onTap: () {
              Provider.of<UserProvider>(context, listen: false).clearUser();
              navigatorKey.currentState?.pushNamedAndRemoveUntil(AppRoute.signin, (route) => false);
            },
          ),
        ],
      ),
    );
  }

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
          _StatItem(label: 'Tổng', value: '$total', color: _AppColors.accentBlue, icon: Icons.devices_rounded),
          _Separator(),
          _StatItem(label: 'Online', value: '$onlineCount', color: _AppColors.onlineGreen, icon: Icons.wifi_rounded),
          _Separator(),
          _StatItem(label: 'Offline', value: '$offline', color: _AppColors.offlineRed, icon: Icons.wifi_off_rounded),
        ],
      ),
    );
  }

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
          itemBuilder: (_, i) => CameraCard(
            item: listCamera[i],
            accessToken: accessToken,
            index: i,
            onDelete: () => _confirmDelete(listCamera[i]['_id']),
          ),
        ),
      ),
    );
  }

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
                spreadRadius: 6,
              ),
            ],
          ),
          child: const Icon(Icons.videocam_off_rounded, size: 48, color: _AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        const Text(
          'Chưa có camera nào',
          style: TextStyle(color: _AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _showAddDeviceDialog,
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: const Text('Thêm camera ngay'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _AppColors.accentBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ],
    ),
  );

  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _AppColors.card,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Thêm Camera Mới', style: TextStyle(color: _AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _inputField(controller: _nameController, label: 'Tên camera', hint: 'Ví dụ: Phòng khách', icon: Icons.drive_file_rename_outline_rounded),
                const SizedBox(height: 16),
                _inputField(controller: _urlController, label: 'Số Serial', hint: 'Ví dụ: C12345678', icon: Icons.qr_code_scanner_rounded),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy', style: TextStyle(color: _AppColors.textSecondary)))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(dialogContext);
                            addDevice();
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: _AppColors.accentBlue, foregroundColor: Colors.white),
                        child: const Text('Thêm'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({required TextEditingController controller, required String label, required String hint, required IconData icon}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: _AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _AppColors.accentBlue),
        filled: true,
        fillColor: _AppColors.inputBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _confirmDelete(String cameraId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _AppColors.card,
        title: const Text('Xóa thiết bị', style: TextStyle(color: _AppColors.textPrimary)),
        content: const Text('Bạn có chắc muốn xóa thiết bị này?', style: TextStyle(color: _AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          TextButton(onPressed: () { Navigator.pop(dialogContext); deleteDevice(cameraId); }, child: const Text('Xóa', style: TextStyle(color: _AppColors.offlineRed))),
        ],
      ),
    );
  }
}

class CameraCard extends StatefulWidget {
  final dynamic item;
  final String accessToken;
  final int index;
  final VoidCallback onDelete;

  const CameraCard({super.key, required this.item, required this.accessToken, required this.index, required this.onDelete});

  @override
  State<CameraCard> createState() => _CameraCardState();
}

class _CameraCardState extends State<CameraCard> {
  int _reloadKey = 0;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _updateStatus();
  }

  void _updateStatus() {
    final parentState = context.findAncestorStateOfType<_HomePageState>();
    if (parentState != null) {
      setState(() {
        _isOnline = parentState._cameraOnlineStatus[widget.item['_id']] == true;
      });
    }
  }

  void _reload() { setState(() { _reloadKey++; }); }

  @override
  Widget build(BuildContext context) {
    _updateStatus();
    final cameraId = widget.item['_id'] as String? ?? '';
    final cameraName = widget.item['name'] as String? ?? 'Camera';
    final cameraSerial = widget.item['url'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(color: _AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: _isOnline ? _AppColors.onlineGreen.withOpacity(0.3) : _AppColors.border)),
      child: Column(
        children: [
          ListTile(
            title: Text(cameraName, style: const TextStyle(color: _AppColors.textPrimary, fontWeight: FontWeight.bold)),
            subtitle: Text(_isOnline ? 'Trực tuyến' : 'Ngoại tuyến', style: TextStyle(color: _isOnline ? _AppColors.onlineGreen : _AppColors.offlineRed, fontSize: 12)),
            trailing: PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'reload') _reload();
                if (v == 'delete') widget.onDelete();
                if (v == 'fullscreen') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => FullscreenCameraPage(
                    cameraId: cameraId,
                    cameraSerial: cameraSerial,
                    cameraName: cameraName,
                    accessToken: widget.accessToken,
                    initialRoi: (widget.item['detection_roi'] as Map<String, dynamic>?) ?? {},
                    isDetectionEnabled: widget.item['is_detection_enabled'] ?? false,
                  )));
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'fullscreen', child: Text('Xem toàn màn hình')),
                const PopupMenuItem(value: 'reload', child: Text('Tải lại')),
                const PopupMenuItem(value: 'delete', child: Text('Xóa')),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildPlayer(cameraSerial, widget.accessToken, _isOnline, _reloadKey),
                  ),
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Consumer<DetectionProvider>(
                          builder: (context, provider, child) {
                            final detection = provider.getDetection(cameraId);
                            if (detection == null) return const SizedBox.shrink();

                            return Stack(
                              children: [
                                Positioned(
                                  left: detection.x * constraints.maxWidth,
                                  top: detection.y * constraints.maxHeight,
                                  width: detection.width * constraints.maxWidth,
                                  height: detection.height * constraints.maxHeight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: _AppColors.accentCyan, width: 1.5),
                                      borderRadius: BorderRadius.circular(2),
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
                                                borderRadius: BorderRadius.circular(2)),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.person_outline_rounded, color: Colors.black, size: 8),
                                                SizedBox(width: 3),
                                                Text('HUMAN',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 8,
                                                        fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer(String cameraSerial, String accessToken, bool isOnline, int reloadKey) {
    if (!isOnline) return Container(color: Colors.black, child: const Center(child: Icon(Icons.wifi_off, color: Colors.white24, size: 40)));
    return EzvizSimplePlayer(
      key: ValueKey('${cameraSerial}_$reloadKey'),
      deviceSerial: cameraSerial,
      channelNo: 1,
      config: EzvizPlayerConfig(
        appKey: 'ca870ed081f24c6d944051ec95c2c361',
        accessToken: accessToken,
        region: EzvizRegion.singapore,
        autoPlay: true,
        showControls: false,
        enableAudio: false,
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;
  final bool isPrimary;
  const _IconBtn({required this.icon, required this.onTap, this.badgeCount = 0, this.isPrimary = false});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Stack(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: isPrimary ? _AppColors.accentBlue : _AppColors.border, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.white, size: 20)), if (badgeCount > 0) Positioned(right: 2, top: 2, child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle), child: Center(child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 9)))))]));
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatItem({required this.label, required this.value, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) => Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 16), const SizedBox(width: 6), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: _AppColors.textSecondary, fontSize: 10))])]));
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 20, color: _AppColors.border);
}

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.6).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          margin: const EdgeInsets.only(bottom: 18),
          height: 250,
          decoration: BoxDecoration(color: _AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: _AppColors.border)),
          child: Column(
            children: [
              const ListTile(title: Text('Loading...', style: TextStyle(color: _AppColors.textSecondary))),
              Expanded(child: Container(decoration: BoxDecoration(color: _AppColors.border.withOpacity(0.5), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))))),
            ],
          ),
        ),
      ),
    );
  }
}
