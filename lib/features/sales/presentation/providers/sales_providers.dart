import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deneme1/core/di/providers.dart';
import 'package:deneme1/core/network/result.dart';
import 'package:deneme1/features/sales/domain/usecases/get_sales_usecase.dart';
import 'package:deneme1/features/sales/domain/entities/sale.dart';
import 'package:deneme1/features/sales/data/repositories/sale_repository_impl.dart';

/// Sales repository provider
final salesRepositoryProvider = Provider<SaleRepositoryImpl>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SaleRepositoryImpl(apiClient: apiClient);
});

/// Get sales use case provider
final getSalesUsecaseProvider = Provider<GetSalesUsecase>((ref) {
  final repository = ref.watch(salesRepositoryProvider);
  return GetSalesUsecase(repository);
});

/// Sales list provider
final salesListProvider = FutureProvider<List<Sale>>((ref) async {
  final useCase = ref.watch(getSalesUsecaseProvider);
  final result = await useCase.execute();
  if (result.isSuccess) {
    return result.data;
  } else {
    throw Exception(result.error.toString());
  }
});
