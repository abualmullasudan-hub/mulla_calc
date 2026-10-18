import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'simple_calc_screen.dart';
import 'currency_screen.dart';
import 'factor_screen.dart';
import 'basket_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final List<Widget> _screens = const [
    SimpleCalcScreen(),
    CurrencyScreen(),
    FactorScreen(),
    BasketScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  final List<(IconData, String)> _items = const [
    (Icons.calculate_outlined, 'حاسبة'),
    (Icons.currency_exchange, 'العملات'),
    (Icons.swap_horiz, 'البدل'),
    (Icons.shopping_basket_outlined, 'السلة'),
    (Icons.description_outlined, 'التقارير'),
    (Icons.settings_outlined, 'الإعدادات'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().theme;
    final hidden = context.watch<AppState>().hiddenPages;
    
    final visibleIdx = <int>[];
    for (var i = 0; i < _items.length; i++) {
      if (!hidden.contains(_pageId(i))) visibleIdx.add(i);
    }
    
    if (visibleIdx.isEmpty) visibleIdx.add(5); 
    if (!visibleIdx.contains(_index)) _index = visibleIdx.first;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: t.primaryDark,
        body: SafeArea(child: _screens[_index]),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [t.cream, t.goldLight],
            ),
            border: Border(top: BorderSide(color: t.gold, width: 2)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: visibleIdx.map((i) {
              final selected = _index == i;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _index = i),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? LinearGradient(colors: [t.primaryDark, t.primaryDarker])
                          : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_items[i].$1,
                            size: 22,
                            color: selected ? t.gold : t.primaryDark.withOpacity(0.8)),
                        const SizedBox(height: 3),
                        Text(_items[i].$2,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: selected ? t.gold : t.primaryDark.withOpacity(0.8))),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _pageId(int i) {
    const ids = ['simple', 'currency', 'factor', 'basket', 'reports', 'settings'];
    return ids[i];
  }
}
