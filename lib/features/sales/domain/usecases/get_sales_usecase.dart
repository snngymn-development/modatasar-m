import 'package:deneme1/core/network/result.dart';
import 'package:deneme1/features/sales/domain/entities/sale.dart';
import 'package:deneme1/features/sales/domain/repositories/sale_repository.dart';

/// Get sales use case
///
/// Usage:
/// ```dart
/// final useCase = GetSalesUsecase(repository);
/// final result = await useCase.execute();
/// ```
class GetSalesUsecase {
  final SaleRepository _repository;

  GetSalesUsecase(this._repository);

  Future<Result<List<Sale>>> execute() async {
    return await _repository.fetchSalesResult();
  }
}
