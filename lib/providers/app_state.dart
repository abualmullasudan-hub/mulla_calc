import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/format.dart';

class AppState extends ChangeNotifier {
  Map<String, double> ratesToSDG = {
    'SDG': 1,
    'AED': 2100,
    'USD': 2100 * 3.67,
    'SAR': 2100 * (3.67 / 3.75),
    'QAR': 2100 * (3.67 / 3.64),
    'EUR': 2100 * 3.67 * 1.08,
    'GBP': 2100 * 3.67 * 1.28,
    'TRY': 2100 * (3.67 / 32.5),
    'LYD': 2100 * (3.67 / 4.85),
    'TND': 2100 * (3.67 / 3.10),
    'DZD': 2100 * (3.67 / 134.5),
    'MAD': 2100 * (3.67 / 10.1),
    'RUB': 2100 * (3.67 / 92.0),
    'FRF': 2100 * 3.67 * 0.15,
    'DEM': 2100 * 3.67 * 0.55,
    'CNY': 2100 * (3.67 / 7.2),
    'XAU': 2100 * 3.67 * 2350,
    'XAG': 2100 * 3.67 * 28,
    'OIL': 2100 * (3.67 / 75),
  };

  Map<String, bool> activeInRatios = {
    'SDG': true, 'AED': true, 'USD': true, 'SAR': true, 'QAR': true,
    'EUR': false, 'GBP': false, 'TRY': false, 'LYD': false, 'TND': false,
    'DZD': false, 'MAD': false, 'RUB': false, 'FRF': false, 'DEM': false,
    'CNY': false, 'XAU': false, 'XAG': false, 'OIL': false,
  };

  Map<String, double> liveMarketRatesUSD = Map.from(defaultMarketRatesUSD);

  String startupBaseCurrency = 'AED';
  String lastUpdateLabel = 'آخر تحديث: متصل بالإنترنت';
  bool isLoading = false;
  bool isLoaded = false;

  AppState() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    startupBaseCurrency = p.getString('startupBaseCurrency') ?? 'AED';
    for (var k in ratesToSDG.keys) {
      final v = p.getDouble('rate_$k');
      if (v != null) ratesToSDG[k] = v;
      final a = p.getBool('active_$k');
      if (a != null) activeInRatios[k] = a;
      final m = p.getDouble('market_$k');
      if (m != null) liveMarketRatesUSD[k] = m;
    }
    isLoaded = true;
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('startupBaseCurrency', startupBaseCurrency);
    for (var k in ratesToSDG.keys) {
      await p.setDouble('rate_$k', ratesToSDG[k] ?? 0);
      await p.setBool('active_$k', activeInRatios[k] ?? false);
      if (liveMarketRatesUSD[k] != null) {
        await p.setDouble('market_$k', liveMarketRatesUSD[k]!);
      }
    }
    notifyListeners();
  }

  double convert(double amount, String from, String to) {
    final rF = ratesToSDG[from] ?? 1;
    final rT = ratesToSDG[to] ?? 1;
    return (amount * rF) / rT;
  }

  Future<void> saveStartupRate(String baseCurr, double val) async {
    startupBaseCurrency = baseCurr;
    ratesToSDG[baseCurr] = val;

    final mRate = liveMarketRatesUSD[baseCurr] ?? 1;
    final usdSDG = val * mRate;
    ratesToSDG['USD'] = usdSDG;

    for (var code in ratesToSDG.keys) {
      if (code == 'SDG' || code == 'USD' || code == baseCurr) continue;
      final m = liveMarketRatesUSD[code];
      if (m != null && m > 0) {
        if (code == 'XAU') {
          ratesToSDG[code] = usdSDG * (liveMarketRatesUSD['XAU'] ?? 2350);
        } else if (code == 'XAG') {
          ratesToSDG[code] = usdSDG * (liveMarketRatesUSD['XAG'] ?? 28);
        } else if (code == 'OIL') {
          ratesToSDG[code] = usdSDG * (liveMarketRatesUSD['OIL'] ?? 75);
        } else {
          ratesToSDG[code] = usdSDG / m;
        }
      }
    }
    if (baseCurr != 'AED') {
      ratesToSDG['AED'] = usdSDG / (liveMarketRatesUSD['AED'] ?? 3.67);
    }
    if (baseCurr != 'SAR') {
      ratesToSDG['SAR'] = usdSDG / (liveMarketRatesUSD['SAR'] ?? 3.75);
    }
    await _savePrefs();
  }

  Future<void> fetchLiveMarketRates() async {
    isLoading = true;
    notifyListeners();
    try {
      final resp = await http
          .get(Uri.parse('https://open.er-api.com/v6/latest/USD'))
          .timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data['rates'] != null) {
          final rates = data['rates'] as Map;
          for (var code in liveMarketRatesUSD.keys) {
            if (rates[code] != null &&
                code != 'XAU' && code != 'XAG' && code != 'OIL') {
              liveMarketRatesUSD[code] = (rates[code] as num).toDouble();
            }
          }
          final baseSDG = ratesToSDG[startupBaseCurrency] ?? ratesToSDG['AED']!;
          final baseM = liveMarketRatesUSD[startupBaseCurrency] ?? 1;
          final usdSDG = baseSDG * baseM;
          ratesToSDG['USD'] = usdSDG;

          for (var code in ratesToSDG.keys) {
            if (code == 'SDG' || code == 'USD' || code == startupBaseCurrency) continue;
            final m = liveMarketRatesUSD[code];
            if (m != null && m > 0) {
              if (code == 'XAU') {
                ratesToSDG[code] = usdSDG * (liveMarketRatesUSD['XAU'] ?? 2350);
              } else if (code == 'XAG') {
                ratesToSDG[code] = usdSDG * (liveMarketRatesUSD['XAG'] ?? 28);
              } else if (code == 'OIL') {
                ratesToSDG[code] = usdSDG * (liveMarketRatesUSD['OIL'] ?? 75);
              } else {
                ratesToSDG[code] = usdSDG / m;
              }
            }
          }
          if (startupBaseCurrency != 'AED') {
            ratesToSDG['AED'] = usdSDG / (liveMarketRatesUSD['AED'] ?? 3.67);
          }
          if (startupBaseCurrency != 'SAR') {
            ratesToSDG['SAR'] = usdSDG / (liveMarketRatesUSD['SAR'] ?? 3.75);
          }
          final now = DateTime.now();
          lastUpdateLabel =
              'آخر تحديث: ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
          await _savePrefs();
        }
      }
    } catch (_) {
      lastUpdateLabel = 'تعذر الاتصال بالإنترنت';
    }
    isLoading = false;
    notifyListeners();
  }

  List<String> get activeCurrencies =>
      activeInRatios.entries.where((e) => e.value).map((e) => e.key).toList();

  void toggleActive(String code) {
    activeInRatios[code] = !(activeInRatios[code] ?? false);
    _savePrefs();
  }

  void setStartupBase(String code) {
    startupBaseCurrency = code;
    _savePrefs();
  }

  Future<void> saveCustomRatios(Map<String, double> newValues) async {
    for (var e in newValues.entries) {
      ratesToSDG[e.key] = e.value;
    }
    await _savePrefs();
  }

  Future<void> addCurrency(String code, double marketRate) async {
    liveMarketRatesUSD[code] = marketRate;
    activeInRatios[code] = true;
    final usdSDG = ratesToSDG['USD'] ?? (ratesToSDG['AED']! * 3.67);
    ratesToSDG[code] = usdSDG / marketRate;
    await _savePrefs();
  }
}
