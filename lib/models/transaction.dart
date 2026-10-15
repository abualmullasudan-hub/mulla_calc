class Transaction {
  String id;
  String invoiceNo;
  String type;
  String customerId;
  String customerName;
  String currencyCode;
  double amount;
  double rate;
  double totalSDG;
  String note;
  DateTime date;

  Transaction({
    required this.id,
    required this.invoiceNo,
    required this.type,
    required this.customerId,
    required this.customerName,
    required this.currencyCode,
    required this.amount,
    required this.rate,
    required this.totalSDG,
    this.note = '',
    required this.date,
  });

  bool get isBuy => type == 'buy';

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNo': invoiceNo,
        'type': type,
        'customerId': customerId,
        'customerName': customerName,
        'currencyCode': currencyCode,
        'amount': amount,
        'rate': rate,
        'totalSDG': totalSDG,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        invoiceNo: json['invoiceNo'],
        type: json['type'],
        customerId: json['customerId'],
        customerName: json['customerName'],
        currencyCode: json['currencyCode'],
        amount: (json['amount'] as num).toDouble(),
        rate: (json['rate'] as num).toDouble(),
        totalSDG: (json['totalSDG'] as num).toDouble(),
        note: json['note'] ?? '',
        date: DateTime.parse(json['date']),
      );
}
