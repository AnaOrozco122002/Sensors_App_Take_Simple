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

  Duration? _customInterval;
  DateTime? _lastSampleTime;

  int? _lastAccelTimestamp;
  int? _lastGyroTimestamp;

  double? _latestAccelFreq;
  double? _latestGyroFreq;

  void setFrequency(String label, [Duration? interval]) {
    frequencyLabel.value = label;
    _customInterval = interval;
    restartListening();
  }

  void startListening() {
    _lastSampleTime = DateTime.now();

    _accelerometerSub = accelerometerEventStream().listen((event) {
      if (_shouldSample()) {
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
        _recordIfNeeded(event.x, event.y, event.z, _lastGyro, _latestAccelFreq, null);

        _updateFrequencyLabel();
      }
    });

    _gyroscopeSub = gyroscopeEventStream().listen((event) {
      if (_shouldSample()) {
        final now = DateTime.now();
        final currentTimestamp = now.microsecondsSinceEpoch;
        double? gyroFreq;

        if (_lastGyroTimestamp != null) {
          final deltaUs = currentTimestamp - _lastGyroTimestamp!;
          gyroFreq = 1000000 / deltaUs;
          _latestGyroFreq = gyroFreq;
        }
        _lastGyroTimestamp = currentTimestamp;

        gyroscopeValues.value = [event.x, event.y, event.z];
        _gyroscopeData.add([event.x, event.y, event.z]);
        _lastGyro = [event.x, event.y, event.z];

        _recordIfNeeded(
            accelerometerValues.value[0],
            accelerometerValues.value[1],
            accelerometerValues.value[2],
            _lastGyro,
            null,
            _latestGyroFreq);

        _updateFrequencyLabel();
      }
    });
  }

  void _updateFrequencyLabel() {
    if (_customInterval == null && _latestAccelFreq != null && _latestGyroFreq != null) {
      final formatted =
          'Por defecto (~${_latestAccelFreq!.toStringAsFixed(1)} Hz / ${_latestGyroFreq!.toStringAsFixed(1)} Hz)';
      frequencyLabel.value = formatted;
      if (onNewFrequency != null) {
        onNewFrequency!(_latestAccelFreq, _latestGyroFreq);
      }
    }
  }

  void restartListening() {
    stopListening();
    startListening();
  }

  bool _shouldSample() {
    if (_customInterval == null) return true;
    final now = DateTime.now();
    if (_lastSampleTime == null || now.difference(_lastSampleTime!) >= _customInterval!) {
      _lastSampleTime = now;
      return true;
    }
    return false;
  }

  void stopListening() {
    _accelerometerSub?.cancel();
    _gyroscopeSub?.cancel();
  }

  void startRecording() {
    _isRecording = true;
  }

  void stopRecording() {
    _isRecording = false;
  }

  void _recordIfNeeded(double ax, double ay, double az, List<double> gyro,
      double? accelFreq, double? gyroFreq) {
    if (!_isRecording) return;
    final timestamp = DateTime.now().toIso8601String();
    _recordedData.add([
      timestamp,
      ax,
      ay,
      az,
      gyro[0],
      gyro[1],
      gyro[2],
      accelFreq?.toStringAsFixed(2) ?? '',
      gyroFreq?.toStringAsFixed(2) ?? ''
    ]);
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
