import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';
import 'package:petcare/services/settings_service.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  final SettingsService _settingsService = SettingsService();
  String _selectedLanguage = SettingsService.languageSpanish;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final language = await _settingsService.getLanguage();
    setState(() {
      _selectedLanguage = language;
      _isLoading = false;
    });
  }

  Future<void> _changeLanguage(String language) async {
    await _settingsService.setLanguage(language);
    setState(() {
      _selectedLanguage = language;
    });
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Idioma actualizado')));
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
        title: const Text('Seleccionar Idioma', style: TextStyles.titleText),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLanguageOption(
            code: SettingsService.languageSpanish,
            name: 'Español',
            subtitle: 'Spanish',
            icon: '🇪🇸',
          ),
          const SizedBox(height: 12),
          _buildLanguageOption(
            code: SettingsService.languageEnglish,
            name: 'English',
            subtitle: 'Inglés',
            icon: '🇺🇸',
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String code,
    required String name,
    required String subtitle,
    required String icon,
  }) {
    final isSelected = _selectedLanguage == code;

    return InkWell(
      onTap: () => _changeLanguage(code),
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
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: isSelected ? AppColors.primary : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
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
