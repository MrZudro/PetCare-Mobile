import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:petcare/services/storage_service.dart';
import 'package:petcare/core/api_constants.dart';

class WishlistService {
  final StorageService _storageService = StorageService();

  // Get user's wishlist
  Future<List<Map<String, dynamic>>> getUserWishlist() async {
    try {
      final token = await _storageService.getToken();
      final userId = await _storageService.getUserId();

      if (token == null || userId == null) {
        throw Exception('No token or user ID found');
      }

      final response = await http.get(
        Uri.parse(ApiConstants.wishlistByUserId(userId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load wishlist: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching wishlist: $e');
      return [];
    }
  }

  // Add product to wishlist
  Future<bool> addToWishlist(int productId) async {
    try {
      final token = await _storageService.getToken();
      final userId = await _storageService.getUserId();

      if (token == null || userId == null) {
        throw Exception('No token or user ID found');
      }

      final response = await http.post(
        Uri.parse(ApiConstants.wishlists),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userId': userId, 'productId': productId}),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error adding to wishlist: $e');
      return false;
    }
  }

  // Remove product from wishlist
  Future<bool> removeFromWishlist(int wishlistId) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.delete(
        Uri.parse('${ApiConstants.wishlists}/$wishlistId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
      return false;
    }
  }

  // Get wishlist count
  Future<int> getWishlistCount() async {
    try {
      final wishlist = await getUserWishlist();
      return wishlist.length;
    } catch (e) {
      debugPrint('Error getting wishlist count: $e');
      return 0;
    }
  }
}
