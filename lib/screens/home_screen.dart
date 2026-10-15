import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/app_state.dart';
import '../utils/format.dart';
import '../widgets/calc_keypad.dart';
import '../widgets/live_ticker.dart';
import 'new_transaction_screen.dart';
import 'customers_screen.dart';
import 'transactions_screen.dart';
import 'currencies_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'rates_editor_screen.dart';

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
    double converted = 0;
    try {
      final val = _safeEval(_amount);
      final cFrom = app.currencies[_from];
      final cTo = app.currencies[_to];
      if (cFrom != null && cTo != null) {
        converted = val * cFrom.buyRate / cTo.buyRate;
      }
    } catch (_) {}

    return Scaffold(
      backgroundColor: const Color(0xFF0B4D2C),
      appBar: AppBar(
        title: const Text('Mulla Exchange'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'محرر الأسعار',
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RatesEditorScreen())).then((_) => setState((){})),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              const LiveTicker(),
              const SizedBox(height: 4),
              _buildStatsRow(app),
              const SizedBox(height: 4),
              Expanded(child: _buildQuickCalc(app, converted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0B4D2C),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF052616)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.currency_exchange, color: Color(0xFFC5A059), size: 40),
                SizedBox(height: 8),
                Text('Mulla Exchange',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text('نظام إدارة الصرافة',
                  style: TextStyle(color: Color(0xFFC5A059), fontSize: 13)),
              ],
            ),
          ),
          _drawerItem(context, Icons.add_circle, 'عملية جديدة',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewTransactionScreen())).then((_) => setState((){}))),
          _drawerItem(context, Icons.list_alt, 'سجل العمليات',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen()))),
          _drawerItem(context, Icons.people, 'العملاء',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersScreen()))),
          _drawerItem(context, Icons.tune, 'محرر الأسعار والمعادلات',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RatesEditorScreen())).then((_) => setState((){}))),
          _drawerItem(context, Icons.attach_money, 'العملات',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrenciesScreen())).then((_) => setState((){}))),
          _drawerItem(context, Icons.bar_chart, 'التقارير',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()))),
          const Divider(color: Color(0xFFC5A059)),
          _drawerItem(context, Icons.settings, 'الإعدادات',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext ctx, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFC5A059)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      onTap: () {
        Navigator.pop(ctx);
        onTap();
      },
    );
  }

  Widget _buildStatsRow(AppState app) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC5A059), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ملخص اليوم', style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0B4D2C))),
              Text(DateTime.now().toString().substring(0, 10),
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _statCard('مشتريات', formatNumber(app.todayBuySDG), const Color(0xFF0B4D2C)),
              const SizedBox(width: 4),
              _statCard('مبيعات', formatNumber(app.todaySellSDG), const Color(0xFFC0392B)),
              const SizedBox(width: 4),
              _statCard('ربح', formatNumber(app.todayProfit), const Color(0xFF27AE60)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.4), width: 1),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCalc(AppState app, double converted) {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _currencySelector('من', _from, (v) => setState(() => _from = v))),
          const SizedBox(width: 4),
          Expanded(child: _currencySelector('إلى', _to, (v) => setState(() => _to = v))),
        ]),
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
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0B4D2C)),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFC5A059), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('الناتج:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(formatNumber(converted),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0B4D2C))),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(child: CalcKeypad(onKeyTap: _handleKey)),
      ],
    );
  }

  Widget _currencySelector(String label, String value, Function(String) onChange) {
    final app = Provider.of<AppState>(context);
    final list = app.activeCurrencies.isNotEmpty ? app.activeCurrencies : app.currencies.values.toList();
    if (!list.any((c) => c.code == value) && list.isNotEmpty) {
      value = list.first.code;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC5A059), width: 2),
      ),
      child: Row(children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(width: 4),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              isDense: true,
              items: list.map((e) => DropdownMenuItem(
                value: e.code,
                child: Text('${e.flag} ${e.code}', style: const TextStyle(fontSize: 12)),
              )).toList(),
              onChanged: (v) { if (v != null) onChange(v); },
            ),
          ),
        ),
      ]),
    );
  }

  // ================= الحاسبة الكاملة =================
  void _handleKey(String k) {
    setState(() {
      if (k == 'C') {
        _amount = '0';
      } else if (k == '⌫') {
        _amount = _amount.length > 1 ? _amount.substring(0, _amount.length - 1) : '0';
      } else if (k == '=') {
        try {
          _amount = _formatResult(_safeEval(_amount));
        } catch (_) {
          _amount = 'خطأ';
        }
      } else if (k == '+/-') {
        final idx = _lastOpIndex();
        if (idx == -1) {
          _amount = _amount.startsWith('-') ? _amount.substring(1) : '-$_amount';
        } else {
          final prefix = _amount.substring(0, idx + 1);
          final last = _amount.substring(idx + 1);
          _amount = last.startsWith('-') ? prefix + last.substring(1) : prefix + '-' + last;
        }
      } else if (k == '%') {
        try { _amount = _formatResult(_safeEval(_amount) / 100); } catch (_) {}
      } else if (k == '√') {
        try {
          final v = _safeEval(_amount);
          _amount = v >= 0 ? _formatResult(math.sqrt(v)) : 'خطأ';
        } catch (_) {}
      } else if (k == '1/x') {
        try {
          final v = _safeEval(_amount);
          _amount = v != 0 ? _formatResult(1 / v) : 'خطأ';
        } catch (_) {}
      } else if (['+', '-', '×', '÷'].contains(k)) {
        if (_amount == '0' && k == '-') {
          _amount = '-';
        } else if (['+', '-', '×', '÷'].contains(_amount[_amount.length - 1])) {
          _amount = _amount.substring(0, _amount.length - 1) + k;
        } else {
          _amount += k;
        }
      } else if (k == '.') {
        final idx = _lastOpIndex();
        final lastNum = idx == -1 ? _amount : _amount.substring(idx + 1);
        if (!lastNum.contains('.')) _amount += '.';
      } else {
        if (_amount == '0') _amount = k;
        else _amount += k;
      }
    });
  }

  int _lastOpIndex() {
    for (int i = _amount.length - 1; i >= 0; i--) {
      if (['+', '-', '×', '÷'].contains(_amount[i])) {
        if (_amount[i] == '-' && (i == 0 || ['+', '-', '×', '÷'].contains(_amount[i - 1]))) continue;
        return i;
      }
    }
    return -1;
  }

  String _formatResult(double v) {
    if (v.isNaN || v.isInfinite) return 'خطأ';
    if (v == v.roundToDouble() && v.abs() < 1e15) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  double _safeEval(String e) {
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
          if (d == 0 && i < e.length - 1) { ok = false; break; }
        }
      }
      if (ok) e = e.substring(1, e.length - 1).trim();
      else break;
    }
    int d = 0;
    for (int i = e.length - 1; i >= 0; i--) {
      final c = e[i];
      if (c == ')') d++;
      if (c == '(') d--;
      if (d == 0) {
        if (c == '+') return _parse(e.substring(0, i)) + _parse(e.substring(i + 1));
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
        if (c == '*') return _parse(e.substring(0, i)) * _parse(e.substring(i + 1));
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
