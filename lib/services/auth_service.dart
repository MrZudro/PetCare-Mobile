import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:petcare/core/api_constants.dart';
import 'package:petcare/models/register_request.dart';

class AuthService {
  Future<bool> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.authRegister),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint("Registration failed: ${response.statusCode}");
        debugPrint("Body: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error during registration: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchDocumentTypes() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.documentTypes));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Error fetching document types: $e");
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchLocalities() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.localities));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Error fetching localities: $e");
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchNeighborhoods() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.neighborhoods));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Error fetching neighborhoods: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.authLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Login failed: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      return null;
    }
  }

  Future<String?> refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.authRefresh),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        debugPrint('Token refresh failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return null;
    }
  }
}
