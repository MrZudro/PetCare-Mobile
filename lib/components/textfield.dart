import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';

class PersonalTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;

  const PersonalTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: AppColors.primary), // Color del texto del input
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 10,
        ),
        floatingLabelStyle: TextStyle(
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
        ), // Color del label cuando tiene focus
        labelStyle: TextStyle(
          color: AppColors.primary,
        ), // Color del label cuando NO tiene focus
        hintStyle: TextStyle(color: Colors.grey), // Color del hint text
        prefixIcon: Icon(prefixIcon, color: AppColors.primary),
        labelText: labelText,
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
