import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/format.dart';

class RatesEditorScreen extends StatefulWidget {
  const RatesEditorScreen({super.key});
  @override
  State<RatesEditorScreen> createState() => _RatesEditorScreenState();
}

class _RatesEditorScreenState extends State<RatesEditorScreen> {
  late TextEditingController _baseRateCtrl;
  final Map<String, TextEditingController> _marketCtrls = {};

  @override
  void initState() {
    super.initState();
    final app = Provider.of<AppState>(context, listen: false);
    _baseRateCtrl = TextEditingController(text: app.baseRateInSDG.toStringAsFixed(0));
    for (var code in app.marketRatesToUSD.keys) {
      _marketCtrls[code] = TextEditingController(
        text: app.marketRatesToUSD[code]!.toString(),
      );
    }
  }

  @override
  void dispose() {
    _baseRateCtrl.dispose();
    for (var c in _marketCtrls.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0B4D2C),
      appBar: AppBar(title: const Text('محرر الأسعار والنسب')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            _buildBaseSection(app),
            const SizedBox(height: 10),
            _buildMarketSection(app),
            const SizedBox(height: 10),
            _buildPreviewSection(app),
          ],
        ),
      ),
    );
  }

  // ================= القسم الأول: العملة الأساسية =================
  Widget _buildBaseSection(AppState app) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _boxDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚙️ العملة الأساسية وسعرها اليومي',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0B4D2C))),
          const SizedBox(height: 2),
          const Text('أدخل سعر العملة الأساسية بالجنيه السوداني',
            style: TextStyle(fontSize: 11, color: Colors.grey)),
          const Divider(),
          // قائمة اختيار العملة الأساسية
          Row(
            children: [
              const Text('العملة:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: app.baseCurrencyCode,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'AED', child: Text('🇦🇪 درهم إماراتي')),
                      DropdownMenuItem(value: 'SAR', child: Text('🇸🇦 ريال سعودي')),
                      DropdownMenuItem(value: 'USD', child: Text('🇺🇸 دولار أمريكي')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        app.setBaseCurrency(v);
                        _baseRateCtrl.text = app.baseRateInSDG.toStringAsFixed(0);
                        setState(() {});
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // حقل السعر
          TextField(
            controller: _baseRateCtrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0B4D2C)),
            decoration: InputDecoration(
              labelText: 'سعر ${app.currencies[app.baseCurrencyCode]?.name} بالجنيه',
              filled: true,
              fillColor: const Color(0xFFF4EBD0),
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) {
              final r = double.tryParse(v);
              if (r != null && r > 0) {
                app.updateBaseRate(r);
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0B4D2C),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('1 USD =', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('${formatNumber(app.usdInSDG)} SDG',
                  style: const TextStyle(color: Color(0xFFC5A059), fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= القسم الثاني: أسعار السوق =================
  Widget _buildMarketSection(AppState app) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _boxDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🌐 أسعار السوق مقابل الدولار (1 USD = ؟)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0B4D2C))),
          const SizedBox(height: 2),
          const Text('عدّل القيم حسب أسعار السوق العالمية',
            style: TextStyle(fontSize: 11, color: Colors.grey)),
          const Divider(),
          ...app.currencies.values.where((c) => c.code != 'SDG').map((c) {
            final ctrl = _marketCtrls[c.code];
            if (ctrl == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Text(c.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 50,
                    child: Text(c.code,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4D2C))),
                  ),
                  const Text('=', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Color(0xFFF4EBD0),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4D2C)),
                      onChanged: (v) {
                        final r = double.tryParse(v);
                        if (r != null && r > 0) {
                          app.updateMarketRate(c.code, r);
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('USD', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ================= القسم الثالث: معاينة مباشرة =================
  Widget _buildPreviewSection(AppState app) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _boxDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📊 الأسعار المستنتجة (مباشر)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0B4D2C))),
          const SizedBox(height: 2),
          const Text('تُحدَّث تلقائياً حسب معادلاتك',
            style: TextStyle(fontSize: 11, color: Colors.grey)),
          const Divider(),
          ...app.currencies.values.where((c) => c.code != 'SDG').map((c) {
            final computed = app.getRateInSDG(c.code);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(c.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('1 ${c.code} = ${formatNumber(computed)} SDG',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4D2C))),
                  ),
                  Switch(
                    value: c.active,
                    activeColor: const Color(0xFF0B4D2C),
                    onChanged: (_) {
                      app.toggleCurrencyActive(c.code);
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  BoxDecoration _boxDeco() => BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC5A059), width: 2),
      );
}
