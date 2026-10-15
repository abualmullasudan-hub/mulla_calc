import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/format.dart';
import '../widgets/calc_keypad.dart';
import 'new_transaction_screen.dart';
import 'customers_screen.dart';
import 'transactions_screen.dart';
import 'currencies_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

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
      final val = double.parse(_amount);
      final c = app.currencies[_from];
      if (c != null) result = val * c.buyRate;
    } catch (_) {}

    return Scaffold(
      backgroundColor: const Color(0xFF0B4D2C),
      appBar: AppBar(
        title: const Text('Mulla Exchange'),
        actions: [
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
              _buildStatsRow(app),
              const SizedBox(height: 8),
              Expanded(child: _buildQuickCalc(app, result)),
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
          _drawerItem(context, Icons.attach_money, 'العملات والأسعار',
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
      padding: const EdgeInsets.all(10),
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
                fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0B4D2C))),
              Text(DateTime.now().toString().substring(0, 10),
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _statCard('مشتريات', formatNumber(app.todayBuySDG), 'SDG', const Color(0xFF0B4D2C)),
              const SizedBox(width: 6),
              _statCard('مبيعات', formatNumber(app.todaySellSDG), 'SDG', const Color(0xFFC0392B)),
              const SizedBox(width: 6),
              _statCard('ربح', formatNumber(app.todayProfit), 'SDG', const Color(0xFF27AE60)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, String unit, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.4), width: 1),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            Text(unit, style: TextStyle(fontSize: 9, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCalc(AppState app, double result) {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _currencySelector('من', _from, (v) => setState(() => _from = v))),
          const SizedBox(width: 4),
          Expanded(child: _currencySelector('إلى', _to, (v) => setState(() => _to = v))),
        ]),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFC5A059), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('الناتج:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(formatNumber(result),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF0B4D2C))),
            ],
          ),
        ),
        const SizedBox(height: 6),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC5A059), width: 2),
      ),
      child: Row(children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(width: 6),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: list.map((e) => DropdownMenuItem(
                value: e.code,
                child: Text('${e.flag} ${e.code}', style: const TextStyle(fontSize: 13)),
              )).toList(),
              onChanged: (v) { if (v != null) onChange(v); },
            ),
          ),
        ),
      ]),
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
          final v = _evaluate(_amount);
          _amount = v.toStringAsFixed(0);
        } catch (_) {}
      } else if (k == '+/-') {
        if (_amount.startsWith('-')) {
          _amount = _amount.substring(1);
        } else {
          _amount = '-$_amount';
        }
      } else if (k == '%') {
        try { _amount = (double.parse(_amount) / 100).toString(); } catch (_) {}
      } else {
        _amount = (_amount == '0' && k != '.') ? k : _amount + k;
      }
    });
  }

  double _evaluate(String s) {
    s = s.replaceAll('×', '*').replaceAll('÷', '/');
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
