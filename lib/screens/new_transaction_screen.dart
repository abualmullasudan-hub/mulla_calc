import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/format.dart';
import '../utils/pdf_helper.dart';
import '../widgets/calc_keypad.dart';

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({super.key});
  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  String _type = 'buy';
  String? _customerId;
  String _currencyCode = 'AED';
  String _amount = '0';
  String _note = '';

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final currency = app.currencies[_currencyCode];
    final rate = _type == 'buy' ? (currency?.buyRate ?? 0) : (currency?.sellRate ?? 0);
    double total = 0;
    try { total = (double.parse(_amount)) * rate; } catch (_) {}

    return Scaffold(
      backgroundColor: const Color(0xFF0B4D2C),
      appBar: AppBar(title: const Text('عملية جديدة')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // نوع العملية
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFC5A059), width: 2),
                ),
                child: Row(
                  children: [
                    Expanded(child: _typeBtn('شراء (من العميل)', 'buy')),
                    const SizedBox(width: 4),
                    Expanded(child: _typeBtn('بيع (للعميل)', 'sell')),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // العميل
              _buildCustomerSelector(app),
              const SizedBox(height: 6),
              // العملة
              _buildCurrencySelector(app),
              const SizedBox(height: 6),
              // المبلغ والسعر
              _buildAmountRow(rate),
              const SizedBox(height: 6),
              _buildTotalRow(total),
              const SizedBox(height: 6),
              _buildNoteField(),
              const SizedBox(height: 6),
              Expanded(child: CalcKeypad(onKeyTap: _handleKey)),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5A059),
                    foregroundColor: const Color(0xFF0B4D2C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: total > 0 ? () => _save(app, rate, total) : null,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('حفظ العملية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeBtn(String text, String val) {
    final active = _type == val;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? const Color(0xFF0B4D2C) : Colors.white,
        foregroundColor: active ? Colors.white : const Color(0xFF0B4D2C),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: Color(0xFFC5A059), width: 1.5),
        ),
      ),
      onPressed: () => setState(() => _type = val),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCustomerSelector(AppState app) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: _boxDeco(),
      child: Row(children: [
        const Icon(Icons.person, color: Color(0xFF0B4D2C), size: 20),
        const SizedBox(width: 6),
        const Text('العميل:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(width: 6),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _customerId,
              isExpanded: true,
              hint: const Text('نقدي'),
              items: [
                const DropdownMenuItem(value: null, child: Text('نقدي (بدون تسجيل)')),
                ...app.customers.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text('${c.name} (${c.balance.toStringAsFixed(0)} SDG)',
                    style: const TextStyle(fontSize: 13)),
                )),
              ],
              onChanged: (v) => setState(() => _customerId = v),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildCurrencySelector(AppState app) {
    final list = app.activeCurrencies;
    if (!list.any((c) => c.code == _currencyCode) && list.isNotEmpty) {
      _currencyCode = list.first.code;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: _boxDeco(),
      child: Row(children: [
        const Icon(Icons.currency_exchange, color: Color(0xFF0B4D2C), size: 20),
        const SizedBox(width: 6),
        const Text('العملة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(width: 6),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currencyCode,
              isExpanded: true,
              items: list.map((c) => DropdownMenuItem(
                value: c.code,
                child: Text('${c.flag} ${c.name} (${c.code})', style: const TextStyle(fontSize: 13)),
              )).toList(),
              onChanged: (v) { if (v != null) setState(() => _currencyCode = v); },
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildAmountRow(double rate) {
    return Row(children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: _boxDeco(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('المبلغ', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text(_amount, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: _boxDeco(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('السعر', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text(formatNumber(rate), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _buildTotalRow(double total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFC5A059),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('الإجمالي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0B4D2C))),
          Text('${formatNumber(total)} SDG',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF0B4D2C))),
        ],
      ),
    );
  }

  Widget _buildNoteField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: _boxDeco(),
      child: TextField(
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'ملاحظة (اختياري)',
          icon: Icon(Icons.note, color: Color(0xFF0B4D2C), size: 20),
        ),
        onChanged: (v) => _note = v,
      ),
    );
  }

  BoxDecoration _boxDeco() => BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC5A059), width: 2),
      );

  void _handleKey(String k) {
    setState(() {
      if (k == 'C') _amount = '0';
      else if (k == '⌫') _amount = _amount.length > 1 ? _amount.substring(0, _amount.length - 1) : '0';
      else if (k == '=' || k == '+' || k == '-' || k == '×' || k == '÷') {}
      else if (k == '+/-') {
        _amount = _amount.startsWith('-') ? _amount.substring(1) : '-$_amount';
      } else if (k == '%') {
        try { _amount = (double.parse(_amount) / 100).toString(); } catch (_) {}
      } else {
        _amount = (_amount == '0' && k != '.') ? k : _amount + k;
      }
    });
  }

  Future<void> _save(AppState app, double rate, double total) async {
    if (total <= 0) return;
    final t = await app.addTransaction(
      type: _type,
      customerId: _customerId ?? '',
      currencyCode: _currencyCode,
      amount: double.tryParse(_amount) ?? 0,
      rate: rate,
      note: _note,
    );
    if (!mounted) return;
    final print = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تم حفظ العملية ✅'),
        content: Text('رقم الفاتورة: ${t.invoiceNo}\nهل تريد الطباعة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('لاحقاً')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('طباعة')),
        ],
      ),
    );
    if (print == true) await PdfHelper.printTransaction(t, app.settings);
    if (mounted) Navigator.pop(context);
  }
}
