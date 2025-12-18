// lib/providers/device_info_provider.dart
import 'dart:developer';

import 'package:flutter/services.dart';

import 'package:flutter_riverpod/legacy.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/device_info_state.dart';


final deviceInfoProvider =
    StateNotifierProvider<DeviceInfoNotifier, DeviceInfoState>(
  (ref) => DeviceInfoNotifier(),
);

class DeviceInfoNotifier extends StateNotifier<DeviceInfoState> {
  DeviceInfoNotifier() : super(const DeviceInfoState(loading: true));

  static const MethodChannel _channel =
      MethodChannel('device_info_channel');

  /// PUBLIC API
  Future<void> fetch() async {
    state = state.copyWith(loading: true, error: null);

    final status = await Permission.location.status;

    if (status.isPermanentlyDenied) {
      state = state.copyWith(
        loading: false,
        error:
            'Location permission permanently denied.\nEnable it from settings.',
      );
      await openAppSettings();
      return;
    }

    if (!status.isGranted) {
      final req = await Permission.location.request();
      if (!req.isGranted) {
        state = state.copyWith(
          loading: false,
          error: 'Location permission denied.',
        );
        return;
      }
    }

    await _fetchNativeInfo();
  }

  Future<void> _fetchNativeInfo() async {
    try {
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('getDeviceAndAppInfo');

          // log(result.toString());

      state = state.copyWith(
        data: Map<String, dynamic>.from(result),
        lastRefreshedAt: DateTime.now(),
        loading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }
}
