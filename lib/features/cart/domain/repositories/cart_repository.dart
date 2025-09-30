import 'package:deneme1/core/network/result.dart';
import 'package:deneme1/features/cart/domain/entities/cart_item.dart';
import 'package:deneme1/features/cart/domain/entities/cart.dart';

/// Cart repository interface
///
/// Usage:
/// ```dart
/// final repository = ref.read(cartRepositoryProvider);
/// final result = await repository.addToCart(cartItem);
/// ```
abstract class CartRepository {
  /// Get current cart
  Future<Result<Cart>> getCart();

  /// Add item to cart
  Future<Result<CartItem>> addToCart(CartItem item);

  /// Update cart item quantity
  Future<Result<CartItem>> updateQuantity(String itemId, int quantity);

  /// Update item quantity in cart
  Future<Result<Cart>> updateItemQuantity(String itemId, int quantity);

  /// Remove item from cart
  Future<Result<void>> removeFromCart(String itemId);

  /// Remove item from cart
  Future<Result<Cart>> removeItemFromCart(String itemId);

  /// Clear entire cart
  Future<Result<void>> clearCart();

  /// Apply discount to cart
  Future<Result<Cart>> applyDiscount(
    double discountAmount,
    String? discountCode,
  );

  /// Remove discount from cart
  Future<Result<Cart>> removeDiscount();

  /// Set customer for cart
  Future<Result<Cart>> setCustomer(String customerId, String customerName);

  /// Calculate cart totals
  Future<Result<Cart>> calculateTotals();

  /// Save cart state
  Future<Result<void>> saveCart();

  /// Load cart state
  Future<Result<Cart>> loadCart();
}
