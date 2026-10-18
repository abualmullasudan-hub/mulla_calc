import 'package:flutter/material.dart';

class AppTheme {
  final String id;
  final String name;
  final Color primaryDark;
  final Color primaryDarker;
  final Color primaryLight;
  final Color gold;
  final Color goldLight;
  final Color cream;
  final Color bgOuter;
  final Color danger;
  final Color dangerDark;
  final Color textDark;
  final Color textLight;

  const AppTheme({
    required this.id,
    required this.name,
    required this.primaryDark,
    required this.primaryDarker,
    required this.primaryLight,
    required this.gold,
    required this.goldLight,
    required this.cream,
    required this.bgOuter,
    required this.danger,
    required this.dangerDark,
    required this.textDark,
    required this.textLight,
  });
}

const List<AppTheme> kThemes = [
  AppTheme(id: 'default', name: 'أخضر ملكي',
    primaryDark: Color(0xFF0b4d2c), primaryDarker: Color(0xFF052616),
    primaryLight: Color(0xFF12633a), gold: Color(0xFFc5a059),
    goldLight: Color(0xFFf4ebd0), cream: Color(0xFFfdfbf7),
    bgOuter: Color(0xFFe5dac2), danger: Color(0xFFc0392b),
    dangerDark: Color(0xFF962a1f), textDark: Color(0xFF0b4d2c),
    textLight: Color(0xFFfdfbf7)),
  AppTheme(id: 'blue', name: 'أزرق داكن',
    primaryDark: Color(0xFF1a3a6b), primaryDarker: Color(0xFF0d2444),
    primaryLight: Color(0xFF2a5298), gold: Color(0xFFc5a059),
    goldLight: Color(0xFFd6e4f0), cream: Color(0xFFf5f8fc),
    bgOuter: Color(0xFFb8cfe0), danger: Color(0xFFc0392b),
    dangerDark: Color(0xFF962a1f), textDark: Color(0xFF1a3a6b),
    textLight: Color(0xFFf5f8fc)),
  AppTheme(id: 'purple', name: 'بنفسجي',
    primaryDark: Color(0xFF4a1a6b), primaryDarker: Color(0xFF2d0d44),
    primaryLight: Color(0xFF6b2a98), gold: Color(0xFFd4af37),
    goldLight: Color(0xFFe8d5f0), cream: Color(0xFFfaf5fc),
    bgOuter: Color(0xFFd0b8e0), danger: Color(0xFFc0392b),
    dangerDark: Color(0xFF962a1f), textDark: Color(0xFF4a1a6b),
    textLight: Color(0xFFfaf5fc)),
  AppTheme(id: 'red', name: 'أحمر غامق',
    primaryDark: Color(0xFF6b1a1a), primaryDarker: Color(0xFF440d0d),
    primaryLight: Color(0xFF982a2a), gold: Color(0xFFd4af37),
    goldLight: Color(0xFFf0d5d5), cream: Color(0xFFfcf5f5),
    bgOuter: Color(0xFFe0b8b8), danger: Color(0xFFc0392b),
    dangerDark: Color(0xFF962a1f), textDark: Color(0xFF6b1a1a),
    textLight: Color(0xFFfcf5f5)),
  AppTheme(id: 'black', name: 'أسود وذهبي',
    primaryDark: Color(0xFF1a1a1a), primaryDarker: Color(0xFF000000),
    primaryLight: Color(0xFF333333), gold: Color(0xFFd4af37),
    goldLight: Color(0xFFf0e6c8), cream: Color(0xFFf5f5f0),
    bgOuter: Color(0xFFd4c8a8), danger: Color(0xFFc0392b),
    dangerDark: Color(0xFF962a1f), textDark: Color(0xFF1a1a1a),
    textLight: Color(0xFFf5f5f0)),
  AppTheme(id: 'brown', name: 'بني داكن',
    primaryDark: Color(0xFF5c3a1e), primaryDarker: Color(0xFF3d2412),
    primaryLight: Color(0xFF7a4e2a), gold: Color(0xFFc5a059),
    goldLight: Color(0xFFe8d5b8), cream: Color(0xFFfaf5ee),
    bgOuter: Color(0xFFd8c0a0), danger: Color(0xFFc0392b),
    dangerDark: Color(0xFF962a1f), textDark: Color(0xFF5c3a1e),
    textLight: Color(0xFFfaf5ee)),
  AppTheme(id: 'pink', name: 'وردي هادئ',
    primaryDark: Color(0xFF8b5a6b), primaryDarker: Color(0xFF6b4250),
    primaryLight: Color(0xFFa87a8a), gold: Color(0xFFc9a86b),
    goldLight: Color(0xFFf5e6ec), cream: Color(0xFFfdf7f9),
    bgOuter: Color(0xFFe8d0d8), danger: Color(0xFFc0392b),
    dangerDark: Color(0xFF962a1f), textDark: Color(0xFF8b5a6b),
    textLight: Color(0xFFfdf7f9)),
  AppTheme(id: 'turquoise', name: 'فيروزي هادئ',
    primaryDark: Color(0xFF2a7a7a), primaryDarker: Color(0xFF1a5555),
    primaryLight: Color(0xFF3a9999), gold: Color(0xFFc9a86b),
    goldLight: Color(0xFFd8f0f0), cream: Color(0xFFf5fcfc),
    bgOuter: Color(0xFFb8e0e0), danger: Color(0xFFc0392b),
    dangerDark: Color(0xFF962a1f), textDark: Color(0xFF2a7a7a),
    textLight: Color(0xFFf5fcfc)),
  AppTheme(id: 'sage', name: 'زيتي فاتح',
    primaryDark: Color(0xFF5a7a5a), primaryDarker: Color(0xFF3d5a3d),
    primaryLight: Color(0xFF7a9a7a), gold: Color(0xFFb8a878),
    goldLight: Color(0xFFe6f0e6), cream: Color(0xFFf7faf7),
    bgOuter: Color(0xFFc8d8c8), danger: Color(0xFFc0392b),
    dangerDark: Color(0xFF962a1f), textDark: Color(0xFF5a7a5a),
    textLight: Color(0xFFf7faf7)),
  AppTheme(id: 'midnight', name: 'أزرق ليلي هادئ',
    primaryDark: Color(0xFF2a3a5a), primaryDarker: Color(0xFF1a2540),
    primaryLight: Color(0xFF3a4a6a), gold: Color(0xFFb8b8c8),
    goldLight: Color(0xFFd8dce8), cream: Color(0xFFf5f7fa),
    bgOuter: Color(0xFFc0c8d8), danger: Color(0xFFc0392b),
    dangerDark: Color(0xFF962a1f), textDark: Color(0xFF2a3a5a),
    textLight: Color(0xFFf5f7fa)),
  AppTheme(id: 'cappuccino', name: 'كابتشينو',
    primaryDark: Color(0xFF8a6a4a), primaryDarker: Color(0xFF6b4e35),
    primaryLight: Color(0xFFa88a6a), gold: Color(0xFFc9b88b),
    goldLight: Color(0xFFf0e6d8), cream: Color(0xFFfdf8f0),
    bgOuter: Color(0xFFe0d0b8), danger: Color(0xFFc0392b),
    dangerDark: Color(0xFF962a1f), textDark: Color(0xFF8a6a4a),
    textLight: Color(0xFFfdf8f0)),
  AppTheme(id: 'burgundy', name: 'عنابي هادئ',
    primaryDark: Color(0xFF7a2a3a), primaryDarker: Color(0xFF5a1a2a),
    primaryLight: Color(0xFF9a3a4a), gold: Color(0xFFc9a86b),
    goldLight: Color(0xFFf0d8dc), cream: Color(0xFFfdf5f7),
    bgOuter: Color(0xFFd8b8c0), danger: Color(0xFFc0392b),
    dangerDark: Color(0xFF962a1f), textDark: Color(0xFF7a2a3a),
    textLight: Color(0xFFfdf5f7)),
];

const Map<String, String> kCurrencyLabels = {
  'SDG': 'جنيه سوداني', 'AED': 'درهم إماراتي', 'USD': 'دولار أمريكي',
  'SAR': 'ريال سعودي', 'QAR': 'ريال قطري', 'EUR': 'يورو أوروبي',
  'GBP': 'جنيه إسترليني', 'TRY': 'ليرة تركي', 'LYD': 'دينار ليبي',
  'TND': 'دينار تونسي', 'DZD': 'دينار جزائري', 'MAD': 'درهم مغربي',
  'RUB': 'روبل روسي', 'CNY': 'يوان صيني', 'XAU': 'أوقية ذهب',
  'XAG': 'أوقية فضة', 'OIL': 'برميل بترول',
  'BHD': 'دينار بحريني', 'KWD': 'دينار كويتي', 'OMR': 'ريال عماني',
  'JOD': 'دينار أردني', 'EGP': 'جنيه مصري', 'CAD': 'دولار كندي',
  'AUD': 'دولار أسترالي', 'CHF': 'فرنك سويسري', 'JPY': 'ين ياباني',
  'INR': 'روبيه هندية', 'SEK': 'كرونة سويدية', 'NOK': 'كرونة نرويجية',
  'DKK': 'كرونة دانماركية', 'MYR': 'رينغيت ماليزي', 'SGD': 'دولار سنغافوري',
};

const Map<String, String> kCurrencyFlags = {
  'SDG': '🇸🇩', 'AED': '🇦🇪', 'USD': '🇺🇸', 'SAR': '🇸🇦', 'QAR': '🇶🇦',
  'EUR': '🇪🇺', 'GBP': '🇬🇧', 'TRY': '🇹🇷', 'LYD': '🇱🇾', 'TND': '🇹🇳',
  'DZD': '🇩🇿', 'MAD': '🇲🇦', 'RUB': '🇷🇺', 'CNY': '🇨🇳',
  'XAU': '🥇', 'XAG': '🥈', 'OIL': '🛢️',
  'BHD': '🇧🇭', 'KWD': '🇰🇼', 'OMR': '🇴🇲', 'JOD': '🇯🇴', 'EGP': '🇪🇬',
  'CAD': '🇨🇦', 'AUD': '🇦🇺', 'CHF': '🇨🇭', 'JPY': '🇯🇵', 'INR': '🇮🇳',
  'SEK': '🇸🇪', 'NOK': '🇳🇴', 'DKK': '🇩🇰', 'MYR': '🇲🇾', 'SGD': '🇸🇬',
};
