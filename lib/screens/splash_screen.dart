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
    try {
      await context.read<AppState>().loadAll().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint("خطأ في التحميل: $e");
    }
    
    await Future.delayed(const Duration(milliseconds: 2000)); // زيادة وقت عرض الشاشة قليلاً لرؤية الصورة
    
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
              // عرض الصورة التي رفعتها بدلاً من حرفي MC
              Container(
                width: 150, 
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // النصوص التوضيحية
              Text('Mulla Calc', style: TextStyle(color: t.cream, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('الآلة الحاسبة المالية', style: TextStyle(color: t.gold, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
