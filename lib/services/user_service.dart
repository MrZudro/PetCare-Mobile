import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:petcare/core/api_constants.dart';
import 'package:petcare/models/user_model.dart';
import 'package:petcare/services/storage_service.dart';
import 'package:petcare/services/auth_service.dart';

class UserService {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();

  Future<UserModel?> getCurrentUser() async {
    try {
      final userId = await _storageService.getUserId();
      var token = await _storageService.getToken();

      if (userId == null || token == null) {
        debugPrint('No user ID or token found');
        return null;
      }

      var response = await http.get(
        Uri.parse(ApiConstants.customerById(userId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // If 401, try to refresh token
      if (response.statusCode == 401) {
        debugPrint('Access token expired, attempting refresh...');
        final newToken = await _refreshTokenIfNeeded();

        if (newToken != null) {
          // Retry with new token
          response = await http.get(
            Uri.parse(ApiConstants.customerById(userId)),
            headers: {
              'Authorization': 'Bearer $newToken',
              'Content-Type': 'application/json',
            },
          );
        } else {
          debugPrint('Refresh token failed or expired');
          return null;
        }
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Get profile photo from stored auth data
        final userData = await _storageService.getUserData();
        if (userData != null && userData['profilePhotoUrl'] != null) {
          data['profilePhotoUrl'] = userData['profilePhotoUrl'];
        }

        return UserModel.fromJson(data);
      } else {
        debugPrint('Failed to fetch user: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching current user: $e');
      return null;
    }
  }

  Future<String?> _refreshTokenIfNeeded() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) {
        debugPrint('No refresh token available');
        return null;
      }

      final newToken = await _authService.refreshAccessToken(refreshToken);
      if (newToken != null) {
        await _storageService.updateToken(newToken);
        debugPrint('Token refreshed successfully');
      }
      return newToken;
    } catch (e) {
      debugPrint('Error during token refresh: $e');
      return null;
    }
  }

  Future<bool> updateUser(int userId, Map<String, dynamic> updateData) async {
    try {
      final token = await _storageService.getToken();

      if (token == null) {
        debugPrint('No token found');
        return false;
      }

      final response = await http.put(
        Uri.parse(ApiConstants.customerById(userId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        debugPrint('User updated successfully');
        return true;
      } else {
        debugPrint('Failed to update user: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }
}
