import 'package:flutter/material.dart';

/// Payment summary widget
class PaymentSummary extends StatelessWidget {
  final double amount;
  final String currency;
  final String? orderId;
  final double? tax;
  final double? discount;
  final double? serviceFee;

  const PaymentSummary({
    super.key,
    required this.amount,
    required this.currency,
    this.orderId,
    this.tax,
    this.discount,
    this.serviceFee,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = amount - (tax ?? 0) + (discount ?? 0) - (serviceFee ?? 0);
    final total = amount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ödeme Özeti',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            if (orderId != null) ...[
              _buildSummaryRow('Sipariş No', orderId!),
              const SizedBox(height: 8),
            ],

            _buildSummaryRow('Ara Toplam', _formatAmount(subtotal)),

            if (tax != null && tax! > 0) ...[
              const SizedBox(height: 4),
              _buildSummaryRow('KDV', _formatAmount(tax!)),
            ],

            if (discount != null && discount! > 0) ...[
              const SizedBox(height: 4),
              _buildSummaryRow(
                'İndirim',
                '-${_formatAmount(discount!)}',
                isDiscount: true,
              ),
            ],

            if (serviceFee != null && serviceFee! > 0) ...[
              const SizedBox(height: 4),
              _buildSummaryRow('Hizmet Bedeli', _formatAmount(serviceFee!)),
            ],

            const Divider(height: 24),

            _buildSummaryRow('Toplam', _formatAmount(total), isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.blue : null,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isDiscount
                ? Colors.green
                : isTotal
                ? Colors.blue
                : null,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }
}
