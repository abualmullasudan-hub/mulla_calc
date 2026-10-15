import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/format.dart';
import '../models/customer.dart';
import 'customer_details_screen.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0B4D2C),
      appBar: AppBar(title: const Text('العملاء')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFC5A059),
        foregroundColor: const Color(0xFF0B4D2C),
        onPressed: () => _showAddDialog(context, app),
        icon: const Icon(Icons.person_add),
        label: const Text('عميل جديد', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: app.customers.isEmpty
          ? const Center(child: Text('لا يوجد عملاء بعد', style: TextStyle(color: Colors.white70, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: app.customers.length,
              itemBuilder: (ctx, i) {
                final c = app.customers[i];
                return Card(
                  color: const Color(0xFFFDFBF7),
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF0B4D2C),
                      child: Text(c.name.isNotEmpty ? c.name[0] : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4D2C))),
                    subtitle: Text(c.phone.isEmpty ? 'بدون هاتف' : c.phone),
                    trailing: Text(
                      '${formatNumber(c.balance)} SDG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: c.balance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => CustomerDetailsScreen(customerId: c.id))),
                  ),
                );
              },
            ),
    );
  }

  void _showAddDialog(BuildContext context, AppState app) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('عميل جديد'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم *')),
          TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'الهاتف'), keyboardType: TextInputType.phone),
          TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'ملاحظة')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              app.addCustomer(nameCtrl.text.trim(), phoneCtrl.text.trim(), noteCtrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
