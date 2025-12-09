import 'package:flutter/material.dart';
import 'package:petcare/components/action_circle_button.dart';
import 'package:petcare/components/custom_settings_tile.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';
import 'package:petcare/models/user_model.dart';
import 'package:petcare/pages/auth.dart';
import 'package:petcare/pages/edit_profile_page.dart';
import 'package:petcare/components/custom_bottom_nav_bar.dart';

class ConfigurationPage extends StatefulWidget {
  final UserModel? user;

  const ConfigurationPage({super.key, this.user});

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  late UserModel currentUser;

  @override
  void initState() {
    super.initState();
    // Default user data from the design if none provided
    currentUser =
        widget.user ??
        UserModel(
          id: 1,
          names: 'Manuel',
          lastNames: 'Quiazua',
          email: 'yatusae@gmail.com',
          phone: '',
          profilePhotoUrl: 'https://i.pravatar.cc/300', // Placeholder
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
              onPressed: () {
                // Close dialog
                Navigator.of(context).pop();
                // Navigate to Auth page and clear navigation stack
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Auth()),
                  (Route<dynamic> route) => false,
                );
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
                            currentUser.profilePhotoUrl ??
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
                      currentUser.fullName,
                      style: TextStyles.titleText.copyWith(
                        color: AppColors.primary,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      currentUser.email,
                      style: TextStyles.bodyTextBlack.copyWith(
                        color: AppColors.tertiary, // Purple color
                        fontSize: 16,
                      ),
                    ),

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
                          onTap: () {},
                        ),
                        ActionCircleButton(
                          icon: Icons.help_outline,
                          label: 'Centro de Ayuda',
                          onTap: () {},
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
                            icon: Icons.phone_android,
                            iconColor: AppColors.tertiary,
                            title: 'Numero de telefono',
                            trailing: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Añadir',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ),
                            showArrow: false,
                          ),
                          CustomSettingsTile(
                            icon: Icons.language,
                            iconColor: AppColors.tertiary,
                            title: 'Lenguaje',
                            value: 'Español (spa)',
                            onTap: () {},
                            showArrow: false,
                          ),
                          CustomSettingsTile(
                            icon: Icons.attach_money,
                            iconColor: AppColors.tertiary,
                            title: 'Moneda',
                            value: 'COP Pesos (\$)',
                            onTap: () {},
                            showArrow: false,
                          ),
                          const SizedBox(height: 10),
                          CustomSettingsTile(
                            icon: Icons.edit,
                            iconColor: AppColors.tertiary,
                            title: 'Ajustes de perfil',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfilePage(user: currentUser),
                                ),
                              );
                            },
                          ),
                          CustomSettingsTile(
                            icon: Icons.delete_outline,
                            iconColor: AppColors.tertiary,
                            title: 'Desactivar cuenta',
                            onTap: () {
                              // Logic for account deactivation
                            },
                          ),
                          CustomSettingsTile(
                            icon: Icons.logout,
                            iconColor: AppColors.tertiary,
                            title: 'Cerrar sesion',
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
              // Navigate back to Home/Start page
              Navigator.of(context).pop();
            }
            // Other navigation items can be implemented later
          },
        ),
      ),
    );
  }
}
