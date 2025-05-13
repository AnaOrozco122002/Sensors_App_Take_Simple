import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SensorChart extends StatelessWidget {
  final String selectedSensor;
  final List<List<double>> accelData;
  final List<List<double>> gyroData;

  const SensorChart({
    super.key,
    required this.selectedSensor,
    required this.accelData,
    required this.gyroData,
  });

  List<FlSpot> _buildSpots(List<List<double>> data, int axis) {
    return data
        .map((row) => FlSpot(
      (row[0] - data.first[0]) / 1000, // tiempo en segundos
      row[axis],
    ))
        .toList();
  }

  LineChartBarData _line(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      dotData: FlDotData(show: false),
      color: color,
      belowBarData: BarAreaData(show: false),
      isStrokeCapRound: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final useAccel = selectedSensor != 'Giroscopio';
    final useGyro = selectedSensor != 'Acelerómetro';

    List<LineChartBarData> lines = [];

    if (useAccel && accelData.length > 1) {
      lines.addAll([
        _line(_buildSpots(accelData, 1), Colors.red),
        _line(_buildSpots(accelData, 2), Colors.green),
        _line(_buildSpots(accelData, 3), Colors.blue),
      ]);
    }

    if (useGyro && gyroData.length > 1) {
      lines.addAll([
        _line(_buildSpots(gyroData, 1), Colors.orange),
        _line(_buildSpots(gyroData, 2), Colors.purple),
        _line(_buildSpots(gyroData, 3), Colors.teal),
      ]);
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: LineChart(
        LineChartData(
          lineBarsData: lines,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }
}
