import 'package:flutter/material.dart';

class CalcKeypad extends StatelessWidget {
  final Function(String) onKeyTap;
  const CalcKeypad({super.key, required this.onKeyTap});

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['C', '⌫', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '00', '000', '.'],
      ['+/-', '√', '1/x', '='],
    ];

    return GridView.count(
      crossAxisCount: 4,
      childAspectRatio: 1.8,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: keys.expand((r) => r).map((k) {
        final isAction = ['÷', '×', '-', '+', '='].contains(k);
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isAction ? const Color(0xFF0B4D2C) : const Color(0xFFFDFBF7),
            foregroundColor: isAction ? Colors.white : const Color(0xFF0B4D2C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFC5A059), width: 1.5),
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: () => onKeyTap(k),
          child: Text(k, style: TextStyle(
            fontSize: k.length > 1 ? 15 : 22,
            fontWeight: FontWeight.bold,
          )),
        );
      }).toList(),
    );
  }
}
