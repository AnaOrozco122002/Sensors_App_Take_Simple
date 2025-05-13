import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'sensor_controller.dart';

class VisualizationPage extends StatefulWidget {
  const VisualizationPage({super.key});

  @override
  State<VisualizationPage> createState() => _VisualizationPageState();
}

class _VisualizationPageState extends State<VisualizationPage> {
  final SensorController _controller = SensorController();
  bool _showAccelerometer = true;
  bool _showGyroscope = true;

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

  void _exportData() async {
    final path = await _controller.exportToCsv(context);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Datos exportados en: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualización de Sensores'),
        actions: [
          IconButton(
            onPressed: _exportData,
            icon: const Icon(Icons.download),
            tooltip: 'Exportar CSV',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _showAccelerometer,
                  onChanged: (value) => setState(() => _showAccelerometer = value!),
                ),
                const Text('Acelerómetro'),
                Checkbox(
                  value: _showGyroscope,
                  onChanged: (value) => setState(() => _showGyroscope = value!),
                ),
                const Text('Giroscopio'),
              ],
            ),
            const SizedBox(height: 10),
            if (_showAccelerometer) _buildChart('Acelerómetro', _controller.accelerometerData),
            if (_showGyroscope) _buildChart('Giroscopio', _controller.gyroscopeData),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(String title, List<List<double>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(show: false),
              gridData: FlGridData(show: true),
              lineBarsData: [
                _createLine(data, 0, Colors.red),   // Eje X
                _createLine(data, 1, Colors.green), // Eje Y
                _createLine(data, 2, Colors.blue),  // Eje Z
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Legend(color: Colors.red, label: 'X'),
            Legend(color: Colors.green, label: 'Y'),
            Legend(color: Colors.blue, label: 'Z'),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  LineChartBarData _createLine(List<List<double>> data, int axis, Color color) {
    final spots = List.generate(
      data.length,
          (i) => FlSpot(i.toDouble(), data[i][axis]),
    );

    return LineChartBarData(
      spots: spots,
      isCurved: false,
      color: color,
      barWidth: 2,
      dotData: FlDotData(show: false),
    );
  }
}

class Legend extends StatelessWidget {
  final Color color;
  final String label;

  const Legend({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
