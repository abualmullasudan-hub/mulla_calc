String formatNumber(double n) {
  if (n.isNaN) return '0';
  final s = n.floor().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

String numberToArabicWords(double n, String currencyName) {
  if (n.isNaN || n == 0) return 'صفر';
  int intPart = n.floor();
  if (intPart == 0) return 'صفر';

  int trillions = intPart ~/ 1000000000000;
  int rem = intPart % 1000000000000;
  int billions = rem ~/ 1000000000;
  rem = rem % 1000000000;
  int millions = rem ~/ 1000000;
  rem = rem % 1000000;
  int thousands = rem ~/ 1000;
  int units = rem % 1000;

  List<String> parts = [];
  if (trillions > 0) parts.add('$trillions ترليون');
  if (billions > 0) parts.add('$billions مليار');
  if (millions > 0) parts.add('$millions مليون');
  if (thousands > 0) parts.add('$thousands ألف');
  if (units > 0) parts.add('$units');

  if (parts.isEmpty) return 'صفر $currencyName';
  return '${parts.join(" و ")} $currencyName';
}
