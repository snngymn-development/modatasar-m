import 'package:flutter/material.dart';
import '../../domain/entities/report.dart';

/// Report card widget
class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onExport;

  const ReportCard({
    super.key,
    required this.report,
    required this.onTap,
    required this.onDelete,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Type Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      report.type.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title and Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                report.status.displayName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              report.type.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          onTap();
                          break;
                        case 'export':
                          onExport();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 16),
                            SizedBox(width: 8),
                            Text('Görüntüle'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.download, size: 16),
                            SizedBox(width: 8),
                            Text('Dışa Aktar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Sil', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Description
              if (report.description.isNotEmpty) ...[
                Text(
                  report.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],

              // Footer
              Row(
                children: [
                  // Date Range
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    report.formattedDateRange,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),

                  const Spacer(),

                  // Record Count
                  if (report.recordCount != null) ...[
                    Icon(Icons.data_usage, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${report.recordCount} kayıt',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 16),
                  ],

                  // Created Date
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(report.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (report.status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.processing:
        return Colors.blue;
      case ReportStatus.completed:
        return Colors.green;
      case ReportStatus.failed:
        return Colors.red;
      case ReportStatus.cancelled:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}sa önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}dk önce';
    } else {
      return 'Şimdi';
    }
  }
}
