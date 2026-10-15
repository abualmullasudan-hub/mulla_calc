import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency.dart';

class AppState extends ChangeNotifier {
  Map<String, Currency> currencies = {};
  String baseCurrencyCode = 'AED';

  AppState() {
    _init();
    _load();
  }

  void _init() {
    currencies = {
      'SDG': Currency(code: 'SDG', name: 'جنيه سوداني', flag: '🇸🇩', rateToSDG: 1),
      'AED': Currency(code: 'AED', name: 'درهم إماراتي', flag: '🇦🇪', rateToSDG: 2100),
      'USD': Currency(code: 'USD', name: 'دولار أمريكي', flag: '🇺🇸', rateToSDG: 2100 * 3.67),
      'SAR': Currency(code: 'SAR', name: 'ريال سعودي', flag: '🇸🇦', rateToSDG: 2100 * (3.67 / 3.75)),
      'QAR': Currency(code: 'QAR', name: 'ريال قطري', flag: '🇶🇦', rateToSDG: 2100 * (3.67 / 3.64)),
      'EUR': Currency(code: 'EUR', name: 'يورو', flag: '🇪🇺', rateToSDG: 2100 * 3.67 * 1.08),
      'GBP': Currency(code: 'GBP', name: 'جنيه إسترليني', flag: '🇬🇧', rateToSDG: 2100 * 3.67 * 1.28),
    };
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    baseCurrencyCode = p.getString('base') ?? 'AED';
    for (var c in currencies.keys) {
      final r = p.getDouble('rate_$c');
      if (r != null) currencies[c]!.rateToSDG = r;
    }
    notifyListeners();
  }

  Future<void> saveBase(String code) async {
    baseCurrencyCode = code;
    (await SharedPreferences.getInstance()).setString('base', code);
    notifyListeners();
  }

  Future<void> updateBaseRate(double rate) async {
    currencies[baseCurrencyCode]!.rateToSDG = rate;
    double usdToBase = 1;
    if (baseCurrencyCode == 'AED') usdToBase = 3.67;
    if (baseCurrencyCode == 'SAR') usdToBase = 3.75;
    final usdSDG = rate * usdToBase;
    currencies['USD']!.rateToSDG = usdSDG;
    currencies['AED']!.rateToSDG = usdSDG / 3.67;
    currencies['SAR']!.rateToSDG = usdSDG / 3.75;
    currencies['QAR']!.rateToSDG = usdSDG / 3.64;
    currencies['EUR']!.rateToSDG = usdSDG / 0.92;
    currencies['GBP']!.rateToSDG = usdSDG / 0.78;

    final p = await SharedPreferences.getInstance();
    for (var e in currencies.entries) {
      await p.setDouble('rate_${e.key}', e.value.rateToSDG);
    }
    notifyListeners();
  }

  double convert(double amount, String from, String to) {
    if (!currencies.containsKey(from) || !currencies.containsKey(to)) return 0;
    return amount * currencies[from]!.rateToSDG / currencies[to]!.rateToSDG;
  }
}
