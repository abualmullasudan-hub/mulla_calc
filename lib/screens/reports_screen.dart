import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/app_state.dart';
import '../models/currency.dart';
import '../utils/format.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Future<void> _generatePdf(BuildContext ctx, String type) async {
    final app = ctx.read<AppState>();
    final font = await PdfGoogleFonts.amiriRegular();
    final fontBold = await PdfGoogleFonts.amiriBold();

    final doc = pw.Document();
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    final titles = {
      'simple': 'تقرير الحاسبة العلمية',
      'currency': 'تقرير حاسبة العملات',
      'factor': 'تقرير معامل البدل',
      'basket': 'تقرير سلة العملات',
    };

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (ctxPdf) => [
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 10),
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 2, color: PdfColors.green900))),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('بسم الله الرحمن الرحيم', style: const pw.TextStyle(fontSize: 14, color: PdfColors.green900)),
                pw.SizedBox(height: 6),
                pw.Text(titles[type] ?? 'تقرير', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                pw.SizedBox(height: 4),
                pw.Text('التاريخ: $dateStr', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          ..._buildContent(app, type),
          pw.SizedBox(height: 20),
          pw.Divider(color: PdfColors.grey400),
          pw.Center(child: pw.Text('تصميم وتطوير ${app.devName} - هاتف: ${app.devPhone}', style: pw.TextStyle(fontSize: 10, color: PdfColors.green900, fontWeight: pw.FontWeight.bold))),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  List<pw.Widget> _buildContent(AppState app, String type) {
    if (type == 'basket') {
      final rows = <List<String>>[];
      int idx = 0;
      app.basketValues.forEach((code, v) {
        final num = double.tryParse(v) ?? 0;
        if (num <= 0) return;
        idx++;
        final rate = app.rates.ratesToSDG[code] ?? 1;
        final targetRate = app.rates.ratesToSDG[app.basketTarget] ?? 1;
        final conv = targetRate != 0 ? (num * rate) / targetRate : 0;
        rows.add(['$idx', '${kCurrencyLabels[code]} ($code)', formatNum(num), '${formatNum(conv)} ${app.basketTarget}']);
      });
      if (rows.isEmpty) return [pw.Center(child: pw.Text('السلة فارغة', style: const pw.TextStyle(fontSize: 12)))];
      final total = app.basketTotalConverted();
      return [
        pw.TableHelper.fromTextArray(headers: ['م', 'العملة', 'المبلغ', 'المقابل'], data: rows, headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white), headerDecoration: const pw.BoxDecoration(color: PdfColors.green900), cellStyle: const pw.TextStyle(fontSize: 10), cellAlignment: pw.Alignment.center),
        pw.SizedBox(height: 10),
        pw.Container(padding: const pw.EdgeInsets.all(8), decoration: pw.BoxDecoration(color: PdfColors.grey300, border: pw.Border.all(color: PdfColors.green900, width: 2)), child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('الإجمالي:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)), pw.Text('${formatNum(total)} ${app.basketTarget}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13))])),
      ];
    } else if (type == 'factor') {
      final amt = double.tryParse(app.factorAmount) ?? 0;
      final f = double.tryParse(app.factorRate) ?? 0;
      final result = amt * f;
      return [
        pw.TableHelper.fromTextArray(headers: ['البيان', 'القيمة'], data: [['من عملة', '${kCurrencyLabels[app.factorFrom]} (${app.factorFrom})'], ['إلى عملة', '${kCurrencyLabels[app.factorTo]} (${app.factorTo})'], ['المبلغ', formatNum(amt)], ['المعامل', f.toString()], ['النتيجة', '${formatNum(result)} ${app.factorTo}']], headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white), headerDecoration: const pw.BoxDecoration(color: PdfColors.green900), cellStyle: const pw.TextStyle(fontSize: 11), cellAlignment: pw.Alignment.center),
      ];
    } else if (type == 'simple') {
      final items = app.logs.take(30).toList();
      if (items.isEmpty) return [pw.Center(child: pw.Text('لا توجد عمليات مسجلة', style: const pw.TextStyle(fontSize: 12)))];
      return [
        pw.TableHelper.fromTextArray(headers: ['م', 'العملية'], data: List.generate(items.length, (i) => ['${i + 1}', '${items[i]['text']}']), headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white), headerDecoration: const pw.BoxDecoration(color: PdfColors.green900), cellStyle: const pw.TextStyle(fontSize: 11), cellAlignment: pw.Alignment.center),
      ];
    }
    return [pw.Center(child: pw.Text('لا توجد بيانات لهذا التقرير', style: const pw.TextStyle(fontSize: 12)))];
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = app.theme;
    final items = [
      ('simple', '📄 تقرير الحاسبة العلمية'),
      ('currency', '💱 تقرير حاسبة العملات'),
      ('factor', '🔁 تقرير معامل البدل'),
      ('basket', '🧺 تقرير سلة العملات'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: items.map((it) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await _generatePdf(context, it.$1);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر إنشاء PDF: $e')));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: t.cream,
                  side: BorderSide(color: t.gold, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.centerRight,
                ),
                child: Row(
                  children: [
                    Text(it.$2, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: t.textDark)),
                    const Spacer(),
                    Icon(Icons.arrow_back_ios, color: t.gold, size: 16),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
