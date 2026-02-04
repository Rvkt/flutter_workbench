import 'package:flutter/material.dart';

class DeviceInfoTable extends StatefulWidget {
  const DeviceInfoTable({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  State<DeviceInfoTable> createState() => _DeviceInfoTableState();
}

class _DeviceInfoTableState extends State<DeviceInfoTable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DeviceInfoTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.length != oldWidget.data.length) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const Map<String, IconData> _defaultIcons = <String, IconData>{
    'Package ID': Icons.apps,
    'App Version': Icons.system_update,
    'Build Number': Icons.build_circle,
    'Device Model': Icons.phone_android,
    'Manufacturer': Icons.business,
    'Android Version': Icons.android,
    'Android SDK': Icons.memory,
    'Device ID': Icons.fingerprint,
    'SIM Operator': Icons.sim_card,
    'SIM Country': Icons.public,
    'Phone Number': Icons.phone,
    'SIM ID': Icons.credit_card,
    'Network Type': Icons.network_cell,
    'Latitude': Icons.location_on,
    'Longitude': Icons.location_on_outlined,
  };

  Map<String, Map<String, dynamic>> _groupData(Map<String, dynamic> data) {
    return <String, Map<String, dynamic>>{
      'App Information': <String, dynamic>{
        'Package ID': data['packageId'],
        'App Version': data['appVersion'],
        'Build Number': data['buildNumber'],
      },
      'Device Information': <String, dynamic>{
        'Device Model': data['deviceModel'],
        'Manufacturer': data['deviceManufacturer'],
        'Android Version': data['androidVersion'],
        'Android SDK': data['androidSdk'],
        'Device ID': data['deviceId'],
      },
      'SIM Information': <String, dynamic>{
        'SIM Operator': data['simOperator'],
        'SIM Country': data['simCountryIso'].toString().toUpperCase(),
      },
      'Location': <String, dynamic>{
        'Latitude': data['latitude'],
        'Longitude': data['longitude'],
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Map<String, Map<String, dynamic>> sections = _groupData(widget.data);

    return SingleChildScrollView(
      child: Column(
        children: sections.entries.map((MapEntry<String, Map<String, dynamic>> sectionEntry) {
          final String sectionName = sectionEntry.key;
          final List<MapEntry<String, dynamic>> sectionData = sectionEntry.value.entries.toList();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Card(
              elevation: 1,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: theme.colorScheme.surface,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    sectionName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  childrenPadding: const EdgeInsets.symmetric(vertical: 8),
                  children: sectionData.asMap().entries.map((MapEntry<int, MapEntry<String, dynamic>> mapEntry) {
                    final int index = mapEntry.key;
                    final MapEntry<String, dynamic> entry = mapEntry.value;
                    final bool isEven = index % 2 == 0;

                    final CurvedAnimation fadeAnim = CurvedAnimation(
                      parent: _controller,
                      curve: Interval(
                          index / sectionData.length, (index + 1) / sectionData.length,
                          curve: Curves.easeOut),
                    );

                    final Animation<Offset> slideAnim = Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: Interval(
                            index / sectionData.length, (index + 1) / sectionData.length,
                            curve: Curves.easeOut)));

                    return FadeTransition(
                      opacity: fadeAnim,
                      child: SlideTransition(
                        position: slideAnim,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isEven
                                ? theme.colorScheme.surfaceVariant.withOpacity(0.05)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                child: Icon(
                                  _defaultIcons[entry.key] ?? Icons.info_outline,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  entry.key,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  entry.value?.toString() ?? '',
                                  textAlign: TextAlign.right,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
