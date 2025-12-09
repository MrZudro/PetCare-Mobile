import 'dart:io';

class ApiConstants {
  // Use 10.0.2.2 for Android Emulator to access localhost
  // Use your machine's IP if testing on a real device
  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8080";
    } else {
      return "http://localhost:8080";
    }
  }

  static String get authRegister => "$baseUrl/auth/register";
  static String get authLogin => "$baseUrl/auth/login";
  static String get authRefresh => "$baseUrl/auth/refresh";
  static String get documentTypes => "$baseUrl/api/document-types";
  static String get localities => "$baseUrl/api/localities";
  static String get neighborhoods => "$baseUrl/api/neighborhoods";
  static String get customers => "$baseUrl/customers";

  static String customerById(int id) => "$customers/$id";
}
