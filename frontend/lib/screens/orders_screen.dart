import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_provider.dart';
import '../services/api_service.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final dio = ref.read(dioProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: FutureBuilder(
        future: dio.get('orders', queryParameters: {'session_code': session.sessionCode}),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data?.data as List? ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('No orders found yet.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          _buildStatusChip(order['status']),
                        ],
                      ),
                      const Divider(),
                      ...(order['items'] as List).map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${item['quantity']}x ${item['menu_item']['name']}'),
                            Text('\$${item['unit_price']}'),
                          ],
                        ),
                      )),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${order['total_price']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending': color = Colors.orange; break;
      case 'preparing': color = Colors.blue; break;
      case 'ready': color = Colors.green; break;
      case 'served': color = Colors.grey; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.black;
    }

    return Chip(
      label: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
    );
  }
}
