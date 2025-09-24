import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class MyoPage extends StatefulWidget {
  const MyoPage({super.key});
  @override
  State<MyoPage> createState() => _MyoTestPageState();
}

class _MyoTestPageState extends State<MyoPage> {
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<OnConnectionStateChangedEvent>? _connEventsSub;
  StreamSubscription<BluetoothConnectionState>? _deviceConnStateSub;
  BluetoothDevice? _device;
  BluetoothConnectionState _connState = BluetoothConnectionState.disconnected;

  final List<ScanResult> _scanResults = [];
  final List<String> _log = [];
  String? _lastPose;

  bool _isScanning = false;
  bool _autoPickMyo = true;
  bool _emgEnabled = true;
  bool _classifierSubscribed = false;

  // Serviços/Chars padrão
  static final Guid _svcBattery = Guid('0000180f-0000-1000-8000-00805f9b34fb');
  static final Guid _chrBattery = Guid('00002a19-0000-1000-8000-00805f9b34fb');

// Myo
  static final Guid _svcControl = Guid('d5060001-a904-deb9-4748-2c7f4a124842');
  static final Guid _chrCommand =
      Guid('d5060401-a904-deb9-4748-2c7f4a124842'); // write
  static final Guid _chrImuData =
      Guid('d5060402-a904-deb9-4748-2c7f4a124842'); // notify
  static final Guid _svcClassifier =
      Guid('d5060003-a904-deb9-4748-2c7f4a124842');
  static final Guid _chrClassifier =
      Guid('d5060103-a904-deb9-4748-2c7f4a124842');

// Refs e dados
  BluetoothCharacteristic? _cmdChar;
  BluetoothCharacteristic? _batteryChar;
  bool get isConnected => _connState == BluetoothConnectionState.connected;
  int? _battery; // 0..100

// Último IMU decodificado
  double? _qw, _qx, _qy, _qz;
  double? _gx, _gy, _gz; // deg/s
  double? _ax, _ay, _az; // g

  bool _emgRaw = false; // toggle (false = filtrado)

  @override
  void initState() {
    super.initState();
    _listenConnection();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _deviceConnStateSub?.cancel();
    _connEventsSub?.cancel();
    _device?.disconnect();
    super.dispose();
  }

  void _listenConnection() {
    _connEventsSub =
        FlutterBluePlus.events.onConnectionStateChanged.listen((event) {
      _appendLog(
          'Evento global: ${event.device.remoteId.str} -> ${event.connectionState.name}');
    });
  }

  Future<void> _ensurePermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    if (statuses.values.any((s) => s.isDenied || s.isPermanentlyDenied)) {
      throw Exception('Permissões de Bluetooth/Localização negadas.');
    }
  }

  Future<void> _startScan() async {
    try {
      await _ensurePermissions();
      setState(() {
        _scanResults.clear();
        _isScanning = true;
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 6));

      _scanSub?.cancel();
      _scanSub = FlutterBluePlus.scanResults.listen((results) async {
        for (final r in results) {
          final already = _scanResults
                  .indexWhere((e) => e.device.remoteId == r.device.remoteId) >=
              0;
          if (!already) setState(() => _scanResults.add(r));

          if (_autoPickMyo &&
              (r.device.platformName.contains('Myo') ||
                  r.advertisementData.advName.contains('Myo'))) {
            await FlutterBluePlus.stopScan();
            setState(() => _isScanning = false);
            _connect(r.device);
            return;
          }
        }
      });
      if (_scanSub != null) {
        FlutterBluePlus.cancelWhenScanComplete(_scanSub!);
      }
    } catch (e) {
      _appendLog('Erro ao iniciar scan: $e');
      setState(() => _isScanning = false);
    }
  }

  Future<void> _stopScan() async {
    await FlutterBluePlus.stopScan();
    setState(() => _isScanning = false);
  }

  String _armStatus = 'unknown'; // 'synced-left', 'synced-right', 'unsynced'

  void _onClassifier(List<int> v) {
    if (v.isEmpty) return;

    final hex = v.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    _appendLog('[Classifier Raw] $hex');

    final type = v[0];

    switch (type) {
      case 0x01: // ARM_SYNCED / ARM_UNSYNCED
        if (v.length >= 3) {
          final evt = v[1];
          final arm = v[2];

          if (evt == 0x01) {
            // ARM_SYNCED (braço sincronizado)
            final armName = arm == 0x01
                ? 'Right'
                : arm == 0x02
                    ? 'Left'
                    : 'Unknown';
            final xDir = v.length >= 4 ? v[3] : 0;
            final xDirName = xDir == 0x01
                ? 'Toward Wrist'
                : xDir == 0x02
                    ? 'Toward Elbow'
                    : 'Unknown';

            setState(() => _armStatus = 'Synced: $armName ($xDirName)');
            _appendLog('✅ Braço sincronizado: $armName, Direção: $xDirName');
          } else if (evt == 0x02) {
            // ARM_UNSYNCED (braço removido)
            setState(() => _armStatus = 'Unsynced (removed)');
            _appendLog('⚠️ Braço removido/não sincronizado');
          }
        }
        break;

      case 0x02: // LOCKED / UNLOCKED
        if (v.length >= 2) {
          final lockState = v[1];
          _appendLog(lockState == 0x00 ? '🔒 Locked' : '🔓 Unlocked');
        }
        break;

      case 0x03: // POSE (gesto detectado)
        if (v.length >= 2) {
          final poseCode = v[1];
          final poseName = _decodePose(poseCode);
          setState(() => _lastPose = poseName);
          _appendLog('👋 Gesto detectado: $poseName');
        }
        break;

      default:
        _appendLog(
            '[Classifier] Tipo desconhecido: 0x${type.toRadixString(16)}');
    }
  }

  void _onImu(List<int> v) {
    if (v.length < 20) return;
    final data = Uint8List.fromList(v);
    final bd = ByteData.sublistView(data);

    // ordem: quat(w,x,y,z), gyro(x,y,z), accel(x,y,z) em int16 little-endian
    final qw = bd.getInt16(0, Endian.little) / 16384.0;
    final qx = bd.getInt16(2, Endian.little) / 16384.0;
    final qy = bd.getInt16(4, Endian.little) / 16384.0;
    final qz = bd.getInt16(6, Endian.little) / 16384.0;

    final gx = bd.getInt16(8, Endian.little) / 16.0; // deg/s
    final gy = bd.getInt16(10, Endian.little) / 16.0;
    final gz = bd.getInt16(12, Endian.little) / 16.0;

    final ax = bd.getInt16(14, Endian.little) / 2048.0; // g
    final ay = bd.getInt16(16, Endian.little) / 2048.0;
    final az = bd.getInt16(18, Endian.little) / 2048.0;

    setState(() {
      _qw = qw;
      _qx = qx;
      _qy = qy;
      _qz = qz;
      _gx = gx;
      _gy = gy;
      _gz = gz;
      _ax = ax;
      _ay = ay;
      _az = az;
    });
  }

  Future<void> _connect(BluetoothDevice device) async {
    try {
      final friendlyName =
          device.platformName.isNotEmpty ? device.platformName : device.advName;
      _appendLog(
          'Conectando em ${friendlyName.isEmpty ? 'dispositivo desconhecido' : friendlyName} '
          '(${device.remoteId.str}) ...');

      await device.connect(
          license: License.free, timeout: const Duration(seconds: 10));
      setState(() => _device = device);

      _deviceConnStateSub?.cancel();
      final subscription = device.connectionState.listen((state) {
        if (!mounted) return;
        setState(() => _connState = state);
      });
      device.cancelWhenDisconnected(subscription);
      _deviceConnStateSub = subscription;

      await _discoverAndSubscribe(device);
    } catch (e) {
      _appendLog('Falha ao conectar: $e');
    }
  }

  Future<void> _disconnect() async {
    try {
      await _device?.disconnect();
      _deviceConnStateSub?.cancel();
      _deviceConnStateSub = null;
      setState(() {
        _device = null;
        _connState = BluetoothConnectionState.disconnected;
        _cmdChar = null;
      });
    } catch (e) {
      _appendLog('Erro ao desconectar: $e');
    }
  }

  // Modifique o método _discoverAndSubscribe para adicionar mais logs:
  Future<void> _discoverAndSubscribe(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      _appendLog('Encontrados ${services.length} serviços.');

      _cmdChar = null;
      _batteryChar = null;
      _classifierSubscribed = false;

      for (final s in services) {
        // Log dos serviços encontrados
        _appendLog('Serviço: ${s.uuid.str}');

        for (final c in s.characteristics) {
          // Command characteristic
          if (s.uuid == _svcControl && c.uuid == _chrCommand) {
            _cmdChar = c;
            _appendLog('✅ Command characteristic encontrado');
          }

          // Battery
          if (s.uuid == _svcBattery && c.uuid == _chrBattery) {
            _batteryChar = c;
            try {
              if (c.properties.read) {
                final v = await c.read();
                if (v.isNotEmpty) {
                  setState(() => _battery = v.first);
                  _appendLog('🔋 Bateria lida: $_battery%');
                }
              }
              if (c.properties.notify) {
                await c.setNotifyValue(true);
                c.onValueReceived.listen((v) {
                  if (v.isNotEmpty) setState(() => _battery = v.first);
                });
              }
            } catch (e) {
              _appendLog('Erro bat: $e');
            }
          }

          // IMU
          if (c.uuid == _chrImuData && c.properties.notify) {
            await c.setNotifyValue(true);
            _appendLog('✅ IMU notifications ativadas');
            c.onValueReceived.listen((v) => _onImu(v));
          }

          // Classifier - CRÍTICO!
          if (s.uuid == _svcClassifier && c.uuid == _chrClassifier) {
            _appendLog('🎯 Classifier characteristic encontrado!');
            _appendLog(
                '  Properties: read=${c.properties.read}, write=${c.properties.write}, '
                'notify=${c.properties.notify}, indicate=${c.properties.indicate}');

            if (c.properties.notify || c.properties.indicate) {
              try {
                // Tenta notify primeiro
                if (c.properties.notify) {
                  await c.setNotifyValue(true);
                  _appendLog('✅ Classifier NOTIFY ativado');
                } else if (c.properties.indicate) {
                  // Se não tiver notify, tenta indicate
                  await c.setNotifyValue(
                      true); // No flutter_blue_plus isso ativa indicate também
                  _appendLog('✅ Classifier INDICATE ativado');
                }

                _classifierSubscribed = true;

                // Listener para o classificador
                c.onValueReceived.listen((v) {
                  _onClassifier(v);
                }, onError: (error) {
                  _appendLog('❌ Erro no classifier listener: $error');
                });
              } catch (e) {
                _appendLog('❌ Erro ao ativar notificações do classifier: $e');
              }
            } else {
              _appendLog('⚠️ Classifier não suporta notify/indicate!');
            }
          }

          // EMG (opcional)
          if (_emgEnabled &&
              (c.uuid.str.endsWith('0105') ||
                  c.uuid.str.endsWith('0205') ||
                  c.uuid.str.endsWith('0305') ||
                  c.uuid.str.endsWith('0405'))) {
            if (c.properties.notify) {
              await c.setNotifyValue(true);
              _appendLog('✅ EMG ${c.uuid.str.substring(4, 8)} ativado');
            }
          }
        }
      }

      if (_cmdChar == null) {
        _appendLog('❌ Command characteristic NÃO encontrado!');
      }

      if (!_classifierSubscribed) {
        _appendLog(
            '⚠️ ATENÇÃO: Classifier não foi inscrito para notificações!');
      }

      // Aguarda um pouco antes de enviar comandos
      await Future.delayed(const Duration(milliseconds: 500));

      // Tenta ativar automaticamente após conectar
      if (_cmdChar != null && _classifierSubscribed) {
        _appendLog('🚀 Iniciando ativação automática dos streams...');
        await _enableStreams();
      }
    } catch (e) {
      _appendLog('Erro em discover/subscribe: $e');
    }
  }

  void _handleIncoming(Guid charUuid, List<int> value) {
    final hex = value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    _appendLog('[${charUuid.str}] <= $hex  (${value.length}B)');

    // Heurística simples: 1 byte = "pose"
    if (value.length == 1) {
      final pose = _decodePose(value.first);
      setState(() => _lastPose = pose);
    }
  }

  String _decodePose(int code) {
    switch (code) {
      case 0:
        return 'Rest';
      case 1:
        return 'Fist';
      case 2:
        return 'Wave In';
      case 3:
        return 'Wave Out';
      case 4:
        return 'Fingers Spread';
      case 5:
        return 'Double Tap';
      case 255:
        return 'Unknown';
      default:
        return 'Code $code';
    }
  }

  void _appendLog(String line) {
    setState(() {
      _log.insert(0, '${DateTime.now().toIso8601String()}  $line');
      if (_log.length > 500) _log.removeLast();
    });
  }

  // ====== Escrita de comandos no Myo ======
  Future<void> _writeCommand(List<int> bytes) async {
    final c = _cmdChar;
    if (_device == null || c == null) {
      _appendLog('❌ Sem dispositivo/command characteristic para escrever.');
      return;
    }
    try {
      _appendLog(
          '=> CMD ${bytes.map((b) => b.toRadixString(16).padLeft(2, "0")).join(" ")}');
      await c.write(bytes, withoutResponse: false);
    } catch (e) {
      _appendLog('Erro escrevendo comando: $e');
    }
  }

  // Vibrar: short(1), medium(2), long(3)
  Future<void> _vibrate(int kind) async {
    // [0x03, payload_size=0x01, kind]
    await _writeCommand([0x03, 0x01, kind]);
  }

  Future<void> _forceSyncArm() async {
    if (!isConnected) return;

    // Vibra para indicar início da sincronização
    await _vibrate(0x01);
    await Future.delayed(const Duration(milliseconds: 200));

    // Envia user action para forçar detecção
    await _writeCommand([0x0B, 0x01, 0x00]);

    _appendLog('🔄 Forçando sincronização do braço...');
  }

  Future<void> _enableStreams() async {
    if (_cmdChar == null) {
      _appendLog('❌ Não posso ativar streams - command char não encontrado');
      return;
    }

    // Verifica se a inscrição foi bem-sucedida antes de tentar ativar.
    if (!_classifierSubscribed) {
      _appendLog(
          '⚠️ ATENÇÃO: Classifier não está inscrito para notificações! Ativação pode falhar.');
      // Você pode optar por parar aqui ou continuar mesmo assim.
    }

    try {
      _appendLog('📤 Iniciando sequência de ativação (MODO ÚNICO)...');
      final emgMode = _emgRaw ? 0x03 : 0x02; // 0x02 = filtered, 0x03 = raw

      // PASSO 1: Comando único para ativar EMG, IMU e CLASSIFIER
      // Comando: 0x01 (set_mode)
      // Payload Size: 0x03
      // Payload: [emg_mode, imu_mode, classifier_mode]
      _appendLog('1️⃣ Ativando EMG(mode=$emgMode) + IMU + Classifier...');
      await _writeCommand(
          [0x01, 0x03, emgMode, 0x01, 0x01]); // EMG on, IMU on, Classifier ON
      await Future.delayed(const Duration(milliseconds: 200));

      // PASSO 2: Never sleep (Manter o dispositivo acordado)
      _appendLog('2️⃣ Configurando never sleep...');
      await _writeCommand([0x09, 0x01, 0x01]);
      await Future.delayed(const Duration(milliseconds: 200));

      // PASSO 3: Desbloquear para receber gestos continuamente
      _appendLog('3️⃣ Desbloqueando (hold mode)...');
      await _writeCommand([0x0A, 0x01, 0x02]); // 0x02 = hold, 0x01 = timed
      await Future.delayed(const Duration(milliseconds: 200));

      // PASSO 4: Vibra para confirmar que a sequência foi enviada
      _appendLog('4️⃣ Vibrando para confirmar...');
      await _vibrate(0x01); // Vibração curta

      _appendLog('✅ Sequência completa enviada!');
      _appendLog(
          '💡 DICA: Coloque o Myo no braço e faça o gesto de PUNHO FECHADO por 1-2 segundos para forçar a sincronização.');
    } catch (e) {
      _appendLog('❌ Erro durante ativação: $e');
    }
  }

  Future<void> _checkMyoStatus() async {
    if (!isConnected) {
      _appendLog('❌ Não conectado');
      return;
    }

    _appendLog('📊 === STATUS DO MYO ===');
    _appendLog('Command char: ${_cmdChar != null ? "✅" : "❌"}');
    _appendLog('Classifier subscribed: ${_classifierSubscribed ? "✅" : "❌"}');
    _appendLog('Battery: ${_battery ?? "?"}%');
    _appendLog('Last pose: ${_lastPose ?? "none"}');
    _appendLog('Arm status: $_armStatus');
    _appendLog('===================');

    // Tenta forçar um user action
    if (_cmdChar != null) {
      await _writeCommand([0x0B, 0x01, 0x00]);
      _appendLog('Enviado user action para atualizar status');
    }
  }

  Future<void> _disableStreams() async {
    await _writeCommand([0x01, 0x03, 0x00, 0x00, 0x00]); // tudo off
    // Opcional: Lock
    await _writeCommand([0x0A, 0x01, 0x00]);
  }

  // Método alternativo para tentar ativação diferente:
  Future<void> _alternativeActivation() async {
    if (_cmdChar == null) return;

    _appendLog('🔧 Tentando ativação alternativa...');

    // Sequência baseada no myo_raw.py
    // Primeiro envia sleep mode never
    await _writeCommand([0x09, 0x01, 0x01]);
    await Future.delayed(const Duration(milliseconds: 100));

    // Depois set mode com IMU RAW
    await _writeCommand(
        [0x01, 0x03, 0x02, 0x03, 0x01]); // EMG filtered, IMU raw, classifier on
    await Future.delayed(const Duration(milliseconds: 100));

    // Unlock
    await _writeCommand([0x0A, 0x01, 0x02]);
    await Future.delayed(const Duration(milliseconds: 100));

    // Vibrate para confirmar
    await _vibrate(0x02);

    _appendLog('✅ Ativação alternativa enviada');
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _connState == BluetoothConnectionState.connected;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teste Myo (BLE)'),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.battery_0_bar), text: 'Bateria'),
            Tab(icon: Icon(Icons.threed_rotation), text: 'IMU'),
            Tab(icon: Icon(Icons.pan_tool_alt), text: 'Gestos'),
          ]),
          actions: [
            // toggle EMG raw/filtrado
            Row(children: [
              const Text('EMG raw'),
              Switch(
                  value: _emgRaw,
                  onChanged: (v) => setState(() => _emgRaw = v)),
            ]),
            // o teu switch _autoPickMyo pode ficar aqui também
          ],
        ),
        body: Column(
          children: [
            _TopStatus(
              isScanning: _isScanning,
              isConnected: isConnected,
              device: _device,
              connState: _connState,
              lastPose: _lastPose,
              armStatus: _armStatus,
              onScan: _startScan,
              onStopScan: _stopScan,
              onDisconnect: _disconnect,
            ),
            // ====== NOVOS BOTÕES ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                FilledButton.tonal(
                    onPressed: isConnected ? () => _vibrate(0x01) : null,
                    child: const Text('Vibrar curto')),
                FilledButton.tonal(
                    onPressed: isConnected ? () => _vibrate(0x02) : null,
                    child: const Text('Vibrar médio')),
                FilledButton.tonal(
                    onPressed: isConnected ? () => _vibrate(0x03) : null,
                    child: const Text('Vibrar longo')),
                const SizedBox(width: 16),
                FilledButton(
                    onPressed: isConnected ? _enableStreams : null,
                    child: const Text('Ativar IMU + Gestos + EMG')),
                FilledButton(
                    onPressed: isConnected ? _disableStreams : null,
                    child: const Text('Parar streams')),
                FilledButton.tonal(
                  onPressed: isConnected ? _forceSyncArm : null,
                  child: const Text('Sincronizar Braço'),
                ),
                FilledButton.tonal(
                  onPressed: isConnected ? _checkMyoStatus : null,
                  child: const Text('Check Status'),
                ),
                FilledButton.tonal(
                  onPressed: isConnected ? _alternativeActivation : null,
                  child: const Text('Alt. Activation'),
                ),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(children: [
                // ---- Aba 1: Bateria ----
                Center(
                  child: Text(
                    _battery == null ? '—' : 'Bateria: $_battery%',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                // ---- Aba 2: IMU ----
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListView(children: [
                    Text(
                        'Quaternion (w,x,y,z): ${_qw?.toStringAsFixed(4) ?? "-"}, '
                        '${_qx?.toStringAsFixed(4) ?? "-"}, '
                        '${_qy?.toStringAsFixed(4) ?? "-"}, '
                        '${_qz?.toStringAsFixed(4) ?? "-"}'),
                    const SizedBox(height: 8),
                    Text('Gyro (deg/s): x=${_gx?.toStringAsFixed(1) ?? "-"}, '
                        'y=${_gy?.toStringAsFixed(1) ?? "-"}, '
                        'z=${_gz?.toStringAsFixed(1) ?? "-"}'),
                    const SizedBox(height: 8),
                    Text('Accel (g): x=${_ax?.toStringAsFixed(3) ?? "-"}, '
                        'y=${_ay?.toStringAsFixed(3) ?? "-"}, '
                        'z=${_az?.toStringAsFixed(3) ?? "-"}'),
                  ]),
                ),
                // ---- Aba 3: Gestos ----
                Center(
                  child: Text(
                    _lastPose == null ? '—' : 'Gesto: $_lastPose',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopStatus extends StatelessWidget {
  const _TopStatus({
    required this.isScanning,
    required this.isConnected,
    required this.device,
    required this.connState,
    required this.lastPose,
    required this.armStatus,
    required this.onScan,
    required this.onStopScan,
    required this.onDisconnect,
  });

  final bool isScanning;
  final bool isConnected;
  final BluetoothDevice? device;
  final BluetoothConnectionState connState;
  final String? lastPose;
  final String armStatus;
  final VoidCallback onScan;
  final VoidCallback onStopScan;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final remoteId = device?.remoteId.str ?? '-';
    final deviceLabel = device == null
        ? '-'
        : device!.platformName.isNotEmpty
            ? device!.platformName
            : device!.advName.isNotEmpty
                ? device!.advName
                : remoteId;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isConnected
                        ? 'Conectado a: $deviceLabel ($remoteId)'
                        : 'Desconectado',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                if (!isConnected && !isScanning)
                  FilledButton.icon(
                    onPressed: onScan,
                    icon: const Icon(Icons.bluetooth_searching),
                    label: const Text('Scan'),
                  ),
                if (isScanning)
                  FilledButton.tonalIcon(
                    onPressed: onStopScan,
                    icon: const Icon(Icons.stop),
                    label: const Text('Parar'),
                  ),
                if (isConnected)
                  FilledButton.icon(
                    onPressed: onDisconnect,
                    icon: const Icon(Icons.link_off),
                    label: const Text('Desconectar'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text('Estado: ${connState.name}')),
                const SizedBox(width: 8),
                Chip(label: Text('Último gesto: ${lastPose ?? "-"}')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [Chip(label: Text('Arm: $armStatus'))],
            )
          ],
        ),
      ),
    );
  }
}

class _ScanList extends StatelessWidget {
  const _ScanList({required this.results, required this.onTap});
  final List<ScanResult> results;
  final void Function(ScanResult r) onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        itemCount: results.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final r = results[i];
          return ListTile(
            leading: const Icon(Icons.bluetooth),
            title: Text(r.device.platformName.isNotEmpty
                ? r.device.platformName
                : r.advertisementData.advName.isNotEmpty
                    ? r.advertisementData.advName
                    : '(sem nome)'),
            subtitle: Text('${r.device.remoteId.str}  RSSI:${r.rssi}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onTap(r),
          );
        },
      ),
    );
  }
}

class _LogView extends StatelessWidget {
  const _LogView({required this.lines});
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: lines.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          lines[i],
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
    );
  }
}

extension on BluetoothConnectionState {
  String get name => switch (this) {
        BluetoothConnectionState.disconnected => 'disconnected',
        BluetoothConnectionState.connected => 'connected',
        _ => toString().split('.').last,
      };
}
