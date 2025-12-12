import 'package:flutter/material.dart';
import '../core/color_theme.dart';
import '../core/text_styles.dart';
import 'cart_page.dart'; // Para la navegación

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Imagen Principal
              // Asegúrate de tener esta imagen en tu pubspec.yaml
              Image.asset(
                'assets/images/HomeImage.png', 
                height: 300,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              
              // Título
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'PetCare',
                  style: TextStyles.titleText.copyWith(
                    fontSize: 40, 
                    color: AppColors.secondary, // Pink
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              // Subtítulo
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Encuentra todo para tu mascota aquí',
                  style: TextStyles.bodyTextBlack.copyWith(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
              
              const Spacer(),

              // Botón de Acción
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const CartPage())
                  );
                },
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3E5FC), // Un azul muy claro (similar a la imagen)
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Vamos a explorar!',
                        style: TextStyles.bodyTextWhite.copyWith(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFFB3E5FC),
                          size: 20,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}