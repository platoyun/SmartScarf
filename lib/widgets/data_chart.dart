import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/device_data.dart';

class DataChart extends StatelessWidget {
  final List<DeviceData> data;
  
  const DataChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: data.map((d) => FlSpot(
              d.timestamp.millisecondsSinceEpoch.toDouble(),
              d.temperature,
            )).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
} 