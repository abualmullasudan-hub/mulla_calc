import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../models/currency.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../models/settings.dart';

class AppState extends ChangeNotifier {
  final _uuid = const Uuid();
  Map<String, Currency> currencies = {};
  List<Customer> customers = [];
  List<Transaction> transactions = [];
  AppSettings settings = AppSettings();
  String baseCurrencyCode = 'AED';
  bool isLoaded = false;

  // ⭐ NEW: محرر النسب
  double baseRateInSDG = 2100;
  Map<String, double> marketRatesToUSD = {
    'AED': 3.67,
    'SAR': 3.75,
    'QAR': 3.64,
    'EUR': 0.92,
    'GBP': 0.78,
    'TRY': 32.5,
    'EGP': 48.5,
    'BHD': 0.38,
    'KWD': 0.31,
    'OMR': 0.38,
    'JOD': 0.71,
    'CAD': 1.35,
    'AUD': 1.50,
    'CHF': 0.88,
    'CNY': 7.2,
  };

  AppState() {
    _initDefaults();
    _loadAll();
  }

  void _initDefaults() {
    currencies = {
      'SDG': Currency(code: 'SDG', name: 'جنيه سوداني', flag: '🇸🇩', buyRate: 1, sellRate: 1, active: true),
      'AED': Currency(code: 'AED', name: 'درهم إماراتي', flag: '🇦🇪', buyRate: 2100, sellRate: 2121, active: true),
      'USD': Currency(code: 'USD', name: 'دولار أمريكي', flag: '🇺🇸', buyRate: 7707, sellRate: 7784, active: true),
      'SAR': Currency(code: 'SAR', name: 'ريال سعودي', flag: '🇸🇦', buyRate: 2055, sellRate: 2076, active: true),
      'QAR': Currency(code: 'QAR', name: 'ريال قطري', flag: '🇶🇦', buyRate: 2117, sellRate: 2138, active: true),
      'EUR': Currency(code: 'EUR', name: 'يورو', flag: '🇪🇺', buyRate: 8377, sellRate: 8461, active: true),
      'GBP': Currency(code: 'GBP', name: 'جنيه إسترليني', flag: '🇬🇧', buyRate: 9881, sellRate: 9980),
      'TRY': Currency(code: 'TRY', name: 'ليرة تركي', flag: '🇹🇷', buyRate: 237),
      'EGP': Currency(code: 'EGP', name: 'جنيه مصري', flag: '🇪🇬', buyRate: 159),
      'BHD': Currency(code: 'BHD', name: 'دينار بحريني', flag: '🇧🇭', buyRate: 20282),
      'KWD': Currency(code: 'KWD', name: 'دينار كويتي', flag: '🇰🇼', buyRate: 24861),
      'OMR': Currency(code: 'OMR', name: 'ريال عماني', flag: '🇴🇲', buyRate: 20282),
      'JOD': Currency(code: 'JOD', name: 'دينار أردني', flag: '🇯🇴', buyRate: 10855),
      'CAD': Currency(code: 'CAD', name: 'دولار كندي', flag: '🇨🇦', buyRate: 5709),
      'AUD': Currency(code: 'AUD', name: 'دولار أسترالي', flag: '🇦🇺', buyRate: 5138),
      'CHF': Currency(code: 'CHF', name: 'فرنك سويسري', flag: '🇨🇭', buyRate: 8758),
      'CNY': Currency(code: 'CNY', name: 'يوان صيني', flag: '🇨🇳', buyRate: 1070),
    };
  }

  // ⭐ حساب سعر الدولار بالجنيه السوداني
  double get usdInSDG {
    final m = marketRatesToUSD[baseCurrencyCode] ?? 1;
    return baseRateInSDG * m;
  }

  // ⭐ حساب سعر أي عملة بالجنيه السوداني حسب المعادلة
  double getRateInSDG(String code) {
    if (code == 'SDG') return 1;
    final m = marketRatesToUSD[code];
    if (m == null || m <= 0) return currencies[code]?.buyRate ?? 0;
    return usdInSDG / m;
  }

  // ⭐ إعادة حساب كل الأسعار
  void refreshAllRates() {
    for (var c in currencies.values) {
      if (c.code == 'SDG') continue;
      final r = getRateInSDG(c.code);
      if (r > 0) {
        c.buyRate = r;
        c.sellRate = r * 1.01;
      }
    }
    saveAll();
  }

  Future<void> _loadAll() async {
    final p = await SharedPreferences.getInstance();
    final currStr = p.getString('currencies_v2');
    if (currStr != null) {
      try {
        final map = jsonDecode(currStr) as Map<String, dynamic>;
        currencies = map.map((k, v) => MapEntry(k, Currency.fromJson(v)));
      } catch (_) {}
    }
    baseCurrencyCode = p.getString('base') ?? 'AED';
    baseRateInSDG = p.getDouble('baseRateInSDG') ?? 2100;
    final mrStr = p.getString('marketRates');
    if (mrStr != null) {
      try {
        final m = jsonDecode(mrStr) as Map<String, dynamic>;
        marketRatesToUSD = m.map((k, v) => MapEntry(k, (v as num).toDouble()));
      } catch (_) {}
    }
    final custStr = p.getString('customers_v2');
    if (custStr != null) {
      try {
        final list = jsonDecode(custStr) as List;
        customers = list.map((e) => Customer.fromJson(e)).toList();
      } catch (_) {}
    }
    final txStr = p.getString('transactions_v2');
    if (txStr != null) {
      try {
        final list = jsonDecode(txStr) as List;
        transactions = list.map((e) => Transaction.fromJson(e)).toList();
      } catch (_) {}
    }
    final settStr = p.getString('settings_v2');
    if (settStr != null) {
      try {
        settings = AppSettings.fromJson(jsonDecode(settStr));
      } catch (_) {}
    }
    isLoaded = true;
    notifyListeners();
  }

  Future<void> saveAll() async {
    final p = await SharedPreferences.getInstance();
    final currJson = currencies.map((k, v) => MapEntry(k, v.toJson()));
    await p.setString('currencies_v2', jsonEncode(currJson));
    await p.setString('base', baseCurrencyCode);
    await p.setDouble('baseRateInSDG', baseRateInSDG);
    await p.setString('marketRates', jsonEncode(marketRatesToUSD));
    await p.setString('customers_v2', jsonEncode(customers.map((e) => e.toJson()).toList()));
    await p.setString('transactions_v2', jsonEncode(transactions.map((e) => e.toJson()).toList()));
    await p.setString('settings_v2', jsonEncode(settings.toJson()));
    notifyListeners();
  }

  // ⭐ تغيير العملة الأساسية
  void setBaseCurrency(String code) {
    baseCurrencyCode = code;
    refreshAllRates();
  }

  // ⭐ تحديث سعر العملة الأساسية
  void updateBaseRate(double rate) {
    baseRateInSDG = rate;
    refreshAllRates();
  }

  // ⭐ تحديث سعر السوق
  void updateMarketRate(String code, double rate) {
    marketRatesToUSD[code] = rate;
    refreshAllRates();
  }

  List<Currency> get activeCurrencies =>
      currencies.values.where((c) => c.active).toList();

  void toggleCurrencyActive(String code) {
    currencies[code]!.active = !currencies[code]!.active;
    saveAll();
  }

  void updateCurrency(String code, {double? buyRate, double? sellRate, String? name}) {
    final c = currencies[code]!;
    if (buyRate != null) c.buyRate = buyRate;
    if (sellRate != null) c.sellRate = sellRate;
    if (name != null) c.name = name;
    saveAll();
  }

  void addCustomer(String name, String phone, String note) {
    customers.add(Customer(
      id: _uuid.v4(),
      name: name,
      phone: phone,
      note: note,
      createdAt: DateTime.now(),
    ));
    saveAll();
  }

  void deleteCustomer(String id) {
    customers.removeWhere((e) => e.id == id);
    saveAll();
  }

  Customer? getCustomer(String id) {
    try {
      return customers.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Transaction> addTransaction({
    required String type,
    required String customerId,
    required String currencyCode,
    required double amount,
    required double rate,
    String note = '',
  }) async {
    final customer = getCustomer(customerId);
    final invoiceNo = (transactions.length + 1).toString().padLeft(4, '0');
    final totalSDG = amount * rate;

    final t = Transaction(
      id: _uuid.v4(),
      invoiceNo: invoiceNo,
      type: type,
      customerId: customerId,
      customerName: customer?.name ?? 'نقدي',
      currencyCode: currencyCode,
      amount: amount,
      rate: rate,
      totalSDG: totalSDG,
      note: note,
      date: DateTime.now(),
    );
    transactions.insert(0, t);

    if (customer != null) {
      if (type == 'buy') {
        customer.balance -= totalSDG;
      } else {
        customer.balance += totalSDG;
      }
    }
    await saveAll();
    return t;
  }

  List<Transaction> get todayTransactions {
    final now = DateTime.now();
    return transactions.where((t) =>
        t.date.year == now.year && t.date.month == now.month && t.date.day == now.day).toList();
  }

  double get todayBuySDG =>
      todayTransactions.where((t) => t.isBuy).fold(0.0, (s, t) => s + t.totalSDG);

  double get todaySellSDG =>
      todayTransactions.where((t) => !t.isBuy).fold(0.0, (s, t) => s + t.totalSDG);

  double get todayProfit {
    double profit = 0;
    for (var t in todayTransactions) {
      final c = currencies[t.currencyCode];
      if (c == null) continue;
      profit += t.amount * (c.sellRate - c.buyRate);
    }
    return profit;
  }

  void updateSettings(AppSettings s) {
    settings = s;
    saveAll();
  }
}
