import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deneme1/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:deneme1/features/customers/domain/entities/customer.dart';
import 'package:deneme1/features/customers/domain/repositories/customer_repository.dart';
import 'package:deneme1/core/network/result.dart';

/// Customer repository provider
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl();
});

/// Customers provider
final customersProvider = FutureProvider<List<Customer>>((ref) async {
  final repository = ref.read(customerRepositoryProvider);
  final result = await repository.getCustomers();
  if (result.isSuccess) {
    return result.data;
  } else {
    throw Exception(result.error.toString());
  }
});

/// Customer by ID provider
final customerProvider = FutureProvider.family<Customer, String>((
  ref,
  id,
) async {
  final repository = ref.read(customerRepositoryProvider);
  final result = await repository.getCustomerById(id);
  if (result.isSuccess) {
    return result.data!;
  } else {
    throw Exception(result.error.toString());
  }
});

/// Search customers provider
final searchCustomersProvider = FutureProvider.family<List<Customer>, String>((
  ref,
  query,
) async {
  final repository = ref.read(customerRepositoryProvider);
  final result = await repository.searchCustomers(query);
  if (result.isSuccess) {
    return result.data;
  } else {
    throw Exception(result.error.toString());
  }
});

/// Create customer provider
final createCustomerProvider = FutureProvider.family<Customer, Customer>((
  ref,
  customer,
) async {
  final repository = ref.read(customerRepositoryProvider);
  final result = await repository.createCustomer(customer);
  if (result.isSuccess) {
    return result.data;
  } else {
    throw Exception(result.error.toString());
  }
});

/// Update customer provider
final updateCustomerProvider = FutureProvider.family<Customer, Customer>((
  ref,
  customer,
) async {
  final repository = ref.read(customerRepositoryProvider);
  final result = await repository.updateCustomer(customer);
  if (result.isSuccess) {
    return result.data;
  } else {
    throw Exception(result.error.toString());
  }
});

/// Delete customer provider
final deleteCustomerProvider = FutureProvider.family<void, String>((
  ref,
  id,
) async {
  final repository = ref.read(customerRepositoryProvider);
  final result = await repository.deleteCustomer(id);
  if (result.isSuccess) {
    return result.data;
  } else {
    throw Exception(result.error.toString());
  }
});

/// Customer statistics provider
final customerStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(customerRepositoryProvider);
  final result = await repository.getCustomerStats();
  if (result.isSuccess) {
    return result.data;
  } else {
    throw Exception(result.error.toString());
  }
});
