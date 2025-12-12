import 'package:flutter/material.dart';
import 'package:petcare/components/action_circle_button.dart';
import 'package:petcare/components/custom_settings_tile.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';
import 'package:petcare/core/page_transitions.dart';
import 'package:petcare/models/user_model.dart';
import 'package:petcare/pages/auth.dart';
import 'package:petcare/pages/edit_profile_page.dart';
import 'package:petcare/pages/alerts_center_page.dart';
import 'package:petcare/pages/help_center_page.dart';
import 'package:petcare/components/custom_bottom_nav_bar.dart';
import 'package:petcare/services/user_service.dart';
import 'package:petcare/services/storage_service.dart';
import 'package:petcare/services/settings_service.dart';
import 'package:petcare/pages/language_settings_page.dart';
import 'package:petcare/pages/currency_settings_page.dart';
import 'package:petcare/pages/products_page.dart';
import 'package:petcare/pages/address_list_page.dart';
import 'package:petcare/pages/payment_method_list_page.dart';

class ConfigurationPage extends StatefulWidget {
  final UserModel? user;

  const ConfigurationPage({super.key, this.user});

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  UserModel? currentUser;
  bool isLoading = true;
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();
  final SettingsService _settingsService = SettingsService();

  String _currentLanguage = '';
  String _currentCurrency = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final language = await _settingsService.getLanguage();
    final currency = await _settingsService.getCurrency();
    if (mounted) {
      setState(() {
        _currentLanguage = language;
        _currentCurrency = currency;
      });
    }
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);

    if (widget.user != null) {
      setState(() {
        currentUser = widget.user;
        isLoading = false;
      });
      return;
    }

    // Check if user is logged in first
    final isLoggedIn = await _storageService.isLoggedIn();
    if (!isLoggedIn) {
      // User is not logged in, redirect to Auth page
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Auth()),
          (Route<dynamic> route) => false,
        );
      }
      return;
    }

    final user = await _userService.getCurrentUser();
    if (mounted) {
      setState(() {
        currentUser = user;
        isLoading = false;
      });

      // If still no user despite being "logged in", clear auth and redirect
      if (user == null) {
        _storageService.clearAuthData();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Auth()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  void _showDeactivateAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '¿Desactivar cuenta?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Esta acción desactivará tu cuenta permanentemente.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '• No podrás iniciar sesión\n• Tus datos se conservarán\n• Puedes reactivarla contactando a soporte',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.tertiary,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Close dialog
                Navigator.of(context).pop();

                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );

                // Deactivate account
                final success = await _userService.deactivateAccount(
                  currentUser!.id!,
                );

                // Close loading
                if (mounted) Navigator.of(context).pop();

                if (success) {
                  // Clear auth data
                  await _storageService.clearAuthData();

                  // Show success message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Cuenta desactivada exitosamente',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }

                  // Navigate to Auth page
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      PageTransitions.fade(const Auth()),
                      (Route<dynamic> route) => false,
                    );
                  }
                } else {
                  // Show error message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error al desactivar la cuenta. Intenta de nuevo.',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Desactivar',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: AppColors.error),
              SizedBox(width: 10),
              Text(
                '¿Cerrar sesión?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Si regresas, se cerrará tu sesión actual. ¿Estás seguro de que deseas continuar?',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.tertiary,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Close dialog
                Navigator.of(context).pop();
                // Clear auth data
                await _storageService.clearAuthData();
                // Navigate to Auth page and clear navigation stack
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Auth()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              SizedBox(height: 16),
              Text('Error al cargar datos del usuario'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Top Section (White)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    // Back Button - removed, navigation now through bottom nav bar

                    // Profile Info
                    const SizedBox(height: 10),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            currentUser!.profilePhotoUrl ??
                                'https://i.pravatar.cc/300',
                          ),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentUser!.fullName,
                      style: TextStyles.titleText.copyWith(
                        color: AppColors.primary,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Action Buttons
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ActionCircleButton(
                          icon: Icons.shopping_bag_outlined,
                          label: 'Historial de Compras',
                          onTap: () {},
                        ),
                        ActionCircleButton(
                          icon: Icons.notifications_none,
                          label: 'Centro de Alertas',
                          onTap: () {
                            Navigator.of(context).push(
                              PageTransitions.slideAndFade(
                                const AlertsCenterPage(),
                              ),
                            );
                          },
                        ),
                        ActionCircleButton(
                          icon: Icons.help_outline,
                          label: 'Centro de Ayuda',
                          onTap: () {
                            Navigator.of(context).push(
                              PageTransitions.slideAndFade(
                                const HelpCenterPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // Bottom Section (Light Blue)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ajustes',
                            style: TextStyles.titleText.copyWith(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 20),

                          CustomSettingsTile(
                            icon: Icons.person_outline,
                            title: 'Perfil',
                            subtitle: 'Edita tu información personal',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfilePage(user: currentUser!),
                                ),
                              ).then((_) => _loadUserData());
                            },
                          ),
                          CustomSettingsTile(
                            icon: Icons.location_on_outlined,
                            title: 'Gestionar Direcciones',
                            subtitle: 'Agrega o elimina tus direcciones',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddressListPage(),
                                ),
                              );
                            },
                          ),
                          CustomSettingsTile(
                            icon: Icons.credit_card_outlined,
                            title: 'Métodos de Pago',
                            subtitle: 'Gestiona tus tarjetas',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PaymentMethodListPage(),
                                ),
                              );
                            },
                          ),
                          CustomSettingsTile(
                            icon: Icons.language_rounded,
                            title: 'Idioma',
                            subtitle: _settingsService.getLanguageDisplayName(
                              _currentLanguage,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const LanguageSettingsPage(),
                                ),
                              ).then((_) => _loadSettings());
                            },
                          ),
                          CustomSettingsTile(
                            icon: Icons.payments_rounded,
                            title: 'Moneda',
                            subtitle: _settingsService.getCurrencyDisplayName(
                              _currentCurrency,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CurrencySettingsPage(),
                                ),
                              ).then((_) => _loadSettings());
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomSettingsTile(
                            icon: Icons.lock_outline_rounded,
                            title: 'Seguridad',
                            subtitle: 'Contraseña y privacidad',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfilePage(user: currentUser!),
                                ),
                              ).then((_) => _loadUserData());
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomSettingsTile(
                            icon: Icons.no_accounts_rounded,
                            title: 'Desactivar cuenta',
                            subtitle: 'Desactiva tu cuenta temporalmente',
                            isDanger: true,
                            onTap: () {
                              _showDeactivateAccountDialog(context);
                            },
                          ),
                          CustomSettingsTile(
                            icon: Icons.logout_rounded,
                            title: 'Cerrar sesión',
                            subtitle: 'Sal de tu cuenta',
                            onTap: () {
                              _showLogoutDialog(context);
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 4, // Settings is selected
          onTap: (index) {
            if (index == 0) {
              // Navigate back to Home/Start page clearly
              Navigator.of(context).popUntil((route) => route.isFirst);
            } else if (index == 1) {
              // Navigate to Products
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductsPage()),
              );
            }
          },
        ),
      ),
    );
  }
}
