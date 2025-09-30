import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/report.dart';
import '../widgets/report_card.dart';
import '../widgets/report_filters.dart';
import '../widgets/report_charts.dart';
import '../providers/report_providers.dart';

/// Export format enum
enum ExportFormat { pdf, excel, csv }

/// Reports dashboard page
///
/// Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (context) => const ReportsDashboard(),
/// ));
/// ```
class ReportsDashboard extends ConsumerStatefulWidget {
  const ReportsDashboard({super.key});

  @override
  ConsumerState<ReportsDashboard> createState() => _ReportsDashboardState();
}

class _ReportsDashboardState extends ConsumerState<ReportsDashboard> {
  ReportType _selectedType = ReportType.sales;
  ReportFilter _currentFilter = const ReportFilter();
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsProvider);
    final statisticsAsync = ref.watch(reportStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Raporlar'),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtreler',
          ),
          IconButton(
            onPressed: _refreshReports,
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Cards
          statisticsAsync.when(
            data: (stats) =>
                _buildStatisticsCards(stats as Map<String, dynamic>),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('İstatistikler yüklenemedi: $error'),
            ),
          ),

          // Report Type Selector
          _buildReportTypeSelector(),

          // Reports List
          Expanded(
            child: reportsAsync.when(
              data: (reports) => _buildReportsList(reports),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Raporlar yüklenirken hata oluştu',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshReports,
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isGenerating ? null : _generateReport,
        icon: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: Text(_isGenerating ? 'Oluşturuluyor...' : 'Yeni Rapor'),
      ),
    );
  }

  Widget _buildStatisticsCards(Map<String, dynamic> stats) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            'Toplam Rapor',
            (stats['totalReports'] ?? 0).toString(),
            Icons.assessment,
            Colors.blue,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Tamamlanan',
            (stats['completedReports'] ?? 0).toString(),
            Icons.check_circle,
            Colors.green,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Başarısız',
            (stats['failedReports'] ?? 0).toString(),
            Icons.error,
            Colors.red,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Beklemede',
            (stats['pendingReports'] ?? 0).toString(),
            Icons.pending,
            Colors.orange,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Başarı Oranı',
            '${((stats['successRate'] ?? 0.0) * 100).toStringAsFixed(1)}%',
            Icons.trending_up,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
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
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ReportType.values.length,
        itemBuilder: (context, index) {
          final type = ReportType.values[index];
          final isSelected = _selectedType == type;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(type.icon),
                  const SizedBox(width: 4),
                  Text(type.displayName),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedType = type;
                  });
                }
              },
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[700],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportsList(List<Report> reports) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assessment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Henüz rapor oluşturulmamış',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni rapor oluşturmak için + butonuna basın',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return ReportCard(
          report: report,
          onTap: () => _viewReport(report),
          onDelete: () => _deleteReport(report),
          onExport: () => _exportReport(report),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => ReportFilters(
        currentFilter: _currentFilter,
        onFilterChanged: (filter) {
          setState(() {
            _currentFilter = filter;
          });
          ref.invalidate(reportsProvider);
        },
      ),
    );
  }

  void _refreshReports() {
    ref.invalidate(reportsProvider);
    ref.invalidate(reportStatisticsProvider);
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final report = await ref.read(
        generateReportProvider(
          GenerateReportParams(type: _selectedType, filter: _currentFilter),
        ).future,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${report.title} oluşturuldu'),
            action: SnackBarAction(
              label: 'Görüntüle',
              onPressed: () => _viewReport(report),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rapor oluşturulamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _viewReport(Report report) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ReportDetailPage(report: report)),
    );
  }

  Future<void> _deleteReport(Report report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raporu Sil'),
        content: Text(
          '${report.title} raporunu silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(deleteReportProvider(report.id).future);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Rapor silindi')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rapor silinemedi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _exportReport(Report report) async {
    try {
      final filePath = await ref.read(
        exportReportProvider(
          ExportReportParams(reportId: report.id, format: ReportFormat.pdf),
        ).future,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rapor dışa aktarıldı: $filePath'),
            action: SnackBarAction(
              label: 'Aç',
              onPressed: () {
                // Open file
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rapor dışa aktarılamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Report detail page
class ReportDetailPage extends StatelessWidget {
  final Report report;

  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(report.title),
        actions: [
          IconButton(
            onPressed: () {
              // Share report
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () {
              // Export report
            },
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rapor Bilgileri',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Tür', report.type.displayName),
                    _buildInfoRow('Durum', report.status.displayName),
                    _buildInfoRow('Tarih Aralığı', report.formattedDateRange),
                    _buildInfoRow(
                      'Oluşturulma',
                      _formatDateTime(report.createdAt),
                    ),
                    if (report.recordCount != null)
                      _buildInfoRow(
                        'Kayıt Sayısı',
                        report.recordCount.toString(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Report Data
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rapor Verileri',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ReportCharts(data: report.data),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
