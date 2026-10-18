import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/currency.dart';
import '../utils/format.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({super.key});
  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  String? _activeCode;

  void _append(String ch) {
    final app = context.read<AppState>();
    if (_activeCode == null) {
      final active = app.activeCurrencies;
      if (active.isEmpty) return;
      _activeCode = active.first;
    }
    final code = _activeCode!;
    final current = app.basketValues[code] ?? '0';
    String next;
    if (ch == '⌫') {
      next = current.length > 1 ? current.substring(0, current.length - 1) : '0';
    } else if (ch == 'C') {
      next = '0';
    } else if (current == '0' && ch != '.') {
      next = ch;
    } else {
      next = current + ch;
    }
    app.setBasketValue(code, next);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = app.theme;
    final active = app.activeCurrencies;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(color: t.cream, borderRadius: BorderRadius.circular(8), border: Border.all(color: t.gold, width: 2)),
                  child: DropdownButton<String>(
                    value: app.basketTarget,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: active.map((c) => DropdownMenuItem(value: c, child: Text('${kCurrencyFlags[c]} ${kCurrencyLabels[c]} ($c)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: t.textDark)))).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        app.basketTarget = v;
                        app.notifyListeners();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => app.clearBasketValues(),
                  style: ElevatedButton.styleFrom(backgroundColor: t.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: Text('تفريغ', style: TextStyle(color: t.cream, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: t.goldLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: t.gold, width: 1.5)),
            child: ListView(
              padding: const EdgeInsets.all(6),
              children: active.map((c) {
                final val = app.basketValues[c] ?? '0';
                final num = double.tryParse(val) ?? 0;
                final rate = app.rates.ratesToSDG[c] ?? 1;
                final targetRate = app.rates.ratesToSDG[app.basketTarget] ?? 1;
                final conv = targetRate != 0 ? (num * rate) / targetRate : 0;
                final selected = _activeCode == c;
                return InkWell(
                  onTap: () => setState(() => _activeCode = c),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(color: selected ? t.goldLight : t.cream, borderRadius: BorderRadius.circular(6), border: Border.all(color: selected ? t.primaryDark : t.gold, width: 1.5)),
                    child: Row(
                      children: [
                        SizedBox(width: 80, child: Text('${kCurrencyFlags[c] ?? ''} $c', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: t.textDark))),
                        Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 4), color: t.cream, child: Center(child: Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: t.textDark))))),
                        const SizedBox(width: 4),
                        Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 4), decoration: BoxDecoration(color: t.cream, border: Border.all(color: t.primaryDark, width: 1), borderRadius: BorderRadius.circular(4)), child: Center(child: Text('${formatNum(conv)} ${app.basketTarget}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: t.textDark), overflow: TextOverflow.ellipsis)))),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: t.bgOuter, borderRadius: BorderRadius.circular(8), border: Border.all(color: t.primaryDark, width: 2)),
            child: Row(
              children: [
                Text('إجمالي السلة:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.textDark)),
                const Spacer(),
                Text('${formatNum(app.basketTotalConverted())} ${app.basketTarget}', textDirection: TextDirection.ltr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.textDark)),
              ],
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: _numpad(app)),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _numpad(AppState app) {
    const rows = [['7', '8', '9', 'C'], ['4', '5', '6', '×'], ['1', '2', '3', '÷'], ['0', '00', '.', '+'], ['⌫', '=', '-', '(']];
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: row.map((ch) {
              VoidCallback action;
              if (ch == 'C') {
                action = () {
                  if (_activeCode != null) app.setBasketValue(_activeCode!, '0');
                };
              } else if (ch == '⌫') {
                action = () => _append('⌫');
              } else if (['×', '÷', '+', '-', '='].contains(ch)) {
                action = () {};
              } else {
                action = () => _append(ch);
              }
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: action,
                      style: ElevatedButton.styleFrom(backgroundColor: ['=', '+'].contains(ch) ? app.theme.gold : app.theme.cream, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: Text(ch, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: app.theme.textDark)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
