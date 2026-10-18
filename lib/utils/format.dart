import 'package:intl/intl.dart';
import '../models/currency.dart';

// دالة تنسيق الأرقام بوضع الفواصل
String formatNum(num value) {
  if (value.isNaN || value.isInfinite) return '0';
  final fmt = NumberFormat('#,##0', 'en_US');
  return fmt.format(value.floor());
}

// دالة تحويل الأرقام إلى كلمات عربية
String numberToWords(num n, String currencyCode) {
  if (n.isNaN || n == 0) return 'صفر';
  final label = kCurrencyLabels[currencyCode] ?? currencyCode;
  final intPart = n.floor();
  if (intPart == 0) return 'صفر';

  final trillions = intPart ~/ 1000000000000;
  final rem1 = intPart % 1000000000000;
  final billions = rem1 ~/ 1000000000;
  final rem2 = rem1 % 1000000000;
  final millions = rem2 ~/ 1000000;
  final rem3 = rem2 % 1000000;
  final thousands = rem3 ~/ 1000;
  final units = rem3 % 1000;

  final parts = <String>[];
  if (trillions > 0) parts.add('$trillions ترليون');
  if (billions > 0) parts.add('$billions مليار');
  if (millions > 0) parts.add('$millions مليون');
  if (thousands > 0) parts.add('$thousands ألف');
  if (units > 0) parts.add('$units');
  if (parts.isEmpty) return 'صفر $label';
  return '${parts.join(' و ')} $label';
}
