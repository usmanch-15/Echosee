import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GlassesConnectionState {
  idle,
  scanning,
  connecting,
  connected,
  disconnected,
  reconnecting,
  bluetoothOff,
  unsupported,
  permissionDenied,
  error,
}

class BluetoothGlassesService {
  static const String _knownDeviceIdKey = 'ecoc_known_glasses_device_id';

  final StreamController<List<ScanResult>> _scanResultsController =
      StreamController<List<ScanResult>>.broadcast();
  final StreamController<GlassesConnectionState> _stateController =
      StreamController<GlassesConnectionState>.broadcast();
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  Stream<List<ScanResult>> get scanResultsStream => _scanResultsController.stream;
  Stream<GlassesConnectionState> get stateStream => _stateController.stream;
  Stream<String> get messageStream => _messageController.stream;

  GlassesConnectionState _state = GlassesConnectionState.idle;
  GlassesConnectionState get state => _state;

  BluetoothDevice? _connectedDevice;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  List<ScanResult> _scanResults = const [];
  List<ScanResult> get scanResults => _scanResults;

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothAdapterState>? _adapterSub;
  StreamSubscription<BluetoothConnectionState>? _connectionSub;
  Timer? _reconnectTimer;

  String? _knownDeviceId;
  bool _manualDisconnect = false;
  bool _disposed = false;
  int _reconnectAttempt = 0;

  Future<void> initialize() async {
    final supported = await FlutterBluePlus.isSupported;
    if (!supported) {
      _setState(
        GlassesConnectionState.unsupported,
        message: 'Bluetooth is not supported on this device.',
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    _knownDeviceId = prefs.getString(_knownDeviceIdKey);

    _scanSub ??= FlutterBluePlus.scanResults.listen(
      _onScanResults,
      onError: (Object error) {
        _setState(
          GlassesConnectionState.error,
          message: 'Scan error: $error',
        );
      },
    );

    _adapterSub ??= FlutterBluePlus.adapterState.listen((adapterState) {
      if (adapterState == BluetoothAdapterState.on) {
        if (_state == GlassesConnectionState.bluetoothOff) {
          _setState(
            GlassesConnectionState.disconnected,
            message: 'Bluetooth is on. Ready to connect.',
          );
        }
        return;
      }

      _setState(
        GlassesConnectionState.bluetoothOff,
        message: 'Please turn on Bluetooth to continue.',
      );
    });

    final adapterState = FlutterBluePlus.adapterStateNow;
    if (adapterState != BluetoothAdapterState.on) {
      _setState(
        GlassesConnectionState.bluetoothOff,
        message: 'Please turn on Bluetooth to continue.',
      );
      return;
    }

    await autoConnectKnownDevice();
  }

  Future<bool> requestBluetoothPermissions() async {
    final permissions = <Permission>[
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ];

    final statuses = await permissions.request();
    final denied = statuses.values.any((status) => !status.isGranted);
    if (denied) {
      _setState(
        GlassesConnectionState.permissionDenied,
        message: 'Bluetooth permissions are required for device discovery.',
      );
      return false;
    }
    return true;
  }

  Future<void> startScan({Duration timeout = const Duration(seconds: 8)}) async {
    if (_state == GlassesConnectionState.connecting ||
        _state == GlassesConnectionState.connected) {
      return;
    }

    if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      _setState(
        GlassesConnectionState.bluetoothOff,
        message: 'Please turn on Bluetooth to scan devices.',
      );
      return;
    }

    final hasPermissions = await requestBluetoothPermissions();
    if (!hasPermissions) {
      return;
    }

    _scanResults = const [];
    _scanResultsController.add(_scanResults);
    _setState(GlassesConnectionState.scanning, message: 'Scanning for glasses...');

    await FlutterBluePlus.stopScan();
    await FlutterBluePlus.startScan(
      timeout: timeout,
      androidScanMode: AndroidScanMode.lowLatency,
      androidUsesFineLocation: true,
    );
    await FlutterBluePlus.isScanning.where((value) => value == false).first;

    if (_state == GlassesConnectionState.scanning) {
      _setState(
        GlassesConnectionState.disconnected,
        message: _scanResults.isEmpty
            ? 'No devices found. Make sure glasses are in pairing mode.'
            : 'Select your glasses from the list.',
      );
    }
  }

  Future<void> connectToDevice(
    BluetoothDevice device, {
    bool remember = true,
  }) async {
    _manualDisconnect = false;
    _reconnectAttempt = 0;
    _reconnectTimer?.cancel();

    final hasPermissions = await requestBluetoothPermissions();
    if (!hasPermissions) {
      return;
    }

    _setState(GlassesConnectionState.connecting, message: 'Connecting...');
    await FlutterBluePlus.stopScan();

    try {
      await _connectionSub?.cancel();
      _connectionSub = null;

      await device.connect(
        license: License.free,
        timeout: const Duration(seconds: 20),
      );

      _connectedDevice = device;
      _attachConnectionListener(device);

      // Pairing is optional; forcing it helps with reconnect stability on Android.
      try {
        await device.createBond();
      } catch (_) {
        // If already bonded or unsupported by device, keep going.
      }

      if (remember) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_knownDeviceIdKey, device.remoteId.str);
        _knownDeviceId = device.remoteId.str;
      }

      _setState(
        GlassesConnectionState.connected,
        message: 'Connected to ${_deviceName(device)}',
      );
    } catch (error) {
      _connectedDevice = null;
      _setState(
        GlassesConnectionState.error,
        message: 'Failed to connect: $error',
      );
    }
  }

  Future<void> disconnect() async {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectAttempt = 0;

    final device = _connectedDevice;
    if (device != null) {
      try {
        await device.disconnect();
      } catch (_) {
        // Keep state cleanup deterministic.
      }
    }

    _connectedDevice = null;
    _setState(GlassesConnectionState.disconnected, message: 'Disconnected.');
  }

  Future<void> forgetKnownDevice() async {
    _knownDeviceId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_knownDeviceIdKey);
    _messageController.add('Forgot saved glasses device.');
  }

  Future<void> autoConnectKnownDevice() async {
    final knownId = _knownDeviceId;
    if (knownId == null || knownId.isEmpty) {
      _setState(
        GlassesConnectionState.disconnected,
        message: 'No saved glasses. Scan and connect first.',
      );
      return;
    }

    if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      _setState(
        GlassesConnectionState.bluetoothOff,
        message: 'Turn on Bluetooth for auto-connect.',
      );
      return;
    }

    final hasPermissions = await requestBluetoothPermissions();
    if (!hasPermissions) {
      return;
    }

    _setState(
      GlassesConnectionState.reconnecting,
      message: 'Trying to auto-connect to saved glasses...',
    );

    try {
      final knownDevice = BluetoothDevice.fromId(knownId);
      await connectToDevice(knownDevice, remember: false);
    } catch (_) {
      // Fallback to filtered scan if direct connect fails.
      await _scanForKnownAndConnect(knownId);
    }
  }

  Future<void> _scanForKnownAndConnect(String knownId) async {
    _setState(
      GlassesConnectionState.reconnecting,
      message: 'Searching for saved glasses...',
    );
    await FlutterBluePlus.stopScan();

    await FlutterBluePlus.startScan(
      withRemoteIds: [knownId],
      timeout: const Duration(seconds: 8),
      androidScanMode: AndroidScanMode.lowLatency,
      androidUsesFineLocation: true,
    );
    await FlutterBluePlus.isScanning.where((value) => value == false).first;

    ScanResult? match;
    for (final result in _scanResults) {
      if (result.device.remoteId.str == knownId) {
        match = result;
        break;
      }
    }

    if (match == null) {
      _setState(
        GlassesConnectionState.disconnected,
        message: 'Saved glasses not found nearby.',
      );
      _scheduleReconnect();
      return;
    }

    await connectToDevice(match.device, remember: false);
  }

  void _attachConnectionListener(BluetoothDevice device) {
    _connectionSub?.cancel();
    _connectionSub = device.connectionState.listen((connectionState) {
      if (connectionState == BluetoothConnectionState.connected) {
        _setState(
          GlassesConnectionState.connected,
          message: 'Connected to ${_deviceName(device)}',
        );
        _reconnectTimer?.cancel();
        _reconnectAttempt = 0;
        return;
      }

      if (connectionState == BluetoothConnectionState.disconnected) {
        _connectedDevice = null;
        if (_manualDisconnect) {
          _setState(
            GlassesConnectionState.disconnected,
            message: 'Disconnected.',
          );
          _manualDisconnect = false;
          return;
        }

        _setState(
          GlassesConnectionState.disconnected,
          message: 'Connection dropped. Reconnecting...',
        );
        _scheduleReconnect();
      }
    });
  }

  void _scheduleReconnect() {
    final knownId = _knownDeviceId;
    if (knownId == null || knownId.isEmpty) {
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_disposed) {
        timer.cancel();
        return;
      }

      if (_connectedDevice != null) {
        timer.cancel();
        return;
      }

      if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
        _setState(
          GlassesConnectionState.bluetoothOff,
          message: 'Bluetooth is off. Waiting to reconnect.',
        );
        return;
      }

      _reconnectAttempt += 1;
      _setState(
        GlassesConnectionState.reconnecting,
        message: 'Reconnect attempt $_reconnectAttempt...',
      );
      await _scanForKnownAndConnect(knownId);

      if (_connectedDevice != null) {
        timer.cancel();
      }
    });
  }

  void _onScanResults(List<ScanResult> results) {
    final deduped = <String, ScanResult>{};
    for (final result in results) {
      deduped[result.device.remoteId.str] = result;
    }
    _scanResults = deduped.values.toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi));
    _scanResultsController.add(_scanResults);
  }

  String _deviceName(BluetoothDevice device) {
    return device.platformName.isNotEmpty
        ? device.platformName
        : device.remoteId.str;
  }

  void _setState(GlassesConnectionState state, {String? message}) {
    _state = state;
    _stateController.add(state);
    if (message != null) {
      _messageController.add(message);
    }
  }

  void dispose() {
    _disposed = true;
    _scanSub?.cancel();
    _adapterSub?.cancel();
    _connectionSub?.cancel();
    _reconnectTimer?.cancel();
    _scanResultsController.close();
    _stateController.close();
    _messageController.close();
  }
}
