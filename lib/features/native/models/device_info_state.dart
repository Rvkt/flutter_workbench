
class DeviceInfoState {
  final Map<String, dynamic>? data;
  final bool loading;
  final String? error;
  final DateTime? lastRefreshedAt;

  const DeviceInfoState({
    this.data,
    this.loading = false,
    this.error,
    this.lastRefreshedAt,
  });

  DeviceInfoState copyWith({
    Map<String, dynamic>? data,
    bool? loading,
    String? error,
    DateTime? lastRefreshedAt,
  }) {
    return DeviceInfoState(
      data: data ?? this.data,
      loading: loading ?? this.loading,
      error: error,
      lastRefreshedAt: lastRefreshedAt ?? this.lastRefreshedAt,
    );
  }
}
