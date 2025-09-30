import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deneme1/core/performance/performance_monitor.dart';

/// Performance dashboard page
///
/// Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (context) => const PerformanceDashboard(),
/// ));
/// ```
class PerformanceDashboard extends ConsumerStatefulWidget {
  const PerformanceDashboard({super.key});

  @override
  ConsumerState<PerformanceDashboard> createState() =>
      _PerformanceDashboardState();
}

class _PerformanceDashboardState extends ConsumerState<PerformanceDashboard> {
  late PerformanceMonitor _monitor;
  PerformanceSummary? _summary;
  Map<String, List<PerformanceMetric>> _metrics = {};

  @override
  void initState() {
    super.initState();
    _monitor = PerformanceMonitor.instance;
    _loadPerformanceData();
  }

  void _loadPerformanceData() {
    setState(() {
      _summary = _monitor.getPerformanceSummary();
      _metrics = _monitor.getAllMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Dashboard'),
        actions: [
          IconButton(
            onPressed: _loadPerformanceData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
          ),
          IconButton(
            onPressed: () {
              _monitor.clearMetrics();
              _loadPerformanceData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Metrikler temizlendi')),
              );
            },
            icon: const Icon(Icons.clear_all),
            tooltip: 'Metrikleri Temizle',
          ),
        ],
      ),
      body: _summary == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Performance Summary Cards
                  _buildSummaryCards(),
                  const SizedBox(height: 24),
                  // FPS Chart
                  _buildFPSChart(),
                  const SizedBox(height: 24),
                  // Memory Usage Chart
                  _buildMemoryChart(),
                  const SizedBox(height: 24),
                  // Recent Metrics
                  _buildRecentMetrics(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'FPS',
          _summary!.currentFPS.toStringAsFixed(1),
          'Frames per second',
          Icons.speed,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Memory',
          '${_summary!.currentMemoryUsage.toStringAsFixed(1)} MB',
          'Current memory usage',
          Icons.memory,
          Colors.green,
        ),
        _buildSummaryCard(
          'Active Traces',
          '${_summary!.totalTraces}',
          'Currently running traces',
          Icons.timeline,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Total Metrics',
          '${_summary!.totalMetrics}',
          'Recorded metrics',
          Icons.analytics,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFPSChart() {
    final fpsMetrics = _metrics['fps'] ?? [];
    if (fpsMetrics.isEmpty) {
      return _buildEmptyChart('FPS Verisi Yok');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FPS Trendi',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: _buildLineChart(fpsMetrics, 'FPS')),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryChart() {
    final memoryMetrics = _metrics['memory_usage'] ?? [];
    if (memoryMetrics.isEmpty) {
      return _buildEmptyChart('Memory Verisi Yok');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Memory Kullanımı',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: _buildLineChart(memoryMetrics, 'MB')),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<PerformanceMetric> metrics, String unit) {
    if (metrics.isEmpty) return const SizedBox();

    final maxValue = metrics
        .map((m) => m.value)
        .reduce((a, b) => a > b ? a : b);
    final minValue = metrics
        .map((m) => m.value)
        .reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    return CustomPaint(
      painter: LineChartPainter(
        metrics: metrics,
        maxValue: maxValue,
        minValue: minValue,
        range: range,
        unit: unit,
      ),
      size: const Size(double.infinity, double.infinity),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.show_chart, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentMetrics() {
    final allMetrics = <PerformanceMetric>[];
    for (final metricList in _metrics.values) {
      allMetrics.addAll(metricList);
    }
    allMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son Metrikler',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (allMetrics.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Henüz metrik kaydedilmemiş'),
                ),
              )
            else
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: allMetrics.take(20).length,
                  itemBuilder: (context, index) {
                    final metric = allMetrics[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getMetricColor(metric.name),
                        child: Icon(
                          _getMetricIcon(metric.name),
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      title: Text(metric.name),
                      subtitle: Text(
                        '${metric.value.toStringAsFixed(2)} ${metric.unit}',
                      ),
                      trailing: Text(
                        _formatTime(metric.timestamp),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getMetricColor(String name) {
    switch (name) {
      case 'fps':
        return Colors.blue;
      case 'memory_usage':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getMetricIcon(String name) {
    switch (name) {
      case 'fps':
        return Icons.speed;
      case 'memory_usage':
        return Icons.memory;
      default:
        return Icons.analytics;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}sa önce';
    } else {
      return '${difference.inDays}gün önce';
    }
  }
}

/// Custom painter for line charts
class LineChartPainter extends CustomPainter {
  final List<PerformanceMetric> metrics;
  final double maxValue;
  final double minValue;
  final double range;
  final String unit;

  LineChartPainter({
    required this.metrics,
    required this.maxValue,
    required this.minValue,
    required this.range,
    required this.unit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / (metrics.length - 1);

    for (int i = 0; i < metrics.length; i++) {
      final metric = metrics[i];
      final x = i * stepX;
      final normalizedValue = range > 0
          ? (metric.value - minValue) / range
          : 0.5;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (int i = 0; i < metrics.length; i++) {
      final metric = metrics[i];
      final x = i * stepX;
      final normalizedValue = range > 0
          ? (metric.value - minValue) / range
          : 0.5;
      final y = size.height - (normalizedValue * size.height);

      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
