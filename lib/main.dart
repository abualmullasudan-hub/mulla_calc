import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MullaApp(),
    ),
  );
}

class MullaApp extends StatelessWidget {
  const MullaApp({super.key});
  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().theme;
    return MaterialApp(
      title: 'Mulla Calc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: t.primaryDark,
        primaryColor: t.primaryDark,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
