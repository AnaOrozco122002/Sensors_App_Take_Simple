import 'package:flutter/material.dart';
import 'sensor_controller.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  final SensorController _controller = SensorController();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
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
      final path = await _controller.exportToCsv(context); //
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos exportados en: $path')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datos en Tiempo Real')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const Text('Acelerómetro:'),
                  ValueListenableBuilder(
                    valueListenable: _controller.accelerometerValues,
                    builder: (context, value, _) => Text(
                      'X: ${value[0].toStringAsFixed(2)} '
                          'Y: ${value[1].toStringAsFixed(2)} '
                          'Z: ${value[2].toStringAsFixed(2)}',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Giroscopio:'),
                  ValueListenableBuilder(
                    valueListenable: _controller.gyroscopeValues,
                    builder: (context, value, _) => Text(
                      'X: ${value[0].toStringAsFixed(2)} '
                          'Y: ${value[1].toStringAsFixed(2)} '
                          'Z: ${value[2].toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _toggleRecording,
                  child: Text(_isRecording ? 'Detener Grabación' : 'Grabar'),
                ),
                ElevatedButton(
                  onPressed: _exportData,
                  child: const Text('Exportar CSV'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
