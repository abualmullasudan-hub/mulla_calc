import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/format.dart';

Future<void> showPreviewModal(BuildContext context) async {
  final app = Provider.of<AppState>(context, listen: false);
  final from = app.startupBaseCurrency;
  final to = 'SDG';
  final words = numberToWords(app.ratesToSDG[from] ?? 0, from);

  await showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: const Color(0xFFFDFBF7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFC5A059), width: 2),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 620),
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('معاينة دفتر الأستاذ',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B4D2C))),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFC0392B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text('✕ إغلاق',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Divider(color: Color(0xFF0B4D2C)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EBD0),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text('دفتر الأستاذ المالي',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B4D2C))),
                    ),
                    const SizedBox(height: 6),
                    Text('العملة الأساسية: $from',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('سعر ${currencyLabels[from]}: ${formatNumber(app.ratesToSDG[from] ?? 0)} SDG',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('سعر الدولار: ${formatNumber(app.ratesToSDG['USD'] ?? 0)} SDG',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('القيمة كتابةً: $words',
                        style: const TextStyle(fontSize: 12, color: Colors.black87)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFBF7),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFC5A059), width: 1),
                      ),
                      child: Column(
                        children: [
                          _row('DR', 'CR', 'البيان'),
                          _row(formatNumber(app.ratesToSDG[from] ?? 0), '-',
                              'رصيد افتتاحي (${currencyFlags[from]} $from)'),
                          _row('-', formatNumber(app.ratesToSDG['USD'] ?? 0),
                              'تحويل إلى دولار'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4D2C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    final buf = StringBuffer();
                    buf.writeln('Mulla Ledger');
                    buf.writeln('---');
                    buf.writeln('العملة الأساسية: $from');
                    buf.writeln('سعر ${currencyLabels[from]}: ${formatNumber(app.ratesToSDG[from] ?? 0)} SDG');
                    buf.writeln('سعر الدولار: ${formatNumber(app.ratesToSDG['USD'] ?? 0)} SDG');
                    buf.writeln('---');
                    buf.writeln('القيمة كتابةً: $words');
                    showDialog(
                      context: ctx,
                      builder: (c) => AlertDialog(
                        content: SingleChildScrollView(child: Text(buf.toString())),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c),
                            child: const Text('إغلاق'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text('طباعة / حفظ',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'تصميم وتطوير Abu Almulla - 0922008009',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _row(String dr, String cr, String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0B4D2C))),
        ),
        Expanded(
          child: Text(dr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF0B4D2C))),
        ),
        Expanded(
          child: Text(cr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFFC0392B))),
        ),
      ],
    ),
  );
}
