import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deneme1/core/ai/ai_service.dart';
import 'package:deneme1/core/ai/ai_models.dart';
import 'package:deneme1/core/network/result.dart';

/// Chat Response model
class ChatResponse {
  final String id;
  final String content;
  final String role;
  final DateTime timestamp;

  const ChatResponse({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
  });
}

/// Chat Role enum
enum ChatRole { user, assistant }

/// Data Analysis model
class DataAnalysis {
  final String id;
  final String summary;
  final List<String> insights;
  final Map<String, dynamic> metrics;
  final DateTime timestamp;

  const DataAnalysis({
    required this.id,
    required this.summary,
    required this.insights,
    required this.metrics,
    required this.timestamp,
  });
}

/// Prediction model
class Prediction {
  final String id;
  final String modelName;
  final Map<String, dynamic> prediction;
  final double confidence;
  final DateTime timestamp;

  const Prediction({
    required this.id,
    required this.modelName,
    required this.prediction,
    required this.confidence,
    required this.timestamp,
  });
}

/// Prediction Session model
class PredictionSession {
  final String id;
  final String userId;
  final List<Prediction> predictions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PredictionSession({
    required this.id,
    required this.userId,
    required this.predictions,
    required this.createdAt,
    this.updatedAt,
  });
}

/// Optimization model
class Optimization {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final double impact;
  final List<String> steps;
  final DateTime timestamp;

  const Optimization({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.impact,
    required this.steps,
    required this.timestamp,
  });
}

/// AI service provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

/// Chat provider
final chatProvider = FutureProvider.family<ChatResponse, String>((
  ref,
  message,
) async {
  final service = ref.read(aiServiceProvider);
  final result = await service.generateText(message);
  if (result.isSuccess) {
    return ChatResponse(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: result.data,
      role: ChatRole.assistant.name,
      timestamp: DateTime.now(),
    );
  } else {
    throw Exception(result.error.toString());
  }
});

/// Data analysis provider
final dataAnalysisProvider =
    FutureProvider.family<DataAnalysis, Map<String, dynamic>>((
      ref,
      data,
    ) async {
      final service = ref.read(aiServiceProvider);
      final result = await service.analyzeData(data);
      if (result.isSuccess) {
        final analysisResult = result.data;
        return DataAnalysis(
          id: analysisResult.id,
          summary: analysisResult.summary,
          insights: analysisResult.insights,
          metrics: analysisResult.metrics,
          timestamp: analysisResult.timestamp,
        );
      } else {
        throw Exception(result.error.toString());
      }
    });

/// AI Analysis provider
final aiAnalysisProvider =
    FutureProvider.family<AIAnalysisResult, Map<String, dynamic>>((
      ref,
      data,
    ) async {
      final service = ref.read(aiServiceProvider);
      final result = await service.analyzeData(data);
      if (result.isSuccess) {
        return result.data;
      } else {
        throw Exception(result.error.toString());
      }
    });

/// AI Chat Session provider
final aiChatSessionProvider = FutureProvider.family<AIChatSession, String>((
  ref,
  sessionId,
) async {
  final service = ref.read(aiServiceProvider);
  final result = await service.getChatSession(sessionId);
  if (result.isSuccess) {
    return result.data;
  } else {
    throw Exception(result.error.toString());
  }
});

/// AI Predictions provider
final aiPredictionsProvider =
    FutureProvider.family<List<AIPredictionResponse>, Map<String, dynamic>>((
      ref,
      data,
    ) async {
      final service = ref.read(aiServiceProvider);
      final result = await service.predict(data);
      if (result.isSuccess) {
        return result.data;
      } else {
        throw Exception(result.error.toString());
      }
    });

/// AI Recommendations provider
final aiRecommendationsProvider =
    FutureProvider.family<List<AIRecommendation>, Map<String, dynamic>>((
      ref,
      data,
    ) async {
      final service = ref.read(aiServiceProvider);
      final result = await service.getRecommendations(data);
      if (result.isSuccess) {
        return result.data;
      } else {
        throw Exception(result.error.toString());
      }
    });

/// AI Optimization provider
final aiOptimizationProvider =
    FutureProvider.family<List<AIOptimizationSuggestion>, Map<String, dynamic>>(
      (ref, data) async {
        final service = ref.read(aiServiceProvider);
        final result = await service.optimize(data);
        if (result.isSuccess) {
          return result.data;
        } else {
          throw Exception(result.error.toString());
        }
      },
    );
