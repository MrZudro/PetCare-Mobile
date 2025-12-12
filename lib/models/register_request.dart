// Increible, tambien se pueden hacer DTOs aqui

class RegisterRequest {
  final String names;
  final String lastNames;
  final String documentNumber;
  final String email;
  final String password;
  final String birthDate; // YYYY-MM-DD
  final String phone;
  final String? profilePhotoUrl;
  final int documentTypeId;
  final String role;

  RegisterRequest({
    required this.names,
    required this.lastNames,
    required this.documentNumber,
    required this.email,
    required this.password,
    required this.birthDate,
    required this.phone,
    this.profilePhotoUrl,
    required this.documentTypeId,
    this.role = "CUSTOMER",
  });

  Map<String, dynamic> toJson() {
    return {
      "names": names,
      "lastNames": lastNames,
      "documentNumber": documentNumber,
      "email": email,
      "password": password,
      "birthDate": birthDate,
      "phone": phone,
      "profilePhotoUrl": profilePhotoUrl,
      "documentTypeId": documentTypeId,
      "role": role,
    };
  }
}
