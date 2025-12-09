class ApiConstants {
  // Use 10.0.2.2 for Android Emulator to access localhost
  // Use your machine's IP if testing on a real device
  static const String baseUrl = "http://10.0.2.2:8080";
  static const String authRegister = "$baseUrl/auth/register";
  static const String documentTypes = "$baseUrl/api/document-types";
  static const String localities = "$baseUrl/api/localities";
  static const String neighborhoods = "$baseUrl/api/neighborhoods";
}
