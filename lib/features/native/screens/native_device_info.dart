import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class NativeDeviceInfoScreen extends StatefulWidget {
  const NativeDeviceInfoScreen({super.key, required this.title});
  final String title;

  @override
  State<NativeDeviceInfoScreen> createState() => _NativeDeviceInfoScreenState();
}

class _NativeDeviceInfoScreenState extends State<NativeDeviceInfoScreen> with SingleTickerProviderStateMixin {
  static const MethodChannel _channel = MethodChannel('device_info_channel');

  Map<String, dynamic>? _deviceInfo;
  bool _loading = true;
  String? _error;
  DateTime? _lastRefreshedAt;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _handlePermissionAndFetch();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// ─────────────────────────────────────────────
  /// Permission → Native Fetch
  /// ─────────────────────────────────────────────
  Future<void> _handlePermissionAndFetch() async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      _fetchNativeInfo();
      return;
    }

    if (status.isPermanentlyDenied) {
      setState(() {
        _loading = false;
        _error = 'Location permission permanently denied.\nPlease enable it from Settings.';
      });
      await openAppSettings();
      return;
    }

    final requestStatus = await Permission.location.request();
    if (requestStatus.isGranted) {
      _fetchNativeInfo();
    } else {
      setState(() {
        _loading = false;
        _error = 'Location permission denied.';
      });
    }
  }

  Future<void> _fetchNativeInfo() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('getDeviceAndAppInfo');

      _animController.reset();

      setState(() {
        _deviceInfo = Map<String, dynamic>.from(result);
        _lastRefreshedAt = DateTime.now();
        _loading = false;
        _error = null;
      });

      _animController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// ─────────────────────────────────────────────
  /// UI HELPERS
  /// ─────────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lastRefreshedText() {
    if (_lastRefreshedAt == null) return const SizedBox.shrink();

    final t = _lastRefreshedAt!;
    final time =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
    final date = '${t.day.toString().padLeft(2, '0')}-${t.month.toString().padLeft(2, '0')}-${t.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('Last refreshed at $time • $date', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
    );
  }

  /// ─────────────────────────────────────────────
  /// BUILD
  /// ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              ),
            )
          : RefreshIndicator(
              onRefresh: _handlePermissionAndFetch,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        _lastRefreshedText(),

                        _sectionHeader('App Information'),
                        _infoCard(Icons.apps, 'Package ID', _deviceInfo!['packageId'] ?? ''),
                        _infoCard(Icons.system_update, 'App Version', _deviceInfo!['appVersion'] ?? ''),
                        _infoCard(Icons.build_circle, 'Build Number', _deviceInfo!['buildNumber'] ?? ''),

                        const SizedBox(height: 16),

                        _sectionHeader('Device Information'),
                        _infoCard(Icons.phone_android, 'Device Model', _deviceInfo!['deviceModel'] ?? ''),
                        _infoCard(Icons.business, 'Manufacturer', _deviceInfo!['deviceManufacturer'] ?? ''),
                        _infoCard(Icons.android, 'Android Version', _deviceInfo!['androidVersion'] ?? ''),
                        _infoCard(Icons.memory, 'Android SDK', _deviceInfo!['androidSdk'] ?? ''),
                        _infoCard(Icons.fingerprint, 'Device ID', _deviceInfo!['deviceId'] ?? ''),

                        const SizedBox(height: 16),

                        _sectionHeader('Location'),
                        _infoCard(Icons.location_on, 'Latitude', _deviceInfo!['latitude'] ?? ''),
                        _infoCard(Icons.location_on_outlined, 'Longitude', _deviceInfo!['longitude'] ?? ''),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
