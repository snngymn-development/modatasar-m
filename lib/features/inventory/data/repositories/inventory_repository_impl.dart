import 'package:deneme1/core/network/result.dart';
import 'package:deneme1/core/error/failure.dart';
import 'package:dio/dio.dart';
import 'package:deneme1/features/inventory/domain/entities/inventory_item.dart';
import 'package:deneme1/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:deneme1/features/inventory/data/models/inventory_item_model.dart';

/// Inventory repository implementation
///
/// Usage:
/// ```dart
/// final repository = InventoryRepositoryImpl(networkClient);
/// final result = await repository.getInventoryItems();
/// ```
class InventoryRepositoryImpl implements InventoryRepository {
  final Dio _dio;

  InventoryRepositoryImpl(this._dio);

  @override
  Future<Result<List<InventoryItem>>> getInventoryItems() async {
    try {
      final response = await _dio.get('/inventory/items');
      final List<dynamic> data = response.data['items'] ?? [];
      final items = data
          .map((json) => InventoryItemModel.fromJson(json).toEntity())
          .toList();
      return Success(items);
    } catch (e) {
      return Error(Failure('Failed to fetch inventory items: $e'));
    }
  }

  @override
  Future<Result<InventoryItem?>> getInventoryItemById(String id) async {
    try {
      final response = await _dio.get('/inventory/items/$id');
      final item = InventoryItemModel.fromJson(response.data).toEntity();
      return Success(item);
    } catch (e) {
      return Error(Failure('Failed to fetch inventory item: $e'));
    }
  }

  @override
  Future<Result<InventoryItem>> createInventoryItem(InventoryItem item) async {
    try {
      final model = InventoryItemModel.fromEntity(item);
      final response = await _dio.post(
        '/inventory/items',
        data: model.toJson(),
      );
      final createdItem = InventoryItemModel.fromJson(response.data).toEntity();
      return Success(createdItem);
    } catch (e) {
      return Error(Failure('Failed to create inventory item: $e'));
    }
  }

  @override
  Future<Result<InventoryItem>> updateInventoryItem(InventoryItem item) async {
    try {
      final model = InventoryItemModel.fromEntity(item);
      final response = await _dio.put(
        '/inventory/items/${item.id}',
        data: model.toJson(),
      );
      final updatedItem = InventoryItemModel.fromJson(response.data).toEntity();
      return Success(updatedItem);
    } catch (e) {
      return Error(Failure('Failed to update inventory item: $e'));
    }
  }

  @override
  Future<Result<void>> deleteInventoryItem(String id) async {
    try {
      await _dio.delete('/inventory/items/$id');
      return const Success(null);
    } catch (e) {
      return Error(Failure('Failed to delete inventory item: $e'));
    }
  }

  @override
  Future<Result<List<InventoryItem>>> searchInventoryItems(String query) async {
    try {
      final response = await _dio.get(
        '/inventory/items/search',
        queryParameters: {'q': query},
      );
      final List<dynamic> data = response.data['items'] ?? [];
      final items = data
          .map((json) => InventoryItemModel.fromJson(json).toEntity())
          .toList();
      return Success(items);
    } catch (e) {
      return Error(Failure('Failed to search inventory items: $e'));
    }
  }

  @override
  Future<Result<List<InventoryItem>>> getInventoryItemsByCategory(
    String category,
  ) async {
    try {
      final response = await _dio.get('/inventory/items/category/$category');
      final List<dynamic> data = response.data['items'] ?? [];
      final items = data
          .map((json) => InventoryItemModel.fromJson(json).toEntity())
          .toList();
      return Success(items);
    } catch (e) {
      return Error(Failure('Failed to fetch inventory items by category: $e'));
    }
  }

  @override
  Future<Result<InventoryItem>> updateStock(String id, int newStock) async {
    try {
      final response = await _dio.patch(
        '/inventory/items/$id/stock',
        data: {'stock': newStock},
      );
      final updatedItem = InventoryItemModel.fromJson(response.data).toEntity();
      return Success(updatedItem);
    } catch (e) {
      return Error(Failure('Failed to update stock: $e'));
    }
  }
}
