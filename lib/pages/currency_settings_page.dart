import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';
import 'package:petcare/services/settings_service.dart';

class CurrencySettingsPage extends StatefulWidget {
  const CurrencySettingsPage({super.key});

  @override
  State<CurrencySettingsPage> createState() => _CurrencySettingsPageState();
}

class _CurrencySettingsPageState extends State<CurrencySettingsPage> {
  final SettingsService _settingsService = SettingsService();
  String _selectedCurrency = SettingsService.currencyCOP;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentCurrency();
  }

  Future<void> _loadCurrentCurrency() async {
    final currency = await _settingsService.getCurrency();
    setState(() {
      _selectedCurrency = currency;
      _isLoading = false;
    });
  }

  Future<void> _changeCurrency(String currency) async {
    await _settingsService.setCurrency(currency);
    setState(() {
      _selectedCurrency = currency;
    });
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Moneda actualizada')));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Seleccionar Moneda', style: TextStyles.titleText),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCurrencyOption(
            code: SettingsService.currencyCOP,
            name: 'Peso Colombiano',
            symbol: '\$',
            country: 'Colombia',
            icon: '🇨🇴',
          ),
          const SizedBox(height: 12),
          _buildCurrencyOption(
            code: SettingsService.currencyUSD,
            name: 'Dólar Estadounidense',
            symbol: '\$',
            country: 'Estados Unidos',
            icon: '🇺🇸',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyOption({
    required String code,
    required String name,
    required String symbol,
    required String country,
    required String icon,
  }) {
    final isSelected = _selectedCurrency == code;

    return InkWell(
      onTap: () => _changeCurrency(code),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentOne : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        code,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: isSelected ? AppColors.primary : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        symbol,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$name - $country',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 28),
          ],
        ),
      ),
    );
  }
}
