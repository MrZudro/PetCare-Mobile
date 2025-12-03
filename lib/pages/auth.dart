import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  String email = '';
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
                    fontWeight: FontWeight.bold,
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
              TabBarView(children: [
                tabOne(),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget tabOne() {
    return Form(
      child: Column(
        children: [
          Container(child: Text("Llenemos este formulario juntos..🐾")),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Email",
              hintText: "tucorreo@gmail.com",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains("@")) {
                return "Introduce un correo valido.";
              }
              return null;
            },
            onSaved: (value) {
              email = value!;
            },
          ),
        ],
      ),
    );
  }
}
