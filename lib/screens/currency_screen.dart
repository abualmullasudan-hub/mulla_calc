import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/currency.dart';
import '../utils/format.dart';
import '../widgets/calc_button.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});
  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String _from = 'AED';
  String _to = 'SDG';
  String _amount = '100';

  void _append(String ch) {
    setState(() {
      if (ch == '⌫') {
        _amount = _amount.length > 1 ? _amount.substring(0, _amount.length - 1) : '0';
      } else if (ch == 'C') {
        _amount = '0';
      } else if (_amount == '0' && ch != '.') {
        _amount = ch;
      } else {
        _amount += ch;
      }
    });
  }

  double _numAmount() {
    final clean = _amount.replaceAll('×', '*').replaceAll('÷', '/');
    try {
      return _Parser(clean).parse();
    } catch (_) {
      return 0;
    }
  }

  Future<void> _pickCurrency(bool isFrom) async {
    final app = context.read<AppState>();
    final active = app.activeCurrencies;
    final t = app.theme;
    final sel = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: t.cream,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(10),
          children: active.map((c) {
            return InkWell(
              onTap: () => Navigator.pop(context, c),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(border: Border.all(color: t.gold, width: 2), borderRadius: BorderRadius.circular(8)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(kCurrencyFlags[c] ?? '', style: const TextStyle(fontSize: 24)),
                  Text(c, style: TextStyle(fontWeight: FontWeight.bold, color: t.textDark)),
                  Text(kCurrencyLabels[c] ?? '', style: TextStyle(fontSize: 11, color: t.textDark.withValues(alpha: 0.7))),
                ]),
              ),
            );
          }).toList(),
        ),
      ),
    );
    if (sel != null) setState(() { if (isFrom) _from = sel; else _to = sel; });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = app.theme;
    final result = app.rates.convert(_numAmount(), _from, _to);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // شريط الأسعار الحي (مبسط)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: t.primaryDarker, borderRadius: BorderRadius.circular(8), border: Border.all(color: t.gold.withValues(alpha: 0.6))),
            child: Text(
              app.activeCurrencies.where((c) => c != 'SDG').map((c) => '${kCurrencyFlags[c] ?? ''} $c: ${(app.rates.marketUSD[c] ?? 0).toStringAsFixed(2)}').join('  |  '),
              style: TextStyle(color: t.cream, fontSize: 11, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              Expanded(child: _pickerBox('من:', '${kCurrencyFlags[_from] ?? ''} $_from', () => _pickCurrency(true), t)),
              const SizedBox(width: 6),
              Expanded(child: _pickerBox('إلى:', '${kCurrencyFlags[_to] ?? ''} $_to', () => _pickCurrency(false), t)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: t.cream, borderRadius: BorderRadius.circular(8), border: Border.all(color: t.gold, width: 2)),
            child: Column(children: [
              Text('الكمية', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: t.textDark)),
              const SizedBox(height: 4),
              Text(_amount, textDirection: TextDirection.ltr, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: t.textDark)),
            ]),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: t.bgOuter, borderRadius: BorderRadius.circular(8), border: Border.all(color: t.primaryDark, width: 2)),
            child: Column(children: [
              Text('المقابل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: t.textDark)),
              const SizedBox(height: 4),
              Text('${formatNum(result)} ${kCurrencyFlags[_to] ?? ''} $_to', textDirection: TextDirection.ltr, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: t.textDark)),
              const SizedBox(height: 4),
              Text(numberToWords(result, _to), style: TextStyle(fontSize: 12, color: t.textDark.withValues(alpha: 0.8))),
            ]),
          ),
          const SizedBox(height: 10),
          _buildNumpad(t, app),
        ],
      ),
    );
  }

  Widget _pickerBox(String label, String value, VoidCallback onTap, AppTheme t) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: t.cream, borderRadius: BorderRadius.circular(8), border: Border.all(color: t.gold, width: 2)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 11, color: t.textDark)),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.textDark)),
            Icon(Icons.arrow_drop_down, color: t.gold),
          ]),
        ]),
      ),
    );
  }

  Widget _buildNumpad(AppTheme t, AppState app) {
    final rows = [['7', '8', '9', 'C'], ['4', '5', '6', '×'], ['1', '2', '3', '÷'], ['0', '00', '.', '+'], ['⌫', '=', '-', '(']];
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: row.map((ch) {
              CalcBtnType type = CalcBtnType.normal;
              VoidCallback action;
              if (ch == 'C') { type = CalcBtnType.clear; action = () => _append('C'); }
              else if (['×', '÷', '+', '-'].contains(ch)) { type = CalcBtnType.action; action = () => _append(ch); }
              else if (ch == '=') { type = CalcBtnType.equal; action = () => app.addLog('$_amount $_from = ${formatNum(app.rates.convert(_numAmount(), _from, _to))} $_to'); }
              else if (ch == '⌫') { type = CalcBtnType.delete; action = () => _append('⌫'); }
              else { action = () => _append(ch); }
              return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: SizedBox(height: 48, child: CalcButton(label: ch, onTap: action, type: type))));
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

// محلل بسيط للعمليات الحسابية داخل حقل العملة
class _Parser {
  final String src;
  int pos = 0;
  _Parser(this.src);
  double parse() { final r = _expr(); if (pos < src.length) throw FormatException('Extra chars'); return r; }
  double _expr() { var v = _term(); while (pos < src.length) { final c = src[pos]; if (c == '+') { pos++; v += _term(); } else if (c == '-') { pos++; v -= _term(); } else break; } return v; }
  double _term() { var v = _factor(); while (pos < src.length) { final c = src[pos]; if (c == '*') { pos++; v *= _factor(); } else if (c == '/') { pos++; v /= _factor(); } else break; } return v; }
  double _factor() { var v = _primary(); while (pos < src.length && src[pos] == '^') { pos++; final e = _primary(); v = _pow(v, e); } return v; }
  double _pow(double a, double b) { var r = 1.0; for (var i = 0; i < b.abs().toInt(); i++) r *= a; return r; }
  double _primary() { if (pos >= src.length) throw FormatException('EOF'); final c = src[pos]; if (c == '(') { pos++; final v = _expr(); if (pos >= src.length || src[pos] != ')') throw FormatException(')'); pos++; return v; } if (c == '-') { pos++; return -_primary(); } if (c == '+') { pos++; return _primary(); } final start = pos; while (pos < src.length && (RegExp(r'[0-9.]').hasMatch(src[pos]))) pos++; if (start == pos) throw FormatException('num'); return double.parse(src.substring(start, pos)); }
}
