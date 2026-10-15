class AppSettings {
  String shopName;
  String phone;
  String address;
  String pin;
  bool pinEnabled;

  AppSettings({
    this.shopName = 'Mulla Exchange',
    this.phone = '0922008009',
    this.address = '',
    this.pin = '0000',
    this.pinEnabled = false,
  });

  Map<String, dynamic> toJson() => {
        'shopName': shopName,
        'phone': phone,
        'address': address,
        'pin': pin,
        'pinEnabled': pinEnabled,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        shopName: json['shopName'] ?? 'Mulla Exchange',
        phone: json['phone'] ?? '0922008009',
        address: json['address'] ?? '',
        pin: json['pin'] ?? '0000',
        pinEnabled: json['pinEnabled'] ?? false,
      );
}
