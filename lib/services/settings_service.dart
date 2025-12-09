import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyLanguage = 'app_language';
  static const String _keyCurrency = 'app_currency';

  // Language options
  static const String languageSpanish = 'es';
  static const String languageEnglish = 'en';

  // Currency options
  static const String currencyCOP = 'COP';
  static const String currencyUSD = 'USD';

  Future<void> setLanguage(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLanguage, language);
    } catch (e) {
      debugPrint('Error saving language: $e');
      // Silently fail - user can try again
    }
  }

  Future<String> getLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyLanguage) ?? languageSpanish;
    } catch (e) {
      debugPrint('Error getting language: $e');
      return languageSpanish; // Return default
    }
  }

  Future<void> setCurrency(String currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCurrency, currency);
    } catch (e) {
      debugPrint('Error saving currency: $e');
      // Silently fail - user can try again
    }
  }

  Future<String> getCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyCurrency) ?? currencyCOP;
    } catch (e) {
      debugPrint('Error getting currency: $e');
      return currencyCOP; // Return default
    }
  }

  String getLanguageDisplayName(String code) {
    switch (code) {
      case languageSpanish:
        return 'Español (spa)';
      case languageEnglish:
        return 'English (eng)';
      default:
        return 'Español (spa)';
    }
  }

  String getCurrencyDisplayName(String code) {
    switch (code) {
      case currencyCOP:
        return 'COP Pesos (\$)';
      case currencyUSD:
        return 'USD Dólares (\$)';
      default:
        return 'COP Pesos (\$)';
    }
  }
}
