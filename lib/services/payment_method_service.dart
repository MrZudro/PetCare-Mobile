import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../core/api_constants.dart';
import '../models/payment_method_model.dart';
import 'storage_service.dart';

class PaymentMethodService {
  final StorageService _storageService = StorageService();

  // Assuming endpoint
  String get _paymentUrl => "${ApiConstants.baseUrl}/api/payment-methods";

  Future<List<PaymentMethodModel>> getUserPaymentMethods() async {
    try {
      final token = await _storageService.getToken();
      final userId = await _storageService.getUserId();
      if (token == null || userId == null) return [];

      final response = await http.get(
        Uri.parse("$_paymentUrl/user/$userId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => PaymentMethodModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching payment methods: $e");
      return [];
    }
  }

  Future<bool> addPaymentMethod(PaymentMethodModel method) async {
    try {
      final token = await _storageService.getToken();
      final userId = await _storageService.getUserId();
      if (token == null || userId == null) return false;

      final body = method.toJson();
      body['user'] = {'id': userId};

      final response = await http.post(
        Uri.parse(_paymentUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Error adding payment method: $e");
      return false;
    }
  }

  Future<bool> deletePaymentMethod(int id) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse("$_paymentUrl/$id"),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("Error deleting payment method: $e");
      return false;
    }
  }
}
