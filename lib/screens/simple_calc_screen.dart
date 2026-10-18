import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/calc_button.dart';

class SimpleCalcScreen extends StatefulWidget {
  const SimpleCalcScreen({super.key});
  @override
  State<SimpleCalcScreen> createState() => _SimpleCalcScreenState();
}

class _SimpleCalcScreenState extends State<SimpleCalcScreen> {
  String _expr = '0';
  bool _newInput = true;

  void _append(String ch) {
    const ops = ['+', '-', '*', '/', '×', '÷'];
    setState(() {
      if (_newInput) {
        if (ops.contains(ch)) _expr = '$_expr$ch';
        else _expr = ch;
        _newInput = false;
      } else {
        if (_expr == '0' && !ops.contains(ch) && ch != '.') _expr = ch;
        else _expr += ch;
      }
    });
  }

  void _clear() => setState(() { _expr = '0'; _newInput = true; });
  
  void _back() {
    setState(() {
      _expr = _expr.length > 1 ? _expr.substring(0, _expr.length - 1) : '0';
      _newInput = false;
    });
  }

  void _equal() {
    try {
      final clean = _expr.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('π', '3.141592653589793').replaceAll('e', '2.718281828459045').replaceAll('^', '**');
      final r = _Parser(clean).parse();
      context.read<AppState>().addLog('$_expr = $r');
      setState(() {
        _expr = r.toStringAsFixed(r == r.roundToDouble() ? 0 : 6);
        _newInput = true;
      });
    } catch (_) {
      setState(() { _expr = 'خطأ'; _newInput = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().theme;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          width: double.infinity,
          decoration: BoxDecoration(
            color: t.bgOuter,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: t.gold, width: 2),
          ),
          child: Text(_expr, textAlign: TextAlign.left, textDirection: TextDirection.ltr, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: t.textDark)),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Expanded(child: _row([_b('7', () => _append('7')), _b('8', () => _append('8')), _b('9', () => _append('9')), _b('C', _clear, type: CalcBtnType.clear)])),
                Expanded(child: _row([_b('4', () => _append('4')), _b('5', () => _append('5')), _b('6', () => _append('6')), _b('×', () => _append('×'), type: CalcBtnType.action)])),
                Expanded(child: _row([_b('1', () => _append('1')), _b('2', () => _append('2')), _b('3', () => _append('3')), _b('÷', () => _append('÷'), type: CalcBtnType.action)])),
                Expanded(child: _row([_b('0', () => _append('0')), _b('00', () => _append('00')), _b('.', () => _append('.')), _b('+', () => _append('+'), type: CalcBtnType.action)])),
                Expanded(child: _row([_b('⌫', _back, type: CalcBtnType.delete), _b('=', _equal, type: CalcBtnType.equal), _b('-', () => _append('-'), type: CalcBtnType.action), _b('(', () => _append('('))])),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _row(List<Widget> children) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: children.map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: w))).toList()),
  );

  Widget _b(String label, VoidCallback onTap, {CalcBtnType type = CalcBtnType.normal}) => CalcButton(label: label, onTap: onTap, type: type);
}

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
