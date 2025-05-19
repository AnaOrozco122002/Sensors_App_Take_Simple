import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class SensorController {
  final ValueNotifier<List<double>> accelerometerValues = ValueNotifier([0.0, 0.0, 0.0]);
  final ValueNotifier<List<double>> gyroscopeValues = ValueNotifier([0.0, 0.0, 0.0]);
  final ValueNotifier<String> frequencyLabel = ValueNotifier('Por defecto');

  Function(double? accelFreq, double? gyroFreq)? onNewFrequency;

  final List<List<dynamic>> _recordedData = [
    ['timestamp', 'ax', 'ay', 'az', 'gx', 'gy', 'gz', 'accel_freq', 'gyro_freq']
  ];

  final List<List<double>> _accelerometerData = [];
  final List<List<double>> _gyroscopeData = [];

  StreamSubscription<AccelerometerEvent>? _accelerometerSub;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSub;

  bool _isRecording = false;
  List<double> _lastGyro = [0.0, 0.0, 0.0];
  List<double>? _latestAccel;
  List<double>? _latestGyro;

  Timer? _timer;

  Duration? _accelInterval;
  Duration? _gyroInterval;
  DateTime? _lastAccelSampleTime;
  DateTime? _lastGyroSampleTime;

  int? _lastAccelTimestamp;
  int? _lastGyroTimestamp;

  double? _latestAccelFreq;
  double? _latestGyroFreq;

  void setFrequency(String label, [Duration? interval]) {
    frequencyLabel.value = label;

    // Establecer intervalos por separado
    _accelInterval = interval;
    _gyroInterval = interval;

    restartListening();
  }


  void startListening() {
    // Escucha siempre y guarda los valores actuales
    _accelerometerSub = accelerometerEventStream().listen((event) {
      accelerometerValues.value = [event.x, event.y, event.z];
    });

    _gyroscopeSub = gyroscopeEventStream().listen((event) {
      gyroscopeValues.value = [event.x, event.y, event.z];
      _lastGyro = [event.x, event.y, event.z];
    });

    // Cancela temporizador anterior
    _timer?.cancel();

    if (_accelInterval != null || _gyroInterval != null) {
      // Usa temporizador para tomar muestras sincronizadas
      final sampleInterval = _accelInterval ?? _gyroInterval ?? Duration(milliseconds: 33); // fallback a 30Hz
      _timer = Timer.periodic(sampleInterval, (_) => _sampleSensors());
    } else {
      // Escucha y graba en cada evento de acelerómetro (modo por defecto)
      _accelerometerSub?.cancel();
      _accelerometerSub = accelerometerEventStream().listen((event) {
        final now = DateTime.now();
        final currentTimestamp = now.microsecondsSinceEpoch;
        double? accelFreq;

        if (_lastAccelTimestamp != null) {
          final deltaUs = currentTimestamp - _lastAccelTimestamp!;
          accelFreq = 1000000 / deltaUs;
          _latestAccelFreq = accelFreq;
        }
        _lastAccelTimestamp = currentTimestamp;

        accelerometerValues.value = [event.x, event.y, event.z];
        _accelerometerData.add([event.x, event.y, event.z]);

        // Usa último giro conocido
        _recordIfNeeded(event.x, event.y, event.z, _lastGyro, accelFreq, _latestGyroFreq);

        _updateFrequencyLabel();
      });
    }
  }


  void _sampleSensors() {
    final now = DateTime.now();
    final currentTimestamp = now.microsecondsSinceEpoch;

    double? accelFreq, gyroFreq;

    if (_lastAccelTimestamp != null) {
      final deltaUs = currentTimestamp - _lastAccelTimestamp!;
      accelFreq = 1000000 / deltaUs;
      _latestAccelFreq = accelFreq;
    }

    if (_lastGyroTimestamp != null) {
      final deltaUs = currentTimestamp - _lastGyroTimestamp!;
      gyroFreq = 1000000 / deltaUs;
      _latestGyroFreq = gyroFreq;
    }

    _lastAccelTimestamp = currentTimestamp;
    _lastGyroTimestamp = currentTimestamp;

    final accel = accelerometerValues.value;
    final gyro = gyroscopeValues.value;

    // Para graficar con timestamp
    _accelerometerData.add([DateTime.now().millisecondsSinceEpoch.toDouble(), ...accel]);
    _gyroscopeData.add([DateTime.now().millisecondsSinceEpoch.toDouble(), ...gyro]);


    _recordIfNeeded(accel[0], accel[1], accel[2], gyro, accelFreq, gyroFreq);

    _updateFrequencyLabel();
  }


  void _updateFrequencyLabel() {
    if (_accelInterval == null && _gyroInterval == null && _latestAccelFreq != null && _latestGyroFreq != null) {
      frequencyLabel.value =
      'Por defecto (~${_latestAccelFreq!.toStringAsFixed(1)} Hz / ${_latestGyroFreq!.toStringAsFixed(1)} Hz)';
    } else if (_accelInterval != null || _gyroInterval != null) {
      final accelHz = _accelInterval != null ? (1000 / _accelInterval!.inMilliseconds).toStringAsFixed(0) : '?';
      final gyroHz = _gyroInterval != null ? (1000 / _gyroInterval!.inMilliseconds).toStringAsFixed(0) : '?';
      frequencyLabel.value = 'Personalizada (${accelHz}Hz / ${gyroHz}Hz)';
    }

    if (onNewFrequency != null) {
      onNewFrequency!(_latestAccelFreq, _latestGyroFreq);
    }
  }



  void restartListening() {
    stopListening();
    startListening();
  }

  bool _shouldSampleAccel() {
    if (_accelInterval == null) return true;
    final now = DateTime.now();
    if (_lastAccelSampleTime == null || now.difference(_lastAccelSampleTime!) >= _accelInterval!) {
      _lastAccelSampleTime = now;
      return true;
    }
    return false;
  }

  bool _shouldSampleGyro() {
    if (_gyroInterval == null) return true;
    final now = DateTime.now();
    if (_lastGyroSampleTime == null || now.difference(_lastGyroSampleTime!) >= _gyroInterval!) {
      _lastGyroSampleTime = now;
      return true;
    }
    return false;
  }


  void stopListening() {
    _accelerometerSub?.cancel();
    _gyroscopeSub?.cancel();
    _timer?.cancel();
  }


  void startRecording() {
    _isRecording = true;
  }

  void stopRecording() {
    _isRecording = false;
  }

  void _recordIfNeeded(double ax, double ay, double az, List<double> gyro, double? accelFreq, double? gyroFreq) {
    if (_isRecording) {
      final timestamp = DateTime.now().toIso8601String();
      _recordedData.add([
        timestamp,
        ax, ay, az,
        gyro[0], gyro[1], gyro[2],
        accelFreq?.toStringAsFixed(2) ?? '',
        gyroFreq?.toStringAsFixed(2) ?? '',
      ]);
    }
  }


  void _recordIfBothAvailable() {
    if (_latestAccel != null && _latestGyro != null) {
      final timestamp = DateTime.now().toIso8601String();
      _recordedData.add([
        timestamp,
        ..._latestAccel!,
        ..._latestGyro!,
        _latestAccelFreq?.toStringAsFixed(2) ?? '',
        _latestGyroFreq?.toStringAsFixed(2) ?? ''
      ]);

      // Limpia para evitar registros duplicados
      _latestAccel = null;
      _latestGyro = null;
    }
  }

  Future<String> exportToCsv(BuildContext context) async {
    final downloads = Directory('/storage/emulated/0/Download/csv');
    if (!await downloads.exists()) {
      await downloads.create(recursive: true);
    }
    final path =
        '${downloads.path}/sensor_data_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    final csv = const ListToCsvConverter().convert(_recordedData);
    await file.writeAsString(csv);
    return path;
  }

  void clearData() {
    _recordedData.removeRange(1, _recordedData.length);
    _accelerometerData.clear();
    _gyroscopeData.clear();
  }

  List<List<double>> get accelerometerData => _accelerometerData;
  List<List<double>> get gyroscopeData => _gyroscopeData;
}
