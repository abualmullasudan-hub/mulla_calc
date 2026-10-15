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
      childAspectRatio: 1.9,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: keys.expand((r) => r).map((k) {
        final isAction = ['÷', '×', '-', '+', '='].contains(k);
        return Material(
          color: isAction ? const Color(0xFF0B4D2C) : const Color(0xFFFDFBF7),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => onKeyTap(k),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC5A059), width: 2),
              ),
              child: Center(
                child: Text(
                  k,
                  style: TextStyle(
                    fontSize: k.length > 1 ? 16 : 22,
                    fontWeight: FontWeight.bold,
                    color: isAction ? const Color(0xFFFDFBF7) : const Color(0xFF0B4D2C),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
