import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

Future<void> showAppAlert(BuildContext ctx, String msg) {
  final t = ctx.read<AppState>().theme;
  return showDialog(
    context: ctx,
    builder: (_) => AlertDialog(
      backgroundColor: t.cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: t.gold, width: 2),
      ),
      content: Text(msg,
          textAlign: TextAlign.center,
          style: TextStyle(color: t.textDark, fontWeight: FontWeight.bold)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('موافق', style: TextStyle(color: t.primaryDark)),
        ),
      ],
    ),
  );
}

Future<bool> showAppConfirm(BuildContext ctx, String msg) async {
  final t = ctx.read<AppState>().theme;
  final res = await showDialog<bool>(
    context: ctx,
    builder: (_) => AlertDialog(
      backgroundColor: t.cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: t.gold, width: 2),
      ),
      content: Text(msg,
          textAlign: TextAlign.center,
          style: TextStyle(color: t.textDark, fontWeight: FontWeight.bold)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('إلغاء', style: TextStyle(color: t.danger)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('نعم', style: TextStyle(color: t.primaryDark)),
        ),
      ],
    ),
  );
  return res ?? false;
}

void showAppToast(BuildContext ctx, String msg) {
  final t = ctx.read<AppState>().theme;
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(msg,
          textAlign: TextAlign.center,
          style: TextStyle(color: t.gold, fontWeight: FontWeight.bold)),
      backgroundColor: t.primaryDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(color: t.gold),
      ),
    ),
  );
}
