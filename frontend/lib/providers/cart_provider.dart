import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'menu_provider.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;
  String? specialInstructions;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
    this.specialInstructions,
  });

  double get total => menuItem.price * quantity;
}

class CartState {
  final Map<int, CartItem> items;
  final bool isSubmitting;

  CartState({this.items = const {}, this.isSubmitting = false});

  double get totalPrice => items.values.fold(0, (sum, item) => sum + item.total);
  int get itemCount => items.values.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({Map<int, CartItem>? items, bool? isSubmitting}) {
    return CartState(
      items: items ?? this.items,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => CartState();

  void addItem(MenuItem item) {
    final newItems = Map<int, CartItem>.from(state.items);
    if (newItems.containsKey(item.id)) {
      newItems[item.id]!.quantity++;
    } else {
      newItems[item.id] = CartItem(menuItem: item);
    }
    state = state.copyWith(items: newItems);
  }

  void removeItem(int itemId) {
    final newItems = Map<int, CartItem>.from(state.items);
    if (newItems.containsKey(itemId)) {
      if (newItems[itemId]!.quantity > 1) {
        newItems[itemId]!.quantity--;
      } else {
        newItems.remove(itemId);
      }
    }
    state = state.copyWith(items: newItems);
  }

  void updateInstructions(int itemId, String instructions) {
    final newItems = Map<int, CartItem>.from(state.items);
    if (newItems.containsKey(itemId)) {
      newItems[itemId]!.specialInstructions = instructions;
      state = state.copyWith(items: newItems);
    }
  }

  void clearCart() {
    state = state.copyWith(items: {});
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});
