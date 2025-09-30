import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/payment.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/payment_form.dart';
import '../widgets/payment_summary.dart';
import '../providers/payment_providers.dart';

/// Payment processing page
///
/// Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (context) => PaymentPage(
///     amount: 29.99,
///     currency: 'USD',
///     orderId: 'ORD-001',
///   ),
/// ));
/// ```
class PaymentPage extends ConsumerStatefulWidget {
  final double amount;
  final String currency;
  final String? orderId;
  final String? customerId;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentFailure;

  const PaymentPage({
    super.key,
    required this.amount,
    required this.currency,
    this.orderId,
    this.customerId,
    this.onPaymentSuccess,
    this.onPaymentFailure,
  });

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  PaymentMethod _selectedMethod = PaymentMethod.creditCard;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödeme'),
        leading: _isProcessing
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
      body: _isProcessing ? _buildProcessingView() : _buildPaymentView(),
    );
  }

  Widget _buildPaymentView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Summary
          PaymentSummary(
            amount: widget.amount,
            currency: widget.currency,
            orderId: widget.orderId,
          ),
          const SizedBox(height: 24),

          // Payment Method Selection
          Text(
            'Ödeme Yöntemi',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          PaymentMethodSelector(
            selectedMethod: _selectedMethod,
            onMethodChanged: (method) {
              setState(() {
                _selectedMethod = method;
                _errorMessage = null;
              });
            },
          ),
          const SizedBox(height: 24),

          // Payment Form
          PaymentForm(
            method: _selectedMethod,
            onPaymentDataChanged: (data) {
              // Handle payment data changes
            },
          ),
          const SizedBox(height: 24),

          // Error Message
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Process Payment Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ödemeyi İşle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Ödeme işleniyor...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Lütfen bekleyin, işleminiz gerçekleştiriliyor.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final paymentRequest = PaymentRequest(
        amount: widget.amount,
        currency: widget.currency,
        method: _selectedMethod,
        customerId: widget.customerId,
        orderId: widget.orderId,
        paymentData: _getPaymentData(),
      );

      final result = await ref.read(
        processPaymentProvider(paymentRequest).future,
      );

      if (result.success) {
        _showSuccessDialog(result);
        widget.onPaymentSuccess?.call();
      } else {
        setState(() {
          _errorMessage = result.errorMessage ?? 'Ödeme işlemi başarısız oldu';
          _isProcessing = false;
        });
        widget.onPaymentFailure?.call();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Beklenmeyen bir hata oluştu: ${e.toString()}';
        _isProcessing = false;
      });
      widget.onPaymentFailure?.call();
    }
  }

  Map<String, dynamic>? _getPaymentData() {
    // This would collect actual payment data from the form
    // For now, return mock data based on payment method
    switch (_selectedMethod) {
      case PaymentMethod.creditCard:
        return {
          'cardNumber': '4111111111111111',
          'expiryDate': '12/25',
          'cvv': '123',
          'cardholderName': 'John Doe',
        };
      case PaymentMethod.debitCard:
        return {
          'cardNumber': '4111111111111111',
          'expiryDate': '12/25',
          'cvv': '123',
          'cardholderName': 'John Doe',
        };
      case PaymentMethod.bankTransfer:
        return {
          'accountNumber': '1234567890',
          'routingNumber': '123456789',
          'accountHolderName': 'John Doe',
        };
      case PaymentMethod.digitalWallet:
        return {'walletId': 'wallet_123456', 'walletType': 'apple_pay'};
      default:
        return null;
    }
  }

  void _showSuccessDialog(PaymentResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Ödeme Başarılı'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('İşlem ID: ${result.transactionId}'),
            const SizedBox(height: 8),
            Text(
              'Tutar: ${widget.currency} ${widget.amount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            Text('Yöntem: ${_selectedMethod.displayName}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
