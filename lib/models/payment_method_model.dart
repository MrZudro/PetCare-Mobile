class PaymentMethodModel {
  final int? id;
  final String tokenPaymentMethod;
  final String tokenClientGateway;
  final String brand;
  final int lastFourDigits;
  final String expirationDate;
  final bool isDefault;

  PaymentMethodModel({
    this.id,
    required this.tokenPaymentMethod,
    required this.tokenClientGateway,
    required this.brand,
    required this.lastFourDigits,
    required this.expirationDate,
    this.isDefault = false,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'],
      tokenPaymentMethod: json['tokenPaymentMethod'],
      tokenClientGateway: json['tokenClientGateway'],
      brand: json['brand'],
      lastFourDigits: json['lastFourDigits'],
      expirationDate: json['expirationDate'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tokenPaymentMethod': tokenPaymentMethod,
      'tokenClientGateway': tokenClientGateway,
      'brand': brand,
      'lastFourDigits': lastFourDigits,
      'expirationDate': expirationDate,
      'isDefault': isDefault,
    };
  }
}
