import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'sensor_controller.dart';

class SensorPage extends StatefulWidget {
  final SensorController controller;

  const SensorPage({super.key, required this.controller});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  bool _isRecording = false;
  final List<String> _frequencies = ['20 Hz', '30 Hz', '50 Hz', '60 Hz'];
  String _selectedFrequency = '20 Hz';

  double? _lastRecordedAccelFreq;
  double? _lastRecordedGyroFreq;

  @override
  void initState() {
    super.initState();

    // Establece frecuencia inicial a 20 Hz
    widget.controller.setFrequency('20 Hz', const Duration(milliseconds: 50));

    widget.controller.onNewFrequency = (accelFreq, gyroFreq) {
      setState(() {
        _lastRecordedAccelFreq = accelFreq;
        _lastRecordedGyroFreq = gyroFreq;
      });
    };
    widget.controller.startListening();
  }

  @override
  void dispose() {
    widget.controller.stopListening();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() => _isRecording = !_isRecording);
    _isRecording ? widget.controller.startRecording() : widget.controller.stopRecording();
  }

  void _exportData() async {
    try {
      final path = await widget.controller.exportToCsv(context);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos exportados en: $path')),
      );

      await Share.shareXFiles([XFile(path)], text: 'Datos de sensores exportados');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
  }

  void _clearData() {
    widget.controller.clearData();
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
      case '20 Hz':
        widget.controller.setFrequency('20 Hz', const Duration(milliseconds: 50));
        break;
      case '30 Hz':
        widget.controller.setFrequency('30 Hz', const Duration(milliseconds: 33));
        break;
      case '50 Hz':
        widget.controller.setFrequency('50 Hz', const Duration(milliseconds: 20));
        break;
      case '60 Hz':
        widget.controller.setFrequency('60 Hz', const Duration(milliseconds: 16));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Datos en Tiempo Real')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.speed, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text('Frecuencia', style: theme.textTheme.titleLarge),
                            ],
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<String>(
                            value: _selectedFrequency,
                            onChanged: _onFrequencyChanged,
                            items: _frequencies
                                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                                .toList(),
                          ),
                          const SizedBox(height: 8),
                          ValueListenableBuilder<String>(
                            valueListenable: widget.controller.frequencyLabel,
                            builder: (_, label, __) => Text(
                              'Frecuencia usada: $label\n'
                                  '(accel: ${_lastRecordedAccelFreq?.toStringAsFixed(2) ?? "?"} Hz, '
                                  'gyro: ${_lastRecordedGyroFreq?.toStringAsFixed(2) ?? "?"} Hz)',
                              textAlign: TextAlign.start,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.straighten, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text('Acelerómetro', style: theme.textTheme.titleLarge),
                            ],
                          ),
                          const Divider(thickness: 1.2),
                          const SizedBox(height: 4),
                          ValueListenableBuilder(
                            valueListenable: widget.controller.accelerometerValues,
                            builder: (_, value, __) => Text(
                              'X: ${value[0].toStringAsFixed(2)}  '
                                  'Y: ${value[1].toStringAsFixed(2)}  '
                                  'Z: ${value[2].toStringAsFixed(2)}',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.rotate_right, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text('Giroscopio', style: theme.textTheme.titleLarge),
                            ],
                          ),
                          const Divider(thickness: 1.2),
                          const SizedBox(height: 4),
                          ValueListenableBuilder(
                            valueListenable: widget.controller.gyroscopeValues,
                            builder: (_, value, __) => Text(
                              'X: ${value[0].toStringAsFixed(2)}  '
                                  'Y: ${value[1].toStringAsFixed(2)}  '
                                  'Z: ${value[2].toStringAsFixed(2)}',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                  ),
                  child: const Text('Exportar CSV'),
                ),
                ElevatedButton(
                  onPressed: _clearData,
                  child: const Text('Reiniciar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
