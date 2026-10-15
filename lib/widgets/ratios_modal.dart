import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/format.dart';

Future<void> showRatiosModal(BuildContext context) async {
  final app = Provider.of<AppState>(context, listen: false);
  String baseRatio = 'USD';
  final ctrls = <String, TextEditingController>{};

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        // تعبئة controllers
        for (var code in currencyLabels.keys) {
          if (!ctrls.containsKey(code)) {
            double v = 0;
            if (code == 'SDG') {
              v = app.ratesToSDG[baseRatio] ?? 0;
            } else if (app.liveMarketRatesUSD[code] != null) {
              v = app.liveMarketRatesUSD[code]!;
            }
            ctrls[code] = TextEditingController(
              text: v == 0 ? '' : v.toStringAsFixed(2),
            );
          }
        }

        return Dialog(
          backgroundColor: const Color(0xFFFDFBF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFC5A059), width: 2),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 640),
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Mulla Calc',
                    style: TextStyle(
                      color: Color(0xFFC5A059),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'إدارة ونسب العملات',
                    style: TextStyle(
                      color: Color(0xFF0B4D2C),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // شريط Ticker (أسعار مقابل الدولار)
                  _buildTicker(app),

                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        app.lastUpdateLabel,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Row(
                        children: [
                          _smallBtn(
                            '➕ إضافة عملة',
                            const Color(0xFF0B4D2C),
                            const Color(0xFFFDFBF7),
                            () async {
                              await _showAddCurrency(ctx, app);
                              setState(() {});
                            },
                          ),
                          const SizedBox(width: 4),
                          _smallBtn(
                            '🔄 تحديث',
                            const Color(0xFFC5A059),
                            const Color(0xFF0B4D2C),
                            () async {
                              await app.fetchLiveMarketRates();
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'اختر العملة الأساسية للنسب:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0B4D2C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: baseRatio,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        items: currencyLabels.keys
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text('${currencyFlags[c]} ${currencyLabels[c]} ($c)'),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              baseRatio = v;
                              for (var code in ctrls.keys) {
                                if (code == 'SDG') {
                                  ctrls[code]!.text =
                                      (app.ratesToSDG[baseRatio] ?? 0).toStringAsFixed(2);
                                } else {
                                  ctrls[code]!.text = (app.liveMarketRatesUSD[code] ?? 0)
                                      .toStringAsFixed(2);
                                }
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                  const Text(
                    'انقر على العملة أدناه لإظهارها أو إخفائها:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),

                  // شريط chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: currencyLabels.keys.map((code) {
                        final active = app.activeInRatios[code] ?? false;
                        return Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: GestureDetector(
                            onTap: () {
                              app.toggleActive(code);
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: active
                                    ? const Color(0xFF0B4D2C)
                                    : const Color(0xFFFDFBF7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFC5A059),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${currencyFlags[code]} $code',
                                    style: TextStyle(
                                      color: active
                                          ? const Color(0xFFFDFBF7)
                                          : const Color(0xFF0B4D2C),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    active ? '✓' : '+',
                                    style: TextStyle(
                                      color: active
                                          ? const Color(0xFFFDFBF7)
                                          : const Color(0xFF0B4D2C),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // قائمة النسب
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4EBD0),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
                    ),
                    child: Column(
                      children: currencyLabels.keys.map((code) {
                        if (code == baseRatio) return const SizedBox.shrink();
                        if (!(app.activeInRatios[code] ?? false)) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${currencyFlags[code]} ${currencyLabels[code]} ($code)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B4D2C),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 110,
                                child: TextField(
                                  controller: ctrls[code],
                                  keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true),
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: Color(0xFFFDFBF7),
                                    border: OutlineInputBorder(),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B4D2C),
                            foregroundColor: const Color(0xFFFDFBF7),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            final newValues = <String, double>{};
                            for (var code in ctrls.keys) {
                              final v = double.tryParse(ctrls[code]!.text);
                              if (v != null && v > 0) {
                                if (code == 'SDG') {
                                  newValues[code] = 1;
                                } else if (code == baseRatio) {
                                  continue;
                                } else {
                                  // نسبة السوق
                                  app.liveMarketRatesUSD[code] = v;
                                }
                              }
                            }
                            // إعادة الحساب عبر المعادلة
                            final baseSDG = app.ratesToSDG[baseRatio] ?? 0;
                            final baseM = app.liveMarketRatesUSD[baseRatio] ?? 1;
                            final usdSDG = baseSDG * baseM;
                            app.ratesToSDG['USD'] = usdSDG;
                            for (var code in app.liveMarketRatesUSD.keys) {
                              if (code == 'SDG') continue;
                              final m = app.liveMarketRatesUSD[code]!;
                              if (m > 0) {
                                app.ratesToSDG[code] = usdSDG / m;
                              }
                            }
                            await app.saveCustomRatios(newValues);
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          child: const Text('حفظ النسب المحددة',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC0392B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('إغلاق',
                              style: TextStyle(fontWeight: FontWeight.bold)),
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

Widget _buildTicker(AppState app) {
  final parts = <String>[];
  for (var code in currencyLabels.keys) {
    if (!(app.activeInRatios[code] ?? false)) continue;
    if (code == 'SDG') continue;
    final m = app.liveMarketRatesUSD[code];
    if (m != null) {
      if (code == 'XAU') {
        parts.add('${currencyFlags[code]} ذهب: ${m.toStringAsFixed(0)}');
      } else if (code == 'XAG') {
        parts.add('${currencyFlags[code]} فضة: ${m.toStringAsFixed(0)}');
      } else if (code == 'OIL') {
        parts.add('${currencyFlags[code]} بترول: ${m.toStringAsFixed(0)}');
      } else {
        parts.add('${currencyFlags[code]} $code: ${m.toStringAsFixed(2)}');
      }
    }
  }
  final line = parts.isEmpty
      ? '💱 لم يتم تحديد عملات'
      : '🌐 أسعار السوق مقابل الدولار | ${parts.join(" | ")}';

  return Container(
    height: 34,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: const Color(0xFF052616),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
    ),
    child: Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              '$line   •   $line   •   $line',
              style: const TextStyle(
                color: Color(0xFFC5A059),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (app.isLoading)
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: Color(0xFFC5A059),
            ),
          ),
      ],
    ),
  );
}

Widget _smallBtn(String label, Color bg, Color fg, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

Future<void> _showAddCurrency(BuildContext ctx, AppState app) async {
  final presets = {
    'BHD': 'دينار بحريني',
    'KWD': 'دينار كويتي',
    'OMR': 'ريال عماني',
    'JOD': 'دينار أردني',
    'EGP': 'جنيه مصري',
    'CAD': 'دولار كندي',
    'AUD': 'دولار أسترالي',
    'CHF': 'فرنك سويسري',
    'JPY': 'ين ياباني',
    'INR': 'روبية هندية',
    'SEK': 'كرونة سويدية',
    'NOK': 'كرونة نرويجية',
    'DKK': 'كرونة دانماركية',
    'MYR': 'رينغيت ماليزي',
    'SGD': 'دولار سنغافوري',
  };
  String sel = presets.keys.first;
  bool auto = true;
  final rateCtrl = TextEditingController();

  await showDialog(
    context: ctx,
    builder: (c) => StatefulBuilder(
      builder: (c, setS) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBF7),
        title: const Text('➕ إضافة عملة جديدة',
            style: TextStyle(color: Color(0xFF0B4D2C), fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EBD0),
                  border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: sel,
                    isExpanded: true,
                    items: presets.entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text('${currencyFlags[e.key]} ${e.value} (${e.key})'),
                            ))
                        .toList(),
                    onChanged: (v) => setS(() => sel = v!),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: auto,
                    onChanged: (v) => setS(() => auto = v!),
                    activeColor: const Color(0xFF0B4D2C),
                  ),
                  const Text('جلب تلقائي', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  Radio<bool>(
                    value: false,
                    groupValue: auto,
                    onChanged: (v) => setS(() => auto = v!),
                    activeColor: const Color(0xFF0B4D2C),
                  ),
                  const Text('يدوي', style: TextStyle(fontSize: 12)),
                ],
              ),
              if (!auto)
                TextField(
                  controller: rateCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'سعرها مقابل الدولار',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B4D2C),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              double rate = 1;
              if (auto) {
                rate = app.liveMarketRatesUSD[sel] ?? 1;
              } else {
                rate = double.tryParse(rateCtrl.text) ?? 1;
              }
              await app.addCurrency(sel, rate);
              if (c.mounted) Navigator.pop(c);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    ),
  );
}
