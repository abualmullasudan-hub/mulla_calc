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

  AppState() {
    _initDefaults();
    _loadAll();
  }

  void _initDefaults() {
    currencies = {
      'SDG': Currency(code: 'SDG', name: 'جنيه سوداني', flag: '🇸🇩', buyRate: 1, sellRate: 1, active: true),
      'AED': Currency(code: 'AED', name: 'درهم إماراتي', flag: '🇦🇪', buyRate: 2100, sellRate: 2120, active: true),
      'USD': Currency(code: 'USD', name: 'دولار أمريكي', flag: '🇺🇸', buyRate: 7700, sellRate: 7750, active: true),
      'SAR': Currency(code: 'SAR', name: 'ريال سعودي', flag: '🇸🇦', buyRate: 2050, sellRate: 2070, active: true),
      'QAR': Currency(code: 'QAR', name: 'ريال قطري', flag: '🇶🇦', buyRate: 2110, sellRate: 2130, active: true),
      'EUR': Currency(code: 'EUR', name: 'يورو', flag: '🇪🇺', buyRate: 8300, sellRate: 8400),
      'GBP': Currency(code: 'GBP', name: 'جنيه إسترليني', flag: '🇬🇧', buyRate: 9800, sellRate: 9900),
      'TRY': Currency(code: 'TRY', name: 'ليرة تركي', flag: '🇹🇷', buyRate: 240, sellRate: 250),
      'EGP': Currency(code: 'EGP', name: 'جنيه مصري', flag: '🇪🇬', buyRate: 155, sellRate: 165),
      'BHD': Currency(code: 'BHD', name: 'دينار بحريني', flag: '🇧🇭', buyRate: 20400, sellRate: 20500),
      'KWD': Currency(code: 'KWD', name: 'دينار كويتي', flag: '🇰🇼', buyRate: 25000, sellRate: 25200),
      'OMR': Currency(code: 'OMR', name: 'ريال عماني', flag: '🇴🇲', buyRate: 20000, sellRate: 20200),
      'JOD': Currency(code: 'JOD', name: 'دينار أردني', flag: '🇯🇴', buyRate: 10800, sellRate: 10900),
      'CAD': Currency(code: 'CAD', name: 'دولار كندي', flag: '🇨🇦', buyRate: 5600, sellRate: 5700),
      'AUD': Currency(code: 'AUD', name: 'دولار أسترالي', flag: '🇦🇺', buyRate: 5100, sellRate: 5200),
      'CHF': Currency(code: 'CHF', name: 'فرنك سويسري', flag: '🇨🇭', buyRate: 8600, sellRate: 8700),
      'CNY': Currency(code: 'CNY', name: 'يوان صيني', flag: '🇨🇳', buyRate: 1070, sellRate: 1080),
    };
  }

  Future<void> _loadAll() async {
    final p = await SharedPreferences.getInstance();
    final currStr = p.getString('currencies_v2');
    if (currStr != null) {
      final map = jsonDecode(currStr) as Map<String, dynamic>;
      currencies = map.map((k, v) => MapEntry(k, Currency.fromJson(v)));
    }
    baseCurrencyCode = p.getString('base') ?? 'AED';
    final custStr = p.getString('customers_v2');
    if (custStr != null) {
      final list = jsonDecode(custStr) as List;
      customers = list.map((e) => Customer.fromJson(e)).toList();
    }
    final txStr = p.getString('transactions_v2');
    if (txStr != null) {
      final list = jsonDecode(txStr) as List;
      transactions = list.map((e) => Transaction.fromJson(e)).toList();
    }
    final settStr = p.getString('settings_v2');
    if (settStr != null) {
      settings = AppSettings.fromJson(jsonDecode(settStr));
    }
    isLoaded = true;
    notifyListeners();
  }

  Future<void> saveAll() async {
    final p = await SharedPreferences.getInstance();
    final currJson = currencies.map((k, v) => MapEntry(k, v.toJson()));
    await p.setString('currencies_v2', jsonEncode(currJson));
    await p.setString('base', baseCurrencyCode);
    await p.setString('customers_v2', jsonEncode(customers.map((e) => e.toJson()).toList()));
    await p.setString('transactions_v2', jsonEncode(transactions.map((e) => e.toJson()).toList()));
    await p.setString('settings_v2', jsonEncode(settings.toJson()));
    notifyListeners();
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

  void setBaseCurrency(String code) {
    baseCurrencyCode = code;
    saveAll();
  }

  Future<void> updateBaseRate(double rate) async {
    currencies[baseCurrencyCode]!.buyRate = rate;
    currencies[baseCurrencyCode]!.sellRate = rate + 20;
    await saveAll();
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
