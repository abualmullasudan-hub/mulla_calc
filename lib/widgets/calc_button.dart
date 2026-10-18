import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

enum CalcBtnType { normal, action, equal, clear, delete }

class CalcButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final CalcBtnType type;
  final double fontSize;

  const CalcButton({
    super.key,
    required this.label,
    required this.onTap,
    this.type = CalcBtnType.normal,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().theme;
    LinearGradient grad;
    Color textColor = t.textDark;
    Color border = t.gold;

    switch (type) {
      case CalcBtnType.action:
        grad = LinearGradient(colors: [t.primaryLight, t.primaryDark]);
        textColor = t.cream;
        break;
      case CalcBtnType.equal:
        grad = LinearGradient(colors: [const Color(0xFFd4a850), t.gold]);
        textColor = t.textDark;
        break;
      case CalcBtnType.clear:
        grad = LinearGradient(colors: [t.primaryDark, t.primaryDarker]);
        textColor = t.gold;
        break;
      case CalcBtnType.delete:
        grad = LinearGradient(colors: [t.danger, t.dangerDark]);
        textColor = t.cream;
        break;
      case CalcBtnType.normal:
        grad = LinearGradient(colors: [t.cream, t.goldLight]);
        break;
    }

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: grad,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
