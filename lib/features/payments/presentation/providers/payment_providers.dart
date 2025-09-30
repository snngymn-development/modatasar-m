import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/payment_gateway_service.dart';
import '../../domain/entities/payment.dart';
import '../../../../core/di/providers.dart';

/// Payment gateway service provider
final paymentGatewayServiceProvider = Provider<PaymentGatewayService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return MockPaymentGatewayService(apiClient: apiClient);
});

/// Process payment provider
final processPaymentProvider =
    FutureProvider.family<PaymentResult, PaymentRequest>((ref, request) async {
      final gateway = ref.read(paymentGatewayServiceProvider);

      // Validate payment data
      if (!gateway.validatePaymentData(request)) {
        return PaymentResult.failure(errorMessage: 'Geçersiz ödeme bilgileri');
      }

      return await gateway.processPayment(request);
    });

/// Refund payment provider
final refundPaymentProvider =
    FutureProvider.family<PaymentResult, ({String paymentId, double amount})>((
      ref,
      params,
    ) async {
      final gateway = ref.read(paymentGatewayServiceProvider);
      return await gateway.refundPayment(params.paymentId, params.amount);
    });

/// Payment status provider
final paymentStatusProvider = FutureProvider.family<PaymentStatus, String>((
  ref,
  transactionId,
) async {
  final gateway = ref.read(paymentGatewayServiceProvider);
  return await gateway.getPaymentStatus(transactionId);
});

/// Payment history provider
final paymentHistoryProvider = FutureProvider<List<Payment>>((ref) async {
  // This would fetch from API in real implementation
  // For now, return empty list
  return [];
});

/// Payment statistics provider
final paymentStatisticsProvider = FutureProvider<PaymentStatistics>((
  ref,
) async {
  // This would calculate from real data in production
  return PaymentStatistics(
    totalPayments: 0,
    totalAmount: 0.0,
    successfulPayments: 0,
    failedPayments: 0,
    averageAmount: 0.0,
    paymentMethods: {},
  );
});

/// Payment statistics data class
class PaymentStatistics {
  final int totalPayments;
  final double totalAmount;
  final int successfulPayments;
  final int failedPayments;
  final double averageAmount;
  final Map<PaymentMethod, int> paymentMethods;

  const PaymentStatistics({
    required this.totalPayments,
    required this.totalAmount,
    required this.successfulPayments,
    required this.failedPayments,
    required this.averageAmount,
    required this.paymentMethods,
  });

  double get successRate {
    if (totalPayments == 0) return 0.0;
    return successfulPayments / totalPayments;
  }

  double get failureRate {
    if (totalPayments == 0) return 0.0;
    return failedPayments / totalPayments;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentStatistics &&
        other.totalPayments == totalPayments &&
        other.totalAmount == totalAmount &&
        other.successfulPayments == successfulPayments &&
        other.failedPayments == failedPayments &&
        other.averageAmount == averageAmount;
  }

  @override
  int get hashCode {
    return totalPayments.hashCode ^
        totalAmount.hashCode ^
        successfulPayments.hashCode ^
        failedPayments.hashCode ^
        averageAmount.hashCode;
  }

  @override
  String toString() {
    return 'PaymentStatistics(totalPayments: $totalPayments, totalAmount: $totalAmount, successRate: ${(successRate * 100).toStringAsFixed(1)}%)';
  }
}
