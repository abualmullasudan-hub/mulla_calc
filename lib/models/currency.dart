class Currency {
  String code;
  String name;
  String flag;
  double buyRate;
  double sellRate;
  bool active;

  Currency({
    required this.code,
    required this.name,
    required this.flag,
    required this.buyRate,
    required this.sellRate,
    this.active = false,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'flag': flag,
        'buyRate': buyRate,
        'sellRate': sellRate,
        'active': active,
      };

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        code: json['code'],
        name: json['name'],
        flag: json['flag'],
        buyRate: (json['buyRate'] as num).toDouble(),
        sellRate: (json['sellRate'] as num).toDouble(),
        active: json['active'] ?? false,
      );
}
