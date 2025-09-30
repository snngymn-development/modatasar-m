import 'package:flutter/material.dart';
import '../../domain/entities/payment.dart';

/// Payment method selector widget
class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selectedMethod;
  final Function(PaymentMethod) onMethodChanged;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: PaymentMethod.values.map((method) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: RadioListTile<PaymentMethod>(
            value: method,
            // ignore: deprecated_member_use
            groupValue: selectedMethod,
            // ignore: deprecated_member_use
            onChanged: (value) {
              if (value != null) {
                onMethodChanged(value);
              }
            },
            title: Row(
              children: [
                Text(method.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(
                  method.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            subtitle: Text(_getMethodSubtitle(method) ?? ''),
            activeColor: Colors.blue,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
          ),
        );
      }).toList(),
    );
  }

  String? _getMethodSubtitle(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Nakit ödeme için kasa personeline başvurun';
      case PaymentMethod.creditCard:
        return 'Visa, Mastercard, American Express';
      case PaymentMethod.debitCard:
        return 'Banka kartı ile ödeme';
      case PaymentMethod.bankTransfer:
        return 'Banka havalesi ile ödeme';
      case PaymentMethod.digitalWallet:
        return 'Apple Pay, Google Pay, Samsung Pay';
      case PaymentMethod.cryptocurrency:
        return 'Bitcoin, Ethereum ve diğer kripto paralar';
      case PaymentMethod.check:
        return 'Çek ile ödeme (onay gerekli)';
      case PaymentMethod.giftCard:
        return 'Hediye kartı kullan';
      case PaymentMethod.storeCredit:
        return 'Mağaza kredisi kullan';
      case PaymentMethod.other:
        return 'Diğer ödeme yöntemleri';
    }
  }
}
