import 'package:deneme1/core/network/result.dart';
import 'package:deneme1/features/cart/domain/entities/cart_item.dart';
import 'package:deneme1/features/cart/domain/entities/cart.dart';
import 'package:deneme1/features/cart/domain/repositories/cart_repository.dart';
import 'package:deneme1/core/logging/talker_config.dart';
import 'package:deneme1/core/error/failure.dart';

/// Cart repository implementation
class CartRepositoryImpl implements CartRepository {
  Cart? _currentCart;
  final List<CartItem> _items = [];

  @override
  Future<Result<Cart>> getCart() async {
    try {
      _currentCart ??= Cart(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
        items: _items,
        subtotal: _calculateSubtotal(),
        tax: _calculateTax(),
        discount: 0.0,
        total: _calculateTotal(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      TalkerConfig.logInfo('Retrieved cart with ${_items.length} items');
      return Result.ok(_currentCart!);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to get cart', e, stackTrace);
      return Result.err(Failure('Failed to get cart: ${e.toString()}'));
    }
  }

  @override
  Future<Result<CartItem>> addToCart(CartItem item) async {
    try {
      final existingItemIndex = _items.indexWhere(
        (existingItem) => existingItem.productId == item.productId,
      );

      if (existingItemIndex != -1) {
        // Update existing item quantity
        final existingItem = _items[existingItemIndex];
        final updatedItem = CartItem(
          id: existingItem.id,
          productId: existingItem.productId,
          productName: existingItem.productName,
          price: existingItem.price,
          quantity: existingItem.quantity + item.quantity,
          total: (existingItem.quantity + item.quantity) * existingItem.price,
          imageUrl: existingItem.imageUrl,
          description: existingItem.description,
          addedAt: existingItem.addedAt,
          updatedAt: DateTime.now(),
        );
        _items[existingItemIndex] = updatedItem;
        TalkerConfig.logInfo(
          'Updated item quantity: ${updatedItem.productName}',
        );
        return Result.ok(updatedItem);
      } else {
        // Add new item
        _items.add(item);
        TalkerConfig.logInfo('Added new item to cart: ${item.productName}');
        return Result.ok(item);
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to add item to cart', e, stackTrace);
      return Result.err(Failure('Failed to add item to cart: ${e.toString()}'));
    }
  }

  @override
  Future<Result<CartItem>> updateQuantity(String itemId, int quantity) async {
    try {
      final itemIndex = _items.indexWhere((item) => item.id == itemId);

      if (itemIndex == -1) {
        return Result.err(Failure('Item not found in cart'));
      }

      if (quantity <= 0) {
        _items.removeAt(itemIndex);
        TalkerConfig.logInfo('Removed item from cart: $itemId');
        return Result.err(Failure('Item removed due to zero quantity'));
      }

      final item = _items[itemIndex];
      final updatedItem = CartItem(
        id: item.id,
        productId: item.productId,
        productName: item.productName,
        price: item.price,
        quantity: quantity,
        total: quantity * item.price,
        imageUrl: item.imageUrl,
        description: item.description,
        addedAt: item.addedAt,
        updatedAt: DateTime.now(),
      );
      _items[itemIndex] = updatedItem;

      TalkerConfig.logInfo('Updated item quantity: ${updatedItem.productName}');
      return Result.ok(updatedItem);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to update item quantity', e, stackTrace);
      return Result.err(
        Failure('Failed to update item quantity: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> removeFromCart(String itemId) async {
    try {
      final itemIndex = _items.indexWhere((item) => item.id == itemId);

      if (itemIndex == -1) {
        return Result.err(Failure('Item not found in cart'));
      }

      _items.removeAt(itemIndex);
      TalkerConfig.logInfo('Removed item from cart: $itemId');
      return Result.ok(null);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to remove item from cart', e, stackTrace);
      return Result.err(
        Failure('Failed to remove item from cart: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> clearCart() async {
    try {
      _items.clear();
      _currentCart = null;
      TalkerConfig.logInfo('Cleared cart');
      return Result.ok(null);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to clear cart', e, stackTrace);
      return Result.err(Failure('Failed to clear cart: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Cart>> applyDiscount(
    double discountAmount,
    String? discountCode,
  ) async {
    try {
      if (_currentCart == null) {
        return Result.err(Failure('No cart available'));
      }

      final updatedCart = Cart(
        id: _currentCart!.id,
        items: _currentCart!.items,
        subtotal: _currentCart!.subtotal,
        tax: _currentCart!.tax,
        discount: discountAmount,
        total: _calculateTotal() - discountAmount,
        customerId: _currentCart!.customerId,
        customerName: _currentCart!.customerName,
        discountCode: discountCode,
        createdAt: _currentCart!.createdAt,
        updatedAt: DateTime.now(),
      );
      _currentCart = updatedCart;

      TalkerConfig.logInfo('Applied discount: $discountAmount');
      return Result.ok(updatedCart);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to apply discount', e, stackTrace);
      return Result.err(Failure('Failed to apply discount: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Cart>> removeDiscount() async {
    try {
      if (_currentCart == null) {
        return Result.err(Failure('No cart available'));
      }

      final updatedCart = Cart(
        id: _currentCart!.id,
        items: _currentCart!.items,
        subtotal: _currentCart!.subtotal,
        tax: _currentCart!.tax,
        discount: 0.0,
        total: _calculateTotal(),
        customerId: _currentCart!.customerId,
        customerName: _currentCart!.customerName,
        discountCode: null,
        createdAt: _currentCart!.createdAt,
        updatedAt: DateTime.now(),
      );
      _currentCart = updatedCart;

      TalkerConfig.logInfo('Removed discount');
      return Result.ok(updatedCart);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to remove discount', e, stackTrace);
      return Result.err(Failure('Failed to remove discount: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Cart>> setCustomer(
    String customerId,
    String customerName,
  ) async {
    try {
      if (_currentCart == null) {
        return Result.err(Failure('No cart available'));
      }

      final updatedCart = Cart(
        id: _currentCart!.id,
        items: _currentCart!.items,
        subtotal: _currentCart!.subtotal,
        tax: _currentCart!.tax,
        discount: _currentCart!.discount,
        total: _currentCart!.total,
        customerId: customerId,
        customerName: customerName,
        discountCode: _currentCart!.discountCode,
        createdAt: _currentCart!.createdAt,
        updatedAt: DateTime.now(),
      );
      _currentCart = updatedCart;

      TalkerConfig.logInfo('Set customer: $customerName');
      return Result.ok(updatedCart);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to set customer', e, stackTrace);
      return Result.err(Failure('Failed to set customer: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Cart>> calculateTotals() async {
    try {
      if (_currentCart == null) {
        return Result.err(Failure('No cart available'));
      }

      final updatedCart = Cart(
        id: _currentCart!.id,
        items: _currentCart!.items,
        subtotal: _calculateSubtotal(),
        tax: _calculateTax(),
        discount: _currentCart!.discount,
        total: _calculateTotal(),
        customerId: _currentCart!.customerId,
        customerName: _currentCart!.customerName,
        discountCode: _currentCart!.discountCode,
        createdAt: _currentCart!.createdAt,
        updatedAt: DateTime.now(),
      );
      _currentCart = updatedCart;

      TalkerConfig.logInfo('Calculated cart totals');
      return Result.ok(updatedCart);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to calculate totals', e, stackTrace);
      return Result.err(Failure('Failed to calculate totals: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Cart>> updateItemQuantity(String itemId, int quantity) async {
    try {
      if (_currentCart == null) {
        return Result.err(Failure('No cart available'));
      }

      final itemIndex = _currentCart!.items.indexWhere(
        (item) => item.id == itemId,
      );
      if (itemIndex == -1) {
        return Result.err(Failure('Item not found in cart'));
      }

      if (quantity <= 0) {
        return await removeItemFromCart(itemId);
      }

      final item = _currentCart!.items[itemIndex];
      final updatedItem = CartItem(
        id: item.id,
        productId: item.productId,
        productName: item.productName,
        price: item.price,
        quantity: quantity,
        total: item.price * quantity,
        imageUrl: item.imageUrl,
        description: item.description,
        addedAt: item.addedAt,
        updatedAt: DateTime.now(),
      );

      final updatedItems = List<CartItem>.from(_currentCart!.items);
      updatedItems[itemIndex] = updatedItem;

      final updatedCart = Cart(
        id: _currentCart!.id,
        items: updatedItems,
        subtotal: _calculateSubtotal(),
        tax: _calculateTax(),
        discount: _currentCart!.discount,
        total: _calculateTotal(),
        customerId: _currentCart!.customerId,
        customerName: _currentCart!.customerName,
        discountCode: _currentCart!.discountCode,
        createdAt: _currentCart!.createdAt,
        updatedAt: DateTime.now(),
      );
      _currentCart = updatedCart;

      TalkerConfig.logInfo('Updated item quantity: $itemId -> $quantity');
      return Result.ok(updatedCart);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to update item quantity', e, stackTrace);
      return Result.err(
        Failure('Failed to update item quantity: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Cart>> removeItemFromCart(String itemId) async {
    try {
      if (_currentCart == null) {
        return Result.err(Failure('No cart available'));
      }

      final updatedItems = _currentCart!.items
          .where((item) => item.id != itemId)
          .toList();

      final updatedCart = Cart(
        id: _currentCart!.id,
        items: updatedItems,
        subtotal: _calculateSubtotal(),
        tax: _calculateTax(),
        discount: _currentCart!.discount,
        total: _calculateTotal(),
        customerId: _currentCart!.customerId,
        customerName: _currentCart!.customerName,
        discountCode: _currentCart!.discountCode,
        createdAt: _currentCart!.createdAt,
        updatedAt: DateTime.now(),
      );
      _currentCart = updatedCart;

      TalkerConfig.logInfo('Removed item from cart: $itemId');
      return Result.ok(updatedCart);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to remove item from cart', e, stackTrace);
      return Result.err(
        Failure('Failed to remove item from cart: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> saveCart() async {
    try {
      // In a real implementation, this would save to local storage or backend
      TalkerConfig.logInfo('Cart saved');
      return Result.ok(null);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to save cart', e, stackTrace);
      return Result.err(Failure('Failed to save cart: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Cart>> loadCart() async {
    try {
      // In a real implementation, this would load from local storage or backend
      if (_currentCart == null) {
        return Result.err(Failure('No saved cart found'));
      }

      TalkerConfig.logInfo('Cart loaded');
      return Result.ok(_currentCart!);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to load cart', e, stackTrace);
      return Result.err(Failure('Failed to load cart: ${e.toString()}'));
    }
  }

  // Helper methods
  double _calculateSubtotal() {
    return _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double _calculateTax() {
    // Simple tax calculation (10% of subtotal)
    return _calculateSubtotal() * 0.1;
  }

  double _calculateTotal() {
    return _calculateSubtotal() +
        _calculateTax() -
        (_currentCart?.discount ?? 0.0);
  }
}
