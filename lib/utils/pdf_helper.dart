import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/transaction.dart';
import '../models/customer.dart';
import '../models/settings.dart';

class PdfHelper {
  static Future<void> printTransaction(Transaction t, AppSettings s) async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a5,
      build: (ctx) => pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Text(s.shopName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 4),
              pw.Center(child: pw.Text('هاتف: ${s.phone}', style: const pw.TextStyle(fontSize: 12))),
              if (s.address.isNotEmpty) pw.Center(child: pw.Text(s.address, style: const pw.TextStyle(fontSize: 11))),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('فاتورة رقم: ${t.invoiceNo}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('التاريخ: ${t.date.toString().substring(0, 16)}', style: const pw.TextStyle(fontSize: 11)),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Text('النوع: ${t.isBuy ? "شراء من العميل" : "بيع للعميل"}',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text('العميل: ${t.customerName}'),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                headers: ['العملة', 'المبلغ', 'سعر الصرف', 'الإجمالي (SDG)'],
                data: [[
                  t.currencyCode,
                  t.amount.toStringAsFixed(0),
                  t.rate.toStringAsFixed(2),
                  t.totalSDG.toStringAsFixed(0),
                ]],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF0B4D2C)),
                cellAlignment: pw.Alignment.center,
                cellStyle: const pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 12),
              if (t.note.isNotEmpty) ...[
                pw.Text('ملاحظة: ${t.note}', style: const pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 8),
              ],
              pw.Spacer(),
              pw.Divider(),
              pw.Center(child: pw.Text('شكراً لتعاملكم معنا',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
              pw.Center(child: pw.Text(s.shopName, style: const pw.TextStyle(fontSize: 10))),
            ],
          ),
        ),
      ),
    ));
    await Printing.layoutPdf(onLayout: (fmt) async => doc.save());
  }

  static Future<void> printCustomerStatement(Customer c, List<Transaction> txns, AppSettings s) async {
    final doc = pw.Document();
    final customerTxns = txns.where((t) => t.customerId == c.id).toList();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => [
        pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Text(s.shopName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold))),
              pw.Center(child: pw.Text('كشف حساب عميل', style: const pw.TextStyle(fontSize: 14))),
              pw.Divider(),
              pw.Text('الاسم: ${c.name}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              if (c.phone.isNotEmpty) pw.Text('الهاتف: ${c.phone}'),
              pw.Text('الرصيد الحالي: ${c.balance.toStringAsFixed(0)} SDG',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold,
                  color: c.balance >= 0 ? PdfColors.green : PdfColors.red)),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                headers: ['التاريخ', 'الفاتورة', 'النوع', 'العملة', 'المبلغ', 'الإجمالي'],
                data: customerTxns.map((t) => [
                  t.date.toString().substring(0, 16),
                  t.invoiceNo,
                  t.isBuy ? 'شراء' : 'بيع',
                  t.currencyCode,
                  t.amount.toStringAsFixed(0),
                  t.totalSDG.toStringAsFixed(0),
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF0B4D2C)),
                cellAlignment: pw.Alignment.center,
                cellStyle: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (fmt) async => doc.save());
  }
}
