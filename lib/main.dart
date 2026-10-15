import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MullaApp(),
      ),
    );

class MullaApp extends StatelessWidget {
  const MullaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MullaCalc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0B4D2C),
        primaryColor: const Color(0xFF0B4D2C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B4D2C),
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
