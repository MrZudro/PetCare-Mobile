import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';

class PersonalTextField extends StatefulWidget {
  final String? labelText;
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;

  const PersonalTextField({
    super.key,
    this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
  });

  @override
  State<PersonalTextField> createState() => _PersonalTextFieldState();
}

class _PersonalTextFieldState extends State<PersonalTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscured,
      style: TextStyle(color: AppColors.primary),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 10,
        ),
        floatingLabelStyle: TextStyle(
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
        ),
        labelStyle: TextStyle(color: AppColors.primary),
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.primary)
            : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.tertiary,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : null,
        labelText: widget.labelText,
        hintText: widget.hintText,
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
