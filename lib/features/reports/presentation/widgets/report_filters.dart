import 'package:flutter/material.dart';
import '../../domain/entities/report.dart';

/// Report filters widget
class ReportFilters extends StatefulWidget {
  final ReportFilter currentFilter;
  final Function(ReportFilter) onFilterChanged;

  const ReportFilters({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<ReportFilters> createState() => _ReportFiltersState();
}

class _ReportFiltersState extends State<ReportFilters> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late List<String> _selectedCategories;
  late List<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _startDate = widget.currentFilter.startDate;
    _endDate = widget.currentFilter.endDate;
    _selectedCategories = widget.currentFilter.categories ?? [];
    _selectedTags = widget.currentFilter.tags ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rapor Filtreleri'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range
            Text(
              'Tarih Aralığı',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectStartDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _startDate != null
                                ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                : 'Başlangıç Tarihi',
                            style: TextStyle(
                              color: _startDate != null
                                  ? Colors.black
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('to'),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: _selectEndDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _endDate != null
                                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                : 'Bitiş Tarihi',
                            style: TextStyle(
                              color: _endDate != null
                                  ? Colors.black
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Categories
            Text(
              'Kategoriler',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _getCategoryChips()),
            const SizedBox(height: 16),

            // Tags
            Text(
              'Etiketler',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _getTagChips()),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _clearFilters, child: const Text('Temizle')),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(onPressed: _applyFilters, child: const Text('Uygula')),
      ],
    );
  }

  List<Widget> _getCategoryChips() {
    final categories = [
      'Satış',
      'Envanter',
      'Müşteri',
      'Ödeme',
      'Mali',
      'Performans',
    ];

    return categories.map((category) {
      final isSelected = _selectedCategories.contains(category);
      return FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _selectedCategories.add(category);
            } else {
              _selectedCategories.remove(category);
            }
          });
        },
      );
    }).toList();
  }

  List<Widget> _getTagChips() {
    final tags = ['Günlük', 'Haftalık', 'Aylık', 'Yıllık', 'Özel', 'Otomatik'];

    return tags.map((tag) {
      final isSelected = _selectedTags.contains(tag);
      return FilterChip(
        label: Text(tag),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _selectedTags.add(tag);
            } else {
              _selectedTags.remove(tag);
            }
          });
        },
      );
    }).toList();
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
        // Ensure end date is not before start date
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate:
          _startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedCategories.clear();
      _selectedTags.clear();
    });
  }

  void _applyFilters() {
    final filter = ReportFilter(
      startDate: _startDate,
      endDate: _endDate,
      categories: _selectedCategories.isNotEmpty ? _selectedCategories : null,
      tags: _selectedTags.isNotEmpty ? _selectedTags : null,
    );

    widget.onFilterChanged(filter);
    Navigator.of(context).pop();
  }
}
