import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/currency.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _editStartup(BuildContext ctx) async {
    final app = ctx.read<AppState>();
    final t = app.theme;
    final ctrl = TextEditingController(
      text: app.startupBaseValue > 0 ? app.startupBaseValue.toString() : '',
    );
    String base = app.startupBase;
    
    await showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(builder: (ctx2, setS) {
        return AlertDialog(
          backgroundColor: t.cream,
          title: Text('تحديث سعر اليوم', textAlign: TextAlign.center, style: TextStyle(color: t.textDark)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: base,
                isExpanded: true,
                items: ['AED', 'SAR', 'USD', 'SDG'].map((c) {
                  return DropdownMenuItem(value: c, child: Text('${kCurrencyFlags[c]} $c'));
                }).toList(),
                onChanged: (v) => setS(() => base = v!),
              ),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(hintText: '0'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final v = double.tryParse(ctrl.text);
                if (v != null && v > 0) {
                  await app.saveStartupRate(base, v);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('تم حفظ السعر ✅')));
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _openThemes(BuildContext ctx) async {
    final app = ctx.read<AppState>();
    final t = app.theme;
    await showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: t.cream,
        title: Text('🎨 الثيمات', style: TextStyle(color: t.textDark)),
        content: SizedBox(
          width: 400, height: 400,
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8, crossAxisSpacing: 8,
            children: kThemes.map((th) {
              return InkWell(
                onTap: () => app.setTheme(th.id),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [th.primaryDark, th.cream]),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: th.id == t.id ? Colors.white : Colors.transparent, width: 3),
                  ),
                  child: Center(
                    child: Text(th.name, style: TextStyle(color: th.id == t.id ? th.gold : Colors.white, fontSize: 11, fontWeight: FontWeight.bold, shadows: const [Shadow(color: Colors.black54, blurRadius: 4)])),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _openCurrencyManager(BuildContext ctx) async {
    final app = ctx.read<AppState>();
    final t = app.theme;
    await showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: t.cream,
        title: Text('📊 إدارة العملات', style: TextStyle(color: t.textDark)),
        content: SizedBox(
          width: 400, height: 450,
          child: Consumer<AppState>(builder: (_, a, __) {
            return ListView(
              children: kCurrencyLabels.keys.map((c) {
                final active = a.activeInRatios[c] ?? false;
                return SwitchListTile(
                  value: active,
                  onChanged: (_) => a.toggleCurrencyActive(c),
                  title: Text('${kCurrencyFlags[c] ?? ''} ${kCurrencyLabels[c]} ($c)', style: TextStyle(fontSize: 13, color: t.textDark)),
                );
              }).toList(),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _openAppManage(BuildContext ctx) async {
    final app = ctx.read<AppState>();
    final t = app.theme;
    await showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: t.cream,
        title: Text('⚙️ إدارة التطبيق', style: TextStyle(color: t.textDark)),
        content: SizedBox(
          width: 400,
          child: Consumer<AppState>(builder: (_, a, __) {
            const pages = [
              ('simple', 'الحاسبة'), ('currency', 'العملات'),
              ('factor', 'البدل'), ('basket', 'السلة'), ('reports', 'التقارير'),
            ];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: pages.map((p) {
                final visible = !a.hiddenPages.contains(p.$1);
                return SwitchListTile(
                  value: visible,
                  onChanged: (_) => a.toggleHiddenPage(p.$1),
                  title: Text('إظهار ${p.$2}', style: TextStyle(fontSize: 13, color: t.textDark)),
                );
              }).toList(),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = app.theme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _btn(context, '💰 تحديث سعر اليوم', () => _editStartup(context), t),
          _btn(context, '📊 إدارة ونسب العملات', () => _openCurrencyManager(context), t),
          _btn(context, '🎨 تخصيص الألوان والثيمات', () => _openThemes(context), t),
          _btn(context, '⚙️ إدارة التطبيق', () => _openAppManage(context), t),
          _btn(context, '🗑️ مسح السجل', () async {
            app.clearLogs();
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم مسح السجل')));
          }, t),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: t.gold))),
            child: Column(
              children: [
                Text('Mulla Calc', style: TextStyle(color: t.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(app.devName, style: TextStyle(color: t.cream, fontSize: 15)),
                Text(app.devPhone, textDirection: TextDirection.ltr, style: TextStyle(color: t.cream, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(BuildContext ctx, String label, VoidCallback onTap, AppTheme t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: t.primaryDark,
            side: BorderSide(color: t.gold, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: t.cream)),
        ),
      ),
    );
  }
}
