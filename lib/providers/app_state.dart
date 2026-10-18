import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency.dart';
import '../services/rates_service.dart'; // <--- هذا هو السطر السحري الذي كان مفقوداً

class AppState extends ChangeNotifier {
  AppTheme theme = kThemes.first;
  final RatesService rates = RatesService();

  Map<String, bool> activeInRatios = {
    'SDG': true, 'AED': true, 'USD': true, 'SAR': true, 'QAR': true,
    'EUR': false, 'GBP': false, 'TRY': false, 'LYD': false, 'TND': false,
    'DZD': false, 'MAD': false, 'RUB': false, 'CNY': false,
    'XAU': false, 'XAG': false, 'OIL': false,
  };

  String startupBase = 'AED';
  double startupBaseValue = 0;
  String customTitle = 'تحديث سعر اليوم';
  String customQuestion = 'اليوم [العملة] بي كم؟';
  String devName = 'Abu Almulla';
  String devPhone = '0922008009';
  List<String> hiddenPages = [];
  List<Map<String, dynamic>> logs = [];

  // حالة البدل
  String factorFrom = 'AED';
  String factorTo = 'SDG';
  String factorAmount = '1000';
  String factorRate = '1.06';
  bool factorLocked = true;
  String defFactorFrom = 'AED';
  String defFactorTo = 'SDG';
  double defFactorAmount = 1000;
  double defRefFactor = 1.00;
  double defLossLimit = 0.01;
  Map<String, double> savedFactors = {};

  // حالة السلة
  String basketTarget = 'SDG';
  Map<String, String> basketValues = {};

  Future<void> loadAll() async {
    final p = await SharedPreferences.getInstance();

    final themeId = p.getString('theme') ?? 'default';
    theme = kThemes.firstWhere((t) => t.id == themeId, orElse: () => kThemes.first);

    startupBase = p.getString('startupBase') ?? 'AED';
    startupBaseValue = p.getDouble('startupBaseValue') ?? 0;

    customTitle = p.getString('customTitle') ?? customTitle;
    customQuestion = p.getString('customQuestion') ?? customQuestion;
    devName = p.getString('devName') ?? devName;
    devPhone = p.getString('devPhone') ?? devPhone;

    final act = p.getString('activeInRatios');
    if (act != null) {
      final m = jsonDecode(act) as Map<String, dynamic>;
      m.forEach((k, v) { if (v is bool) activeInRatios[k] = v; });
    }

    final ratesStr = p.getString('ratesToSDG');
    if (ratesStr != null) {
      final m = jsonDecode(ratesStr) as Map<String, dynamic>;
      m.forEach((k, v) {
        if (v is num && rates.ratesToSDG.containsKey(k)) {
          rates.ratesToSDG[k] = v.toDouble();
        }
      });
    }

    final hp = p.getStringList('hiddenPages');
    if (hp != null) hiddenPages = hp;

    final lg = p.getString('logs');
    if (lg != null) {
      try { logs = List<Map<String, dynamic>>.from(jsonDecode(lg)); }
      catch (_) { logs = []; }
    }

    final sf = p.getString('savedFactors');
    if (sf != null) {
      try {
        final m = jsonDecode(sf) as Map<String, dynamic>;
        savedFactors = m.map((k, v) => MapEntry(k, (v as num).toDouble()));
      } catch (_) {}
    }

    final df = p.getString('defFactor');
    if (df != null) {
      try {
        final m = jsonDecode(df) as Map<String, dynamic>;
        defFactorFrom = m['from'] ?? 'AED';
        defFactorTo = m['to'] ?? 'SDG';
        defFactorAmount = (m['amount'] as num?)?.toDouble() ?? 1000;
        defRefFactor = (m['refFactor'] as num?)?.toDouble() ?? 1.00;
        defLossLimit = (m['lossLimit'] as num?)?.toDouble() ?? 0.01;
      } catch (_) {}
    }

    notifyListeners();
  }

  Future<void> setTheme(String id) async {
    theme = kThemes.firstWhere((t) => t.id == id, orElse: () => kThemes.first);
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString('theme', id);
  }

  Future<void> saveStartupRate(String base, double value) async {
    startupBase = base;
    startupBaseValue = value;
    rates.saveBaseRate(base, value);
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString('startupBase', base);
    await p.setDouble('startupBaseValue', value);
    await p.setString('ratesToSDG', jsonEncode(rates.ratesToSDG));
  }

  Future<void> saveCustomLabels({
    required String title, required String question,
    required String name, required String phone,
  }) async {
    customTitle = title; customQuestion = question;
    devName = name; devPhone = phone;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString('customTitle', title);
    await p.setString('customQuestion', question);
    await p.setString('devName', name);
    await p.setString('devPhone', phone);
  }

  String startupQuestionFormatted() {
    final flag = kCurrencyFlags[startupBase] ?? '';
    final name = kCurrencyLabels[startupBase] ?? startupBase;
    return customQuestion.replaceAll('[العملة]', '$name $flag');
  }

  Future<void> toggleCurrencyActive(String code) async {
    activeInRatios[code] = !(activeInRatios[code] ?? false);
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString('activeInRatios', jsonEncode(activeInRatios));
  }

  Future<void> toggleHiddenPage(String pageId) async {
    if (hiddenPages.contains(pageId)) hiddenPages.remove(pageId);
    else hiddenPages.add(pageId);
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList('hiddenPages', hiddenPages);
  }

  List<String> get activeCurrencies =>
      kCurrencyLabels.keys.where((c) => activeInRatios[c] == true).toList();

  void addLog(String text) {
    logs.add({'text': text, 'time': DateTime.now().toIso8601String()});
    if (logs.length > 200) logs.removeAt(0);
    notifyListeners();
    SharedPreferences.getInstance().then((p) => p.setString('logs', jsonEncode(logs)));
  }

  void clearLogs() {
    logs.clear();
    notifyListeners();
    SharedPreferences.getInstance().then((p) => p.remove('logs'));
  }

  double getFactorFor(String from, String to) {
    final key = '${from}_$to';
    if (savedFactors.containsKey(key)) return savedFactors[key]!;
    return rates.baseFactor(from, to);
  }

  Future<void> saveFactor(String from, String to, double value) async {
    savedFactors['${from}_$to'] = value;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString('savedFactors', jsonEncode(savedFactors));
  }

  Future<void> saveDefaultFactorSettings({
    required String from, required String to, required double amount,
    required double refFactor, required double lossLimit,
  }) async {
    defFactorFrom = from; defFactorTo = to;
    defFactorAmount = amount;
    defRefFactor = refFactor; defLossLimit = lossLimit;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString('defFactor', jsonEncode({
      'from': from, 'to': to, 'amount': amount,
      'refFactor': refFactor, 'lossLimit': lossLimit,
    }));
  }

  Future<void> setBasketValue(String code, String value) async {
    basketValues[code] = value;
    notifyListeners();
  }

  void clearBasketValues() {
    basketValues.clear();
    notifyListeners();
  }

  double basketTotalInSDG() {
    double total = 0;
    basketValues.forEach((code, v) {
      final num = double.tryParse(v) ?? 0;
      final rate = rates.ratesToSDG[code] ?? 1;
      total += num * rate;
    });
    return total;
  }

  double basketTotalConverted() {
    final rt = rates.ratesToSDG[basketTarget] ?? 1;
    if (rt == 0) return 0;
    return basketTotalInSDG() / rt;
  }
}
