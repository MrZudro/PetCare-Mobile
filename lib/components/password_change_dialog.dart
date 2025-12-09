import 'package:flutter/material.dart';
import 'package:petcare/components/button.dart';
import 'package:petcare/components/textfield.dart';
import 'package:petcare/core/color_theme.dart';

class PasswordChangeDialog extends StatefulWidget {
  final Function(String currentPassword, String newPassword) onConfirm;

  const PasswordChangeDialog({super.key, required this.onConfirm});

  @override
  State<PasswordChangeDialog> createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends State<PasswordChangeDialog> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')),
        );
        return;
      }

      widget.onConfirm(
        _currentPasswordController.text,
        _newPasswordController.text,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lock_outline, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Cambiar Contraseña',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              PersonalTextField(
                controller: _currentPasswordController,
                labelText: 'Contraseña Actual',
                hintText: 'Ingrese su contraseña actual',
                prefixIcon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 16),

              PersonalTextField(
                controller: _newPasswordController,
                labelText: 'Nueva Contraseña',
                hintText: 'Ingrese nueva contraseña',
                prefixIcon: Icons.lock_open,
                obscureText: true,
              ),
              const SizedBox(height: 16),

              PersonalTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirmar Contraseña',
                hintText: 'Confirme nueva contraseña',
                prefixIcon: Icons.lock_open,
                obscureText: true,
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PersonalTextButton(
                    text: 'Cancelar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Cambiar',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
