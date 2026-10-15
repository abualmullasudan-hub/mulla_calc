import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/format.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _period = 'today'; // today | week | month | all

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final now = DateTime.now();
    List txns = app.transactions;
    if (_period == 'today') {
      txns = txns.where((t) => t.date.year == now.year && t.date.month == now.month && t.date.day == now.day).toList();
    } else if (_period == 'week') {
      final w = now.subtract(const Duration(days: 7));
      txns = txns.where((t) => t.date.isAfter(w)).toList();
    } else if (_period == 'month') {
      txns = txns.where((t) => t.date.year == now.year && t.date.month == now.month).toList();
    }

    double buyTotal = 0, sellTotal = 0, profitTotal = 0;
    Map<String, double> byCurrency = {};
    for (var t in txns) {
      if (t.isBuy) buyTotal += t.totalSDG;
      else sellTotal += t.totalSDG;
      final c = app.currencies[t.currencyCode];
      if (c != null) profitTotal += t.amount * (c.sellRate - c.buyRate);
      byCurrency[t.currencyCode] = (byCurrency[t.currencyCode] ?? 0) + t.totalSDG;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B4D2C),
      appBar: AppBar(title: const Text('التقارير')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _chip('اليوم', 'today'),
                  _chip('آخر أسبوع', 'week'),
                  _chip('هذا الشهر', 'month'),
                  _chip('الكل', 'all'),
                ]),
              ),
              const SizedBox(height: 10),
              _bigCard('مشتريات', buyTotal, Colors.green),
              const SizedBox(height: 6),
              _bigCard('مبيعات', sellTotal, Colors.red),
              const SizedBox(height: 6),
              _bigCard('أرباح تقديرية', profitTotal, const Color(0xFFC5A059)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFC5A059), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('حسب العملة', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4D2C), fontSize: 15)),
                    const Divider(),
                    if (byCurrency.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('لا توجد بيانات', style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ...byCurrency.entries.map((e) {
                        final c = app.currencies[e.key];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${c?.flag ?? ''} ${e.key}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4D2C))),
                              Text('${formatNumber(e.value)} SDG', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4D2C))),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text('عدد العمليات: ${txns.length}', style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, String val) {
    final active = _period == val;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => setState(() => _period = val),
        selectedColor: const Color(0xFFC5A059),
        backgroundColor: const Color(0xFFFDFBF7),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4D2C)),
      ),
    );
  }

  Widget _bigCard(String title, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
          Text('${formatNumber(value)} SDG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        ],
      ),
    );
  }
}
