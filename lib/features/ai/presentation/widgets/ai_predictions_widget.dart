import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ai/ai_providers.dart';
// Removed unused import

/// AI Predictions Widget
class AIPredictionsWidget extends ConsumerStatefulWidget {
  const AIPredictionsWidget({super.key});

  @override
  ConsumerState<AIPredictionsWidget> createState() =>
      _AIPredictionsWidgetState();
}

class _AIPredictionsWidgetState extends ConsumerState<AIPredictionsWidget> {
  // Removed unused field
  String _modelName = 'sales_forecast';
  int _days = 30;
  Map<String, dynamic> _predictionData = {};

  @override
  void initState() {
    super.initState();
    // Load sample data
    _predictionData = {
      "historical_sales": [1000, 1100, 1200, 1300, 1400],
      "seasonality": "high",
      "trend": "increasing",
      "external_factors": ["holiday", "promotion"],
    };
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final predictionsState = ref.watch(aiPredictionsProvider(_predictionData));

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
                    'AI Predictions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Model selector
                  DropdownButtonFormField<String>(
                    initialValue: _modelName,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'sales_forecast',
                        child: Text('Sales Forecast'),
                      ),
                      DropdownMenuItem(
                        value: 'demand_prediction',
                        child: Text('Demand Prediction'),
                      ),
                      DropdownMenuItem(
                        value: 'price_optimization',
                        child: Text('Price Optimization'),
                      ),
                      DropdownMenuItem(
                        value: 'customer_behavior',
                        child: Text('Customer Behavior'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _modelName = value ?? 'sales_forecast';
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Days input
                  TextFormField(
                    initialValue: _days.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Prediction Period (Days)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _days = int.tryParse(value) ?? 30;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Data input
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Historical Data (JSON)',
                      border: OutlineInputBorder(),
                      helperText: 'Enter historical data in JSON format',
                    ),
                    maxLines: 6,
                    onChanged: (value) {
                      // Update prediction data when user types
                      setState(() {
                        _predictionData = {'raw_data': value};
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Predict button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _makePrediction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Make Prediction'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Results section
          Expanded(
            child: predictionsState.when(
              data: (predictions) => predictions.isEmpty
                  ? const Center(
                      child: Text(
                        'No predictions yet. Click "Make Prediction" to get started.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : _buildPredictionsList(
                      predictions.cast<Map<String, dynamic>>(),
                    ),
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating predictions...'),
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
                      onPressed: _makePrediction,
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

  Widget _buildPredictionsList(List<Map<String, dynamic>> predictions) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Predictions (${predictions.length})',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            IconButton(
              onPressed: () {
                // Clear predictions by resetting data
                setState(() {
                  _predictionData = {};
                });
              },
              icon: const Icon(Icons.clear),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: predictions.length,
            itemBuilder: (context, index) {
              final prediction = predictions[index];
              return _buildPredictionCard(prediction);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionCard(Map<String, dynamic> prediction) {
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
                    'Model: ${prediction['modelName'] ?? 'Unknown'}',
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
                    color: _getConfidenceColor(prediction['confidence'] ?? 0.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${((prediction['confidence'] ?? 0.0) * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Generated: ${_formatTimestamp(DateTime.tryParse(prediction['timestamp'] ?? '') ?? DateTime.now())}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Predictions visualization
            _buildPredictionsVisualization(prediction['output'] ?? {}),

            if (prediction['metadata'] != null)
              _buildMetadata(prediction['metadata']),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsVisualization(Map<String, dynamic> output) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Predictions:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...output.entries.map((entry) {
          return _buildPredictionItem(entry.key, entry.value);
        }),
      ],
    );
  }

  Widget _buildPredictionItem(String key, dynamic value) {
    if (value is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$key:',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            height: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: value.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 40,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      value[index].toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              '$key: ',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                value.toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }
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

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _makePrediction() {
    try {
      // Parse JSON data
      final data = <String, dynamic>{
        'raw_data': _predictionData,
        'model_name': _modelName,
        'days': _days,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Make prediction by updating data
      setState(() {
        _predictionData = data;
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
