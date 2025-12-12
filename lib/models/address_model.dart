class AddressModel {
  final int? id;
  final String addressLine;
  final String? additionalInfo;
  final String? deliveryNotes;
  final String addressType; // 'HOME', 'WORK', etc.
  final bool isDefault;
  final bool isActive;
  final int neighborhoodId; // Assuming we send ID for linking
  // Optional: Full neighborhood object if needed for display
  final String? neighborhoodName;

  AddressModel({
    this.id,
    required this.addressLine,
    this.additionalInfo,
    this.deliveryNotes,
    required this.addressType,
    this.isDefault = false,
    this.isActive = true,
    required this.neighborhoodId,
    this.neighborhoodName,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      addressLine: json['addressLine'],
      additionalInfo: json['additionalInfo'],
      deliveryNotes: json['deliveryNotes'],
      addressType: json['addressType'] ?? 'HOME',
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
      neighborhoodId: json['neighborhood'] != null
          ? (json['neighborhood']['id'] ?? 0)
          : 0,
      neighborhoodName: json['neighborhood'] != null
          ? json['neighborhood']['name']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'addressLine': addressLine,
      'additionalInfo': additionalInfo,
      'deliveryNotes': deliveryNotes,
      'addressType': addressType,
      'isDefault': isDefault,
      'isActive': isActive,
      'neighborhood': {'id': neighborhoodId},
    };
  }
}
