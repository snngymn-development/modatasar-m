/// Validation utilities for form inputs
///
/// Usage:
/// ```dart
/// final validator = Validators.combine([
///   (v) => Validators.requiredField(v),
///   (v) => Validators.email(v),
/// ]);
/// final error = validator('test@example.com'); // null if valid
/// ```
class Validators {
  // 'required' adı yer tutucu/anahtar kelimeyle çakışmasın:
  static String? requiredField(
    String? v, {
    String message = 'Bu alan zorunludur',
  }) => (v == null || v.trim().isEmpty) ? message : null;

  // örnek ekstra:
  static String? minLen(
    String? v,
    int n, {
    String message = 'Yetersiz uzunluk',
  }) => (v ?? '').trim().length < n ? message : null;

  // Email validation
  static String? email(
    String? v, {
    String message = 'Geçerli bir email adresi giriniz',
  }) {
    if (v == null || v.trim().isEmpty) {
      return null; // Let requiredField handle empty
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(v.trim()) ? null : message;
  }

  // Phone number validation (Turkish format)
  static String? phone(
    String? v, {
    String message = 'Geçerli bir telefon numarası giriniz',
  }) {
    if (v == null || v.trim().isEmpty) return null;
    final phoneRegex = RegExp(r'^(\+90|0)?[5][0-9]{9}$');
    return phoneRegex.hasMatch(v.trim().replaceAll(' ', '')) ? null : message;
  }

  // Max length validation
  static String? maxLen(
    String? v,
    int n, {
    String message = 'Maksimum uzunluk aşıldı',
  }) => (v ?? '').trim().length > n ? message : null;

  // Numeric validation
  static String? numeric(
    String? v, {
    String message = 'Sadece sayısal değer giriniz',
  }) {
    if (v == null || v.trim().isEmpty) return null;
    final numericRegex = RegExp(r'^\d+$');
    return numericRegex.hasMatch(v.trim()) ? null : message;
  }

  // Decimal validation
  static String? decimal(
    String? v, {
    String message = 'Geçerli bir ondalık sayı giriniz',
  }) {
    if (v == null || v.trim().isEmpty) return null;
    final decimalRegex = RegExp(r'^\d+\.?\d*$');
    return decimalRegex.hasMatch(v.trim()) ? null : message;
  }

  // Custom validation with function
  static String? custom(
    String? v,
    bool Function(String) validator, {
    String message = 'Geçersiz değer',
  }) => (v == null || v.trim().isEmpty)
      ? null
      : (validator(v.trim()) ? null : message);

  // Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
