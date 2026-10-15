import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/format.dart';

Future<void> showStartupModal(BuildContext context) async {
  final app = Provider.of<AppState>(context, listen: false);
  String base = app.startupBaseCurrency;
  final ctrl = TextEditingController(
    text: app.ratesToSDG[base]?.toStringAsFixed(0) ?? '',
  );

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Dialog(
        backgroundColor: const Color(0xFFFDFBF7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFC5A059), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Mulla Calc',
                style: TextStyle(
                  color: Color(0xFFC5A059),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'تحديث سعر اليوم',
                style: TextStyle(
                  color: Color(0xFF0B4D2C),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'عملة الأساس لسعر اليوم:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B4D2C),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EBD0),
                  border: Border.all(color: const Color(0xFFC5A059), width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: base,
                    isExpanded: true,
                    dropdownColor: const Color(0xFFF4EBD0),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    items: const [
                      DropdownMenuItem(value: 'AED', child: Text('🇦🇪 درهم إماراتي (AED)')),
                      DropdownMenuItem(value: 'SAR', child: Text('🇸🇦 ريال سعودي (SAR)')),
                      DropdownMenuItem(value: 'USD', child: Text('🇺🇸 دولار أمريكي (USD)')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          base = v;
                          ctrl.text = app.ratesToSDG[v]?.toStringAsFixed(0) ?? '';
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'اليوم ${currencyLabels[base]} بي كم ؟ ${currencyFlags[base]}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B4D2C),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF4EBD0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFC5A059), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFC5A059), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4D2C),
                    foregroundColor: const Color(0xFFFDFBF7),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: const BorderSide(color: Color(0xFFC5A059), width: 1.5),
                    ),
                  ),
                  onPressed: () async {
                    final v = double.tryParse(ctrl.text);
                    if (v != null && v > 0) {
                      await app.saveStartupRate(base, v);
                      if (ctx.mounted) Navigator.pop(ctx);
                    }
                  },
                  child: const Text(
                    'الحفظ و الاعتماد',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xFFC5A059)),
              const Text(
                'Abu Almulla',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B4D2C),
                ),
              ),
              const Text(
                '0922008009',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
