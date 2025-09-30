import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/payment.dart';

/// Payment form widget for collecting payment data
class PaymentForm extends StatefulWidget {
  final PaymentMethod method;
  final Function(Map<String, dynamic>) onPaymentDataChanged;

  const PaymentForm({
    super.key,
    required this.method,
    required this.onPaymentDataChanged,
  });

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _routingNumberController = TextEditingController();
  final _walletIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupInputFormatters();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardholderNameController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    _walletIdController.dispose();
    super.dispose();
  }

  void _setupInputFormatters() {
    _cardNumberController.addListener(() {
      final text = _cardNumberController.text.replaceAll(' ', '');
      final formatted = _formatCardNumber(text);
      if (formatted != _cardNumberController.text) {
        _cardNumberController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    });

    _expiryDateController.addListener(() {
      final text = _expiryDateController.text.replaceAll('/', '');
      final formatted = _formatExpiryDate(text);
      if (formatted != _expiryDateController.text) {
        _expiryDateController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    });
  }

  String _formatCardNumber(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    final chunks = <String>[];
    for (int i = 0; i < cleaned.length; i += 4) {
      chunks.add(cleaned.substring(i, (i + 4).clamp(0, cleaned.length)));
    }
    return chunks.join(' ');
  }

  String _formatExpiryDate(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length >= 2) {
      return '${cleaned.substring(0, 2)}/${cleaned.substring(2, cleaned.length.clamp(2, 4))}';
    }
    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ödeme Bilgileri',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildFormFields(),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    switch (widget.method) {
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        return _buildCardForm();
      case PaymentMethod.bankTransfer:
        return _buildBankTransferForm();
      case PaymentMethod.digitalWallet:
        return _buildDigitalWalletForm();
      case PaymentMethod.cash:
        return _buildCashForm();
      default:
        return _buildGenericForm();
    }
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        // Card Number
        TextFormField(
          controller: _cardNumberController,
          decoration: const InputDecoration(
            labelText: 'Kart Numarası',
            hintText: '1234 5678 9012 3456',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.credit_card),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(19), // 16 digits + 3 spaces
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Kart numarası gereklidir';
            }
            final cleaned = value.replaceAll(' ', '');
            if (cleaned.length < 13 || cleaned.length > 19) {
              return 'Geçerli bir kart numarası girin';
            }
            if (!_isValidCardNumber(cleaned)) {
              return 'Geçersiz kart numarası';
            }
            return null;
          },
          onChanged: _notifyDataChanged,
        ),
        const SizedBox(height: 16),

        // Expiry Date and CVV
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  labelText: 'Son Kullanma Tarihi',
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Son kullanma tarihi gereklidir';
                  }
                  if (value.length != 5) {
                    return 'MM/YY formatında girin';
                  }
                  if (!_isValidExpiryDate(value)) {
                    return 'Geçersiz tarih';
                  }
                  return null;
                },
                onChanged: _notifyDataChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'CVV gereklidir';
                  }
                  if (value.length < 3 || value.length > 4) {
                    return 'Geçerli CVV girin';
                  }
                  return null;
                },
                onChanged: _notifyDataChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Cardholder Name
        TextFormField(
          controller: _cardholderNameController,
          decoration: const InputDecoration(
            labelText: 'Kart Sahibinin Adı',
            hintText: 'John Doe',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Kart sahibinin adı gereklidir';
            }
            return null;
          },
          onChanged: _notifyDataChanged,
        ),
      ],
    );
  }

  Widget _buildBankTransferForm() {
    return Column(
      children: [
        TextFormField(
          controller: _accountNumberController,
          decoration: const InputDecoration(
            labelText: 'Hesap Numarası',
            hintText: '1234567890',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.account_balance),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Hesap numarası gereklidir';
            }
            return null;
          },
          onChanged: _notifyDataChanged,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _routingNumberController,
          decoration: const InputDecoration(
            labelText: 'Routing Numarası',
            hintText: '123456789',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.sort),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Routing numarası gereklidir';
            }
            return null;
          },
          onChanged: _notifyDataChanged,
        ),
      ],
    );
  }

  Widget _buildDigitalWalletForm() {
    return Column(
      children: [
        TextFormField(
          controller: _walletIdController,
          decoration: const InputDecoration(
            labelText: 'Cüzdan ID',
            hintText: 'wallet_123456',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.wallet),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Cüzdan ID gereklidir';
            }
            return null;
          },
          onChanged: _notifyDataChanged,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dijital cüzdanınızı seçin ve ödeme yapın',
                  style: TextStyle(color: Colors.blue[600]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCashForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.money, color: Colors.green[600], size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nakit Ödeme',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kasa personeline nakit ödeme yapın',
                  style: TextStyle(color: Colors.green[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Bu ödeme yöntemi için özel form gerekli',
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  bool _isValidCardNumber(String number) {
    // Luhn algorithm for card number validation
    int sum = 0;
    bool alternate = false;

    for (int i = number.length - 1; i >= 0; i--) {
      int digit = int.parse(number[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  bool _isValidExpiryDate(String date) {
    if (date.length != 5) return false;

    final parts = date.split('/');
    if (parts.length != 2) return false;

    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;

    final now = DateTime.now();
    final currentYear = now.year % 100;
    final currentMonth = now.month;

    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return false;
    }

    return true;
  }

  void _notifyDataChanged(String value) {
    final data = _getPaymentData();
    widget.onPaymentDataChanged(data);
  }

  Map<String, dynamic> _getPaymentData() {
    switch (widget.method) {
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        return {
          'cardNumber': _cardNumberController.text.replaceAll(' ', ''),
          'expiryDate': _expiryDateController.text,
          'cvv': _cvvController.text,
          'cardholderName': _cardholderNameController.text,
        };
      case PaymentMethod.bankTransfer:
        return {
          'accountNumber': _accountNumberController.text,
          'routingNumber': _routingNumberController.text,
        };
      case PaymentMethod.digitalWallet:
        return {
          'walletId': _walletIdController.text,
          'walletType': 'digital_wallet',
        };
      default:
        return {};
    }
  }
}
