import 'package:flutter/material.dart';

/// Report charts widget for data visualization
class ReportCharts extends StatelessWidget {
  final Map<String, dynamic> data;

  const ReportCharts({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Cards
        if (data['summary'] != null) ...[
          _buildSummaryCards(data['summary'] as Map<String, dynamic>),
          const SizedBox(height: 24),
        ],

        // Charts
        if (data['charts'] != null) ...[
          _buildCharts(data['charts'] as Map<String, dynamic>),
          const SizedBox(height: 24),
        ],

        // Data Tables
        if (data['daily_data'] != null) ...[
          _buildDataTable(
            'Günlük Veriler',
            data['daily_data'] as List<dynamic>,
          ),
          const SizedBox(height: 24),
        ],

        if (data['products'] != null) ...[
          _buildDataTable('Ürünler', data['products'] as List<dynamic>),
          const SizedBox(height: 24),
        ],

        if (data['customers'] != null) ...[
          _buildDataTable('Müşteriler', data['customers'] as List<dynamic>),
          const SizedBox(height: 24),
        ],

        if (data['payments'] != null) ...[
          _buildDataTable('Ödemeler', data['payments'] as List<dynamic>),
        ],
      ],
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> summary) {
    final cards = <Widget>[];

    summary.forEach((key, value) {
      cards.add(
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatKey(key),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatValue(value),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });

    return Row(children: cards);
  }

  Widget _buildCharts(Map<String, dynamic> charts) {
    final chartWidgets = <Widget>[];

    charts.forEach((key, value) {
      if (value is List) {
        chartWidgets.add(
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatKey(key),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(height: 200, child: _buildSimpleChart(value)),
                ],
              ),
            ),
          ),
        );
      }
    });

    return Column(children: chartWidgets);
  }

  Widget _buildSimpleChart(List<dynamic> data) {
    if (data.isEmpty) {
      return const Center(child: Text('Veri bulunamadı'));
    }

    // Simple bar chart
    return CustomPaint(
      painter: SimpleBarChartPainter(data),
      size: const Size(double.infinity, double.infinity),
    );
  }

  Widget _buildDataTable(String title, List<dynamic> data) {
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(child: Text('$title için veri bulunamadı')),
        ),
      );
    }

    final firstItem = data.first as Map<String, dynamic>;
    final columns = firstItem.keys.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: columns
                    .map(
                      (column) => DataColumn(label: Text(_formatKey(column))),
                    )
                    .toList(),
                rows: data.take(10).map((item) {
                  return DataRow(
                    cells: columns
                        .map(
                          (column) =>
                              DataCell(Text(_formatValue(item[column]))),
                        )
                        .toList(),
                  );
                }).toList(),
              ),
            ),
            if (data.length > 10) ...[
              const SizedBox(height: 8),
              Text(
                '... ve ${data.length - 10} kayıt daha',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatValue(dynamic value) {
    if (value is double) {
      return value.toStringAsFixed(2);
    } else if (value is int) {
      return value.toString();
    } else if (value is String) {
      return value;
    } else {
      return value.toString();
    }
  }
}

/// Simple bar chart painter
class SimpleBarChartPainter extends CustomPainter {
  final List<dynamic> data;

  SimpleBarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final maxValue = data
        .map((item) {
          if (item is Map<String, dynamic>) {
            return item.values.whereType<num>().fold(
              0.0,
              (max, value) => value > max ? value.toDouble() : max,
            );
          }
          return 0.0;
        })
        .fold(0.0, (max, value) => value > max ? value : max);

    if (maxValue == 0) return;

    final barWidth = size.width / data.length;
    final barSpacing = barWidth * 0.1;
    final actualBarWidth = barWidth - barSpacing;

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      double value = 0.0;
      String label = '';

      if (item is Map<String, dynamic>) {
        // Get the first numeric value
        final numericValue = item.values.whereType<num>().firstOrNull;
        value = numericValue?.toDouble() ?? 0.0;

        // Get the first string value for label
        final stringValue = item.values.whereType<String>().firstOrNull;
        label = stringValue ?? '';
      } else if (item is num) {
        value = item.toDouble();
        label = value.toString();
      }

      final barHeight = (value / maxValue) * size.height;
      final x = i * barWidth + barSpacing / 2;
      final y = size.height - barHeight;

      // Draw bar
      canvas.drawRect(Rect.fromLTWH(x, y, actualBarWidth, barHeight), paint);

      // Draw border
      canvas.drawRect(
        Rect.fromLTWH(x, y, actualBarWidth, barHeight),
        strokePaint,
      );

      // Draw label
      if (label.isNotEmpty) {
        textPainter.text = TextSpan(
          text: label,
          style: const TextStyle(fontSize: 10, color: Colors.black),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            x + actualBarWidth / 2 - textPainter.width / 2,
            size.height + 4,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
