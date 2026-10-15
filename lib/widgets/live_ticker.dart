import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/format.dart';

class LiveTicker extends StatefulWidget {
  const LiveTicker({super.key});
  @override
  State<LiveTicker> createState() => _LiveTickerState();
}

class _LiveTickerState extends State<LiveTicker> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final items = app.activeCurrencies;
    if (items.isEmpty) return const SizedBox(height: 28);

    final totalWidth = items.length * 130.0;

    Widget buildRow() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((c) => Container(
          width: 130,
          alignment: Alignment.center,
          child: Text(
            '${c.flag} ${c.code}: ${formatNumber(c.buyRate)}',
            style: const TextStyle(
              color: Color(0xFFC5A059),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        )).toList(),
      );
    }

    return Container(
      height: 26,
      decoration: BoxDecoration(
        color: const Color(0xFF052616),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (ctx, child) {
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: -(_ctrl.value * totalWidth),
                  top: 0,
                  bottom: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildRow(),
                      buildRow(),
                      buildRow(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
