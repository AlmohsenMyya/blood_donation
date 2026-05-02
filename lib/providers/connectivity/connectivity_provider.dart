import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider =
    NotifierProvider<ConnectivityNotifier, bool>(ConnectivityNotifier.new);

class ConnectivityNotifier extends Notifier<bool> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  bool build() {
    ref.onDispose(() => _subscription?.cancel());
    _init();
    return true;
  }

  Future<void> _init() async {
    final results = await Connectivity().checkConnectivity();
    state = _isOnline(results);
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      state = _isOnline(results);
    });
  }

  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }
}
