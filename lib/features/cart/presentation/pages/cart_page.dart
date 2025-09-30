import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deneme1/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:deneme1/features/cart/presentation/widgets/cart_summary.dart';
import 'package:deneme1/features/cart/presentation/providers/cart_providers.dart';
import 'package:deneme1/features/payments/presentation/pages/payment_page.dart';

/// Shopping cart page
///
/// Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (context) => const CartPage(),
/// ));
/// ```
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sepet'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(clearCartProvider.future);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Sepet temizlendi')));
            },
            icon: const Icon(Icons.clear_all),
            tooltip: 'Sepeti Temizle',
          ),
        ],
      ),
      body: cartAsync.when(
        data: (cart) {
          if (cart.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Sepetiniz boş',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ürün eklemek için alışverişe başlayın',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart items list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return CartItemCard(
                      item: item,
                      onQuantityChanged: (newQuantity) {
                        ref.read(
                          updateQuantityProvider((
                            itemId: item.id,
                            quantity: newQuantity,
                          )),
                        );
                      },
                      onRemove: () {
                        ref.read(removeFromCartProvider(item.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${item.productName} sepetten kaldırıldı',
                            ),
                            action: SnackBarAction(
                              label: 'Geri Al',
                              onPressed: () {
                                ref.read(addToCartProvider(item).future);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Cart summary
              CartSummary(cart: cart),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Sepet yüklenirken hata oluştu',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(cartProvider);
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: cartAsync.whenOrNull(
        data: (cart) => cart.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () {
                  _showCheckoutDialog(context, ref, cart);
                },
                icon: const Icon(Icons.payment),
                label: const Text('Ödeme'),
              )
            : null,
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, WidgetRef ref, cart) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödeme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Toplam: \$${cart.total.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('Ödeme işlemini başlatmak istiyor musunuz?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToPayment(context, cart);
            },
            child: const Text('Ödemeye Geç'),
          ),
        ],
      ),
    );
  }

  void _navigateToPayment(BuildContext context, cart) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          amount: cart.total,
          currency: 'USD',
          orderId: cart.id,
          customerId: cart.customerId,
          onPaymentSuccess: () {
            // Clear cart after successful payment
            // Note: Cart clearing should be handled by PaymentPage
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ödeme başarılı! Siparişiniz alındı.'),
                backgroundColor: Colors.green,
              ),
            );
          },
          onPaymentFailure: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ödeme başarısız oldu. Lütfen tekrar deneyin.'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      ),
    );
  }
}
