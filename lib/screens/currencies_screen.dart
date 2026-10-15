import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/format.dart';
import '../models/currency.dart';

class CurrenciesScreen extends StatelessWidget {
  const CurrenciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final list = app.currencies.values.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B4D2C),
      appBar: AppBar(title: const Text('العملات والأسعار')),
      body: ListView.builder(
        padding: const EdgeInsets.all(6),
        itemCount: list.length,
        itemBuilder: (ctx, i) {
          final c = list[i];
          return Card(
            color: const Color(0xFFFDFBF7),
            margin: const EdgeInsets.only(bottom: 6),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(c.flag, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0B4D2C))),
                            Text(c.code, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Switch(
                        value: c.active,
                        activeColor: const Color(0xFF0B4D2C),
                        onChanged: (_) => app.toggleCurrencyActive(c.code),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(child: _rateField(context, c, 'شراء', c.buyRate, true, app)),
                      const SizedBox(width: 8),
                      Expanded(child: _rateField(context, c, 'بيع', c.sellRate, false, app)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _rateField(BuildContext context, Currency c, String label, double val, bool isBuy, AppState app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        TextField(
          controller: TextEditingController(text: val.toStringAsFixed(0)),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF4EBD0),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4D2C)),
          onSubmitted: (v) {
            final d = double.tryParse(v);
            if (d != null) {
              app.updateCurrency(c.code, buyRate: isBuy ? d : null, sellRate: isBuy ? null : d);
            }
          },
        ),
      ],
    );
  }
}
