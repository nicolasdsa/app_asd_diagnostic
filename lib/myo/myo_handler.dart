// lib/myo/myo_handler.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

enum MyoPose { rest, fist, waveIn, waveOut, fingersSpread, doubleTap, unknown }

enum MyoConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  failed
}

class MyoHandler {
  static final MyoHandler _instance = MyoHandler._internal();
  factory MyoHandler() => _instance;
  MyoHandler._internal();

  // UUIDs
  static final Guid _svcControl = Guid('d5060001-a904-deb9-4748-2c7f4a124842');
  static final Guid _chrCommand = Guid('d5060401-a904-deb9-4748-2c7f4a124842');
  static final Guid _svcClassifier =
      Guid('d5060003-a904-deb9-4748-2c7f4a124842');
  static final Guid _chrClassifier =
      Guid('d5060103-a904-deb9-4748-2c7f4a124842');

  BluetoothDevice? _device;
  BluetoothCharacteristic? _cmdCharacteristic;
  BluetoothCharacteristic? _classifierCharacteristic;
  StreamSubscription? _scanSub;

  // Notificador de Estado para a UI
  final ValueNotifier<MyoConnectionState> connectionState =
      ValueNotifier(MyoConnectionState.disconnected);

  final StreamController<MyoPose> _poseController =
      StreamController<MyoPose>.broadcast();
  Stream<MyoPose> get poseStream => _poseController.stream;

  bool get isConnected => connectionState.value == MyoConnectionState.connected;

  Future<void> connect() async {
    if (isConnected ||
        connectionState.value == MyoConnectionState.scanning ||
        connectionState.value == MyoConnectionState.connecting) {
      return;
    }

    try {
      // 1. Solicitar Permissões
      await _requestPermissions();

      // 2. Iniciar Scan
      connectionState.value = MyoConnectionState.scanning;
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

      _scanSub = FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult r in results) {
          final deviceName = r.device.platformName.isNotEmpty
              ? r.device.platformName
              : r.advertisementData.advName;
          if (deviceName.contains('Myo')) {
            await FlutterBluePlus.stopScan();
            _scanSub?.cancel();

            // 3. Conectar ao Dispositivo
            connectionState.value = MyoConnectionState.connecting;
            _device = r.device;
            await _device!.connect(
                license: License.free, timeout: const Duration(seconds: 15));

            // 4. Descobrir Serviços e Habilitar Myo
            await _discoverServices();
            await _setupClassifier();

            connectionState.value = MyoConnectionState.connected;
            vibrate(1); // Vibra para indicar sucesso
            return;
          }
        }
      });
    } catch (e) {
      print("Erro na conexão com o Myo: $e");
      disconnect();
    }
  }

  Future<void> _discoverServices() async {
    if (_device == null) return;
    final services = await _device!.discoverServices();
    for (var s in services) {
      for (var c in s.characteristics) {
        if (s.uuid == _svcControl && c.uuid == _chrCommand)
          _cmdCharacteristic = c;
        if (s.uuid == _svcClassifier && c.uuid == _chrClassifier)
          _classifierCharacteristic = c;
      }
    }
  }

  Future<void> _setupClassifier() async {
    if (_classifierCharacteristic == null) return;

    await _classifierCharacteristic!.setNotifyValue(true);
    _classifierCharacteristic!.onValueReceived.listen((value) {
      if (value.isNotEmpty && value[0] == 0x03 && value.length >= 2) {
        _poseController.add(_parsePose(value[1]));
      }
    });
    // Comando para habilitar a classificação, EMG e IMU
    await _writeCmd([0x01, 0x03, 0x02, 0x01, 0x01]);
  }

  MyoPose _parsePose(int poseCode) {
    switch (poseCode) {
      case 0:
        return MyoPose.rest;
      case 1:
        return MyoPose.fist;
      case 2:
        return MyoPose.waveIn;
      case 3:
        return MyoPose.waveOut;
      case 4:
        return MyoPose.fingersSpread;
      case 5:
        return MyoPose.doubleTap;
      default:
        return MyoPose.unknown;
    }
  }

  Future<void> vibrate(int duration) async {
    await _writeCmd([0x03, 0x01, duration]);
  }

  Future<void> _writeCmd(List<int> bytes) async {
    await _cmdCharacteristic?.write(bytes, withoutResponse: false);
  }

  void disconnect() {
    _scanSub?.cancel();
    _device?.disconnect();
    _device = null;
    connectionState.value = MyoConnectionState.disconnected;
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }
}
