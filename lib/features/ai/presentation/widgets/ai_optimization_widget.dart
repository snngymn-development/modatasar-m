import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ai/ai_providers.dart';
// Removed unused import

/// AI Optimization Widget
class AIOptimizationWidget extends ConsumerStatefulWidget {
  const AIOptimizationWidget({super.key});

  @override
  ConsumerState<AIOptimizationWidget> createState() =>
      _AIOptimizationWidgetState();
}

class _AIOptimizationWidgetState extends ConsumerState<AIOptimizationWidget> {
  // Removed unused field
  String _optimizationType = 'general';
  Map<String, dynamic> _optimizationData = {};

  @override
  void initState() {
    super.initState();
    // Load sample data
    _optimizationData = {
      "current_operations": {
        "inventory_turnover": 4.2,
        "customer_satisfaction": 0.92,
        "operational_costs": 50000,
        "efficiency_score": 0.75,
      },
      "goals": {
        "increase_efficiency": 0.20,
        "reduce_costs": 0.15,
        "improve_satisfaction": 0.05,
      },
    };
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final optimizationState = ref.watch(
      aiOptimizationProvider(_optimizationData),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Optimization',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Optimization type selector
                  DropdownButtonFormField<String>(
                    initialValue: _optimizationType,
                    decoration: const InputDecoration(
                      labelText: 'Optimization Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'general',
                        child: Text('General'),
                      ),
                      DropdownMenuItem(
                        value: 'inventory',
                        child: Text('Inventory'),
                      ),
                      DropdownMenuItem(
                        value: 'pricing',
                        child: Text('Pricing'),
                      ),
                      DropdownMenuItem(
                        value: 'workflow',
                        child: Text('Workflow'),
                      ),
                      DropdownMenuItem(
                        value: 'resource',
                        child: Text('Resource Allocation'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _optimizationType = value ?? 'general';
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Data input
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Operations Data (JSON)',
                      border: OutlineInputBorder(),
                      helperText: 'Enter your operations data in JSON format',
                    ),
                    maxLines: 8,
                    onChanged: (value) {
                      // Update optimization data when user types
                      setState(() {
                        _optimizationData = {'raw_data': value};
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Optimize button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _generateOptimizations,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Generate Optimizations'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Results section
          Expanded(
            child: optimizationState.when(
              data: (suggestions) => suggestions.isEmpty
                  ? const Center(
                      child: Text(
                        'No optimization suggestions yet. Click "Generate Optimizations" to get started.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : _buildOptimizationsList(
                      suggestions.cast<Map<String, dynamic>>(),
                    ),
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating optimization suggestions...'),
                  ],
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _generateOptimizations,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizationsList(List<Map<String, dynamic>> suggestions) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Optimization Suggestions (${suggestions.length})',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            IconButton(
              onPressed: () {
                // Clear optimizations by resetting data
                setState(() {
                  _optimizationData = {};
                });
              },
              icon: const Icon(Icons.clear),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return _buildOptimizationCard(suggestion);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptimizationCard(Map<String, dynamic> suggestion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    suggestion['title'] ?? 'No title',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(
                      suggestion['priority'] ?? 'medium',
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (suggestion['priority'] ?? 'medium')
                        .toString()
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              suggestion['description'] ?? 'No description',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    suggestion['category'] ?? 'general',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Impact: ${((suggestion['impact'] ?? 0.0) * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Steps
            _buildStepsSection(
              (suggestion['steps'] as List?)?.cast<String>() ?? [],
            ),

            if (suggestion['metadata'] != null)
              _buildMetadata(suggestion['metadata']),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsSection(List<String> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Implementation Steps:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(step, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMetadata(Map<String, dynamic> metadata) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Information:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...metadata.entries.map((entry) {
            return Text(
              '• ${entry.key}: ${entry.value}',
              style: const TextStyle(fontSize: 11),
            );
          }),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _generateOptimizations() {
    try {
      // Parse JSON data
      final data = <String, dynamic>{
        'raw_data': _optimizationData,
        'optimization_type': _optimizationType,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Generate optimizations by updating data
      setState(() {
        _optimizationData = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid JSON data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
