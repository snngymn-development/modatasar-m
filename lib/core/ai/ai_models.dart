/// AI Model Configuration
class AIModelConfig {
  final String name;
  final String version;
  final String type;
  final Map<String, dynamic> parameters;
  final bool isEnabled;
  final String? description;
  final Map<String, dynamic>? metadata;

  const AIModelConfig({
    required this.name,
    required this.version,
    required this.type,
    required this.parameters,
    required this.isEnabled,
    this.description,
    this.metadata,
  });

  factory AIModelConfig.fromJson(Map<String, dynamic> json) {
    return AIModelConfig(
      name: json['name'] as String,
      version: json['version'] as String,
      type: json['type'] as String,
      parameters: Map<String, dynamic>.from(json['parameters'] as Map),
      isEnabled: json['isEnabled'] as bool,
      description: json['description'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'type': type,
      'parameters': parameters,
      'isEnabled': isEnabled,
      'description': description,
      'metadata': metadata,
    };
  }
}

/// AI Prediction Request
class AIPredictionRequest {
  final String modelName;
  final Map<String, dynamic> inputData;
  final Map<String, dynamic>? options;
  final String? userId;
  final String? sessionId;

  const AIPredictionRequest({
    required this.modelName,
    required this.inputData,
    this.options,
    this.userId,
    this.sessionId,
  });

  factory AIPredictionRequest.fromJson(Map<String, dynamic> json) {
    return AIPredictionRequest(
      modelName: json['modelName'] as String,
      inputData: Map<String, dynamic>.from(json['inputData'] as Map),
      options: json['options'] != null
          ? Map<String, dynamic>.from(json['options'] as Map)
          : null,
      userId: json['userId'] as String?,
      sessionId: json['sessionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modelName': modelName,
      'inputData': inputData,
      'options': options,
      'userId': userId,
      'sessionId': sessionId,
    };
  }
}

/// AI Prediction Response
class AIPredictionResponse {
  final String id;
  final String modelName;
  final Map<String, dynamic> output;
  final double confidence;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const AIPredictionResponse({
    required this.id,
    required this.modelName,
    required this.output,
    required this.confidence,
    required this.timestamp,
    this.metadata,
  });

  factory AIPredictionResponse.fromJson(Map<String, dynamic> json) {
    return AIPredictionResponse(
      id: json['id'] as String,
      modelName: json['modelName'] as String,
      output: Map<String, dynamic>.from(json['output'] as Map),
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelName': modelName,
      'output': output,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// AI Training Data
class AITrainingData {
  final String id;
  final Map<String, dynamic> input;
  final Map<String, dynamic> output;
  final String category;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const AITrainingData({
    required this.id,
    required this.input,
    required this.output,
    required this.category,
    required this.timestamp,
    this.metadata,
  });

  factory AITrainingData.fromJson(Map<String, dynamic> json) {
    return AITrainingData(
      id: json['id'] as String,
      input: Map<String, dynamic>.from(json['input'] as Map),
      output: Map<String, dynamic>.from(json['output'] as Map),
      category: json['category'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'input': input,
      'output': output,
      'category': category,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// AI Model Performance
class AIModelPerformance {
  final String modelName;
  final double accuracy;
  final double precision;
  final double recall;
  final double f1Score;
  final DateTime lastUpdated;
  final Map<String, double>? additionalMetrics;

  const AIModelPerformance({
    required this.modelName,
    required this.accuracy,
    required this.precision,
    required this.recall,
    required this.f1Score,
    required this.lastUpdated,
    this.additionalMetrics,
  });

  factory AIModelPerformance.fromJson(Map<String, dynamic> json) {
    return AIModelPerformance(
      modelName: json['modelName'] as String,
      accuracy: (json['accuracy'] as num).toDouble(),
      precision: (json['precision'] as num).toDouble(),
      recall: (json['recall'] as num).toDouble(),
      f1Score: (json['f1Score'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      additionalMetrics: json['additionalMetrics'] != null
          ? Map<String, double>.from(json['additionalMetrics'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modelName': modelName,
      'accuracy': accuracy,
      'precision': precision,
      'recall': recall,
      'f1Score': f1Score,
      'lastUpdated': lastUpdated.toIso8601String(),
      'additionalMetrics': additionalMetrics,
    };
  }
}

/// AI Chat Message
class AIChatMessage {
  final String id;
  final String content;
  final String role; // 'user' or 'assistant'
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const AIChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.metadata,
  });

  factory AIChatMessage.fromJson(Map<String, dynamic> json) {
    return AIChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      role: json['role'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// AI Chat Session
class AIChatSession {
  final String id;
  final String userId;
  final List<AIChatMessage> messages;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? context;

  const AIChatSession({
    required this.id,
    required this.userId,
    required this.messages,
    required this.createdAt,
    this.updatedAt,
    this.context,
  });

  factory AIChatSession.fromJson(Map<String, dynamic> json) {
    return AIChatSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      messages: (json['messages'] as List)
          .map((e) => AIChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      context: json['context'] != null
          ? Map<String, dynamic>.from(json['context'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'messages': messages.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'context': context,
    };
  }
}

/// AI Recommendation
class AIRecommendation {
  final String id;
  final String type;
  final String title;
  final String description;
  final String category;
  final double score;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const AIRecommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.category,
    required this.score,
    required this.timestamp,
    this.metadata,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      score: (json['score'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'category': category,
      'score': score,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// AI Analysis Result
class AIAnalysisResult {
  final String id;
  final String summary;
  final List<String> insights;
  final Map<String, dynamic> metrics;
  final DateTime timestamp;
  final Map<String, dynamic>? rawData;

  const AIAnalysisResult({
    required this.id,
    required this.summary,
    required this.insights,
    required this.metrics,
    required this.timestamp,
    this.rawData,
  });

  factory AIAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AIAnalysisResult(
      id: json['id'] as String,
      summary: json['summary'] as String,
      insights: List<String>.from(json['insights'] as List),
      metrics: Map<String, dynamic>.from(json['metrics'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      rawData: json['rawData'] != null
          ? Map<String, dynamic>.from(json['rawData'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'summary': summary,
      'insights': insights,
      'metrics': metrics,
      'timestamp': timestamp.toIso8601String(),
      'rawData': rawData,
    };
  }
}

/// AI Optimization Suggestion
class AIOptimizationSuggestion {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final double impact;
  final List<String> steps;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const AIOptimizationSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.impact,
    required this.steps,
    required this.timestamp,
    this.metadata,
  });

  factory AIOptimizationSuggestion.fromJson(Map<String, dynamic> json) {
    return AIOptimizationSuggestion(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      impact: (json['impact'] as num).toDouble(),
      steps: List<String>.from(json['steps'] as List),
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'impact': impact,
      'steps': steps,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// AI Error
class AIError {
  final String id;
  final String message;
  final String code;
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  const AIError({
    required this.id,
    required this.message,
    required this.code,
    required this.type,
    required this.timestamp,
    this.details,
  });

  factory AIError.fromJson(Map<String, dynamic> json) {
    return AIError(
      id: json['id'] as String,
      message: json['message'] as String,
      code: json['code'] as String,
      type: json['type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: json['details'] != null
          ? Map<String, dynamic>.from(json['details'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'code': code,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }
}

/// AI Configuration
class AIConfiguration {
  final String defaultModel;
  final bool isEnabled;
  final Map<String, dynamic> settings;
  final List<String> enabledFeatures;
  final Map<String, dynamic>? customSettings;

  const AIConfiguration({
    required this.defaultModel,
    required this.isEnabled,
    required this.settings,
    required this.enabledFeatures,
    this.customSettings,
  });

  factory AIConfiguration.fromJson(Map<String, dynamic> json) {
    return AIConfiguration(
      defaultModel: json['defaultModel'] as String,
      isEnabled: json['isEnabled'] as bool,
      settings: Map<String, dynamic>.from(json['settings'] as Map),
      enabledFeatures: List<String>.from(json['enabledFeatures'] as List),
      customSettings: json['customSettings'] != null
          ? Map<String, dynamic>.from(json['customSettings'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultModel': defaultModel,
      'isEnabled': isEnabled,
      'settings': settings,
      'enabledFeatures': enabledFeatures,
      'customSettings': customSettings,
    };
  }
}
