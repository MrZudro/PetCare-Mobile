import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:petcare/services/storage_service.dart';
import 'package:petcare/core/api_constants.dart';

class ProductService {
  final StorageService _storageService = StorageService();

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.get(
        Uri.parse(ApiConstants.products),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getFeaturedProducts({
    int limit = 10,
  }) async {
    try {
      final products = await getAllProducts();

      debugPrint('Total products fetched: ${products.length}');

      if (products.isEmpty) {
        debugPrint('No products available');
        return [];
      }

      // Log first product to see structure
      if (products.isNotEmpty) {
        debugPrint('Sample product isActive value: ${products[0]['isActive']}');
        debugPrint(
          'Sample product isActive type: ${products[0]['isActive'].runtimeType}',
        );
      }

      // Filter active products - handle both string and object formats
      final activeProducts = products.where((p) {
        final isActive = p['isActive'];
        // Handle different formats: "ACTIVE", {"name": "ACTIVE"}, etc.
        if (isActive is String) {
          return isActive == 'ACTIVE';
        } else if (isActive is Map) {
          return isActive['name'] == 'ACTIVE' || isActive['status'] == 'ACTIVE';
        }
        return true; // If format unknown, include it
      }).toList();

      debugPrint('Active products after filter: ${activeProducts.length}');

      // If no active products, use all products
      final productsToUse = activeProducts.isEmpty ? products : activeProducts;

      // Sort by wishlist count (most popular first)
      productsToUse.sort((a, b) {
        final wishlistsA = (a['wishlists'] as List?)?.length ?? 0;
        final wishlistsB = (b['wishlists'] as List?)?.length ?? 0;

        // If both have 0 wishlists, maintain original order
        if (wishlistsA == 0 && wishlistsB == 0) return 0;

        return wishlistsB.compareTo(wishlistsA);
      });

      // Check if any product has wishlists
      final hasWishlists = productsToUse.any(
        (p) => ((p['wishlists'] as List?)?.length ?? 0) > 0,
      );

      // If no products have wishlists, return first 7 products
      if (!hasWishlists) {
        debugPrint('No products in wishlists, returning first 7 products');
        final result = productsToUse.take(7).toList();
        debugPrint('Returning ${result.length} products');
        return result;
      }

      // Return products sorted by wishlist count
      debugPrint('Returning products sorted by wishlist count');
      final result = productsToUse.take(limit).toList();
      debugPrint('Returning ${result.length} products');
      return result;
    } catch (e) {
      debugPrint('Error fetching featured products: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProductById(int id) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.get(
        Uri.parse(ApiConstants.productById(id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching product: $e');
      return null;
    }
  }
}
