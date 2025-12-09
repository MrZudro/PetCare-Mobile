import 'package:flutter/material.dart';
import 'package:petcare/components/button.dart';
import 'package:petcare/components/textfield.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';
import 'package:petcare/models/user_model.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _namesController;
  late TextEditingController _lastNamesController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _namesController = TextEditingController(text: widget.user.names);
    _lastNamesController = TextEditingController(text: widget.user.lastNames);
    _emailController = TextEditingController(text: widget.user.email);
    _passwordController = TextEditingController(); // Empty for security
  }

  @override
  void dispose() {
    _namesController.dispose();
    _lastNamesController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // Implement API call to update user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cambios guardados exitosamente')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Ajustes de perfil', style: TextStyles.titleText),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              PersonalTextField(
                controller: _namesController,
                labelText: 'Nombres',
                hintText: 'Ingrese sus nombres',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              PersonalTextField(
                controller: _lastNamesController,
                labelText: 'Apellidos',
                hintText: 'Ingrese sus apellidos',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              PersonalTextField(
                controller: _emailController,
                labelText: 'Correo electrónico',
                hintText: 'Ingrese su correo',
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              PersonalTextField(
                controller: _passwordController,
                labelText: 'Contraseña',
                hintText: 'Ingrese nueva contraseña',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 40),
              PersonalButton(text: 'Guardar cambios', onPressed: _saveChanges),
            ],
          ),
        ),
      ),
    );
  }
}
