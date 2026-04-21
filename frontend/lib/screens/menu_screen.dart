import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../providers/session_provider.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(menuProvider);
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${session.tableNumber ?? ""} Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              // TODO: Navigate to Order cart/summary
            },
          )
        ],
      ),
      body: menuAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No menu items available.'));
          }
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...category.items.map((item) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: item.imageUrl != null 
                        ? Image.network(item.imageUrl!, width: 60, height: 60, fit: BoxFit.cover)
                        : Container(width: 60, height: 60, color: Colors.grey[300], child: const Icon(Icons.fastfood, color: Colors.grey)),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        if (!item.isAvailable)
                          const Text('Sold out', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                    ),
                    onTap: item.isAvailable ? () {
                      // TODO: Add to order/cart logic
                    } : null,
                  )).toList(),
                  const Divider(),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
