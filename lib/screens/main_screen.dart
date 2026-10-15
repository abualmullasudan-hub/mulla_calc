import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/app_state.dart';
import '../utils/format.dart';
import '../widgets/calc_keypad.dart';
import '../widgets/startup_modal.dart';
import '../widgets/ratios_modal.dart';
import '../widgets/basket_modal.dart';
import '../widgets/preview_modal.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _fromCurrency = 'AED';
  String _toCurrency = 'SDG';
  String _amount = '100';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showStartupModal(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    double result = 0;
    try {
      final v = _evaluate(_amount);
      result = app.convert(v, _fromCurrency, _toCurrency);
    } catch (_) {}

    final activeList = app.activeCurrencies;
    if (activeList.isEmpty) activeList.add('SDG');
    if (!activeList.contains(_fromCurrency)) _fromCurrency = activeList.first;
    if (!activeList.contains(_toCurrency)) _toCurrency = activeList.last;

    return Scaffold(
      backgroundColor: const Color(0xFF0B4D2C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Column(
            children: [
              const Text(
                'Mulla Calc',
                style: TextStyle(
                  color: Color(0xFFFDFBF7),
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 5,
                runSpacing: 5,
                children: [
                  _headerBtn('⚙ السعر', () => showStartupModal(context)),
                  _headerBtn('📊 العملات', () => showRatiosModal(context)),
                  _headerBtn('🧮 سلة العملات', () => showBasketModal(context)),
                  _headerBtn('👁️ معاينة', () => showPreviewModal(context)),
                ],
              ),
              const SizedBox(height: 4),
              _currencyField('معروض:', _fromCurrency, activeList,
                  (v) => setState(() => _fromCurrency = v)),
              const SizedBox(height: 3),
              _amountField(),
              const SizedBox(height: 3),
              _currencyField('مطلوب:', _toCurrency, activeList,
                  (v) => setState(() => _toCurrency = v)),
              const SizedBox(height: 3),
              _resultField(result, _toCurrency),
              const SizedBox(height: 3),
              _wordsField(result, _toCurrency),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5DAC2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFC5A059), width: 2),
                ),
                child: Text(
                  _amount,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    color: Color(0xFF0B4D2C),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(child: CalcKeypad(onKeyTap: _handleKey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF4EBD0),
          border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0B4D2C),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _currencyField(
    String label,
    String value,
    List<String> currencies,
    Function(String) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC5A059), width: 2),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0B4D2C),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                isDense: true,
                dropdownColor: const Color(0xFFFDFBF7),
                items: currencies.map((code) {
                  final flag = currencyFlags[code] ?? '💱';
                  final name = currencyLabels[code] ?? code;
                  return DropdownMenuItem(
                    value: code,
                    child: Text(
                      '$flag $name ($code)',
                      style: const TextStyle(
                        color: Color(0xFF0B4D2C),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (v) => onChanged(v!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC5A059), width: 2),
      ),
      child: Row(
        children: [
          const Text(
            'الكمية:',
            style: TextStyle(
              color: Color(0xFF0B4D2C),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
              ),
              child: Text(
                _amount,
                textAlign: TextAlign.right,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  color: Color(0xFF0B4D2C),
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultField(double result, String toCode) {
    final flag = currencyFlags[toCode] ?? '💱';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC5A059), width: 2),
      ),
      child: Row(
        children: [
          const Text(
            'المقابل:',
            style: TextStyle(
              color: Color(0xFF0B4D2C),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              formatNumber(result),
              textAlign: TextAlign.right,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                color: Color(0xFF0B4D2C),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Text(
            '$flag $toCode',
            style: const TextStyle(
              color: Color(0xFF0B4D2C),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _wordsField(double result, String toCode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC5A059), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'القيمة كتابةً:',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            numberToWords(result, toCode),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0B4D2C),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          _amount = _format(_evaluate(_amount));
        } catch (_) {
          _amount = 'خطأ';
        }
      } else if (k == '+/-') {
        if (_amount.startsWith('-')) {
          _amount = _amount.substring(1);
        } else {
          _amount = '-$_amount';
        }
      } else if (k == '%') {
        try { _amount = _format(_evaluate(_amount) / 100); } catch (_) {}
      } else if (k == '√') {
        try {
          final v = _evaluate(_amount);
          _amount = v >= 0 ? _format(math.sqrt(v)) : 'خطأ';
        } catch (_) {}
      } else if (k == '1/x') {
        try {
          final v = _evaluate(_amount);
          _amount = v != 0 ? _format(1 / v) : 'خطأ';
        } catch (_) {}
      } else if (['+', '-', '×', '÷'].contains(k)) {
        if (_amount == '0' && k == '-') {
          _amount = '-';
        } else if (_amount.isNotEmpty &&
            ['+', '-', '×', '÷'].contains(_amount[_amount.length - 1])) {
          _amount = _amount.substring(0, _amount.length - 1) + k;
        } else {
          _amount += k;
        }
      } else if (k == '.') {
        final idx = _lastOpIdx();
        final last = idx == -1 ? _amount : _amount.substring(idx + 1);
        if (!last.contains('.')) _amount += '.';
      } else {
        if (_amount == '0') {
          _amount = k;
        } else {
          _amount += k;
        }
      }
    });
  }

  int _lastOpIdx() {
    for (int i = _amount.length - 1; i >= 0; i--) {
      if (['+', '-', '×', '÷'].contains(_amount[i])) {
        if (_amount[i] == '-' &&
            (i == 0 || ['+', '-', '×', '÷'].contains(_amount[i - 1]))) {
          continue;
        }
        return i;
      }
    }
    return -1;
  }

  String _format(double v) {
    if (v.isNaN || v.isInfinite) return 'خطأ';
    if (v == v.roundToDouble() && v.abs() < 1e15) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  double _evaluate(String e) {
    try {
      return _parse(e.replaceAll('×', '*').replaceAll('÷', '/'));
    } catch (_) {
      return 0;
    }
  }

  double _parse(String e) {
    e = e.trim();
    if (e.isEmpty) return 0;
    while (e.startsWith('(') && e.endsWith(')')) {
      int d = 0;
      bool ok = true;
      for (int i = 0; i < e.length; i++) {
        if (e[i] == '(') d++;
        if (e[i] == ')') {
          d--;
          if (d == 0 && i < e.length - 1) {
            ok = false;
            break;
          }
        }
      }
      if (ok) {
        e = e.substring(1, e.length - 1).trim();
      } else {
        break;
      }
    }
    int d = 0;
    for (int i = e.length - 1; i >= 0; i--) {
      final c = e[i];
      if (c == ')') d++;
      if (c == '(') d--;
      if (d == 0) {
        if (c == '+') {
          return _parse(e.substring(0, i)) + _parse(e.substring(i + 1));
        }
        if (c == '-' && i > 0 && !'+*-/('.contains(e[i - 1])) {
          return _parse(e.substring(0, i)) - _parse(e.substring(i + 1));
        }
      }
    }
    d = 0;
    for (int i = e.length - 1; i >= 0; i--) {
      final c = e[i];
      if (c == ')') d++;
      if (c == '(') d--;
      if (d == 0) {
        if (c == '*') {
          return _parse(e.substring(0, i)) * _parse(e.substring(i + 1));
        }
        if (c == '/') {
          final div = _parse(e.substring(i + 1));
          if (div == 0) throw Exception('div0');
          return _parse(e.substring(0, i)) / div;
        }
      }
    }
    return double.tryParse(e) ?? 0;
  }
}
