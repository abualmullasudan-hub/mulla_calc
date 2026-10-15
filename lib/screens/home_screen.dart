import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/calc_keypad.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _from = 'AED';
  String _to = 'SDG';
  String _amount = '100';

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    double result = 0;
    try {
      result = app.convert(double.parse(_amount), _from, _to);
    } catch (_) {}

    return Scaffold(
      backgroundColor: const Color(0xFF0B4D2C),
      appBar: AppBar(title: const Text('Mulla Calc')),
      body: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            _currencyBox('معروض:', _from, (v) => setState(() => _from = v!)),
            const SizedBox(height: 4),
            _amountBox(),
            const SizedBox(height: 4),
            _currencyBox('مطلوب:', _to, (v) => setState(() => _to = v!)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC5A059), width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المقابل:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(result.toStringAsFixed(0),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Text('${app.currencies[_to]?.flag} $_to',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: CalcKeypad(onKeyTap: _handleKey)),
          ],
        ),
      ),
    );
  }

  Widget _currencyBox(String label, String value, Function(String?) onChange) {
    final app = Provider.of<AppState>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC5A059), width: 2),
      ),
      child: Row(children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: app.currencies.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text('${e.value.flag} ${e.value.name}'),
                      ))
                  .toList(),
              onChanged: onChange,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _amountBox() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE5DAC2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC5A059), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('الكمية:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(_amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        ],
      ),
    );
  }

  void _handleKey(String k) {
    setState(() {
      if (k == 'C') {
        _amount = '0';
      } else if (k == '⌫') {
        _amount = _amount.length > 1 ? _amount.substring(0, _amount.length - 1) : '0';
      } else if (k == '=') {
        try {
          _amount = _evaluate(_amount).toStringAsFixed(0);
        } catch (_) {}
      } else {
        _amount = (_amount == '0' && k != '.') ? k : _amount + k;
      }
    });
  }

  double _evaluate(String s) {
    s = s.replaceAll('×', '*').replaceAll('÷', '/');
    return _parseExpr(s);
  }

  double _parseExpr(String s) {
    double result = 0;
    String num = '';
    String op = '+';
    for (int i = 0; i < s.length; i++) {
      final c = s[i];
      if ('0123456789.'.contains(c)) {
        num += c;
      } else {
        final n = double.tryParse(num) ?? 0;
        if (op == '+') result += n;
        else if (op == '-') result -= n;
        else if (op == '*') result *= n;
        else if (op == '/') result = n != 0 ? result / n : result;
        op = c;
        num = '';
      }
    }
    final n = double.tryParse(num) ?? 0;
    if (op == '+') result += n;
    else if (op == '-') result -= n;
    else if (op == '*') result *= n;
    else if (op == '/') result = n != 0 ? result / n : result;
    return result;
  }
}
