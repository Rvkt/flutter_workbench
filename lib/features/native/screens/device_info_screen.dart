import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device_info_state.dart';
import '../providers/device_info_provider.dart';
import '../widgets/device_info_table.dart';
import '../widgets/workbench_app_bar.dart';

class NativeDeviceInfoTableScreen extends ConsumerStatefulWidget {
  const NativeDeviceInfoTableScreen({super.key, required this.title});
  final String title;

  @override
  ConsumerState<NativeDeviceInfoTableScreen> createState() =>
      _NativeDeviceInfoTableScreenState();
}

class _NativeDeviceInfoTableScreenState
    extends ConsumerState<NativeDeviceInfoTableScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

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
    final ThemeData theme = Theme.of(context);

    ref.listen(deviceInfoProvider, (_, DeviceInfoState next) {
      if (!next.loading && next.error == null) {
        _animController
          ..reset()
          ..forward();
      }
    });

    return Scaffold(
      appBar: WorkbenchAppBar(title: widget.title),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            state.error!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: () => ref.read(deviceInfoProvider.notifier).fetch(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: DeviceInfoTable(
                data: state.data ?? <String, dynamic>{},
              ),
            ),
          ),
        ),
      ),
    );
  }
}