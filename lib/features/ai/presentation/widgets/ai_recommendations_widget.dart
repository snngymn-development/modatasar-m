import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ai/ai_providers.dart';
// Removed unused import

/// AI Recommendations Widget
class AIRecommendationsWidget extends ConsumerStatefulWidget {
  const AIRecommendationsWidget({super.key});

  @override
  ConsumerState<AIRecommendationsWidget> createState() =>
      _AIRecommendationsWidgetState();
}

class _AIRecommendationsWidgetState
    extends ConsumerState<AIRecommendationsWidget> {
  // Removed unused field
  String _category = 'general';
  Map<String, dynamic> _recommendationData = {};

  @override
  void initState() {
    super.initState();
    // Load sample data
    _recommendationData = {
      "user_id": "user_123",
      "purchase_history": ["electronics", "clothing", "books"],
      "preferences": ["quality", "price", "brand"],
      "budget": 1000,
    };
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recommendationsState = ref.watch(
      aiRecommendationsProvider(_recommendationData),
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
                    'AI Recommendations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Category selector
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'general',
                        child: Text('General'),
                      ),
                      DropdownMenuItem(
                        value: 'products',
                        child: Text('Products'),
                      ),
                      DropdownMenuItem(
                        value: 'services',
                        child: Text('Services'),
                      ),
                      DropdownMenuItem(
                        value: 'content',
                        child: Text('Content'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _category = value ?? 'general';
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Data input
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'User Data (JSON)',
                      border: OutlineInputBorder(),
                      helperText: 'Enter user data in JSON format',
                    ),
                    maxLines: 6,
                    onChanged: (value) {
                      // Update recommendation data when user types
                      setState(() {
                        _recommendationData = {'raw_data': value};
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Generate button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _generateRecommendations,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Generate Recommendations'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Results section
          Expanded(
            child: recommendationsState.when(
              data: (recommendations) => recommendations.isEmpty
                  ? const Center(
                      child: Text(
                        'No recommendations yet. Click "Generate Recommendations" to get started.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : _buildRecommendationsList(
                      recommendations.cast<Map<String, dynamic>>(),
                    ),
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating recommendations...'),
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
                      onPressed: _generateRecommendations,
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

  Widget _buildRecommendationsList(List<Map<String, dynamic>> recommendations) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommendations (${recommendations.length})',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            IconButton(
              onPressed: () {
                // Clear recommendations by resetting data
                setState(() {
                  _recommendationData = {};
                });
              },
              icon: const Icon(Icons.clear),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return _buildRecommendationCard(recommendation);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> recommendation) {
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
                    recommendation['title'] ?? 'No title',
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
                    color: _getScoreColor(recommendation['score'] ?? 0.0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${((recommendation['score'] ?? 0.0) * 100).toInt()}%',
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
              recommendation['description'] ?? 'No description',
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
                    recommendation['category'] ?? 'general',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Type: ${recommendation['type'] ?? 'unknown'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            if (recommendation['metadata'] != null)
              _buildMetadata(recommendation['metadata']),
          ],
        ),
      ),
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

  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  void _generateRecommendations() {
    try {
      // Parse JSON data
      final data = <String, dynamic>{
        'raw_data': _recommendationData,
        'category': _category,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Generate recommendations by updating data
      setState(() {
        _recommendationData = data;
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
