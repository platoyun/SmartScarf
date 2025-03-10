import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthDataCard extends StatelessWidget {
  final String title;
  final String currentValue;
  final List<FlSpot>? chartData;
  final String unit;
  final Color color;
  final String? status;

  const HealthDataCard({
    super.key,
    required this.title,
    required this.currentValue,
    this.chartData,
    required this.unit,
    required this.color,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                currentValue,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(unit),
            ],
          ),
          if (status != null) ...[
            const SizedBox(height: 4),
            Text(
              status!,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
          if (chartData != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData!,
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
} 