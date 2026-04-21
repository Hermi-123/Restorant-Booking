import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class ChefDashboardScreen extends ConsumerStatefulWidget {
  const ChefDashboardScreen({super.key});

  @override
  ConsumerState<ChefDashboardScreen> createState() => _ChefDashboardScreenState();
}

class _ChefDashboardScreenState extends ConsumerState<ChefDashboardScreen> {
  List<dynamic> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final dio = ref.read(dioProvider);
    try {
      final response = await dio.get('chef/orders');
      setState(() {
        _orders = response.data;
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; });
    }
  }

  Future<void> _updateStatus(int orderId, String status) async {
    final dio = ref.read(dioProvider);
    try {
      await dio.patch('chef/orders/$orderId', data: {'status': status});
      _fetchOrders(); // Refresh list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👨‍🍳 Kitchen Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders),
        ],
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : _orders.isEmpty
          ? const Center(child: Text('No active orders'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final table = order['session']['table']['table_number'];
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Table $table - Order #${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            _buildStatusDropdown(order['id'], order['status']),
                          ],
                        ),
                        const Divider(),
                        ...(order['items'] as List).map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text('• ${item['quantity']}x ${item['menu_item']['name']}', style: const TextStyle(fontSize: 16)),
                        )),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusDropdown(int id, String currentStatus) {
    return DropdownButton<String>(
      value: currentStatus,
      items: ['pending', 'preparing', 'ready', 'served', 'cancelled']
          .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
      onChanged: (val) {
        if (val != null) _updateStatus(id, val);
      },
    );
  }
}
