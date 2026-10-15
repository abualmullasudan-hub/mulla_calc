import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'home_screen.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});
  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  String _error = '';

  void _addDigit(String d) {
    if (_pin.length < 4) {
      setState(() => _pin += d);
      if (_pin.length == 4) _check();
    }
  }

  void _check() {
    final app = Provider.of<AppState>(context, listen: false);
    if (_pin == app.settings.pin) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      setState(() {
        _error = 'الرقم السري خطأ';
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B4D2C),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, color: Color(0xFFC5A059), size: 60),
            const SizedBox(height: 16),
            const Text('أدخل الرقم السري',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: i < _pin.length ? const Color(0xFFC5A059) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC5A059), width: 2),
                ),
              )),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_error, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ],
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  for (var d in ['1','2','3','4','5','6','7','8','9','C','0','⌫'])
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFDFBF7),
                        foregroundColor: const Color(0xFF0B4D2C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: const BorderSide(color: Color(0xFFC5A059), width: 2),
                        ),
                      ),
                      onPressed: () {
                        if (d == 'C') {
                          setState(() { _pin = ''; _error = ''; });
                        } else if (d == '⌫') {
                          if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
                        } else {
                          _addDigit(d);
                        }
                      },
                      child: Text(d, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
