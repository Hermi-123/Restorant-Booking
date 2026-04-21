import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛡️ Admin Dashboard'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _TablesList(),
          _MenuManagement(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.table_restaurant), label: 'Tables'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
        ],
      ),
    );
  }
}

class _TablesList extends ConsumerStatefulWidget {
  const _TablesList();
  @override
  ConsumerState<_TablesList> createState() => _TablesListState();
}

class _TablesListState extends ConsumerState<_TablesList> {
  @override
  Widget build(BuildContext context) {
    final dio = ref.read(dioProvider);
    return FutureBuilder(
      future: dio.get('admin/tables'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final tables = snapshot.data!.data as List;
        return ListView.builder(
          itemCount: tables.length,
          itemBuilder: (context, index) {
            final t = tables[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.table_bar)),
              title: Text('Table ${t['table_number']}'),
              subtitle: Text('Capacity: ${t['capacity']} | Status: ${t['status']}'),
              trailing: Text('QR: ${t['qr_token']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          },
        );
      },
    );
  }
}

class _MenuManagement extends ConsumerWidget {
  const _MenuManagement();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dio = ref.read(dioProvider);
    return FutureBuilder(
      future: dio.get('menu'), // Reuse public menu for viewing
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final categories = snapshot.data!.data as List;
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return ExpansionTile(
              title: Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              children: (cat['menu_items'] as List).map((item) {
                return SwitchListTile(
                  title: Text(item['name']),
                  subtitle: Text('\$${item['price']}'),
                  value: item['is_available'] == 1 || item['is_available'] == true,
                  onChanged: (val) async {
                    await dio.patch('admin/menu-items/${item['id']}/availability', data: {'is_available': val});
                    // Refresh would be better with a provider, but for MVP we use FutureBuilder
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}
