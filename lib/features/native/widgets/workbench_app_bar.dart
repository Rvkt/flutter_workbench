import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/device_info_provider.dart';

class WorkbenchAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const WorkbenchAppBar({required this.title, super.key});

  final String title;

  static const double _toolbarHeight = 56;
  static const double _bottomHeight = 36;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight + _bottomHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime? lastRefreshed = ref.watch(deviceInfoProvider).lastRefreshedAt;

    return AppBar(
      centerTitle: true,
      title: Text(title),
      toolbarHeight: _toolbarHeight,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(_bottomHeight),
        child: lastRefreshed == null
            ? const SizedBox(height: _bottomHeight)
            : _LastRefreshedBar(dateTime: lastRefreshed, height: _bottomHeight),
      ),
    );
  }
}

class _LastRefreshedBar extends StatelessWidget {
  const _LastRefreshedBar({required this.dateTime, required this.height});

  final DateTime dateTime;
  final double height;

  @override
  Widget build(BuildContext context) {
    final String time =
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';

    final String date =
        '${dateTime.day.toString().padLeft(2, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.year}';

    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      // ignore: deprecated_member_use
      color: Colors.black.withOpacity(0.025),
      child: Text(
        'Last refreshed at $time • $date',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}
