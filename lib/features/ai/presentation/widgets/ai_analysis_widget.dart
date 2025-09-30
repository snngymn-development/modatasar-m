import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ai/ai_providers.dart';
// Removed unused import

/// AI Analysis Widget
class AIAnalysisWidget extends ConsumerStatefulWidget {
  const AIAnalysisWidget({super.key});

  @override
  ConsumerState<AIAnalysisWidget> createState() => _AIAnalysisWidgetState();
}

class _AIAnalysisWidgetState extends ConsumerState<AIAnalysisWidget> {
  // Removed unused field
  String _analysisType = 'general';
  Map<String, dynamic> _analysisData = {};

  @override
  void initState() {
    super.initState();
    // Load sample data
    _analysisData = {
      "sales": 125000,
      "growth_rate": 0.15,
      "customer_satisfaction": 0.92,
      "inventory_turnover": 4.2,
      "profit_margin": 0.18,
    };
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(aiAnalysisProvider(_analysisData));

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
                    'Data Analysis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Analysis type selector
                  DropdownButtonFormField<String>(
                    initialValue: _analysisType,
                    decoration: const InputDecoration(
                      labelText: 'Analysis Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'general',
                        child: Text('General'),
                      ),
                      DropdownMenuItem(value: 'sales', child: Text('Sales')),
                      DropdownMenuItem(
                        value: 'financial',
                        child: Text('Financial'),
                      ),
                      DropdownMenuItem(
                        value: 'customer',
                        child: Text('Customer'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _analysisType = value ?? 'general';
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Data input
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Data (JSON)',
                      border: OutlineInputBorder(),
                      helperText: 'Enter your data in JSON format',
                    ),
                    maxLines: 8,
                    onChanged: (value) {
                      // Update analysis data when user types
                      setState(() {
                        _analysisData = {'raw_data': value};
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Analyze button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _analyzeData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Analyze Data'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Results section
          Expanded(
            child: analysisState.when(
              data: (analysis) => const Center(
                child: Text(
                  'No analysis results yet. Click "Analyze Data" to get started.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Analyzing data...'),
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
                      onPressed: _analyzeData,
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

  // Removed unused method

  // Removed unused method

  // Removed unused method

  // Removed unused method

  void _analyzeData() {
    try {
      // Parse JSON data
      final data = <String, dynamic>{
        'raw_data': _analysisData,
        'analysis_type': _analysisType,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Update analysis data
      setState(() {
        _analysisData = data;
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
