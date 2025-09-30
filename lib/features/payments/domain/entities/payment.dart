/// Payment domain entity
///
/// Usage:
/// ```dart
/// final payment = Payment(
///   id: 'PAY-001',
///   amount: 29.99,
///   currency: 'USD',
///   method: PaymentMethod.creditCard,
///   status: PaymentStatus.completed,
/// );
/// ```
class Payment {
  final String id;
  final double amount;
  final String currency;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? transactionId;
  final String? gatewayResponse;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? customerId;
  final String? orderId;

  const Payment({
    required this.id,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    this.transactionId,
    this.gatewayResponse,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
    this.customerId,
    this.orderId,
  });

  /// Create a copy with updated values
  Payment copyWith({
    String? id,
    double? amount,
    String? currency,
    PaymentMethod? method,
    PaymentStatus? status,
    String? transactionId,
    String? gatewayResponse,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerId,
    String? orderId,
  }) {
    return Payment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      method: method ?? this.method,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      gatewayResponse: gatewayResponse ?? this.gatewayResponse,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerId: customerId ?? this.customerId,
      orderId: orderId ?? this.orderId,
    );
  }

  /// Check if payment is successful
  bool get isSuccessful => status == PaymentStatus.completed;

  /// Check if payment is pending
  bool get isPending => status == PaymentStatus.pending;

  /// Check if payment failed
  bool get isFailed => status == PaymentStatus.failed;

  /// Get formatted amount
  String get formattedAmount => '$currency ${amount.toStringAsFixed(2)}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Payment &&
        other.id == id &&
        other.amount == amount &&
        other.currency == currency &&
        other.method == method &&
        other.status == status &&
        other.transactionId == transactionId &&
        other.gatewayResponse == gatewayResponse &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.customerId == customerId &&
        other.orderId == orderId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        currency.hashCode ^
        method.hashCode ^
        status.hashCode ^
        transactionId.hashCode ^
        gatewayResponse.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        customerId.hashCode ^
        orderId.hashCode;
  }

  @override
  String toString() {
    return 'Payment(id: $id, amount: $formattedAmount, method: ${method.name}, status: ${status.name})';
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
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
      transactionId: json['transactionId'] as String?,
      gatewayResponse: json['gatewayResponse'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      customerId: json['customerId'] as String?,
      orderId: json['orderId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'method': method.name,
      'status': status.name,
      'transactionId': transactionId,
      'gatewayResponse': gatewayResponse,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'customerId': customerId,
      'orderId': orderId,
    };
  }
}

/// Payment method enumeration
enum PaymentMethod {
  cash,
  creditCard,
  debitCard,
  bankTransfer,
  digitalWallet,
  cryptocurrency,
  check,
  giftCard,
  storeCredit,
  other;

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Nakit';
      case PaymentMethod.creditCard:
        return 'Kredi Kartı';
      case PaymentMethod.debitCard:
        return 'Banka Kartı';
      case PaymentMethod.bankTransfer:
        return 'Banka Havalesi';
      case PaymentMethod.digitalWallet:
        return 'Dijital Cüzdan';
      case PaymentMethod.cryptocurrency:
        return 'Kripto Para';
      case PaymentMethod.check:
        return 'Çek';
      case PaymentMethod.giftCard:
        return 'Hediye Kartı';
      case PaymentMethod.storeCredit:
        return 'Mağaza Kredisi';
      case PaymentMethod.other:
        return 'Diğer';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethod.cash:
        return '💵';
      case PaymentMethod.creditCard:
        return '💳';
      case PaymentMethod.debitCard:
        return '💳';
      case PaymentMethod.bankTransfer:
        return '🏦';
      case PaymentMethod.digitalWallet:
        return '📱';
      case PaymentMethod.cryptocurrency:
        return '₿';
      case PaymentMethod.check:
        return '📝';
      case PaymentMethod.giftCard:
        return '🎁';
      case PaymentMethod.storeCredit:
        return '🎫';
      case PaymentMethod.other:
        return '❓';
    }
  }
}

/// Payment status enumeration
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
  partiallyRefunded;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Beklemede';
      case PaymentStatus.processing:
        return 'İşleniyor';
      case PaymentStatus.completed:
        return 'Tamamlandı';
      case PaymentStatus.failed:
        return 'Başarısız';
      case PaymentStatus.cancelled:
        return 'İptal Edildi';
      case PaymentStatus.refunded:
        return 'İade Edildi';
      case PaymentStatus.partiallyRefunded:
        return 'Kısmi İade';
    }
  }

  String get color {
    switch (this) {
      case PaymentStatus.pending:
        return 'orange';
      case PaymentStatus.processing:
        return 'blue';
      case PaymentStatus.completed:
        return 'green';
      case PaymentStatus.failed:
        return 'red';
      case PaymentStatus.cancelled:
        return 'grey';
      case PaymentStatus.refunded:
        return 'purple';
      case PaymentStatus.partiallyRefunded:
        return 'yellow';
    }
  }
}

/// Payment request data class
class PaymentRequest {
  final double amount;
  final String currency;
  final PaymentMethod method;
  final String? customerId;
  final String? orderId;
  final Map<String, dynamic>? paymentData;
  final Map<String, dynamic>? metadata;

  const PaymentRequest({
    required this.amount,
    required this.currency,
    required this.method,
    this.customerId,
    this.orderId,
    this.paymentData,
    this.metadata,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentRequest &&
        other.amount == amount &&
        other.currency == currency &&
        other.method == method &&
        other.customerId == customerId &&
        other.orderId == orderId;
  }

  @override
  int get hashCode {
    return amount.hashCode ^
        currency.hashCode ^
        method.hashCode ^
        customerId.hashCode ^
        orderId.hashCode;
  }

  @override
  String toString() {
    return 'PaymentRequest(amount: $amount, currency: $currency, method: ${method.name})';
  }
}

/// Payment result data class
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;
  final Payment? payment;
  final Map<String, dynamic>? gatewayResponse;

  const PaymentResult({
    required this.success,
    this.transactionId,
    this.errorMessage,
    this.payment,
    this.gatewayResponse,
  });

  factory PaymentResult.success({
    required String transactionId,
    required Payment payment,
    Map<String, dynamic>? gatewayResponse,
  }) {
    return PaymentResult(
      success: true,
      transactionId: transactionId,
      payment: payment,
      gatewayResponse: gatewayResponse,
    );
  }

  factory PaymentResult.failure({
    required String errorMessage,
    Map<String, dynamic>? gatewayResponse,
  }) {
    return PaymentResult(
      success: false,
      errorMessage: errorMessage,
      gatewayResponse: gatewayResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentResult &&
        other.success == success &&
        other.transactionId == transactionId &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return success.hashCode ^ transactionId.hashCode ^ errorMessage.hashCode;
  }

  @override
  String toString() {
    return 'PaymentResult(success: $success, transactionId: $transactionId, errorMessage: $errorMessage)';
  }
}
