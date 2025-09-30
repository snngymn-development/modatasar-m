import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deneme1/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:deneme1/features/cart/domain/entities/cart_item.dart';
import 'package:deneme1/features/cart/domain/entities/cart.dart' as cart_entity;
import 'package:deneme1/features/cart/domain/repositories/cart_repository.dart';
import 'package:deneme1/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:deneme1/core/network/result.dart';

/// Cart repository provider
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl();
});

/// Add to cart use case provider
final addToCartUseCaseProvider = Provider<AddToCartUseCase>((ref) {
  return AddToCartUseCase(ref.read(cartRepositoryProvider));
});

/// Cart provider
final cartProvider = FutureProvider<cart_entity.Cart>((ref) async {
  final repository = ref.read(cartRepositoryProvider);
  final result = await repository.getCart();
  if (result.isSuccess) {
    return result.data;
  } else {
    throw Exception(result.error.toString());
  }
});

/// Add to cart provider
final addToCartProvider = FutureProvider.family<CartItem, CartItem>((
  ref,
  item,
) async {
  final useCase = ref.read(addToCartUseCaseProvider);
  final result = await useCase.execute(item);
  if (result.isSuccess) {
    return result.data;
  } else {
    throw Exception(result.error.toString());
  }
});

/// Update quantity provider
final updateQuantityProvider =
    FutureProvider.family<CartItem, ({String itemId, int quantity})>((
      ref,
      params,
    ) async {
      final repository = ref.read(cartRepositoryProvider);
      final result = await repository.updateQuantity(
        params.itemId,
        params.quantity,
      );
      if (result.isSuccess) {
        return result.data;
      } else {
        throw Exception(result.error.toString());
      }
    });

/// Remove from cart provider
final removeFromCartProvider = FutureProvider.family<cart_entity.Cart, String>((
  ref,
  itemId,
) async {
  final repository = ref.read(cartRepositoryProvider);
  final result = await repository.removeItemFromCart(itemId);
  if (result.isSuccess) {
    return result.data;
  } else {
    throw Exception(result.error.toString());
  }
});

/// Clear cart provider
final clearCartProvider = FutureProvider<void>((ref) async {
  final repository = ref.read(cartRepositoryProvider);
  final result = await repository.clearCart();
  if (result.isSuccess) {
    return result.data;
  } else {
    throw Exception(result.error.toString());
  }
});

/// Apply discount provider
final applyDiscountProvider =
    FutureProvider.family<cart_entity.Cart, ({double amount, String? code})>((
      ref,
      params,
    ) async {
      final repository = ref.read(cartRepositoryProvider);
      final result = await repository.applyDiscount(params.amount, params.code);
      if (result.isSuccess) {
        return result.data;
      } else {
        throw Exception(result.error.toString());
      }
    });

/// Set customer provider
final setCustomerProvider =
    FutureProvider.family<
      cart_entity.Cart,
      ({String customerId, String customerName})
    >((ref, params) async {
      final repository = ref.read(cartRepositoryProvider);
      final result = await repository.setCustomer(
        params.customerId,
        params.customerName,
      );
      if (result.isSuccess) {
        return result.data;
      } else {
        throw Exception(result.error.toString());
      }
    });
