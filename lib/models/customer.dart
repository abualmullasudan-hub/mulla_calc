class Customer {
  String id;
  String name;
  String phone;
  String note;
  double balance;
  DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    this.phone = '',
    this.note = '',
    this.balance = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'note': note,
        'balance': balance,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'],
        name: json['name'],
        phone: json['phone'] ?? '',
        note: json['note'] ?? '',
        balance: (json['balance'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt']),
      );
}
