import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/components/textfield.dart';
import 'package:petcare/components/button.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                print("Email: ${emailController.text}");
                print("Password: ${passwordController.text}");
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget tabTwo() {
    return Form(
      child: Column(children: [Text("Llenemos este formulario juntos..🐾")]),
    );
  }
}
