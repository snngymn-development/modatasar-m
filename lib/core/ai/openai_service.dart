import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../logging/talker_config.dart';
import '../error/failure.dart';
import '../network/result.dart';

/// OpenAI integration service for advanced AI features
///
/// Usage:
/// ```dart
/// final openaiService = OpenAIService();
/// await openaiService.initialize();
/// final result = await openaiService.generateText('Analyze sales data');
/// ```
class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  factory OpenAIService() => _instance;
  OpenAIService._internal();

  late String _apiKey;
  late String _baseUrl;
  bool _isInitialized = false;

  /// Initialize OpenAI service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _apiKey = const String.fromEnvironment(
        'OPENAI_API_KEY',
        defaultValue: 'your-openai-api-key',
      );

      _baseUrl = const String.fromEnvironment(
        'OPENAI_BASE_URL',
        defaultValue: 'https://api.openai.com/v1',
      );

      if (_apiKey == 'your-openai-api-key') {
        throw Exception('OpenAI API key not configured');
      }

      _isInitialized = true;
      TalkerConfig.logInfo('OpenAI service initialized');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to initialize OpenAI service',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Generate text using GPT-4
  Future<Result<String>> generateText(
    String prompt, {
    String model = 'gpt-4',
    int maxTokens = 1000,
    double temperature = 0.7,
    List<String>? stop,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final response = await _makeRequest('/chat/completions', {
        'model': model,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': maxTokens,
        'temperature': temperature,
        if (stop != null) 'stop': stop,
      });

      if (response.isSuccess) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'] as String;
        return Success(content);
      } else {
        return Error(response.error);
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to generate text with OpenAI',
        e,
        stackTrace,
      );
      return Error(Failure('Failed to generate text: $e'));
    }
  }

  /// Analyze sales data
  Future<Result<Map<String, dynamic>>> analyzeSalesData(
    List<Map<String, dynamic>> salesData,
  ) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final prompt =
          '''
        Analyze the following sales data and provide insights:
        
        Sales Data: ${jsonEncode(salesData)}
        
        Please provide:
        1. Total sales amount
        2. Average sale amount
        3. Top selling products
        4. Sales trends
        5. Recommendations for improvement
        
        Format the response as JSON.
      ''';

      final result = await generateText(prompt, model: 'gpt-4');

      if (result.isSuccess) {
        try {
          final analysis = jsonDecode(result.data) as Map<String, dynamic>;
          return Success(analysis);
        } catch (e) {
          // If JSON parsing fails, return the raw text
          return Success({'analysis': result.data, 'raw_response': true});
        }
      } else {
        return Error(result.error);
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to analyze sales data', e, stackTrace);
      return Error(Failure('Failed to analyze sales data: $e'));
    }
  }

  /// Generate product recommendations
  Future<Result<List<Map<String, dynamic>>>> generateProductRecommendations(
    String customerId,
    List<Map<String, dynamic>> purchaseHistory,
    List<Map<String, dynamic>> availableProducts,
  ) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final prompt =
          '''
        Based on the customer's purchase history and available products, 
        generate personalized product recommendations.
        
        Customer ID: $customerId
        Purchase History: ${jsonEncode(purchaseHistory)}
        Available Products: ${jsonEncode(availableProducts)}
        
        Please provide 5 product recommendations with:
        - Product ID
        - Reason for recommendation
        - Confidence score (0-1)
        
        Format as JSON array.
      ''';

      final result = await generateText(prompt, model: 'gpt-4');

      if (result.isSuccess) {
        try {
          final recommendations = jsonDecode(result.data) as List<dynamic>;
          return Success(recommendations.cast<Map<String, dynamic>>());
        } catch (e) {
          return Error(Failure('Failed to parse recommendations: $e'));
        }
      } else {
        return Error(result.error);
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to generate product recommendations',
        e,
        stackTrace,
      );
      return Error(Failure('Failed to generate recommendations: $e'));
    }
  }

  /// Generate customer insights
  Future<Result<Map<String, dynamic>>> generateCustomerInsights(
    Map<String, dynamic> customerData,
    List<Map<String, dynamic>> purchaseHistory,
  ) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final prompt =
          '''
        Analyze the customer data and purchase history to generate insights:
        
        Customer Data: ${jsonEncode(customerData)}
        Purchase History: ${jsonEncode(purchaseHistory)}
        
        Please provide:
        1. Customer segment
        2. Purchase patterns
        3. Lifetime value prediction
        4. Churn risk assessment
        5. Engagement recommendations
        
        Format as JSON.
      ''';

      final result = await generateText(prompt, model: 'gpt-4');

      if (result.isSuccess) {
        try {
          final insights = jsonDecode(result.data) as Map<String, dynamic>;
          return Success(insights);
        } catch (e) {
          return Success({'insights': result.data, 'raw_response': true});
        }
      } else {
        return Error(result.error);
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to generate customer insights',
        e,
        stackTrace,
      );
      return Error(Failure('Failed to generate customer insights: $e'));
    }
  }

  /// Generate inventory optimization suggestions
  Future<Result<List<Map<String, dynamic>>>> generateInventoryOptimization(
    List<Map<String, dynamic>> inventoryData,
    List<Map<String, dynamic>> salesData,
  ) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final prompt =
          '''
        Analyze inventory and sales data to provide optimization suggestions:
        
        Inventory Data: ${jsonEncode(inventoryData)}
        Sales Data: ${jsonEncode(salesData)}
        
        Please provide suggestions for:
        1. Stock level adjustments
        2. Reorder points
        3. Slow-moving items
        4. Fast-moving items
        5. Seasonal adjustments
        
        Format as JSON array of suggestions.
      ''';

      final result = await generateText(prompt, model: 'gpt-4');

      if (result.isSuccess) {
        try {
          final suggestions = jsonDecode(result.data) as List<dynamic>;
          return Success(suggestions.cast<Map<String, dynamic>>());
        } catch (e) {
          return Error(Failure('Failed to parse optimization suggestions: $e'));
        }
      } else {
        return Error(result.error);
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to generate inventory optimization',
        e,
        stackTrace,
      );
      return Error(Failure('Failed to generate inventory optimization: $e'));
    }
  }

  /// Generate marketing content
  Future<Result<String>> generateMarketingContent(
    String productName,
    String productDescription,
    String targetAudience,
    String contentType,
  ) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final prompt =
          '''
        Generate $contentType for the following product:
        
        Product Name: $productName
        Product Description: $productDescription
        Target Audience: $targetAudience
        
        Please create engaging, professional content that highlights the product's benefits
        and appeals to the target audience.
      ''';

      final result = await generateText(
        prompt,
        model: 'gpt-4',
        maxTokens: 500,
        temperature: 0.8,
      );

      if (result.isSuccess) {
        return Success(result.data);
      } else {
        return Error(result.error);
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to generate marketing content',
        e,
        stackTrace,
      );
      return Error(Failure('Failed to generate marketing content: $e'));
    }
  }

  /// Generate report summary
  Future<Result<String>> generateReportSummary(
    Map<String, dynamic> reportData,
    String reportType,
  ) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final prompt =
          '''
        Generate a professional summary for a $reportType report:
        
        Report Data: ${jsonEncode(reportData)}
        
        Please provide:
        1. Executive summary
        2. Key findings
        3. Important metrics
        4. Actionable recommendations
        
        Keep it concise and professional.
      ''';

      final result = await generateText(
        prompt,
        model: 'gpt-4',
        maxTokens: 800,
        temperature: 0.6,
      );

      if (result.isSuccess) {
        return Success(result.data);
      } else {
        return Error(result.error);
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to generate report summary', e, stackTrace);
      return Error(Failure('Failed to generate report summary: $e'));
    }
  }

  /// Make HTTP request to OpenAI API
  Future<Result<Map<String, dynamic>>> _makeRequest(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return Success(responseData);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return Error(
          Failure(
            'OpenAI API error: ${errorData['error']?['message'] ?? 'Unknown error'}',
            code: 'OPENAI_ERROR',
          ),
        );
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('OpenAI API request failed', e, stackTrace);
      return Error(Failure('OpenAI API request failed: $e'));
    }
  }

  /// Get service status
  bool get isInitialized => _isInitialized;

  /// Close service
  void close() {
    _isInitialized = false;
    TalkerConfig.logInfo('OpenAI service closed');
  }
}
