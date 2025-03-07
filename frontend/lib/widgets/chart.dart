import 'dart:math';

import 'package:flutter/material.dart';

class SimpleChart extends StatelessWidget {
  final String title;
  final List<double>? data;

  SimpleChart({
    super.key,
    required this.title,
    this.data,
  });

  // Generate random data if none provided
  final List<double> _demoData =
      List.generate(7, (_) => Random().nextDouble() * 20 - 5);

  @override
  Widget build(BuildContext context) {
    final chartData = data ?? _demoData;
    final maxValue = chartData.reduce(max).abs();
    final minValue = chartData.reduce(min).abs();
    final scale = maxValue > minValue ? maxValue : minValue;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Y-axis labels
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('+${scale.toStringAsFixed(1)}%'),
                      const Text('0%'),
                      Text('-${scale.toStringAsFixed(1)}%'),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Chart bars
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                        chartData.length,
                        (index) {
                          final value = chartData[index];
                          final normalizedHeight = (value / (scale * 2)) + 0.5;

                          return Tooltip(
                            message: '${value.toStringAsFixed(2)}%',
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 20,
                                  height: 120 * normalizedHeight,
                                  color: value >= 0 ? Colors.green : Colors.red,
                                ),
                                const SizedBox(height: 4),
                                Text('Day ${index + 1}'),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LineChart extends StatelessWidget {
  final String title;
  final List<double>? data;
  final Color lineColor;

  LineChart({
    super.key,
    required this.title,
    this.data,
    this.lineColor = Colors.blue,
  });

  // Generate random data if none provided
  final List<double> _demoData = List.generate(
      30, (index) => 100 + Random().nextDouble() * 50 * sin(index / 5));

  @override
  Widget build(BuildContext context) {
    final chartData = data ?? _demoData;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            Expanded(
              child: CustomPaint(
                size: Size.infinite,
                painter: _LineChartPainter(
                  data: chartData,
                  lineColor: lineColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;

  _LineChartPainter({
    required this.data,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (data.isEmpty) return;

    final maxValue = data.reduce(max);
    final minValue = data.reduce(min);
    final range = maxValue - minValue;

    final xStep = size.width / (data.length - 1);

    path.moveTo(0, size.height - (data[0] - minValue) / range * size.height);

    for (int i = 1; i < data.length; i++) {
      final x = xStep * i;
      final y = size.height - (data[i] - minValue) / range * size.height;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Draw fill
    final fillPaint = Paint()
      ..color = lineColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
