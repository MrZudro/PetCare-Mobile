import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserData = 'user_data';

  Future<void> saveAuthData({
    required String token,
    String? refreshToken,
    required int userId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      if (refreshToken != null) {
        await prefs.setString(_keyRefreshToken, refreshToken);
      }
      await prefs.setInt(_keyUserId, userId);
      await prefs.setString(_keyUserData, jsonEncode(userData));
    } catch (e) {
      debugPrint('Error saving auth data: $e');
      rethrow; // Re-throw because auth data is critical
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyToken);
    } catch (e) {
      debugPrint('Error getting token: $e');
      return null;
    }
  }

  Future<int?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyUserId);
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_keyUserData);
      if (userDataString != null) {
        return jsonDecode(userDataString);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyRefreshToken);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserData);
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
      // Don't rethrow - clearing is best effort
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyRefreshToken);
    } catch (e) {
      debugPrint('Error getting refresh token: $e');
      return null;
    }
  }

  Future<void> updateToken(String newToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, newToken);
    } catch (e) {
      debugPrint('Error updating token: $e');
      rethrow; // Re-throw because token update is critical
    }
  }
}
