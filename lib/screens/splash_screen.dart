import 'package:flutter/material.dart';
import 'startup_rate_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StartupRateScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B4D2C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                border: Border.all(color: const Color(0xFFC5A059), width: 6),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Text('Mulla', style: TextStyle(
                  color: Color(0xFF0B4D2C), fontSize: 28, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Mulla Calc',
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('الآلة الحاسبة المالية',
              style: TextStyle(color: Color(0xFFC5A059), fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
