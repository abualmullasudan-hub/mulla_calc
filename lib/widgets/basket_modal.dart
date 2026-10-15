import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/format.dart';

Future<void> showBasketModal(BuildContext context) async {
  final app = Provider.of<AppState>(context, listen: false);
  String target = 'SDG';
  final values = <String, String>{};
  for (var c in app.activeCurrencies) {
    values[c] = '0';
  }
  String? activeField = app.activeCurrencies.contains('AED')
      ? 'AED'
      : (app.activeCurrencies.isNotEmpty ? app.activeCurrencies.first : null);

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        double total = 0;
        for (var c in values.keys) {
          final v = double.tryParse(values[c] ?? '0') ?? 0;
          total += app.convert(v, c, target);
        }

        return Dialog(
          backgroundColor: const Color(0xFFFDFBF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFC5A059), width: 2),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 620),
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('🧮 سلة العملات',
                          style: TextStyle(
                              color: Color(0xFF0B4D2C),
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFC0392B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: const Size(0, 0),
                        ),
                        child: const Text('✕ إغلاق', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF0B4D2C)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('العملة المراد تجميع الإجمالي بها:',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0B4D2C))),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4EBD0),
                      border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: target,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        items: currencyLabels.keys
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                      '${currencyFlags[c]} ${currencyLabels[c]} ($c)'),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => target = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // الرأس
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    color: const Color(0xFFF4EBD0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('العملة والمبلغ',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B4D2C))),
                        Text('المقابل',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B4D2C))),
                      ],
                    ),
                  ),

                  // الصفوف
                  Container(
                    constraints: const BoxConstraints(maxHeight: 160),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4EBD0),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: values.keys.map((c) {
                          final active = activeField == c;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${currencyFlags[c]} ${currencyLabels[c]} ($c)',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0B4D2C)),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      activeField = c;
                                    });
                                  },
                                  child: Container(
                                    width: 80,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? const Color(0xFFF4EBD0)
                                          : const Color(0xFFFDFBF7),
                                      border: Border.all(
                                        color: active
                                            ? const Color(0xFF0B4D2C)
                                            : const Color(0xFFC5A059),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      values[c] ?? '0',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0B4D2C)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4EBD0),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: const Color(0xFFC5A059),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '${formatNumber(app.convert(double.tryParse(values[c] ?? '0') ?? 0, c, target))} $target',
                                      textAlign: TextAlign.left,
                                      textDirection: TextDirection.ltr,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0B4D2C)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5DAC2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF0B4D2C), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        const Text('إجمالي سلة العملات النهائي:',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B4D2C))),
                        Text(
                          '${formatNumber(total)} ${currencyFlags[target]} $target',
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B4D2C)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),
                  _miniPad(
                    onKey: (k) {
                      if (activeField == null) return;
                      final v = values[activeField!] ?? '0';
                      setState(() {
                        if (k == 'C') {
                          values[activeField!] = '0';
                        } else if (k == '⌫') {
                          values[activeField!] =
                              v.length > 1 ? v.substring(0, v.length - 1) : '0';
                        } else if (k == '.') {
                          if (!v.contains('.')) values[activeField!] = '$v.';
                        } else if (k == '✓') {
                          // لا شيء
                        } else {
                          if (v == '0') {
                            values[activeField!] = k;
                          } else {
                            values[activeField!] = '$v$k';
                          }
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B4D2C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () {
                            // طباعة بسيطة عبر share نصي
                            final buf = StringBuffer();
                            buf.writeln('سلة العملات');
                            buf.writeln('---');
                            values.forEach((c, v) {
                              if ((double.tryParse(v) ?? 0) > 0) {
                                buf.writeln(
                                    '$c: $v = ${formatNumber(app.convert(double.tryParse(v)!, c, target))} $target');
                              }
                            });
                            buf.writeln('---');
                            buf.writeln('الإجمالي: ${formatNumber(total)} $target');
                            showDialog(
                              context: ctx,
                              builder: (c) => AlertDialog(
                                content: Text(buf.toString()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(c),
                                    child: const Text('إغلاق'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.print, size: 16),
                          label: const Text('طباعة التقرير',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC0392B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () {
                            setState(() {
                              for (var k in values.keys) {
                                values[k] = '0';
                              }
                            });
                          },
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('تفريغ',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

Widget _miniPad({required Function(String) onKey}) {
  const keys = [
    ['7', '8', '9', '⌫'],
    ['4', '5', '6', 'C'],
    ['1', '2', '3', '00'],
    ['0', '.', '✓', ''], // 0 مدموج مع span
  ];
  return Column(
    children: [
      Row(
        children: ['7', '8', '9', '⌫']
            .map((k) => Expanded(child: _miniBtn(k, onKey)))
            .toList(),
      ),
      const SizedBox(height: 3),
      Row(
        children: ['4', '5', '6', 'C']
            .map((k) => Expanded(child: _miniBtn(k, onKey)))
            .toList(),
      ),
      const SizedBox(height: 3),
      Row(
        children: ['1', '2', '3', '00']
            .map((k) => Expanded(child: _miniBtn(k, onKey)))
            .toList(),
      ),
      const SizedBox(height: 3),
      Row(
        children: [
          Expanded(
            flex: 2,
            child: _miniBtn('0', onKey),
          ),
          Expanded(child: _miniBtn('.', onKey)),
          Expanded(child: _miniBtn('✓', onKey)),
        ],
      ),
    ],
  );
}

Widget _miniBtn(String k, Function(String) onKey) {
  final isAction = ['⌫', 'C', '✓'].contains(k);
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 1.5),
    child: GestureDetector(
      onTap: () => onKey(k),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: isAction ? const Color(0xFF0B4D2C) : const Color(0xFFFDFBF7),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          k,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isAction ? const Color(0xFFFDFBF7) : const Color(0xFF0B4D2C),
          ),
        ),
      ),
    ),
  );
}
