class ApiConstants {
  // Use 10.0.2.2 for Android Emulator to access localhost
  // Use your machine's IP if testing on a real device
  static const String baseUrl = "http://10.0.2.2:8080";
  static const String authRegister = "$baseUrl/auth/register";
  static const String authLogin = "$baseUrl/auth/login";
  static const String authRefresh = "$baseUrl/auth/refresh";
  static const String documentTypes = "$baseUrl/api/document-types";
  static const String localities = "$baseUrl/api/localities";
  static const String neighborhoods = "$baseUrl/api/neighborhoods";
  static const String customers = "$baseUrl/customers";

  static String customerById(int id) => "$customers/$id";
}
