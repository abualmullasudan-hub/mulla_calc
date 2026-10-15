String formatNumber(num n) {
  if (n.isNaN) return '0';
  final neg = n < 0;
  final s = n.abs().floor().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return (neg ? '-' : '') + buf.toString();
}

String numberToWords(num n, String code) {
  if (n.isNaN || n == 0) return 'صفر';
  final intPart = n.abs().floor();
  if (intPart == 0) return 'صفر';
  final label = currencyLabels[code] ?? code;

  final trillions = intPart ~/ 1000000000000;
  var rem = intPart % 1000000000000;
  final billions = rem ~/ 1000000000;
  rem %= 1000000000;
  final millions = rem ~/ 1000000;
  rem %= 1000000;
  final thousands = rem ~/ 1000;
  final units = rem % 1000;

  final parts = <String>[];
  if (trillions > 0) parts.add('$trillions ترليون');
  if (billions > 0) parts.add('$billions مليار');
  if (millions > 0) parts.add('$millions مليون');
  if (thousands > 0) parts.add('$thousands ألف');
  if (units > 0) parts.add('$units');
  if (parts.isEmpty) return 'صفر $label';
  return '${parts.join(" و ")} $label';
}

const Map<String, String> currencyLabels = {
  'AED': 'درهم إماراتي', 'USD': 'دولار أمريكي', 'SAR': 'ريال سعودي',
  'QAR': 'ريال قطري', 'EUR': 'يورو أوروبي', 'GBP': 'جنيه إسترليني',
  'CNY': 'يوان صيني', 'XAU': 'أوقية ذهب', 'OIL': 'برميل بترول',
  'TRY': 'ليرة تركي', 'LYD': 'دينار ليبي', 'TND': 'دينار تونسي',
  'DZD': 'دينار جزائري', 'MAD': 'درهم مغربي', 'RUB': 'روبل روسي',
  'FRF': 'فرنك فرنسي', 'DEM': 'مارك ألماني', 'XAG': 'أوقية فضة',
  'SDG': 'جنيه سوداني', 'BHD': 'دينار بحريني', 'KWD': 'دينار كويتي',
  'OMR': 'ريال عماني', 'JOD': 'دينار أردني', 'EGP': 'جنيه مصري',
  'CAD': 'دولار كندي', 'AUD': 'دولار أسترالي', 'CHF': 'فرنك سويسري',
  'JPY': 'ين ياباني', 'INR': 'روبية هندية', 'SEK': 'كرونة سويدية',
  'NOK': 'كرونة نرويجية', 'DKK': 'كرونة دانماركية', 'MYR': 'رينغيت ماليزي',
  'SGD': 'دولار سنغافوري',
};

const Map<String, String> currencyFlags = {
  'SDG': '🇸🇩', 'AED': '🇦🇪', 'USD': '🇺🇸', 'SAR': '🇸🇦', 'QAR': '🇶🇦',
  'EUR': '🇪🇺', 'GBP': '🇬🇧', 'TRY': '🇹🇷', 'LYD': '🇱🇾', 'TND': '🇹🇳',
  'DZD': '🇩🇿', 'MAD': '🇲🇦', 'RUB': '🇷🇺', 'FRF': '🇫🇷', 'DEM': '🇩🇪',
  'CNY': '🇨🇳', 'XAU': '🥇', 'XAG': '🥈', 'OIL': '🛢️', 'BHD': '🇧🇭',
  'KWD': '🇰🇼', 'OMR': '🇴🇲', 'JOD': '🇯🇴', 'EGP': '🇪🇬', 'CAD': '🇨🇦',
  'AUD': '🇦🇺', 'CHF': '🇨🇭', 'JPY': '🇯🇵', 'INR': '🇮🇳', 'SEK': '🇸🇪',
  'NOK': '🇳🇴', 'DKK': '🇩🇰', 'MYR': '🇲🇾', 'SGD': '🇸🇬',
};

const Map<String, double> defaultMarketRatesUSD = {
  'AED': 3.67, 'SAR': 3.75, 'QAR': 3.64, 'EUR': 0.92, 'GBP': 0.78,
  'TRY': 32.5, 'LYD': 4.85, 'TND': 3.10, 'DZD': 134.5, 'MAD': 10.1,
  'RUB': 92.0, 'CNY': 6.73, 'XAU': 2350, 'XAG': 28, 'OIL': 75,
  'BHD': 0.38, 'KWD': 0.31, 'OMR': 0.38, 'JOD': 0.71, 'EGP': 48.5,
  'CAD': 1.35, 'AUD': 1.50, 'CHF': 0.88, 'JPY': 155.0, 'INR': 83.5,
  'SEK': 10.5, 'NOK': 10.8, 'DKK': 6.8, 'MYR': 4.7, 'SGD': 1.35,
};
