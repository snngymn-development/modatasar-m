import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/ai_chat_widget.dart';
import '../widgets/ai_analysis_widget.dart';
import '../widgets/ai_recommendations_widget.dart';
import '../widgets/ai_predictions_widget.dart';
import '../widgets/ai_optimization_widget.dart';

/// AI Dashboard Page
class AIDashboard extends ConsumerStatefulWidget {
  const AIDashboard({super.key});

  @override
  ConsumerState<AIDashboard> createState() => _AIDashboardState();
}

class _AIDashboardState extends ConsumerState<AIDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.chat), text: 'Chat'),
            Tab(icon: Icon(Icons.analytics), text: 'Analysis'),
            Tab(icon: Icon(Icons.recommend), text: 'Recommendations'),
            Tab(icon: Icon(Icons.trending_up), text: 'Predictions'),
            Tab(icon: Icon(Icons.tune), text: 'Optimization'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AIChatWidget(),
          AIAnalysisWidget(),
          AIRecommendationsWidget(),
          AIPredictionsWidget(),
          AIOptimizationWidget(),
        ],
      ),
    );
  }
}
