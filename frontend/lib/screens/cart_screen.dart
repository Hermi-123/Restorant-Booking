import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../providers/session_provider.dart';
import '../services/api_service.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  Future<void> _submitOrder(BuildContext context, WidgetRef ref) async {
    final cart = ref.read(cartProvider);
    final session = ref.read(sessionProvider);
    final dio = ref.read(dioProvider);

    if (cart.items.isEmpty) return;

    try {
      final response = await dio.post('orders', data: {
        'session_code': session.sessionCode,
        'items': cart.items.values.map((item) => {
          'menu_item_id': item.menuItem.id,
          'quantity': item.quantity,
          'special_instructions': item.specialInstructions,
        }).toList(),
      });

      if (response.statusCode == 201) {
        ref.read(cartProvider.notifier).clearCart();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order placed successfully!')),
          );
          context.pushReplacement('/orders');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items.values.elementAt(index);
                      return ListTile(
                        title: Text(item.menuItem.name),
                        subtitle: Text('\$${item.menuItem.price} x ${item.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => ref.read(cartProvider.notifier).removeItem(item.menuItem.id),
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => ref.read(cartProvider.notifier).addItem(item.menuItem),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('\$${cart.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                          onPressed: () => _submitOrder(context, ref),
                          child: const Text('Confirm Order', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
