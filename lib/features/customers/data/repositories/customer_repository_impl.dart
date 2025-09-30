import 'package:deneme1/core/network/result.dart';
import 'package:deneme1/core/error/failure.dart';
import 'package:deneme1/features/customers/domain/entities/customer.dart';
import 'package:deneme1/features/customers/domain/repositories/customer_repository.dart';
import 'package:deneme1/core/logging/talker_config.dart';

/// Customer repository implementation
class CustomerRepositoryImpl implements CustomerRepository {
  final List<Customer> _customers = [];

  CustomerRepositoryImpl() {
    _initializeMockData();
  }

  void _initializeMockData() {
    _customers.addAll([
      Customer(
        id: 'C-001',
        name: 'Ahmet Yılmaz',
        email: 'ahmet@example.com',
        phone: '+90 555 123 4567',
        address: 'Atatürk Caddesi No: 15',
        city: 'İstanbul',
        country: 'Türkiye',
        postalCode: '34000',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isActive: true,
      ),
      Customer(
        id: 'C-002',
        name: 'Fatma Demir',
        email: 'fatma@example.com',
        phone: '+90 555 234 5678',
        address: 'Cumhuriyet Bulvarı No: 42',
        city: 'Ankara',
        country: 'Türkiye',
        postalCode: '06000',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        isActive: true,
      ),
      Customer(
        id: 'C-003',
        name: 'Mehmet Kaya',
        email: 'mehmet@example.com',
        phone: '+90 555 345 6789',
        address: 'Kıbrıs Şehitleri Caddesi No: 8',
        city: 'İzmir',
        country: 'Türkiye',
        postalCode: '35000',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        isActive: true,
      ),
      Customer(
        id: 'C-004',
        name: 'Ayşe Özkan',
        email: 'ayse@example.com',
        phone: '+90 555 456 7890',
        address: 'Gazi Mustafa Kemal Bulvarı No: 25',
        city: 'Bursa',
        country: 'Türkiye',
        postalCode: '16000',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        isActive: false,
      ),
    ]);
  }

  @override
  Future<Result<List<Customer>>> getCustomers() async {
    try {
      TalkerConfig.logInfo('Retrieved ${_customers.length} customers');
      return Result.ok(List.from(_customers));
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to get customers', e, stackTrace);
      return Result.err(Failure('Failed to get customers: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Customer?>> getCustomerById(String id) async {
    try {
      final customer = _customers.firstWhere(
        (c) => c.id == id,
        orElse: () => throw Exception('Customer not found'),
      );
      TalkerConfig.logInfo('Retrieved customer: ${customer.name}');
      return Result.ok(customer);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to get customer by ID: $id', e, stackTrace);
      return Result.err(Failure('Customer not found: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Customer>> createCustomer(Customer customer) async {
    try {
      // Check if customer with same email already exists
      final existingCustomer = _customers.any((c) => c.email == customer.email);
      if (existingCustomer) {
        return Result.err(
          Failure('Customer with email ${customer.email} already exists'),
        );
      }

      final newCustomer = customer.copyWith(
        id: 'C-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );
      _customers.add(newCustomer);

      TalkerConfig.logInfo('Created customer: ${newCustomer.name}');
      return Result.ok(newCustomer);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to create customer', e, stackTrace);
      return Result.err(Failure('Failed to create customer: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Customer>> updateCustomer(Customer customer) async {
    try {
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index == -1) {
        return Result.err(Failure('Customer not found'));
      }

      final updatedCustomer = customer.copyWith(updatedAt: DateTime.now());
      _customers[index] = updatedCustomer;

      TalkerConfig.logInfo('Updated customer: ${updatedCustomer.name}');
      return Result.ok(updatedCustomer);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to update customer', e, stackTrace);
      return Result.err(Failure('Failed to update customer: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> deleteCustomer(String id) async {
    try {
      final index = _customers.indexWhere((c) => c.id == id);
      if (index == -1) {
        return Result.err(Failure('Customer not found'));
      }

      final removedCustomer = _customers.removeAt(index);
      TalkerConfig.logInfo('Deleted customer: ${removedCustomer.name}');
      return Result.ok(null);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to delete customer', e, stackTrace);
      return Result.err(Failure('Failed to delete customer: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<Customer>>> searchCustomers(String query) async {
    try {
      final lowercaseQuery = query.toLowerCase();
      final filteredCustomers = _customers.where((customer) {
        return customer.name.toLowerCase().contains(lowercaseQuery) ||
            customer.email.toLowerCase().contains(lowercaseQuery) ||
            (customer.phone?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();

      TalkerConfig.logInfo(
        'Found ${filteredCustomers.length} customers for query: $query',
      );
      return Result.ok(filteredCustomers);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to search customers', e, stackTrace);
      return Result.err(Failure('Failed to search customers: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<Customer>>> getActiveCustomers() async {
    try {
      final activeCustomers = _customers.where((c) => c.isActive).toList();
      TalkerConfig.logInfo(
        'Retrieved ${activeCustomers.length} active customers',
      );
      return Result.ok(activeCustomers);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to get active customers', e, stackTrace);
      return Result.err(
        Failure('Failed to get active customers: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getCustomerStats() async {
    try {
      final totalCustomers = _customers.length;
      final activeCustomers = _customers.where((c) => c.isActive).length;
      final inactiveCustomers = totalCustomers - activeCustomers;

      final stats = {
        'totalCustomers': totalCustomers,
        'activeCustomers': activeCustomers,
        'inactiveCustomers': inactiveCustomers,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      TalkerConfig.logInfo('Retrieved customer statistics: $stats');
      return Result.ok(stats);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to get customer statistics', e, stackTrace);
      return Result.err(
        Failure('Failed to get customer statistics: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Customer>>> getCustomersByCity(String city) async {
    try {
      final cityCustomers = _customers
          .where((c) => c.city?.toLowerCase() == city.toLowerCase())
          .toList();
      TalkerConfig.logInfo(
        'Retrieved ${cityCustomers.length} customers from $city',
      );
      return Result.ok(cityCustomers);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to get customers by city', e, stackTrace);
      return Result.err(
        Failure('Failed to get customers by city: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<CustomerStatistics>> getCustomerStatistics() async {
    try {
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month);

      final totalCustomers = _customers.length;
      final activeCustomers = _customers.where((c) => c.isActive).length;
      final inactiveCustomers = totalCustomers - activeCustomers;
      final newCustomersThisMonth = _customers
          .where((c) => c.createdAt.isAfter(thisMonth))
          .length;

      // Mock average orders per customer
      const averageOrdersPerCustomer = 2.5;

      final statistics = CustomerStatistics(
        totalCustomers: totalCustomers,
        activeCustomers: activeCustomers,
        inactiveCustomers: inactiveCustomers,
        newCustomersThisMonth: newCustomersThisMonth,
        averageOrdersPerCustomer: averageOrdersPerCustomer,
      );

      TalkerConfig.logInfo('Retrieved customer statistics');
      return Result.ok(statistics);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to get customer statistics', e, stackTrace);
      return Result.err(
        Failure('Failed to get customer statistics: ${e.toString()}'),
      );
    }
  }
}
