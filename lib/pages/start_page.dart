import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petcare/components/custom_bottom_nav_bar.dart';
import 'package:petcare/pages/configuration_page.dart';
import 'package:petcare/pages/auth.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

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
        _showLogoutDialog(context);
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false, // Remove back button
          title: Text(
            'PetCare',
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w800,
              fontSize: 24,
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.account_circle_outlined,
                color: AppColors.primary,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.tertiary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenido! 🐾',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Cuida a tus mascotas con amor',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // Quick Actions Section
                Text(
                  'Acciones rápidas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 15),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  children: [
                    _buildQuickActionCard(
                      icon: FontAwesomeIcons.paw,
                      title: 'Mis Mascotas',
                      color: AppColors.secondary,
                      onTap: () {},
                    ),
                    _buildQuickActionCard(
                      icon: FontAwesomeIcons.calendarCheck,
                      title: 'Citas',
                      color: AppColors.primary,
                      onTap: () {},
                    ),
                    _buildQuickActionCard(
                      icon: FontAwesomeIcons.shoppingCart,
                      title: 'Productos',
                      color: AppColors.tertiary,
                      onTap: () {},
                    ),
                    _buildQuickActionCard(
                      icon: FontAwesomeIcons.userDoctor,
                      title: 'Servicios',
                      color: AppColors.success,
                      onTap: () {},
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // Recent Activity Section
                Text(
                  'Actividad reciente',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 15),
                _buildActivityCard(
                  icon: FontAwesomeIcons.circleCheck,
                  title: 'Cuenta creada exitosamente',
                  subtitle:
                      'Ahora puedes disfrutar de todos nuestros servicios',
                  color: AppColors.success,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 0, // Home is selected
          onTap: (index) {
            if (index == 4) {
              // Navigate to Configuration page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConfigurationPage()),
              );
            }
            // Other navigation items can be implemented later
          },
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 40, color: color),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(icon, color: color, size: 24),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: AppColors.primaryText.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
