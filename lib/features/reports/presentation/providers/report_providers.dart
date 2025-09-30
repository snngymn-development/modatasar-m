import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/report_service.dart';
import '../../domain/entities/report.dart';
import '../../../../core/di/providers.dart';

/// Report service provider
final reportServiceProvider = Provider<ReportService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return MockReportService(apiClient: apiClient);
});

/// Generate report provider
final generateReportProvider =
    FutureProvider.family<Report, GenerateReportParams>((ref, params) async {
      final service = ref.read(reportServiceProvider);
      return await service.generateReport(params.type, params.filter);
    });

/// Get report provider
final getReportProvider = FutureProvider.family<Report?, String>((
  ref,
  id,
) async {
  final service = ref.read(reportServiceProvider);
  return await service.getReport(id);
});

/// Reports list provider
final reportsProvider = FutureProvider<List<Report>>((ref) async {
  final service = ref.read(reportServiceProvider);
  return await service.getReports();
});

/// Delete report provider
final deleteReportProvider = FutureProvider.family<void, String>((
  ref,
  id,
) async {
  final service = ref.read(reportServiceProvider);
  await service.deleteReport(id);
});

/// Export report provider
final exportReportProvider = FutureProvider.family<String, ExportReportParams>((
  ref,
  params,
) async {
  final service = ref.read(reportServiceProvider);
  return await service.exportReport(params.reportId, params.format);
});

/// Report templates provider
final reportTemplatesProvider = FutureProvider<List<ReportTemplate>>((
  ref,
) async {
  final service = ref.read(reportServiceProvider);
  return await service.getReportTemplates();
});

/// Report statistics provider
final reportStatisticsProvider = FutureProvider<ReportStatistics>((ref) async {
  final service = ref.read(reportServiceProvider);
  return await service.getReportStatistics();
});

/// Generate report parameters
class GenerateReportParams {
  final ReportType type;
  final ReportFilter filter;

  const GenerateReportParams({required this.type, required this.filter});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GenerateReportParams &&
        other.type == type &&
        other.filter == filter;
  }

  @override
  int get hashCode => type.hashCode ^ filter.hashCode;
}

/// Export report parameters
class ExportReportParams {
  final String reportId;
  final ReportFormat format;

  const ExportReportParams({required this.reportId, required this.format});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExportReportParams &&
        other.reportId == reportId &&
        other.format == format;
  }

  @override
  int get hashCode => reportId.hashCode ^ format.hashCode;
}
