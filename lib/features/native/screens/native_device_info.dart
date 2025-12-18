import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device_info_state.dart';
import '../providers/device_info_provider.dart';
import '../widgets/workbench_app_bar.dart';

class NativeDeviceInfoScreen extends ConsumerStatefulWidget {
  const NativeDeviceInfoScreen({super.key, required this.title});
  final String title;

  @override
  ConsumerState<NativeDeviceInfoScreen> createState() => _NativeDeviceInfoScreenState();
}

class _NativeDeviceInfoScreenState extends ConsumerState<NativeDeviceInfoScreen> with SingleTickerProviderStateMixin {
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

    Future.microtask(() {
      ref.read(deviceInfoProvider.notifier).fetch();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DeviceInfoState state = ref.watch(deviceInfoProvider);

    ref.listen(deviceInfoProvider, (_, DeviceInfoState next) {
      if (!next.loading && next.error == null) {
        _animController
          ..reset()
          ..forward();
      }
    });

    return Scaffold(
      appBar: const WorkbenchAppBar(title: 'Device Info'),

      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(state.error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(deviceInfoProvider.notifier).fetch(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(position: _slideAnim, child: _DeviceInfoView(state)),
                ),
              ),
            ),
    );
  }
}

class _DeviceInfoView extends StatelessWidget {
  const _DeviceInfoView(this.state);

  final DeviceInfoState state;

  Map<String, dynamic> get _data => state.data ?? const <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        _sectionHeader('App Information'),
        _infoCard(context, Icons.apps, 'Package ID', _data['packageId']),
        _infoCard(context, Icons.system_update, 'App Version', _data['appVersion']),
        _infoCard(context, Icons.build_circle, 'Build Number', _data['buildNumber']),

        const SizedBox(height: 16),

        _sectionHeader('Device Information'),
        _infoCard(context, Icons.phone_android, 'Device Model', _data['deviceModel']),
        _infoCard(context, Icons.business, 'Manufacturer', _data['deviceManufacturer']),
        _infoCard(context, Icons.android, 'Android Version', _data['androidVersion']),
        _infoCard(context, Icons.memory, 'Android SDK', _data['androidSdk']),
        _infoCard(context, Icons.fingerprint, 'Device ID', _data['deviceId']),

        const SizedBox(height: 16),

        _sectionHeader('Location'),
        _infoCard(context, Icons.location_on, 'Latitude', _data['latitude']),
        _infoCard(context, Icons.location_on_outlined, 'Longitude', _data['longitude']),
      ],
    );
  }

  /// ─────────────────────────────────────────────
  /// UI HELPERS (LOCAL)
  /// ─────────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoCard(BuildContext context, IconData icon, String label, dynamic value) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(value?.toString() ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
