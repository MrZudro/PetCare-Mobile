import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:petcare/core/api_constants.dart';
import 'package:petcare/services/storage_service.dart';

class AddressService {
  final StorageService _storageService = StorageService();

  Future<bool> createAddress(
    int customerId,
    Map<String, dynamic> addressData,
  ) async {
    try {
      final token = await _storageService.getToken();
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/customers/$customerId/addresses"),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode(addressData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        debugPrint(
          "Error creating address: ${response.statusCode} - ${response.body}",
        );
        return false;
      }
    } catch (e) {
      debugPrint("Exception creating address: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAddresses(int customerId) async {
    try {
      final token = await _storageService.getToken();
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/customers/$customerId/addresses"),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        debugPrint("Error fetching addresses: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Exception fetching addresses: $e");
      return [];
    }
  }
}
