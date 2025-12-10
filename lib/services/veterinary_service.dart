import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:petcare/services/storage_service.dart';
import 'package:petcare/core/api_constants.dart';

class VeterinaryService {
  final StorageService _storageService = StorageService();

  // Get all services
  Future<List<Map<String, dynamic>>> getAllServices() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.get(
        Uri.parse(ApiConstants.services),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
      return [];
    }
  }

  // Get active services
  Future<List<Map<String, dynamic>>> getActiveServices({int limit = 6}) async {
    try {
      final services = await getAllServices();
      final activeServices = services
          .where((s) => s['status'] == 'ACTIVE')
          .take(limit)
          .toList();
      return activeServices;
    } catch (e) {
      debugPrint('Error fetching active services: $e');
      return [];
    }
  }

  // Get all veterinary clinics
  Future<List<Map<String, dynamic>>> getAllClinics() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.get(
        Uri.parse(ApiConstants.veterinaryClinics),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load clinics: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching clinics: $e');
      return [];
    }
  }

  // Get top rated clinics
  Future<List<Map<String, dynamic>>> getTopRatedClinics({int limit = 5}) async {
    try {
      final clinics = await getAllClinics();
      // Sort by rating (puntuacion) descending
      clinics.sort((a, b) {
        final ratingA = (a['puntuacion'] as num?)?.toDouble() ?? 0.0;
        final ratingB = (b['puntuacion'] as num?)?.toDouble() ?? 0.0;
        return ratingB.compareTo(ratingA);
      });
      return clinics.take(limit).toList();
    } catch (e) {
      debugPrint('Error fetching top rated clinics: $e');
      return [];
    }
  }
}
