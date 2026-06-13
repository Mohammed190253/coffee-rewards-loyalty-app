/// Centralized network configuration for the Astrolabe Flutter app.
///
/// Mobile devices cannot use `localhost` or `127.0.0.1` — those refer to the
/// phone itself, not your PC. Pick the [reachability] mode that matches how
/// you are running the app, then start the backend with `npm start` in
/// `backend/` (listening on `0.0.0.0:3000`).
enum BackendReachability {
  /// Real phone/tablet on the same Wi-Fi as your development PC.
  /// Uses [localNetworkIp] (run `ipconfig` and copy your Wi-Fi IPv4).
  physicalDevice,

  /// Android Emulator (AVD). Host machine loopback is `10.0.2.2`.
  androidEmulator,

  /// iOS Simulator on the same Mac/PC. Host loopback is `127.0.0.1`.
  iosSimulator,

  /// External tunnel (ngrok, localtunnel, etc.). Set [tunnelUrl] below.
  localTunnel,
}

class NetworkConfig {
  NetworkConfig._();

  // ---------------------------------------------------------------------------
  // >>> Switch this when you change test target (emulator vs physical device)
  // ---------------------------------------------------------------------------
  static const BackendReachability reachability = BackendReachability.physicalDevice;

  /// Your PC's Wi-Fi IPv4 address (from `ipconfig` → Wireless LAN Adapter).
  /// Current machine address detected: 192.168.1.10 — update if your network changes.
  static const String localNetworkIp = '192.168.1.10';

  /// Node.js backend port (`backend/server.js`).
  static const int port = 3000;

  /// Only used when [reachability] is [BackendReachability.localTunnel].
  static const String tunnelUrl = 'https://your-tunnel-url.example.com';

  /// Fully-qualified API base URL consumed by all repositories.
  static String get apiBaseUrl {
    switch (reachability) {
      case BackendReachability.localTunnel:
        return tunnelUrl;
      case BackendReachability.androidEmulator:
        return 'http://10.0.2.2:$port';
      case BackendReachability.iosSimulator:
        return 'http://127.0.0.1:$port';
      case BackendReachability.physicalDevice:
        return 'http://$localNetworkIp:$port';
    }
  }
}
