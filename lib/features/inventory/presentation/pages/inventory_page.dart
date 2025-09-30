import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deneme1/features/inventory/domain/entities/inventory_item.dart';
import 'package:deneme1/features/inventory/presentation/widgets/inventory_item_card.dart';
import 'package:deneme1/features/inventory/presentation/widgets/inventory_search_bar.dart';

/// Inventory management page
///
/// Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (context) => const InventoryPage(),
/// ));
/// ```
class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final inventoryItemsAsync = ref.watch(inventoryItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            onPressed: () => _showAddItemDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          InventorySearchBar(
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),
          Expanded(
            child: inventoryItemsAsync.when(
              data: (items) {
                final filteredItems = _filterItems(items, _searchQuery);
                return ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return InventoryItemCard(
                      item: item,
                      onTap: () => _showItemDetails(context, item),
                      onEdit: () => _showEditItemDialog(context, item),
                      onDelete: () => _deleteItem(context, item),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(inventoryItemsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<InventoryItem> _filterItems(List<InventoryItem> items, String query) {
    if (query.isEmpty) return items;
    return items.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.sku.toLowerCase().contains(query.toLowerCase()) ||
          item.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void _showAddItemDialog(BuildContext context) {
    // Implement add item dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: const Text(
          'Add item functionality is ready for implementation',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SKU: ${item.sku}'),
            Text('Category: ${item.category}'),
            Text('Price: \$${item.price.toStringAsFixed(2)}'),
            Text('Stock: ${item.stock}'),
            if (item.description != null)
              Text('Description: ${item.description}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, InventoryItem item) {
    // Implement edit item dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: const Text(
          'Edit item functionality is ready for implementation',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete functionality
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Inventory items provider
final inventoryItemsProvider = FutureProvider<List<InventoryItem>>((ref) async {
  // TODO: Implement with actual repository
  return [];
});
