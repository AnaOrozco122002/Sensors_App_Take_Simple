import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'sensor_controller.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  final SensorController _controller = SensorController();
  bool _isRecording = false;
  final List<String> _frequencies = ['Por defecto', '30 Hz', '50 Hz', '60 Hz'];
  String _selectedFrequency = 'Por defecto';

  double? _lastRecordedAccelFreq;
  double? _lastRecordedGyroFreq;

  @override
  void initState() {
    super.initState();
    _controller.onNewFrequency = (accelFreq, gyroFreq) {
      setState(() {
        _lastRecordedAccelFreq = accelFreq;
        _lastRecordedGyroFreq = gyroFreq;
      });
    };
    _controller.startListening();
  }

  @override
  void dispose() {
    _controller.stopListening();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() => _isRecording = !_isRecording);
    _isRecording ? _controller.startRecording() : _controller.stopRecording();
  }

  void _exportData() async {
    try {
      final path = await _controller.exportToCsv(context);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos exportados en: $path')),
      );

      // Compartir el archivo exportado
      await Share.shareXFiles([XFile(path)], text: 'Datos de sensores exportados');

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
  }

  void _clearData() {
    _controller.clearData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos CSV reiniciados')),
    );
  }

  void _onFrequencyChanged(String? value) {
    if (value == null) return;
    setState(() {
      _selectedFrequency = value;
    });

    switch (value) {
      case '30 Hz':
        _controller.setFrequency('30 Hz', const Duration(milliseconds: 33));
        break;
      case '50 Hz':
        _controller.setFrequency('50 Hz', const Duration(milliseconds: 20));
        break;
      case '60 Hz':
        _controller.setFrequency('60 Hz', const Duration(milliseconds: 16));
        break;
      default:
        _controller.setFrequency('Por defecto');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultInfo = (_selectedFrequency == 'Por defecto')
        ? '\n(accel: ${_lastRecordedAccelFreq?.toStringAsFixed(2) ?? "?"} Hz, '
        'gyro: ${_lastRecordedGyroFreq?.toStringAsFixed(2) ?? "?"} Hz)'
        : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Datos en Tiempo Real')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedFrequency,
              onChanged: _onFrequencyChanged,
              items: _frequencies
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
            ),
            ValueListenableBuilder<String>(
              valueListenable: _controller.frequencyLabel,
              builder: (_, label, __) => Text(
                'Frecuencia usada: $label$defaultInfo',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  const Text('Acelerómetro:'),
                  ValueListenableBuilder(
                    valueListenable: _controller.accelerometerValues,
                    builder: (_, value, __) => Text(
                      'X: ${value[0].toStringAsFixed(2)} '
                          'Y: ${value[1].toStringAsFixed(2)} '
                          'Z: ${value[2].toStringAsFixed(2)}',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Giroscopio:'),
                  ValueListenableBuilder(
                    valueListenable: _controller.gyroscopeValues,
                    builder: (_, value, __) => Text(
                      'X: ${value[0].toStringAsFixed(2)} '
                          'Y: ${value[1].toStringAsFixed(2)} '
                          'Z: ${value[2].toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _toggleRecording,
                  child: Text(_isRecording ? 'Detener Grabación' : 'Grabar'),
                ),
                ElevatedButton(
                  onPressed: _exportData,
                  child: const Text('Exportar CSV'),
                ),
                ElevatedButton(
                  onPressed: _clearData,
                  child: const Text('Reiniciar'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
