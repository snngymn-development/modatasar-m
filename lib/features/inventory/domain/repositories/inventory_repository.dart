import 'package:deneme1/core/network/result.dart';
import 'package:deneme1/features/inventory/domain/entities/inventory_item.dart';

/// Inventory repository interface
///
/// Usage:
/// ```dart
/// final repository = ref.read(inventoryRepositoryProvider);
/// final result = await repository.getInventoryItems();
/// ```
abstract class InventoryRepository {
  /// Get all inventory items
  Future<Result<List<InventoryItem>>> getInventoryItems();

  /// Get inventory item by ID
  Future<Result<InventoryItem?>> getInventoryItemById(String id);

  /// Create new inventory item
  Future<Result<InventoryItem>> createInventoryItem(InventoryItem item);

  /// Update existing inventory item
  Future<Result<InventoryItem>> updateInventoryItem(InventoryItem item);

  /// Delete inventory item
  Future<Result<void>> deleteInventoryItem(String id);

  /// Search inventory items by name or SKU
  Future<Result<List<InventoryItem>>> searchInventoryItems(String query);

  /// Get inventory items by category
  Future<Result<List<InventoryItem>>> getInventoryItemsByCategory(
    String category,
  );

  /// Update stock quantity
  Future<Result<InventoryItem>> updateStock(String id, int newStock);
}
