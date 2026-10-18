import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/currency.dart';
import '../utils/format.dart';
import '../widgets/calc_button.dart';

class FactorScreen extends StatefulWidget {
  const FactorScreen({super.key});
  @override
  State<FactorScreen> createState() => _FactorScreenState();
}

class _FactorScreenState extends State<FactorScreen> {
  final TextEditingController _rateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    app.factorFrom = app.defFactorFrom;
    app.factorTo = app.defFactorTo;
    app.factorAmount = app.defFactorAmount.toStringAsFixed(0);
    app.factorRate = app.getFactorFor(app.factorFrom, app.factorTo).toStringAsFixed(4);
    app.factorLocked = true;
    _rateController.text = app.factorRate;
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  void _updateRate(String newRate) {
    _rateController.text = newRate;
    _rateController.selection = TextSelection.fromPosition(TextPosition(offset: newRate.length));
  }

  void _append(String ch) {
    final app = context.read<AppState>();
    setState(() {
      if (ch == '⌫') {
        app.factorAmount = app.factorAmount.length > 1 ? app.factorAmount.substring(0, app.factorAmount.length - 1) : '0';
      } else if (ch == 'C') {
        app.factorAmount = '0';
      } else if (app.factorAmount == '0' && ch != '.') {
        app.factorAmount = ch;
      } else {
        app.factorAmount += ch;
      }
    });
  }

  void _swap() {
    final app = context.read<AppState>();
    setState(() {
      final tmp = app.factorFrom;
      app.factorFrom = app.factorTo;
      app.factorTo = tmp;
      app.factorRate = app.getFactorFor(app.factorFrom, app.factorTo).toStringAsFixed(4);
      _updateRate(app.factorRate);
    });
  }

  void _onCurrencyChanged(String v, bool isFrom) {
    final app = context.read<AppState>();
    setState(() {
      if (isFrom) app.factorFrom = v; else app.factorTo = v;
      app.factorRate = app.getFactorFor(app.factorFrom, app.factorTo).toStringAsFixed(4);
      _updateRate(app.factorRate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = app.theme;
    final amount = double.tryParse(app.factorAmount) ?? 0;
    final factor = double.tryParse(app.factorRate) ?? 0;
    final result = amount * factor;
    final isLoss = !app.factorLocked && factor > 0 && factor < (app.defRefFactor - app.defLossLimit);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _currencyBox('من', app.factorFrom, (v) => _onCurrencyChanged(v, true), t, app.activeCurrencies)),
              IconButton(onPressed: _swap, icon: Icon(Icons.swap_horiz, color: t.gold, size: 28)),
              Expanded(child: _currencyBox('إلى', app.factorTo, (v) => _onCurrencyChanged(v, false), t, app.activeCurrencies)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: t.cream, borderRadius: BorderRadius.circular(8), border: Border.all(color: t.gold, width: 2)),
            child: Column(children: [
              Text('المبلغ', style: TextStyle(fontSize: 12, color: t.textDark, fontWeight: FontWeight.bold)),
              Text(app.factorAmount, textDirection: TextDirection.ltr, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: t.textDark)),
            ]),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isLoss ? t.danger.withValues(alpha: 0.2) : t.bgOuter,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isLoss ? t.danger : t.primaryDark, width: 2),
            ),
            child: Row(
              children: [
                Text('معامل البدل', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.textDark)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    readOnly: app.factorLocked,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isLoss ? t.danger : t.textDark),
                    onChanged: (v) => app.factorRate = v,
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                  ),
                ),
                IconButton(
                  icon: Icon(app.factorLocked ? Icons.lock : Icons.lock_open, color: t.gold),
                  onPressed: () async {
                    if (app.factorLocked) {
                      setState(() => app.factorLocked = false);
                    } else {
                      final v = double.tryParse(app.factorRate);
                      if (v != null && v > 0) await app.saveFactor(app.factorFrom, app.factorTo, v);
                      setState(() => app.factorLocked = true);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: t.bgOuter, borderRadius: BorderRadius.circular(8), border: Border.all(color: t.primaryDark, width: 2)),
            child: Column(children: [
              Text('المقابل', style: TextStyle(fontSize: 12, color: t.textDark, fontWeight: FontWeight.bold)),
              Text(isLoss ? '⚠️ خسارة' : formatNum(result), textDirection: TextDirection.ltr, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isLoss ? t.danger : t.textDark)),
              if (!isLoss) Text(numberToWords(result, app.factorTo), style: TextStyle(fontSize: 12, color: t.textDark.withValues(alpha: 0.8))),
            ]),
          ),
          const SizedBox(height: 10),
          _numpad(t, app),
        ],
      ),
    );
  }

  Widget _currencyBox(String label, String value, ValueChanged<String> onChanged, AppTheme t, List<String> active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: t.cream, borderRadius: BorderRadius.circular(8), border: Border.all(color: t.gold, width: 2)),
      child: Column(children: [
        Text(label, style: TextStyle(fontSize: 11, color: t.textDark)),
        DropdownButton<String>(
          value: active.contains(value) ? value : active.first,
          isExpanded: true,
          underline: const SizedBox(),
          items: active.map((c) => DropdownMenuItem(value: c, child: Text('${kCurrencyFlags[c] ?? ''} $c', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: t.textDark)))).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ]),
    );
  }

  Widget _numpad(AppTheme t, AppState app) {
    const rows = [['7', '8', '9', 'C'], ['4', '5', '6', '×'], ['1', '2', '3', '÷'], ['0', '00', '.', '+'], ['⌫', '=', '-', '(']];
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: row.map((ch) {
              CalcBtnType type = CalcBtnType.normal;
              VoidCallback action;
              if (ch == 'C') { type = CalcBtnType.clear; action = () => _append('C'); }
              else if (['×', '÷', '+', '-'].contains(ch)) { type = CalcBtnType.action; action = () {}; }
              else if (ch == '=') { type = CalcBtnType.equal; action = () { final amt = double.tryParse(app.factorAmount) ?? 0; final f = double.tryParse(app.factorRate) ?? 0; app.addLog('${formatNum(amt)} × $f = ${formatNum(amt * f)} ${app.factorTo}'); }; }
              else if (ch == '⌫') { type = CalcBtnType.delete; action = () => _append('⌫'); }
              else { action = () => _append(ch); }
              return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: SizedBox(height: 46, child: CalcButton(label: ch, onTap: action, type: type, fontSize: 18))));
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
