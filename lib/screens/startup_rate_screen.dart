import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'home_screen.dart';

class StartupRateScreen extends StatefulWidget {
  const StartupRateScreen({super.key});
  @override
  State<StartupRateScreen> createState() => _StartupRateScreenState();
}

class _StartupRateScreenState extends State<StartupRateScreen> {
  final _ctrl = TextEditingController();
  String _base = 'AED';

  @override
  void initState() {
    super.initState();
    final app = Provider.of<AppState>(context, listen: false);
    _base = app.baseCurrencyCode;
    _ctrl.text = app.currencies[_base]?.buyRate.toStringAsFixed(0) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0B4D2C),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            color: const Color(0xFFFDFBF7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFC5A059), width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Mulla Exchange', style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFC5A059))),
                  const SizedBox(height: 4),
                  const Text('تحديث سعر اليوم', style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B4D2C))),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _base,
                    decoration: const InputDecoration(
                      labelText: 'عملة الأساس',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFF4EBD0),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'AED', child: Text('🇦🇪 درهم (AED)')),
                      DropdownMenuItem(value: 'SAR', child: Text('🇸🇦 ريال (SAR)')),
                      DropdownMenuItem(value: 'USD', child: Text('🇺🇸 دولار (USD)')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _base = v;
                          _ctrl.text = app.currencies[v]?.buyRate.toStringAsFixed(0) ?? '';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('اليوم ${app.currencies[_base]?.name} بي كم ؟',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ctrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold,
                      color: Color(0xFF0B4D2C)),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF4EBD0),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B4D2C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final r = double.tryParse(_ctrl.text);
                        if (r != null && r > 0) {
                          app.setBaseCurrency(_base);
                          await app.updateBaseRate(r);
                          if (mounted) {
                            Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()));
                          }
                        }
                      },
                      child: const Text('الحفظ و الاعتماد',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFC5A059)),
                  const Text('Abu Almulla',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0B4D2C))),
                  const Text('0922008009',
                    style: TextStyle(fontSize: 13, color: Color(0xFF0B4D2C)),
                    textDirection: TextDirection.ltr),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
