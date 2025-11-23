import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity connectivity;

  ConnectivityService({Connectivity? connectivity})
      : connectivity = connectivity ?? Connectivity();

  /// Vérifie si on est connecté à internet (Wi-Fi ou mobile)
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile || result == ConnectivityResult.wifi;
  }

  /// Ecoute les changements de statut réseau
  Stream<ConnectivityResult> get onConnectivityChanged =>
      connectivity.onConnectivityChanged;

  /// Retourne "wifi", "mobile" ou "none"
  Future<String> get connectionType async {
    final result = await connectivity.checkConnectivity();
    switch (result) {
      case ConnectivityResult.mobile:
        return 'mobile';
      case ConnectivityResult.wifi:
        return 'wifi';
      case ConnectivityResult.ethernet:
        return 'ethernet';
      default:
        return 'none';
    }
  }
}
