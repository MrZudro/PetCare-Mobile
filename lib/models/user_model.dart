class UserModel {
  final int? id;
  final String names;
  final String lastNames;
  final String email;
  final String phone;
  final String? profilePhotoUrl;
  final String? documentNumber;
  final String? birthDate; // Changed to String to match API format (YYYY-MM-DD)
  final int? documentTypeId;

  UserModel({
    this.id,
    required this.names,
    required this.lastNames,
    required this.email,
    required this.phone,
    this.profilePhotoUrl,
    this.documentNumber,
    this.birthDate,
    this.documentTypeId,
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
      birthDate: json['birthDate'],
      documentTypeId: json['documentTypeId'],
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
      'birthDate': birthDate,
      'documentTypeId': documentTypeId,
    };
  }

  // Helper getters
  String get fullName => '$names $lastNames';
}
