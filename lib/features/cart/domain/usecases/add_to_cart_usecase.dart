import 'package:deneme1/core/network/result.dart';
import 'package:deneme1/core/error/failure.dart';
import 'package:deneme1/features/cart/domain/entities/cart_item.dart';
import 'package:deneme1/features/cart/domain/repositories/cart_repository.dart';

/// Add to cart use case
///
/// Usage:
/// ```dart
/// final useCase = ref.read(addToCartUseCaseProvider);
/// final result = await useCase.execute(cartItem);
/// ```
class AddToCartUseCase {
  final CartRepository _repository;

  AddToCartUseCase(this._repository);

  /// Execute add to cart operation
  Future<Result<CartItem>> execute(CartItem item) async {
    try {
      // Validate item
      if (item.quantity <= 0) {
        return Result.err(Failure('Quantity must be greater than 0'));
      }

      if (item.price < 0) {
        return Result.err(Failure('Price cannot be negative'));
      }

      // Add to cart
      return await _repository.addToCart(item);
    } catch (e) {
      return Result.err(Failure('Failed to add item to cart: ${e.toString()}'));
    }
  }
}
