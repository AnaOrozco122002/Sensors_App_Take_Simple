import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'sensor_controller.dart';

class VisualizationPage extends StatelessWidget {
  final SensorController controller;

  const VisualizationPage({super.key, required this.controller});

  List<FlSpot> _extractAxisData(List<List<double>> data, int axisIndex) {
    final maxPoints = 200;
    final start = data.length > maxPoints ? data.length - maxPoints : 0;
    return List.generate(data.length - start, (i) {
      final x = i.toDouble();
      final y = data[start + i].length > axisIndex ? data[start + i][axisIndex] : 0.0;
      return FlSpot(x, y);
    });
  }

  Widget _buildChart(List<List<double>> data, int axisIndex, String label, Color color) {
    final spots = _extractAxisData(data, axisIndex);

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          minY: -20,
          maxY: 20,
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return value % 40 == 0
                      ? Text('${value.toInt()}', style: const TextStyle(fontSize: 10))
                      : const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(8),
              tooltipBorderRadius: BorderRadius.circular(8),
              tooltipMargin: 8,
              getTooltipColor: (touchedSpot) => Colors.black,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.x.toInt()}, ${spot.y.toStringAsFixed(2)}',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Visualización en Tiempo Real')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            const Text('Acelerómetro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildChart(controller.accelerometerData, 1, 'X', theme.colorScheme.primary),
            const SizedBox(height: 16),
            _buildChart(controller.accelerometerData, 2, 'Y', theme.colorScheme.secondary),
            const SizedBox(height: 16),
            _buildChart(controller.accelerometerData, 3, 'Z', theme.colorScheme.tertiary),

            const SizedBox(height: 24),
            const Text('Giroscopio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildChart(controller.gyroscopeData, 1, 'X', theme.colorScheme.primary),
            const SizedBox(height: 16),
            _buildChart(controller.gyroscopeData, 2, 'Y', theme.colorScheme.secondary),
            const SizedBox(height: 16),
            _buildChart(controller.gyroscopeData, 3, 'Z', theme.colorScheme.tertiary),
          ],
        ),
      ),
    );
  }
}
