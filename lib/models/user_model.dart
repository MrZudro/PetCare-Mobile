class UserModel {
  final int? id;
  final String names;
  final String lastNames;
  final String email;
  final String phone;
  final String? profilePhotoUrl;
  final String? documentNumber;
  final String? address;
  final String? birthDate; // Changed to String to match API format (YYYY-MM-DD)
  final int? documentTypeId;
  final int? neighborhoodId;

  UserModel({
    this.id,
    required this.names,
    required this.lastNames,
    required this.email,
    required this.phone,
    this.profilePhotoUrl,
    this.documentNumber,
    this.address,
    this.birthDate,
    this.documentTypeId,
    this.neighborhoodId,
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
      birthDate: json['birthDate'],
      documentTypeId: json['documentTypeId'],
      neighborhoodId: json['neighborhoodId'],
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
      'birthDate': birthDate,
      'documentTypeId': documentTypeId,
      'neighborhoodId': neighborhoodId,
    };
  }

  // Helper getters
  String get fullName => '$names $lastNames';
}
