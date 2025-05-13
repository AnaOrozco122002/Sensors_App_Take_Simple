import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class SensorController {
  final ValueNotifier<List<double>> accelerometerValues = ValueNotifier([0.0, 0.0, 0.0]);
  final ValueNotifier<List<double>> gyroscopeValues = ValueNotifier([0.0, 0.0, 0.0]);

  final List<List<dynamic>> _recordedData = [
    ['timestamp', 'ax', 'ay', 'az', 'gx', 'gy', 'gz']
  ];

  final List<List<double>> _accelerometerData = [];
  final List<List<double>> _gyroscopeData = [];

  StreamSubscription<AccelerometerEvent>? _accelerometerSub;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSub;

  bool _isRecording = false;
  List<double> _lastGyro = [0.0, 0.0, 0.0];

  void startListening() {
    _accelerometerSub = accelerometerEventStream().listen((event) {
      accelerometerValues.value = [event.x, event.y, event.z];
      _accelerometerData.add([event.x, event.y, event.z]);
      _recordIfNeeded(event.x, event.y, event.z, _lastGyro);
    });

    _gyroscopeSub = gyroscopeEventStream().listen((event) {
      gyroscopeValues.value = [event.x, event.y, event.z];
      _gyroscopeData.add([event.x, event.y, event.z]);
      _lastGyro = [event.x, event.y, event.z];
    });
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

  void _recordIfNeeded(double ax, double ay, double az, List<double> gyro) {
    if (!_isRecording) return;
    final timestamp = DateTime.now().toIso8601String();
    _recordedData.add([timestamp, ax, ay, az, gyro[0], gyro[1], gyro[2]]);
  }

  Future<String> exportToCsv(BuildContext context) async {
    final directory = Directory('/storage/emulated/0/Download/csv');
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }
    final path = '${directory.path}/sensor_data_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    final csv = const ListToCsvConverter().convert(_recordedData);
    await file.writeAsString(csv);
    return path;
  }

  List<List<double>> get accelerometerData => _accelerometerData;
  List<List<double>> get gyroscopeData => _gyroscopeData;
}
