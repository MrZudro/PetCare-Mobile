class RegisterRequest {
  final String names;
  final String lastNames;
  final String documentNumber;
  final String email;
  final String password;
  final String birthDate; // YYYY-MM-DD
  final String address;
  final String phone;
  final String? profilePhotoUrl;
  final int documentTypeId;
  final int? neighborhoodId;
  final String role;

  RegisterRequest({
    required this.names,
    required this.lastNames,
    required this.documentNumber,
    required this.email,
    required this.password,
    required this.birthDate,
    required this.address,
    required this.phone,
    this.profilePhotoUrl,
    required this.documentTypeId,
    this.neighborhoodId,
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
      "address": address,
      "phone": phone,
      "profilePhotoUrl": profilePhotoUrl,
      "documentTypeId": documentTypeId,
      "neighborhoodId": neighborhoodId,
      "role": role,
    };
  }
}
