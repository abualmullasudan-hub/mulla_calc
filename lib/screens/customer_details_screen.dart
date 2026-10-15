import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/format.dart';
import '../utils/pdf_helper.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final String customerId;
  const CustomerDetailsScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final customer = app.getCustomer(customerId);
    if (customer == null) {
      return const Scaffold(body: Center(child: Text('عميل غير موجود')));
    }
    final txns = app.transactions.where((t) => t.customerId == customerId).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B4D2C),
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => PdfHelper.printCustomerStatement(customer, app.transactions, app.settings),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, app),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Card(
                color: const Color(0xFFFDFBF7),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _row('الاسم', customer.name),
                      if (customer.phone.isNotEmpty) _row('الهاتف', customer.phone),
                      if (customer.note.isNotEmpty) _row('ملاحظة', customer.note),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الرصيد الحالي:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${formatNumber(customer.balance)} SDG',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: customer.balance >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Text('سجل العمليات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: txns.isEmpty
                    ? const Center(child: Text('لا توجد عمليات', style: TextStyle(color: Colors.white70)))
                    : ListView.builder(
                        itemCount: txns.length,
                        itemBuilder: (ctx, i) {
                          final t = txns[i];
                          return Card(
                            color: const Color(0xFFFDFBF7),
                            margin: const EdgeInsets.only(bottom: 4),
                            child: ListTile(
                              dense: true,
                              leading: Icon(t.isBuy ? Icons.arrow_downward : Icons.arrow_upward,
                                color: t.isBuy ? Colors.green : Colors.red),
                              title: Text('#${t.invoiceNo} - ${t.currencyCode} ${formatNumber(t.amount)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text(t.date.toString().substring(0, 16), style: const TextStyle(fontSize: 11)),
                              trailing: Text('${formatNumber(t.totalSDG)} SDG',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4D2C))),
          Text(value, style: const TextStyle(color: Color(0xFF0B4D2C))),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState app) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف العميل'),
        content: const Text('هل أنت متأكد؟ سيتم حذف بيانات العميل فقط، والعمليات ستبقى.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              app.deleteCustomer(customerId);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
