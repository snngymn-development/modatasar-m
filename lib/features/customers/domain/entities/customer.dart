/// Customer domain entity
///
/// Usage:
/// ```dart
/// final customer = Customer(
///   id: 'C-001',
///   name: 'John Doe',
///   email: 'john@example.com',
///   phone: '+1234567890',
///   address: '123 Main St',
/// );
/// ```
class Customer {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final DateTime? dateOfBirth;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.dateOfBirth,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a copy with updated values
  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? postalCode,
    DateTime? dateOfBirth,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get full address as string
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  /// Get display name with email
  String get displayName => '$name ($email)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.address == address &&
        other.city == city &&
        other.country == country &&
        other.postalCode == postalCode &&
        other.dateOfBirth == dateOfBirth &&
        other.notes == notes &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        address.hashCode ^
        city.hashCode ^
        country.hashCode ^
        postalCode.hashCode ^
        dateOfBirth.hashCode ^
        notes.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, email: $email, phone: $phone)';
  }
}
