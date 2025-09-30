import 'dart:async';
import 'dart:math';
import '../../domain/entities/payment.dart';
import '../../../../core/logging/talker_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/config/api_config.dart';

/// Payment gateway service for processing payments
///
/// Usage:
/// ```dart
/// final gateway = PaymentGatewayService();
/// final result = await gateway.processPayment(paymentRequest);
/// ```
abstract class PaymentGatewayService {
  /// Process a payment
  Future<PaymentResult> processPayment(PaymentRequest request);

  /// Refund a payment
  Future<PaymentResult> refundPayment(String paymentId, double amount);

  /// Get payment status
  Future<PaymentStatus> getPaymentStatus(String transactionId);

  /// Validate payment data
  bool validatePaymentData(PaymentRequest request);
}

/// Mock payment gateway service for development
class MockPaymentGatewayService implements PaymentGatewayService {
  final ApiClient _apiClient;
  final Random _random = Random();

  MockPaymentGatewayService({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    try {
      TalkerConfig.logInfo(
        'Processing payment: ${request.amount} ${request.currency} via ${request.method.name}',
      );

      // Simulate processing delay
      await Future.delayed(
        Duration(milliseconds: 1000 + _random.nextInt(2000)),
      );

      // Simulate success/failure based on amount and method
      final success = _simulatePaymentSuccess(request);

      if (success) {
        final transactionId = _generateTransactionId();
        final payment = Payment(
          id: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
          amount: request.amount,
          currency: request.currency,
          method: request.method,
          status: PaymentStatus.completed,
          transactionId: transactionId,
          gatewayResponse: _generateGatewayResponse(
            transactionId,
            true,
          ).toString(),
          metadata: request.metadata,
          createdAt: DateTime.now(),
          customerId: request.customerId,
          orderId: request.orderId,
        );

        // Log to API (in real implementation)
        final logResult = await _logPaymentToAPI(payment);
        if (logResult.isFailure) {
          TalkerConfig.logWarning(
            'Failed to log payment to API: ${logResult.error.message}',
          );
        }

        TalkerConfig.logInfo('Payment processed successfully: $transactionId');
        return PaymentResult.success(
          transactionId: transactionId,
          payment: payment,
          gatewayResponse: payment.gatewayResponse != null
              ? {'response': payment.gatewayResponse}
              : null,
        );
      } else {
        final errorMessage = _generateErrorMessage(request);
        TalkerConfig.logWarning('Payment failed: $errorMessage');

        return PaymentResult.failure(
          errorMessage: errorMessage,
          gatewayResponse: _generateGatewayResponse(null, false),
        );
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Payment processing error', e, stackTrace);
      return PaymentResult.failure(
        errorMessage: 'Payment processing failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<PaymentResult> refundPayment(String paymentId, double amount) async {
    try {
      TalkerConfig.logInfo(
        'Processing refund for payment: $paymentId, amount: $amount',
      );

      // Simulate processing delay
      await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));

      // Simulate refund success (90% success rate)
      final success = _random.nextDouble() > 0.1;

      if (success) {
        final refundId = 'REF-${DateTime.now().millisecondsSinceEpoch}';
        TalkerConfig.logInfo('Refund processed successfully: $refundId');

        return PaymentResult.success(
          transactionId: refundId,
          payment: Payment(
            id: refundId,
            amount: -amount, // Negative amount for refund
            currency: 'USD', // Would get from original payment
            method: PaymentMethod.creditCard,
            status: PaymentStatus.refunded,
            transactionId: refundId,
            createdAt: DateTime.now(),
          ),
        );
      } else {
        return PaymentResult.failure(
          errorMessage: 'Refund failed: Insufficient funds or invalid payment',
        );
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Refund processing error', e, stackTrace);
      return PaymentResult.failure(
        errorMessage: 'Refund processing failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<PaymentStatus> getPaymentStatus(String transactionId) async {
    try {
      // Simulate API call delay
      await Future.delayed(Duration(milliseconds: 500));

      // Simulate different statuses
      final statuses = PaymentStatus.values;
      final randomStatus = statuses[_random.nextInt(statuses.length)];

      TalkerConfig.logInfo(
        'Payment status for $transactionId: ${randomStatus.name}',
      );
      return randomStatus;
    } catch (e, stackTrace) {
      TalkerConfig.logError('Error getting payment status', e, stackTrace);
      return PaymentStatus.failed;
    }
  }

  @override
  bool validatePaymentData(PaymentRequest request) {
    if (request.amount <= 0) {
      TalkerConfig.logWarning('Invalid payment amount: ${request.amount}');
      return false;
    }

    if (request.currency.isEmpty) {
      TalkerConfig.logWarning('Invalid currency: ${request.currency}');
      return false;
    }

    // Additional validation based on payment method
    switch (request.method) {
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        return _validateCardPayment(request);
      case PaymentMethod.bankTransfer:
        return _validateBankTransfer(request);
      case PaymentMethod.digitalWallet:
        return _validateDigitalWallet(request);
      default:
        return true;
    }
  }

  /// Simulate payment success based on various factors
  bool _simulatePaymentSuccess(PaymentRequest request) {
    // Higher success rate for smaller amounts
    final amountFactor = request.amount < 100 ? 0.95 : 0.85;

    // Different success rates by payment method
    final methodFactor = switch (request.method) {
      PaymentMethod.cash => 1.0,
      PaymentMethod.creditCard => 0.9,
      PaymentMethod.debitCard => 0.85,
      PaymentMethod.digitalWallet => 0.8,
      PaymentMethod.bankTransfer => 0.75,
      PaymentMethod.cryptocurrency => 0.7,
      PaymentMethod.giftCard => 0.95,
      PaymentMethod.storeCredit => 1.0,
      PaymentMethod.check => 0.6,
      PaymentMethod.other => 0.5,
    };

    final successRate = amountFactor * methodFactor;
    return _random.nextDouble() < successRate;
  }

  /// Generate transaction ID
  String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(9999).toString().padLeft(4, '0');
    return 'TXN$timestamp$random';
  }

  /// Generate gateway response
  Map<String, dynamic> _generateGatewayResponse(
    String? transactionId,
    bool success,
  ) {
    return {
      'success': success,
      'transaction_id': transactionId,
      'gateway': 'mock_gateway',
      'timestamp': DateTime.now().toIso8601String(),
      'response_code': success ? '00' : '01',
      'response_message': success ? 'Approved' : 'Declined',
      'auth_code': success ? _generateAuthCode() : null,
    };
  }

  /// Generate authorization code
  String _generateAuthCode() {
    return _random.nextInt(999999).toString().padLeft(6, '0');
  }

  /// Generate error message
  String _generateErrorMessage(PaymentRequest request) {
    final errors = [
      'Insufficient funds',
      'Invalid card number',
      'Card expired',
      'CVV mismatch',
      'Transaction declined by bank',
      'Network timeout',
      'Invalid payment method',
      'Daily limit exceeded',
    ];
    return errors[_random.nextInt(errors.length)];
  }

  /// Validate card payment
  bool _validateCardPayment(PaymentRequest request) {
    final paymentData = request.paymentData;
    if (paymentData == null) return false;

    final cardNumber = paymentData['cardNumber'] as String?;
    final expiryDate = paymentData['expiryDate'] as String?;
    final cvv = paymentData['cvv'] as String?;

    if (cardNumber == null || cardNumber.length < 13) return false;
    if (expiryDate == null || expiryDate.length != 5) return false;
    if (cvv == null || (cvv.length != 3 && cvv.length != 4)) return false;

    return true;
  }

  /// Validate bank transfer
  bool _validateBankTransfer(PaymentRequest request) {
    final paymentData = request.paymentData;
    if (paymentData == null) return false;

    final accountNumber = paymentData['accountNumber'] as String?;
    final routingNumber = paymentData['routingNumber'] as String?;

    return accountNumber != null &&
        accountNumber.isNotEmpty &&
        routingNumber != null &&
        routingNumber.isNotEmpty;
  }

  /// Validate digital wallet
  bool _validateDigitalWallet(PaymentRequest request) {
    final paymentData = request.paymentData;
    if (paymentData == null) return false;

    final walletId = paymentData['walletId'] as String?;
    return walletId != null && walletId.isNotEmpty;
  }

  /// Log payment to API
  Future<Result<Map<String, dynamic>>> _logPaymentToAPI(Payment payment) async {
    try {
      final result = await _apiClient.post(
        ApiConfig.paymentsEndpoint,
        data: payment.toJson(),
      );
      return Result.ok(result.data as Map<String, dynamic>);
    } catch (e) {
      TalkerConfig.logError('Failed to log payment to API', e);
      return Result.err(
        Failure('Failed to log payment to API: ${e.toString()}'),
      );
    }
  }
}

/// Real payment gateway service (placeholder for production)
class RealPaymentGatewayService implements PaymentGatewayService {
  final ApiClient _apiClient;

  RealPaymentGatewayService({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    // This would integrate with real payment gateways like:
    // - Stripe
    // - PayPal
    // - Square
    // - Adyen
    // - etc.

    try {
      final result = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.paymentsEndpoint,
        data: request.toJson(),
      );

      if (result.isSuccess) {
        final response = result.data;
        if (response['success'] == true) {
          return PaymentResult.success(
            transactionId: response['transaction_id'] as String,
            payment: Payment.fromJson(
              response['payment'] as Map<String, dynamic>,
            ),
            gatewayResponse: response,
          );
        } else {
          return PaymentResult.failure(
            errorMessage:
                response['error_message'] as String? ?? 'Payment failed',
            gatewayResponse: response,
          );
        }
      } else {
        return PaymentResult.failure(errorMessage: result.error.message);
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Real payment gateway error', e, stackTrace);
      return PaymentResult.failure(
        errorMessage: 'Payment processing failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<PaymentResult> refundPayment(String paymentId, double amount) async {
    // Implementation for real refund processing
    throw UnimplementedError('Real refund processing not implemented');
  }

  @override
  Future<PaymentStatus> getPaymentStatus(String transactionId) async {
    // Implementation for real status checking
    throw UnimplementedError('Real status checking not implemented');
  }

  @override
  bool validatePaymentData(PaymentRequest request) {
    // Real validation logic
    return request.amount > 0 && request.currency.isNotEmpty;
  }
}

/// Extension to convert Payment to JSON
extension PaymentJson on Payment {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'method': method.name,
      'status': status.name,
      'transaction_id': transactionId,
      'gateway_response': gatewayResponse,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'customer_id': customerId,
      'order_id': orderId,
    };
  }
}

/// Helper class for Payment JSON conversion
class PaymentJsonHelper {
  static Payment fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => PaymentMethod.other,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: json['transaction_id'] as String?,
      gatewayResponse: json['gateway_response'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      customerId: json['customer_id'] as String?,
      orderId: json['order_id'] as String?,
    );
  }
}

/// Extension to convert PaymentRequest to JSON
extension PaymentRequestJson on PaymentRequest {
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'method': method.name,
      'customer_id': customerId,
      'order_id': orderId,
      'payment_data': paymentData,
      'metadata': metadata,
    };
  }
}
