import 'dart:convert';
import 'package:http/http.dart' as http;

class RatesService {
  final Map<String, double> ratesToSDG = {
    'SDG': 1.0,
    'AED': 0, 'USD': 0, 'SAR': 0, 'QAR': 0, 'EUR': 0, 'GBP': 0,
    'TRY': 0, 'LYD': 0, 'TND': 0, 'DZD': 0, 'MAD': 0, 'RUB': 0,
    'CNY': 0, 'XAU': 0, 'XAG': 0, 'OIL': 0,
    'BHD': 0, 'KWD': 0, 'OMR': 0, 'JOD': 0, 'EGP': 0,
    'CAD': 0, 'AUD': 0, 'CHF': 0, 'JPY': 0, 'INR': 0,
    'SEK': 0, 'NOK': 0, 'DKK': 0, 'MYR': 0, 'SGD': 0,
  };

  final Map<String, double> marketUSD = {
    'AED': 3.67, 'SAR': 3.75, 'QAR': 3.64, 'EUR': 0.92, 'GBP': 0.78,
    'TRY': 32.5, 'LYD': 4.85, 'TND': 3.10, 'DZD': 134.5, 'MAD': 10.1,
    'RUB': 92.0, 'CNY': 6.73, 'XAU': 2350, 'XAG': 28, 'OIL': 75,
    'BHD': 0.38, 'KWD': 0.31, 'OMR': 0.38, 'JOD': 0.71, 'EGP': 48.5,
    'CAD': 1.35, 'AUD': 1.50, 'CHF': 0.88, 'JPY': 155.0, 'INR': 83.5,
    'SEK': 10.5, 'NOK': 10.8, 'DKK': 6.8, 'MYR': 4.7, 'SGD': 1.35,
  };

  void saveBaseRate(String baseCode, double baseValueInSDG) {
    ratesToSDG[baseCode] = baseValueInSDG;
    final baseToUSD = marketUSD[baseCode] ?? 1.0;
    final usdInSDG = baseValueInSDG * baseToUSD;
    ratesToSDG['USD'] = usdInSDG;

    for (final code in ratesToSDG.keys) {
      if (code == 'SDG' || code == 'USD' || code == baseCode) continue;
      final m = marketUSD[code];
      if (m == null) continue;
      if (code == 'XAU' || code == 'XAG' || code == 'OIL') {
        ratesToSDG[code] = usdInSDG * m;
      } else {
        ratesToSDG[code] = usdInSDG / m;
      }
    }
    if (baseCode != 'AED') {
      ratesToSDG['AED'] = usdInSDG / (marketUSD['AED'] ?? 3.67);
    }
    if (baseCode != 'SAR') {
      ratesToSDG['SAR'] = usdInSDG / (marketUSD['SAR'] ?? 3.75);
    }
  }

  Future<bool> fetchLiveRates(String baseCode, double baseValueInSDG) async {
    try {
      final resp = await http.get(Uri.parse('https://open.er-api.com/v6/latest/USD'));
      if (resp.statusCode != 200) return false;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>?;
      if (rates == null) return false;
      
      for (final code in marketUSD.keys.toList()) {
        if (code == 'XAU' || code == 'XAG' || code == 'OIL') continue;
        final r = rates[code];
        if (r is num) marketUSD[code] = r.toDouble();
      }
      saveBaseRate(baseCode, baseValueInSDG);
      return true;
    } catch (_) {
      return false;
    }
  }

  double convert(double amount, String from, String to) {
    final rf = ratesToSDG[from] ?? 1;
    final rt = ratesToSDG[to] ?? 1;
    if (rt == 0) return 0;
    return (amount * rf) / rt;
  }

  double baseFactor(String from, String to) {
    final rf = ratesToSDG[from] ?? 1;
    final rt = ratesToSDG[to] ?? 1;
    if (rt == 0) return 1;
    return rf / rt;
  }
}
