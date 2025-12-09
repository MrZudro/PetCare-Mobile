import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/components/textfield.dart';
import 'package:petcare/components/button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petcare/pages/registration.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  // Login Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Register Controllers
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController =
      TextEditingController();
  final TextEditingController registerConfirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 50, bottom: 20),
                child: Text(
                  "PetCare",
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 40,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              TabBar(
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                indicatorWeight: 5,
                unselectedLabelColor: AppColors.tertiary,
                dividerColor: Colors.transparent,
                labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                tabs: [
                  Tab(text: "Iniciar sesión"),
                  Tab(text: "Registrarse"),
                ],
              ),
              Expanded(child: TabBarView(children: [tabOne(), tabTwo()])),
            ],
          ),
        ),
      ),
    );
  }

  Widget tabOne() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 25, bottom: 40, left: 30),
              child: Text("Llenemos este formulario juntos..🐾"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 8,
              right: 20,
              left: 20,
            ),
            child: PersonalTextField(
              controller: emailController,
              prefixIcon: Icons.email,
              labelText: "Correo electrónico",
              hintText: "tucorreo@gmail.com",
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 8,
              right: 20,
              left: 20,
            ),
            child: PersonalTextField(
              controller: passwordController,
              labelText: "Contraseña",
              hintText: "",
              prefixIcon: Icons.lock,
              obscureText: true,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: PersonalButton(
              text: "Iniciar sesión",
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  print("Login Email: ${emailController.text}");
                  print("Login Password: ${passwordController.text}");
                }
              },
            ),
          ),
          PersonalTextButton(
            text: "¿Olvidaste tu contraseña?",
            onPressed: () {},
          ),
          const SizedBox(height: 20),
          Text("O ingresar con ..", style: TextStyle(fontFamily: "Poppins")),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: PersonalOutlineButton(
              text: "Continue con Google",
              icon: FontAwesomeIcons.google,
              onPressed: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: PersonalOutlineButton(
              text: "Continue con Apple",
              icon: FontAwesomeIcons.apple,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget tabTwo() {
    return SingleChildScrollView(
      child: Form(
        key: _registerFormKey,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 40, left: 30),
                child: Text("Llenemos este formulario juntos..🐾"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: PersonalTextField(
                controller: registerEmailController,
                prefixIcon: Icons.email,
                labelText: "Email",
                hintText: "tucorreo@gmail.com",
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: PersonalTextField(
                controller: registerPasswordController,
                labelText: "Contraseña",
                hintText: "",
                prefixIcon: Icons.lock,
                obscureText: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: PersonalTextField(
                controller: registerConfirmPasswordController,
                labelText: "Confirmar contraseña",
                hintText: "",
                prefixIcon: Icons.lock,
                obscureText: true,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: PersonalButton(
                text: "Crear cuenta",
                backgroundColor: AppColors.secondary,
                onPressed: () {
                  if (_registerFormKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrationPage(
                          email: registerEmailController.text,
                          password: registerPasswordController.text,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "O registrarse con ...",
              style: TextStyle(fontFamily: "Poppins"),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: PersonalOutlineButton(
                text: "Continue con Google",
                icon: FontAwesomeIcons.google,
                onPressed: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: PersonalOutlineButton(
                text: "Continue con Apple",
                icon: FontAwesomeIcons.apple,
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
