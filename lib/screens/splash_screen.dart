import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await context.read<AppState>().loadAll();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().theme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [t.primaryDark, t.primaryDarker],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  color: t.cream,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: t.gold, width: 6),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8)),
                  ],
                ),
                child: Center(
                  child: Text('MC', style: TextStyle(color: t.primaryDark, fontSize: 42, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Mulla Calc', style: TextStyle(color: t.cream, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('الآلة الحاسبة المالية', style: TextStyle(color: t.gold, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
