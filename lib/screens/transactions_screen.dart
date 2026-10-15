import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/format.dart';
import '../utils/pdf_helper.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _filter = 'all'; // all | buy | sell | today
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    var list = app.transactions.toList();
    if (_filter == 'buy') list = list.where((t) => t.isBuy).toList();
    if (_filter == 'sell') list = list.where((t) => !t.isBuy).toList();
    if (_filter == 'today') list = app.todayTransactions;
    if (_search.isNotEmpty) {
      list = list.where((t) =>
        t.customerName.contains(_search) ||
        t.invoiceNo.contains(_search) ||
        t.currencyCode.contains(_search.toUpperCase())
      ).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B4D2C),
      appBar: AppBar(title: const Text('سجل العمليات')),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF0B4D2C)),
                  hintText: 'بحث (اسم، رقم فاتورة، عملة)',
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  _chip('الكل', 'all'),
                  _chip('شراء', 'buy'),
                  _chip('بيع', 'sell'),
                  _chip('اليوم', 'today'),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: list.isEmpty
                  ? const Center(child: Text('لا توجد عمليات', style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      itemCount: list.length,
                      itemBuilder: (ctx, i) {
                        final t = list[i];
                        return Card(
                          color: const Color(0xFFFDFBF7),
                          margin: const EdgeInsets.only(bottom: 4),
                          child: ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              backgroundColor: t.isBuy ? Colors.green : Colors.red,
                              child: Icon(t.isBuy ? Icons.arrow_downward : Icons.arrow_upward,
                                color: Colors.white, size: 18),
                            ),
                            title: Text('#${t.invoiceNo} - ${t.customerName}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('${t.currencyCode} ${formatNumber(t.amount)} @ ${formatNumber(t.rate)}\n${t.date.toString().substring(0, 16)}',
                              style: const TextStyle(fontSize: 11)),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${formatNumber(t.totalSDG)} SDG',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                IconButton(
                                  icon: const Icon(Icons.print, size: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => PdfHelper.printTransaction(t, app.settings),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String val) {
    final active = _filter == val;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => setState(() => _filter = val),
        selectedColor: const Color(0xFFC5A059),
        backgroundColor: const Color(0xFFFDFBF7),
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: active ? const Color(0xFF0B4D2C) : const Color(0xFF0B4D2C),
        ),
      ),
    );
  }
}
