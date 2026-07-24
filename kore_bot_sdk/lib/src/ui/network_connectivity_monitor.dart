import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Tracks device network reachability via [Connectivity].
class NetworkConnectivityMonitor {
  NetworkConnectivityMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool hasInternet = true;

  void Function(bool hasInternet)? onChanged;

  Future<void> start() async {
    final results = await _connectivity.checkConnectivity();
    _applyResults(results, notify: false);

    _subscription = _connectivity.onConnectivityChanged.listen(_applyResults);
  }

  void _applyResults(
    List<ConnectivityResult> results, {
    bool notify = true,
  }) {
    final online = isOnline(results);
    if (online == hasInternet) return;

    hasInternet = online;
    if (notify) {
      onChanged?.call(online);
    }
  }

  static bool isOnline(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((result) => result != ConnectivityResult.none);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
