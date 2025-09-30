/// Report Statistics domain entity
class ReportStatistics {
  final int totalReports;
  final int completedReports;
  final int pendingReports;
  final int failedReports;
  final double averageProcessingTime;
  final double successRate;
  final DateTime lastGenerated;

  const ReportStatistics({
    this.totalReports = 0,
    this.completedReports = 0,
    this.pendingReports = 0,
    this.failedReports = 0,
    this.averageProcessingTime = 0.0,
    this.successRate = 0.0,
    required this.lastGenerated,
  });

  factory ReportStatistics.fromJson(Map<String, dynamic> json) {
    return ReportStatistics(
      totalReports: json['totalReports'] as int? ?? 0,
      completedReports: json['completedReports'] as int? ?? 0,
      pendingReports: json['pendingReports'] as int? ?? 0,
      failedReports: json['failedReports'] as int? ?? 0,
      averageProcessingTime:
          (json['averageProcessingTime'] as num?)?.toDouble() ?? 0.0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0.0,
      lastGenerated: DateTime.parse(json['lastGenerated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReports': totalReports,
      'completedReports': completedReports,
      'pendingReports': pendingReports,
      'failedReports': failedReports,
      'averageProcessingTime': averageProcessingTime,
      'successRate': successRate,
      'lastGenerated': lastGenerated.toIso8601String(),
    };
  }
}
