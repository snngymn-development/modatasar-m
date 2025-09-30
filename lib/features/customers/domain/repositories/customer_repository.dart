import 'package:deneme1/core/network/result.dart';
import 'package:deneme1/features/customers/domain/entities/customer.dart';

/// Customer repository interface
///
/// Usage:
/// ```dart
/// final repository = ref.read(customerRepositoryProvider);
/// final result = await repository.getCustomers();
/// ```
abstract class CustomerRepository {
  /// Get all customers
  Future<Result<List<Customer>>> getCustomers();

  /// Get customer by ID
  Future<Result<Customer?>> getCustomerById(String id);

  /// Create new customer
  Future<Result<Customer>> createCustomer(Customer customer);

  /// Update existing customer
  Future<Result<Customer>> updateCustomer(Customer customer);

  /// Delete customer
  Future<Result<void>> deleteCustomer(String id);

  /// Search customers by name or email
  Future<Result<List<Customer>>> searchCustomers(String query);

  /// Get active customers only
  Future<Result<List<Customer>>> getActiveCustomers();

  /// Get customer statistics
  Future<Result<Map<String, dynamic>>> getCustomerStats();

  /// Get customers by city
  Future<Result<List<Customer>>> getCustomersByCity(String city);

  /// Get customer statistics
  Future<Result<CustomerStatistics>> getCustomerStatistics();
}

/// Customer statistics data class
class CustomerStatistics {
  final int totalCustomers;
  final int activeCustomers;
  final int inactiveCustomers;
  final int newCustomersThisMonth;
  final double averageOrdersPerCustomer;

  const CustomerStatistics({
    required this.totalCustomers,
    required this.activeCustomers,
    required this.inactiveCustomers,
    required this.newCustomersThisMonth,
    required this.averageOrdersPerCustomer,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomerStatistics &&
        other.totalCustomers == totalCustomers &&
        other.activeCustomers == activeCustomers &&
        other.inactiveCustomers == inactiveCustomers &&
        other.newCustomersThisMonth == newCustomersThisMonth &&
        other.averageOrdersPerCustomer == averageOrdersPerCustomer;
  }

  @override
  int get hashCode {
    return totalCustomers.hashCode ^
        activeCustomers.hashCode ^
        inactiveCustomers.hashCode ^
        newCustomersThisMonth.hashCode ^
        averageOrdersPerCustomer.hashCode;
  }

  @override
  String toString() {
    return 'CustomerStatistics(total: $totalCustomers, active: $activeCustomers)';
  }
}
