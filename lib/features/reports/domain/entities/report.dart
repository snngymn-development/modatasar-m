/// Report domain entity
///
/// Usage:
/// ```dart
/// final report = Report(
///   id: 'RPT-001',
///   title: 'Sales Report',
///   type: ReportType.sales,
///   data: reportData,
/// );
/// ```
class Report {
  final String id;
  final String title;
  final String description;
  final ReportType type;
  final ReportStatus status;
  final Map<String, dynamic> data;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final List<String> tags;
  final ReportFormat format;
  final String? filePath;
  final int? recordCount;

  const Report({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.data,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.tags = const [],
    this.format = ReportFormat.json,
    this.filePath,
    this.recordCount,
  });

  /// Create a copy with updated values
  Report copyWith({
    String? id,
    String? title,
    String? description,
    ReportType? type,
    ReportStatus? status,
    Map<String, dynamic>? data,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    List<String>? tags,
    ReportFormat? format,
    String? filePath,
    int? recordCount,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      data: data ?? this.data,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      tags: tags ?? this.tags,
      format: format ?? this.format,
      filePath: filePath ?? this.filePath,
      recordCount: recordCount ?? this.recordCount,
    );
  }

  /// Check if report is completed
  bool get isCompleted => status == ReportStatus.completed;

  /// Check if report is processing
  bool get isProcessing => status == ReportStatus.processing;

  /// Check if report failed
  bool get isFailed => status == ReportStatus.failed;

  /// Get duration of report period
  Duration get duration => endDate.difference(startDate);

  /// Get formatted date range
  String get formattedDateRange {
    final start = '${startDate.day}/${startDate.month}/${startDate.year}';
    final end = '${endDate.day}/${endDate.month}/${endDate.year}';
    return '$start - $end';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Report &&
        other.id == id &&
        other.title == title &&
        other.type == type &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ type.hashCode ^ status.hashCode;
  }

  @override
  String toString() {
    return 'Report(id: $id, title: $title, type: ${type.name}, status: ${status.name})';
  }
}

/// Report type enumeration
enum ReportType {
  sales,
  inventory,
  customer,
  payment,
  financial,
  performance,
  custom;

  String get displayName {
    switch (this) {
      case ReportType.sales:
        return 'Satış Raporu';
      case ReportType.inventory:
        return 'Envanter Raporu';
      case ReportType.customer:
        return 'Müşteri Raporu';
      case ReportType.payment:
        return 'Ödeme Raporu';
      case ReportType.financial:
        return 'Mali Rapor';
      case ReportType.performance:
        return 'Performans Raporu';
      case ReportType.custom:
        return 'Özel Rapor';
    }
  }

  String get icon {
    switch (this) {
      case ReportType.sales:
        return '📊';
      case ReportType.inventory:
        return '📦';
      case ReportType.customer:
        return '👥';
      case ReportType.payment:
        return '💳';
      case ReportType.financial:
        return '💰';
      case ReportType.performance:
        return '⚡';
      case ReportType.custom:
        return '📋';
    }
  }
}

/// Report status enumeration
enum ReportStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled;

  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Beklemede';
      case ReportStatus.processing:
        return 'İşleniyor';
      case ReportStatus.completed:
        return 'Tamamlandı';
      case ReportStatus.failed:
        return 'Başarısız';
      case ReportStatus.cancelled:
        return 'İptal Edildi';
    }
  }

  String get color {
    switch (this) {
      case ReportStatus.pending:
        return 'orange';
      case ReportStatus.processing:
        return 'blue';
      case ReportStatus.completed:
        return 'green';
      case ReportStatus.failed:
        return 'red';
      case ReportStatus.cancelled:
        return 'grey';
    }
  }
}

/// Report format enumeration
enum ReportFormat {
  json,
  csv,
  excel,
  pdf,
  html;

  String get displayName {
    switch (this) {
      case ReportFormat.json:
        return 'JSON';
      case ReportFormat.csv:
        return 'CSV';
      case ReportFormat.excel:
        return 'Excel';
      case ReportFormat.pdf:
        return 'PDF';
      case ReportFormat.html:
        return 'HTML';
    }
  }

  String get fileExtension {
    switch (this) {
      case ReportFormat.json:
        return '.json';
      case ReportFormat.csv:
        return '.csv';
      case ReportFormat.excel:
        return '.xlsx';
      case ReportFormat.pdf:
        return '.pdf';
      case ReportFormat.html:
        return '.html';
    }
  }
}

/// Report filter data class
class ReportFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? categories;
  final List<String>? tags;
  final Map<String, dynamic>? customFilters;

  const ReportFilter({
    this.startDate,
    this.endDate,
    this.categories,
    this.tags,
    this.customFilters,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportFilter &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.categories == categories &&
        other.tags == tags;
  }

  @override
  int get hashCode {
    return startDate.hashCode ^
        endDate.hashCode ^
        categories.hashCode ^
        tags.hashCode;
  }

  @override
  String toString() {
    return 'ReportFilter(startDate: $startDate, endDate: $endDate, categories: $categories)';
  }
}

/// Report template data class
class ReportTemplate {
  final String id;
  final String name;
  final String description;
  final ReportType type;
  final Map<String, dynamic> configuration;
  final List<String> requiredFields;
  final bool isDefault;

  const ReportTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.configuration,
    required this.requiredFields,
    this.isDefault = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportTemplate &&
        other.id == id &&
        other.name == name &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ type.hashCode;
  }

  @override
  String toString() {
    return 'ReportTemplate(id: $id, name: $name, type: ${type.name})';
  }
}
