import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class ApiConstants {
  static String _baseUrl = "http://localhost:8080";

  static String get baseUrl => _baseUrl;

  static Future<void> init() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.isPhysicalDevice) {
        // Physical device via USB (requires 'adb reverse tcp:8080 tcp:8080')
        _baseUrl = "http://localhost:8080";
      } else {
        // Android Emulator
        _baseUrl = "http://10.0.2.2:8080";
      }
    } else {
      // Windows, iOS Simulator, etc.
      _baseUrl = "http://localhost:8080";
    }
  }

  static String get authRegister => "$baseUrl/auth/register";
  static String get authLogin => "$baseUrl/auth/login";
  static String get authRefresh => "$baseUrl/auth/refresh";
  static String get documentTypes => "$baseUrl/api/document-types";
  static String get localities => "$baseUrl/api/localities";
  static String get neighborhoods => "$baseUrl/api/neighborhoods";
  static String get customers => "$baseUrl/customers";

  // Products and Services endpoints (without /api prefix)
  static String get products => "$baseUrl/products";
  static String get services => "$baseUrl/services";

  // Wishlists endpoint (without /api prefix)
  static String get wishlists => "$baseUrl/wishlists";

  // Veterinary clinics (with /api prefix)
  static String get veterinaryClinics => "$baseUrl/api/veterinary-clinics";

  static String customerById(int id) => "$customers/$id";
  static String productById(int id) => "$products/$id";
  static String wishlistByUserId(int userId) => "$wishlists/user/$userId";
}
