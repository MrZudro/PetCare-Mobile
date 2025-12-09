class UserModel {
  final int? id;
  final String names;
  final String lastNames;
  final String email;
  final String phone;
  final String? profilePhotoUrl;
  final String? documentNumber;
  final String? address;

  UserModel({
    this.id,
    required this.names,
    required this.lastNames,
    required this.email,
    required this.phone,
    this.profilePhotoUrl,
    this.documentNumber,
    this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      names: json['names'] ?? '',
      lastNames: json['lastNames'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profilePhotoUrl: json['profilePhotoUrl'],
      documentNumber: json['documentNumber'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'names': names,
      'lastNames': lastNames,
      'email': email,
      'phone': phone,
      'profilePhotoUrl': profilePhotoUrl,
      'documentNumber': documentNumber,
      'address': address,
    };
  }

  // Helper getters
  String get fullName => '$names $lastNames';
}
